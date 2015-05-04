
namespace Echo
{
	public errordomain CompleterError
	{
		NO_ACCESSOR,
		NAME_TOO_SHORT
	}

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

		Gee.HashMap<string,Vala.SourceFile> files =
			new Gee.HashMap<string,Vala.SourceFile> ();

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
			context.add_external_package (package);
		}

		public void add_file (string full_path, string? content = null)
		{
			var file = new Vala.SourceFile (context, Vala.SourceFileType.SOURCE,
					full_path, content);
			files[full_path] = file;
			clear_file (file);
			context.add_source_file (file);
		}

		public void update_sync ()
		{
			var monitor = new Monitor ();
			monitor.start ();
			((Reporter) context.report).clear_all_errors ();

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
			file.content = content;
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
		void clear_file (Vala.SourceFile file)
		{
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


		public Gee.List<Symbol> get_constructors_for_class (string file_full_path, string class_name, int line, int column) {
			var result = new Gee.ArrayList<Symbol>();
			// CARL TODO
			return result;
		}

		public Vala.Symbol get_symbol_at_position (string file_full_path, int line, int column)
		{
			var src = files[file_full_path];
			assert (src != null);

			var block = locator.find_closest_block (src, line, column);
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


		public Gee.List<Symbol> complete (string file_full_path, int line, int column)
			throws CompleterError
		{
			var source = files[file_full_path];
			if (source == null) {
				Utils.report_error ("complete", "Exiting: can't find source for '%s'".printf (file_full_path));
				return new Gee.LinkedList<string> ();
			}

			return completor.complete (source, locator, line, column);
		}
	}
}

