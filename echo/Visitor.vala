namespace Echo
{
	public class Visitor : Vala.CodeVisitor
	{

		Vala.SourceFile current_file;
		public Gee.List<Symbol> current_symbol_list = new Gee.ArrayList<Symbol> ();
		Symbol current;

		public class Visitor (Symbol current, Vala.SourceFile current_file) {
			this.current = current;
			this.current_file = current_file;
		}

		void check_location (Vala.Symbol symbol, SymbolType symbol_type)
		{
			if (symbol.external || symbol.external_package)
				return;

			// if we are at a root namespace, we just visit it and check if it makes sense
			// to stay
			var is_root_namespace = symbol is Vala.Namespace && symbol.name == null;
			if (symbol.source_reference == null || is_root_namespace) {
				symbol.accept_children (this);
				return;
			}

			if (symbol.source_reference.file != current_file) {
				print ("VISITED %s\n", Utils.symbol_to_string (symbol));
				return;
			}

			var s = new Symbol ();
			s.symbol_type = symbol_type;
			s.access_type = (AccessType) symbol.access;
			s.source_file_name = symbol.source_reference.file.filename;
			s.source_line = symbol.source_reference.begin.line;
			s.source_last_line = symbol.source_reference.end.line;
			s.source_column = symbol.source_reference.begin.column;
			s.verbose_name = Utils.symbol_to_string (symbol);
			s.name = Utils.symbol_to_name (symbol);
			s.parent = current;
			s.parameters = Utils.extract_parameters (symbol);
			s.symbols = current.symbols;

			current_symbol_list.add (s);

			current.symbols.add (s);
			var prev = current;
			current = s;

			prev.children.add (s);
			symbol.accept_children (this);

			current = prev;
		}

		public override void visit_namespace (Vala.Namespace symbol)
		{
			check_location (symbol, SymbolType.NAMESPACE);
		}
		public override void visit_class (Vala.Class symbol)
		{
			check_location (symbol, SymbolType.CLASS);
		}
		public override void visit_block (Vala.Block symbol)
		{
			symbol.accept_children (this);
		}
		public override void visit_constructor (Vala.Constructor symbol)
		{
			check_location (symbol, SymbolType.CONSTRUCTOR);
		}
		public override void visit_creation_method (Vala.CreationMethod symbol)
		{
			check_location (symbol, SymbolType.CONSTRUCTOR);
		}
		public override void visit_destructor (Vala.Destructor symbol)
		{
			check_location (symbol, SymbolType.DESTRUCTOR);
		}
		public override void visit_enum (Vala.Enum symbol)
		{
			check_location (symbol, SymbolType.ENUM);
		}
		public override void visit_interface (Vala.Interface symbol)
		{
			check_location (symbol, SymbolType.INTERFACE);
		}
		public override void visit_method (Vala.Method symbol)
		{
			check_location (symbol, SymbolType.METHOD);
		}
		public override void visit_struct (Vala.Struct symbol)
		{
			check_location (symbol, SymbolType.STRUCT);
		}
		public override void visit_property (Vala.Property symbol)
		{
			check_location (symbol, SymbolType.PROPERTY);
		}
		public override void visit_field (Vala.Field symbol)
		{
			check_location (symbol, SymbolType.FIELD);
		}
		public override void visit_signal (Vala.Signal symbol)
		{
			check_location (symbol, SymbolType.SIGNAL);
		}
	}
}
