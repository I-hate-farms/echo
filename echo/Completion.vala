namespace Echo
{

	class Completor {

		static Regex override_stmt_regex;
		static Regex match_type_regex;
		static Regex member_access_regex;
		static Regex member_access_split_regex;

		// TODO revise the allowed chars in variable names
		const string VARIABLE = "[A-Za-z0-9_$@]";

		static construct
		{
			try {
				// TODO may match at irrelevant places, check that
				override_stmt_regex = new Regex ("override [^\\s]+ (" + VARIABLE + "*)");
				match_type_regex = new Regex ("(?:(?:is|as) (" + VARIABLE + "*))|(?:new (" + VARIABLE + "*))");

				// copied from anjuta
				member_access_regex = new Regex ("""((?:\w+(?:\s*\([^()]*\))?\.)*)(\w*)$""");
				member_access_split_regex = new Regex ("""(\s*\([^()]*\))?\.""");
			} catch (Error e) {
				warning (e.message);
			}
		}

		public Completor (Project project) {
		}

		string prepare_line (string line, int column)
		{
			var leading_tabs = 0;
			for (var i = 0; i < line.length; i++) {
				if (line[i] == ' ')
					continue;
				else if (line[i] == '\t')
					leading_tabs++;
				else
					break;
			}

			// vala counts tabs as 4 chars, so we have to subtract the 3 chars that
			// are on top when we cut
			var end = column - leading_tabs * 3;
			return (end >= line.length ? line : line.substring (0, end)).chug ();
		}

		/*
		 * Complete code. 
		 * <blah>
		 * Main cases
		 *   . after a '.': displays the methods for classes, values for enums, 
		 *     sub namespaces
		 *   . after a 'is': display types
		 *   . after a 'new': displays types
		 *   . after an 'override': displays overridable methods
		 *   . fallback: what does it do?
		 * Nice to have :   . 
		 *   . complete keywords
		 *   . after 'using' to find namespace
		 *   . delegates signatures?
		 *   . support for generics if not included 
		 */
		public Gee.List<string> complete (Vala.SourceFile src, Locator locator, int line, int column) {
			var line_str = prepare_line (src.get_source_line (line), column);

			MatchInfo match_info;
			SearchType search_type = SearchType.ACCESSIBLE_SYMBOLS;
			Vala.Expression? inner = null;
			string? searched = null;

			if (override_stmt_regex.match (line_str, 0, out match_info)) {
				search_type = SearchType.OVERRIDABLE;
				searched = match_info.fetch (1);
			} else if (match_type_regex.match (line_str, 0, out match_info)) {
				search_type = SearchType.TYPES;
				var new_str = match_info.fetch (1);
				var is_str = match_info.fetch (2);
				if (new_str != null && new_str != "")
					searched = new_str;
				else
					searched = is_str == "" ? null : is_str;
			} else if (member_access_regex.match (line_str, 0, out match_info)) {
				search_type = SearchType.MEMBER;
				inner = construct_member_access (member_access_split_regex.split (match_info.fetch (1)));
				searched = match_info.fetch (2);
			}

			var smart_case_is_lower = searched == null || searched == "" ||
				searched.down () == searched;

			// print ("%s `%s`\n", search_type.to_string (), searched);

			var block = locator.find_closest_block (src, line, column);
			var symbols = lookup_symbol (inner, searched, block as Vala.Block, search_type,
					smart_case_is_lower ? MatchType.PREFIX_INSENSITIVE : MatchType.PREFIX);

			var result = new Gee.ArrayList<string> ();

			foreach (var symbol in symbols) {
				if (symbol is Vala.LocalVariable
					&& symbol.source_reference.begin.line > line)
					continue;

				result.add(symbol.name);
			}

			return result;
		}

		// TODO make flags
		enum MatchType
		{
			NONE,
			PREFIX,
			PREFIX_INSENSITIVE,
			INSENSITIVE,
			EXACT
		}

		enum SearchType
		{
			MEMBER,
			TYPES,
			OVERRIDABLE,
			ACCESSIBLE_SYMBOLS
		}

		bool name_matches (string name, string? match, MatchType match_type)
		{
			switch (match_type) {
				case MatchType.NONE:
					return true;
				case MatchType.PREFIX:
					return match == null || match == "" || name.has_prefix (match);
				case MatchType.PREFIX_INSENSITIVE:
					return match == null || match == "" || name.down ().has_prefix (match.down ());
				case MatchType.INSENSITIVE:
					return match != null && match != "" && name.down () == match.down ();
				case MatchType.EXACT:
					return match != null && match != "" && name == match;
				default:
					assert_not_reached ();
			}
		}

		bool type_matches (Vala.Symbol symbol, SearchType type)
		{
			switch (type) {
				case SearchType.MEMBER:
				case SearchType.ACCESSIBLE_SYMBOLS:
					// TODO maybe limit acceptable result types
					return true;
				case SearchType.TYPES:
					return symbol is Vala.Enum ||
						symbol is Vala.Class ||
						symbol is Vala.Struct ||
						symbol is Vala.Interface ||
						symbol is Vala.Namespace;
				case SearchType.OVERRIDABLE:
					if (symbol is Vala.Method)
						return ((Vala.Method) symbol).is_virtual;
					if (symbol is Vala.Signal)
						return ((Vala.Signal) symbol).is_virtual;

					return false;
				default:
					assert_not_reached ();
			}
		}

		/**
		 * copied from anjuta
		 */
		Gee.LinkedList<Vala.Symbol> lookup_symbol (Vala.Expression? inner, string name, Vala.Block? block,
				SearchType search_type, MatchType match_type) {
			var matching_symbols = new Gee.LinkedList<Vala.Symbol> ();

			if (block == null)
				return matching_symbols;

			if (inner == null) {
				for (var sym = (Vala.Symbol) block; sym != null; sym = sym.parent_symbol) {
					matching_symbols.add_all (symbol_lookup_inherited (sym, name, search_type, match_type));
				}

				foreach (var ns in block.source_reference.file.current_using_directives) {
					matching_symbols.add_all (symbol_lookup_inherited (ns.namespace_symbol, name, search_type, match_type));
				}
			} else if (inner.symbol_reference != null) {
				matching_symbols.add_all (symbol_lookup_inherited (inner.symbol_reference, name, search_type, match_type));
			} else if (inner is Vala.MemberAccess) {
				var inner_ma = (Vala.MemberAccess) inner;
				var matching = lookup_symbol (inner_ma.inner, inner_ma.member_name, block, search_type, match_type);
				if (matching.size > 0)
					matching_symbols.add_all (symbol_lookup_inherited (matching[0], name, search_type, match_type));
			} else if (inner is Vala.MethodCall) {
				var inner_inv = (Vala.MethodCall) inner;
				var inner_ma = inner_inv.call as Vala.MemberAccess;
				if (inner_ma != null) {
					var matching = lookup_symbol (inner_ma.inner, inner_ma.member_name, block, search_type, match_type);
					if (matching.size > 0)
						matching_symbols.add_all (symbol_lookup_inherited (matching[0], name, search_type, match_type));
				}
			}
			return matching_symbols;
		}

		/**
		 * copied from anjuta
		 *
		 * Finds all members of the given symbol
		 *
		 * @param symbol The symbol to find members for
		 */
		Gee.LinkedList symbol_lookup_inherited (Vala.Symbol? symbol,
				string? searched, SearchType search_type, MatchType match_type)
		{
			// print ("SEARCHING FOR: `%s`\n", searched);
			var matching_symbols = new Gee.LinkedList<Vala.Symbol> ();

			if (symbol == null)
				return matching_symbols;

			var table = symbol.scope.get_symbol_table ();

			// print ("FROM: %s <%s>\n", symbol.name, symbol.type_name);
			if (table != null) {
				foreach (var key in table.get_keys ()) {
					var candidate = table[key];
					if (name_matches (candidate.name, searched, match_type) &&
							type_matches (candidate, search_type)) {
						// print ("\t%s\n", Utils.symbol_to_string (candidate));
						matching_symbols.add (candidate);
					}
				}
			}

			if (symbol is Vala.Method) {
				matching_symbols.add_all (symbol_lookup_inherited (((Vala.Method) symbol).return_type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Class) {
				foreach (var type in ((Vala.Class) symbol).get_base_types ())
					matching_symbols.add_all (symbol_lookup_inherited (type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Struct) {
				var base_type = ((Vala.Struct) symbol).base_type;
				if (base_type != null)
					matching_symbols.add_all (symbol_lookup_inherited (base_type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Interface) {
				foreach (var type in ((Vala.Interface) symbol).get_prerequisites ())
					matching_symbols.add_all (symbol_lookup_inherited (type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.LocalVariable) {
				matching_symbols.add_all (symbol_lookup_inherited (((Vala.LocalVariable) symbol).variable_type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Field) {
				matching_symbols.add_all (symbol_lookup_inherited (((Vala.Field) symbol).variable_type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Property) {
				matching_symbols.add_all (symbol_lookup_inherited (((Vala.Property) symbol).property_type.data_type, searched, search_type, match_type));
			} else if (symbol is Vala.Parameter) {
				matching_symbols.add_all (symbol_lookup_inherited (((Vala.Parameter) symbol).variable_type.data_type, searched, search_type, match_type));
			}

			return matching_symbols;
		}

		/**
		 * copied from anjuta
		 *
		 * Given a number of accessor parts, constructs a usable chain of member accesses
		 * for vala
		 *
		 * @param names The split accesor parts
		 *
		 * @return      A ValaExpression representing the given accesor chain
		 */
		Vala.Expression construct_member_access (string[] names) {
			Vala.Expression expr = null;

			for (var i = 0; names[i] != null; i++) {
				if (names[i] != "") {
					expr = new Vala.MemberAccess (expr, names[i]);
					if (names[i+1] != null && names[i+1].chug ().has_prefix ("(")) {
						expr = new Vala.MethodCall (expr);
						i++;
					}
				}
			}

			return expr;
		}

			/*switch (completionChar)
            {
                case '.': // foo.[complete]
                    lineText = Editor.GetLineText(line);
                    if (column > lineText.Length) { column = lineText.Length; }
                    lineText = lineText.Substring(0, column - 1);

                    string itemName = GetTrailingSymbol(lineText);

                    if (string.IsNullOrEmpty(itemName))
                        return null;

                    return GetMembersOfItem(itemName, line, column);
                case '\t':
                case ' ':
                    lineText = Editor.GetLineText(line);
                    if (0 == lineText.Length) { return null; }
                    if (column > lineText.Length) { column = lineText.Length; }
                    lineText = lineText.Substring(0, column - 1).Trim();

                    if (lineText.EndsWith("new"))
                    {
                        return CompleteConstructor(lineText, line, column);
                    }
                    else if (lineText.EndsWith("is"))
                    {
                        ValaCompletionDataList list = new ValaCompletionDataList();
                        ThreadPool.QueueUserWorkItem(delegate
                        {
                            Completion.GetTypesVisibleFrom(Document.FileName, line, column, list);
                        });
                        return list;
                    }
                    else if (0 < lineText.Length)
                    {
                        char lastNonWS = lineText[lineText.Length - 1];
                        if (0 <= Array.IndexOf(operators, lastNonWS) ||
                              (1 == lineText.Length && 0 > Array.IndexOf(allowedChars, lastNonWS)))
                        {
                            return GlobalComplete(completionContext);
                        }
                    }

                    break;
                default:
                    if (0 <= Array.IndexOf(operators, completionChar))
                    {
                        return GlobalComplete(completionContext);
                    }
                    break;
            }
			*/

			/*static string GetTrailingSymbol (string text)
		{
			// remove the trailing '.'
			if (text.EndsWith (".", StringComparison.Ordinal))
				text = text.Substring (0, text.Length - 1);

			int nameStart = text.LastIndexOfAny (allowedChars);
			return text.Substring (nameStart + 1).Trim ();
		}*/

		/// <summary>
		/// Perform constructor-specific completion
		/// </summary>
		/*private ValaCompletionDataList CompleteConstructor (string lineText, int line, int column)
		{
			//ProjectInformation parser = ProjectInfo;
			Match match = initializationRegex.Match (lineText);
			var list = new ValaCompletionDataList ();

			ThreadPool.QueueUserWorkItem (delegate {
				if (match.Success) {
					// variable initialization
					if (match.Groups ["typename"].Success || "var" != match.Groups ["typename"].Value) {
						// simultaneous declaration and initialization
						Completion.GetConstructorsForType (match.Groups ["typename"].Value, Document.FileName, line, column, list);
					} else if (match.Groups ["variable"].Success) {
						// initialization of previously declared variable
						Completion.GetConstructorsForExpression (match.Groups ["variable"].Value, Document.FileName, line, column, list);
					}
					if (0 == list.Count) {
						// Fallback to known types
						Completion.GetTypesVisibleFrom (Document.FileName, line, column, list);
					}
				}
			});

			return list;
		}*/

		/// <summary>
		/// Get the members of a symbol
		/// </summary>
		/*private ValaCompletionDataList GetMembersOfItem (string itemFullName, int line, int column)
		{
			//ProjectInformation info = ProjectInfo;
			if (null == ProjectInfo) {
				return null;
			}

			ValaCompletionDataList list = new ValaCompletionDataList ();
			ThreadPool.QueueUserWorkItem (delegate {
				ProjectInfo.Completion.Complete (itemFullName, Document.FileName, line, column, list);
			});
			return list;
		}
*/

	}

  /**
   * Returns the completion results and parsing errors
   **/

	public class CompletionReport {

	}
}
