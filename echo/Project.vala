
namespace Echo
{
	public errordomain CompleterError
	{
		NO_ACCESSOR,
		NAME_TOO_SHORT
	}

	public class Project : Object
	{
		Vala.CodeContext context;
		Vala.Parser parser;
		Locator locator;
		Completor completor;
		CodeTree code_tree;
		Cancellable cancellable;

		static Regex member_access;
		static Regex member_access_split;

		static construct
		{
			// stolen from anjuta
			try {
				member_access = new Regex("""((?:\w+(?:\s*\([^()]*\))?\.)*)(\w*)$""");
				member_access_split = new Regex ("""(\s*\([^()]*\))?\.""");
			} catch (Error e) {
				warning (e.message);
			}
		}

		class Reporter : Vala.Report
		{
		}

		construct
		{
			context = new Vala.CodeContext ();
			context.profile = Vala.Profile.GOBJECT;
			context.report = new Reporter ();

			parser = new Vala.Parser ();
			parser.parse (context);

			locator = new Locator ();
			code_tree = new CodeTree (context);

			cancellable = new Cancellable ();
			completor = new Completor (this) ;
		}

		public void add_external_package (string package) {
			context.add_external_package (package);
		}

		public void add_file (string file)
		{
			context.add_source_filename (file);
		}

		public void update_sync ()
		{
			// TODO wrap in thread

			lock (context) {
				Vala.CodeContext.push (context);

				foreach (var src in context.get_source_files ()) {

					if (src.get_nodes ().size > 0)
						continue;

					parser.visit_source_file (src);
				}

				context.check ();

				Vala.CodeContext.pop ();
			}
		}

		public async void update ()
		{
			// TODO wrap in thread

			lock (context) {
				Vala.CodeContext.push (context);

				foreach (var src in context.get_source_files ()) {
					if (cancellable.is_cancelled ())
						break;

					if (src.get_nodes ().size > 0)
						continue;

					parser.visit_source_file (src);
				}

				context.check ();

				Vala.CodeContext.pop ();
			}
		}


		/** 
		 * Returns the enclosing symbol at the specific position of the file.
		 **/ 
		public Symbol get_enclosing_symbol_at_position (string file_full_path, int line, int column) {
			Symbol current = null ;
			
			foreach (var symbol in get_all_symbols_for_file (file_full_path)) { 
				if (symbol.source_line > line) break; 
				current = symbol; 
			}
			
			return current;
		}

		/** 
		 * Returns all the symbols (even the nested ones) for the file of type `type`.
		 **/ 
		public Vala.List<Symbol> get_all_symbols_for_file (string file_full_path, SymbolType? type=null) {
			var result = code_tree.find_symbols (file_full_path)  ;
			if( result == null)
				return new Vala.ArrayList<Symbol>();
			return result ; 
		}

		private Vala.SourceFile? find_source (string file_full_path) 
		{
			Vala.SourceFile source = null;
			foreach (var source_file in context.get_source_files ())
			{
				if( source_file.filename == file_full_path) {
					return source_file ; 
				}
			}
			return null ;
		}
		
		public Vala.List<Symbol> get_symbols_for_file (string file_full_path) {
					var result = new Vala.ArrayList<Symbol>();
				// FIXME PERF use a hashmap!
				/*Vala.SourceFile source = null;
				foreach (var source_file in context.get_source_files ())
				{
					if( source_file.filename == file_full_path) {
						source = source_file ; 
						break;
					}
				}*/

				/*var source = code_tree.find_root_symbol (file_full_path)  ;

			
				if( source == null ) {
				}
				else
				{*/
					//var symbol = code_tree.find_root_symbol (file_full_path)  ;
					var symbol = code_tree.get_code_tree (find_source (file_full_path)) ;
					if (symbol == null) 
					{
						Utils.report_debug ("Project.get_symbols_for_file", "Can't find Vala.SourceFile for file '%s'".printf(file_full_path));
					}
					else
					{

						if( symbol.symbol_type != SymbolType.FILE) 
							result.add (symbol);
					  else 
						  // We skip the first level that is FILE
							foreach (var child in symbol.children )
								result.add (child);
							}
				//}
				return result ; 
		} 

		public CompletionReport complete_input (string file_full_path, int line, int column) 
		{
			return completor.complete (file_full_path, line, column) ;
		}

		public Vala.List<Symbol> get_constructors_for_class (string file_full_path, string class_name, int line, int column) {
			var result = new Vala.ArrayList<Symbol>();
			// TODO 
			return result;
		}


		public void complete (string filename, int line, int column) throws CompleterError
		{
			var name = File.new_for_commandline_arg (filename).get_path ();

			foreach (var src in context.get_source_files ()) {
				if (src.filename == name) {
					var line_str = src.get_source_line (line).strip ();

					/*MatchInfo info;
					if (!member_access.match (line_str, 0, out info))
						throw new CompleterError.NO_ACCESOR ("Line is not an accesor");
					if (info.fetch (0).length < 2)
						throw new CompleterError.NAME_TOO_SHORT ("Accessor name not long enough");

					var names = member_access_split.split (info.fetch (1));
					foreach (var n in names)
						print ("n: %s\n", n);
					print ("f: %s\n", info.fetch (2));*/

					var root = code_tree.get_code_tree (src);
					Utils.print_node (root);

					return;
					print ("LINE: %s\n", line_str);

					var block = locator.find_closest_block (src, line, column);
					print ("CLOSEST: %s %s %s\n", block.name, block.to_string (), block.type_name);
					for (var sym = (Vala.Symbol) block; sym != null; sym = sym.parent_symbol)
						symbol_lookup_inherited (sym);

					break;
				}
			}
		}

		/**
		 * Finds all members of the given symbol
		 *
		 * @param symbol The symbol to find members for
		 */
		void symbol_lookup_inherited (Vala.Symbol? symbol)
		{
			if (symbol == null)
				return;

			var table = symbol.scope.get_symbol_table ();
			print ("FROM: %s <%s>\n", symbol.name, symbol.type_name);
			if (table != null) {
				foreach (var key in table.get_keys ()) {
					print ("\t%s\n", Utils.symbol_to_string (table[key]));
				}
			}

			if (symbol is Vala.Method) {
				symbol_lookup_inherited (((Vala.Method) symbol).return_type.data_type);
			} else if (symbol is Vala.Class) {
				foreach (var type in ((Vala.Class) symbol).get_base_types ())
					symbol_lookup_inherited (type.data_type);
			} else if (symbol is Vala.Struct) {
				symbol_lookup_inherited (((Vala.Struct) symbol).base_type.data_type);
			} else if (symbol is Vala.Interface) {
				foreach (var type in ((Vala.Interface) symbol).get_prerequisites ())
					symbol_lookup_inherited (type.data_type);
			} else if (symbol is Vala.LocalVariable) {
				symbol_lookup_inherited (((Vala.LocalVariable) symbol).variable_type.data_type);
			} else if (symbol is Vala.Field) {
				symbol_lookup_inherited (((Vala.Field) symbol).variable_type.data_type);
			} else if (symbol is Vala.Property) {
				symbol_lookup_inherited (((Vala.Property) symbol).property_type.data_type);
			} else if (symbol is Vala.Parameter) {
				symbol_lookup_inherited (((Vala.Parameter) symbol).variable_type.data_type);
			}
		}
	}
}

