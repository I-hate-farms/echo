
namespace Echo
{
	public errordomain CompleterError
	{
		NO_ACCESOR,
		NAME_TOO_SHORT
	}

	public class Project : Object
	{
		Vala.CodeContext context;
		Vala.Parser parser;
		Locator locator;
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

		class Locator : Vala.CodeVisitor
		{
			Vala.Symbol? closest;
			int current_line;
			int current_column;

			public Vala.Symbol? find_closest_block (Vala.SourceFile src, int line, int column)
			{
				closest = null;
				current_line = line;
				current_column = column;

				// we now run through the doc and have check_location called repeatedly
				src.accept_children (this);

				return closest;
			}

			bool location_before (Vala.SourceLocation a, Vala.SourceLocation b)
			{
				return a.line < b.line || (a.line == b.line && a.column < b.column);
			}

			bool reference_inside (Vala.SourceReference r, int line, int column)
			{
				if (r.begin.line > line || r.end.line < line)
					return false;

				if (r.begin.line == line && r.begin.column < column)
					return false;

				if (r.end.line == line && r.end.column > column)
					return false;

				return true;
			}

			void check_location (Vala.Symbol symbol)
			{
				if (!reference_inside (symbol.source_reference, current_line, current_column))
					return;

				if (closest == null ||
					(location_before (closest.source_reference.begin,
									  symbol.source_reference.begin) &&
					 location_before (symbol.source_reference.end,
									  closest.source_reference.end))) {
					closest = symbol;
				}
			}

			public override void visit_namespace (Vala.Namespace symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_class (Vala.Class symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_block (Vala.Block symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_constructor (Vala.Constructor symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_creation_method (Vala.CreationMethod symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_destructor (Vala.Destructor symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_enum (Vala.Enum symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_interface (Vala.Interface symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_method (Vala.Method symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}
			public override void visit_struct (Vala.Struct symbol)
			{
				check_location (symbol);
				symbol.accept_children (this);
			}

			// those are just here to descend deeper into the structure
			public override void visit_property (Vala.Property prop) {
				prop.accept_children(this);
			}
			public override void visit_property_accessor (Vala.PropertyAccessor acc) {
				acc.accept_children(this);
			}
			public override void visit_if_statement (Vala.IfStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_switch_statement (Vala.SwitchStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_switch_section (Vala.SwitchSection section) {
				visit_block (section);
			}
			public override void visit_while_statement (Vala.WhileStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_do_statement (Vala.DoStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_for_statement (Vala.ForStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_try_statement (Vala.TryStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_catch_clause (Vala.CatchClause clause) {
				clause.accept_children(this);
			}
			public override void visit_lock_statement (Vala.LockStatement stmt) {
				stmt.accept_children(this);
			}
			public override void visit_lambda_expression (Vala.LambdaExpression expr) {
				expr.accept_children(this);
			}
		}

		construct
		{
			context = new Vala.CodeContext ();
			context.profile = Vala.Profile.GOBJECT;
			context.report = new Reporter ();

			parser = new Vala.Parser ();
			parser.parse (context);

			locator = new Locator ();
			code_tree = new CodeTree ();

			cancellable = new Cancellable ();
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

		public Gee.ArrayList<Symbol> get_symbols () {
				// TODO 
				return new Gee.ArrayList<Symbol>() ;
		} 

		public Gee.ArrayList<Symbol> get_symbols_for_file (string full_path) {
				// TODO 
				return new Gee.ArrayList<Symbol>() ;
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
					print_node (root);

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

		void print_node (Symbol symbol, int indent = 0)
		{
			var s = "";
			for (var i = 0; i < indent; i++)
				s += "  ";

			print ("SYM: %s%s\n", s, symbol.fully_qualified_name);

			foreach (var child in symbol.children)
				print_node (child, indent + 1);
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

