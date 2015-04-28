namespace Echo
{

	public class Completor {
		
		public Completor (Project project) {

		}

		/**
		 * Complete code. 
		    <blah>
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
		public CompletionReport complete (string file_full_path, int line, int column) {
			return new CompletionReport () ;
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