
namespace Echo
{
	public class Project : Object
	{

		const int UPDATE_IDLE_DELAY = 2000;

		Vala.CodeContext context;
		Vala.Parser parser;
		Locator locator;
		Completor completor;
		CodeTree code_tree;
		Cancellable cancellable;
		Reporter reporter;
		string name;

		Gee.HashMap<string,SourceFile> files =
			new Gee.HashMap<string,SourceFile> ();

		uint scheduled_update_id;

		private int original_target_glib_major;
		private int original_target_glib_minor;

		construct
		{
			context = new Vala.CodeContext ();
			original_target_glib_major = context.target_glib_major;
			original_target_glib_minor = context.target_glib_minor;
			_target_glib232 = (original_target_glib_major==2) && (original_target_glib_minor==32);

			reporter = new Reporter ();
			context.profile = Vala.Profile.GOBJECT;
			context.report = reporter;

			parser = new Vala.Parser ();
			parser.parse (context);

			locator = new Locator ();
			code_tree = new CodeTree (context);

			cancellable = new Cancellable ();
			completor = new Completor (this);
		}

		public Project (string name)
		{
			this.name = name;
		}

		public Gee.List<ParsingError> parsing_errors {
			get {
				return reporter.error_list;
			}
		}

		private bool _target_glib232 = false;

		public bool target_glib232  {
			get {
				return _target_glib232;
			}
			set {
				_target_glib232 = value;
				if (value) {
					context.target_glib_major = 2;
					context.target_glib_minor = 32;
				}
				else
				{
					context.target_glib_major = original_target_glib_major;
					context.target_glib_minor = original_target_glib_minor;
				}
			}
		}

		public void add_external_package (string package) {
			Vala.CodeContext.push (context);
			context.add_external_package (package);
			Vala.CodeContext.pop ();
		}

		public void add_file (string full_path, string? content = null)
		{
			var file = new Vala.SourceFile (context, Vala.SourceFileType.SOURCE,
					full_path, content);
			var source = new SourceFile (file) ;
			files[full_path] = source;
			clear_file (source);
			context.add_source_file (source.source_file);
		}

		private SourceFile? find_source_file (string filename) {
			foreach (var source in files.values)
			{
				if (source.source_file.filename == filename)
					return source ;
			}
			return null ;
		}

		public void update_sync ()
		{
			var monitor = new Monitor ();
			monitor.start ();
			((Reporter) context.report).clear_all_errors ();

			lock (context) {
				Vala.CodeContext.push (context);

				foreach (var src in context.get_source_files ()) {
					var source = find_source_file (src.filename) ;
					if( source != null)
						source.status = ParsingStatus.PARSING ;
					if (cancellable.is_cancelled ())
						break;

					if (src.get_nodes ().size > 0)
						continue;

					parser.visit_source_file (src);

				}

				context.check ();

				Vala.CodeContext.pop ();
			}
			monitor.stop ();
			//Utils.report_debug ("update_sync", "Update done for %s in %s".printf (name, monitor.to_string ()) );
		}

		public async void update ()
		{
			if (scheduled_update_id != 0) {
				scheduled_update_id = 0;
				Source.remove (scheduled_update_id);
			}

			new Thread<void*> (null, () => {
				update_sync ();

				Idle.add (() => {
					update.callback ();
					return false;
				});
				return null;
			});

			yield;
		}

		public void update_file_contents (string full_filepath, string content, bool schedule_update = true)
		{
			var file = files[full_filepath];

			if (file == null) {
				Utils.report_error ( "update_file_contents", "Exiting: can't find source for '%s'".printf (full_filepath));
				return;
			}
			file.status = ParsingStatus.PARSING ;
			file.source_file.content = content;
			clear_file (file);

			if (!schedule_update)
				return;

			if (scheduled_update_id != 0)
				Source.remove (scheduled_update_id);

			scheduled_update_id = Timeout.add (UPDATE_IDLE_DELAY, () => {
				scheduled_update_id = Idle.add (() => {
					scheduled_update_id = 0;

					update.begin ();
					return false;
				});
				return false;
			});
		}

		/**
		 * Remove all parsed nodes from a given source file
		 */
		void clear_file (SourceFile source)
		{
			source.status = ParsingStatus.PARSING ;
			var file = source.source_file ;
			// copied from anjuta
			var nodes = new Gee.ArrayList<Vala.CodeNode> ();
			foreach (var node in file.get_nodes()) {
				nodes.add(node);
			}

			foreach (var node in nodes) {
				file.remove_node (node);
				if (node is Vala.Symbol) {
					var sym = (Vala.Symbol) node;
					if (sym.owner != null)
						/* we need to remove it from the scope*/
						sym.owner.remove (sym.name);
					if (context.entry_point == sym)
						context.entry_point = null;
				}
			}

			file.current_using_directives = new Vala.ArrayList<Vala.UsingDirective>();
			var ns_ref = new Vala.UsingDirective (new Vala.UnresolvedSymbol (null, "GLib"));
			file.add_using_directive (ns_ref);
			context.root.add_using_directive (ns_ref);
			source.status = ParsingStatus.NOT_PARSED ;
		}

		/**
		 * Returns the enclosing symbol at the specific position of the file.
		 **/
		public Symbol get_enclosing_symbol_at_position (string file_full_path, int line, int column) {
			Symbol current = null;

			foreach (var symbol in get_all_symbols_for_file (file_full_path)) {
				if (symbol.source_line > line) break;
				current = symbol;
			}

			return current;
		}

		/**
		 * Returns all the symbols (even the nested ones) for the file of type `type`.
		 **/
		public Gee.List<Symbol> get_all_symbols_for_file (string file_full_path, SymbolType? type=null) {
			var source = files[file_full_path];

			if (source == null) {
				Utils.report_error ("get_all_symbols_for_file", "Exiting: can't find source for '%s'".printf (file_full_path));
				return new Gee.ArrayList<Symbol>();;
			}
			// CARL TODO
			return code_tree.find_symbols (source);
		}

		public Gee.List<Symbol> get_symbols_for_file (string file_full_path) {
			var source = files[file_full_path];
			var result = new Gee.ArrayList<Symbol>();

			if (source == null) {
				Utils.report_error ("get_symbols_for_file", "Exiting: can't find source for '%s'".printf (file_full_path));
				return result;
			}
			var symbol = code_tree.get_code_tree (source);
			if (symbol != null) {
				if (symbol.symbol_type != SymbolType.FILE)
					result.add (symbol);
				else {
					// We skip the first level that is FILE
					foreach (var child in symbol.children)
						result.add (child);
				}
			}
			return result;

		}

		/**
		 * Returns a list of merged top level symbols (mainly namespace).
		 * This method can be used in a class explorer to give a global
		 * hierarchical view of the project.
		 *
		 * IMPORTANT: please not that only the top level namespaces of each file will be
		 * merged!
		 * This is good enough for a first implementation
		 */

		public Gee.List<Symbol> get_symbols () {
			var result = new Gee.ArrayList<Symbol>();
			foreach( var file_full_path in files.keys) {
				var source = files[file_full_path];

				if (source == null) {
					Utils.report_error ("get_symbols_for_file", "Exiting: can't find source for '%s'".printf (file_full_path));
					return result;
				}
				var symbol = code_tree.get_code_tree (source);

				if (symbol.symbol_type == SymbolType.FILE)
				{
					foreach ( var child in symbol.children)
						merge_symbols (result, child);
				}
				else
					merge_symbols (result, symbol);

			}
			return result;
		}

		private void merge_symbols (Gee.ArrayList<Symbol> symbols, Symbol symbol) {
			var s = Utils.find_symbol (symbols, symbol.name);
			if( s == null )
			{
				var to_be_inserted = symbol;
				if (symbol.symbol_type == SymbolType.NAMESPACE)
				{
					// We copy the namespace we add because we might add
					// merged children to them and we don't want to
					// change the per file symbol collections
					to_be_inserted = new Symbol.from_symbol (symbol);
				}
				symbols.add (to_be_inserted);
			}
			else
			{
				if( s.symbol_type == SymbolType.NAMESPACE && symbol.symbol_type == SymbolType.NAMESPACE)
				{
					foreach (var child in symbol.children)
						s.children.add (child);
				}
				else
				{
					Utils.report_debug ("CodeTree.merge_symbols", "Try to merge %s '%s' into %s '%s".printf (
						symbol.symbol_type.to_string (), symbol.fully_qualified_name,
						s.symbol_type.to_string (), s.fully_qualified_name) );
				}
			}
		}

		public Gee.List<Symbol> get_constructors_for_class (string file_full_path, string class_name, int line, int column) {
			var result = new Gee.ArrayList<Symbol>();
			// CARL TODO
			return result;
		}

		public Vala.Symbol get_symbol_at_position (string file_full_path, int line, int column)
		{
			var src = files[file_full_path];
			assert (src != null);

			var block = locator.find_closest_block (src.source_file, line, column);
			print ("%s\n", Utils.symbol_to_string (block));

			var table = block.scope.get_symbol_table ();
			print ("FROM: %s <%s>\n", block.name, block.type_name);
			if (table != null) {
				foreach (var key in table.get_keys ()) {
					print ("\t%s\n", Utils.symbol_to_string (table[key]));
				}
			}
			return block;
		}


		public Gee.List<Symbol> complete (string file_full_path, int line, int column, string? line_text=null)
		{
			var source = files[file_full_path];
			if (source == null) {
				Utils.report_error ("complete", "Exiting: can't find source for '%s'".printf (file_full_path));
				return new Gee.ArrayList<string> ();
			}

			return completor.complete (source.source_file, locator, line, column, line_text);
		}
	}
}

