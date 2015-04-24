
namespace Echo
{
	public enum SymbolType
	{
		FILE,
		NAMESPACE,
		CLASS,
		CONSTRUCTOR,
		DESTRUCTOR,
		ENUM,
		INTERFACE,
		METHOD,
		STRUCT,
		PROPERTY,
		FIELD,
		SIGNAL
	}

	public enum AccessType
	{
		PRIVATE,
		INTERNAL,
		PROTECTED,
		PUBLIC
	}

	public class DataType
	{
		/**
		 * Symbol this DataType belongs to
		 */
		public unowned Symbol? symbol;

		public string name;
		public string type_name;

		public bool is_array;
		public bool is_pointer;
		public bool is_generic;
		public bool is_nullable;
		public bool is_out;
		public bool is_ref;
	}

	public class Symbol
	{
		public SymbolType symbol_type;
		public AccessType access_type;
		public string verbose_name;
		public string name;
		public Symbol? parent;
		public List<Symbol> children = new List<Symbol> ();
		public string source_file_name;
		public int source_line;

		public List<DataType>? parameters;

		public string fully_qualified_name {
			owned get {
				return parent == null || parent.parent == null ?
					name :
					"%s.%s".printf (parent.fully_qualified_name, name);
			}
		}
	}

	public class CodeTree : Vala.CodeVisitor
	{
		Symbol current;

		HashTable<string,Symbol> trees = new HashTable<string,Symbol> (str_hash, str_equal);

		public void update_code_tree (Vala.SourceFile src)
		{
			var root = new Symbol ();
			root.symbol_type = SymbolType.FILE;
			root.verbose_name = root.name = src.filename;

			current = root;
			src.accept_children (this);

			trees[src.filename] = root;
		}

		public Symbol? get_code_tree (Vala.SourceFile src)
		{
			var tree = trees[src.filename];
			if (tree == null)
				update_code_tree (src);

			return trees[src.filename];
		}

		void check_location (Vala.Symbol symbol, SymbolType symbol_type)
		{
			if (symbol.hides)
				return;

			var s = new Symbol ();
			s.symbol_type = symbol_type;
			s.access_type = (AccessType) symbol.access;
			s.source_file_name = symbol.source_reference.file.filename;
			s.source_line = symbol.source_reference.begin.line;
			s.verbose_name = Utils.symbol_to_string (symbol);
			s.name = Utils.symbol_to_name (symbol);
			s.parent = current;
			s.parameters = Utils.extract_parameters (symbol);

			var prev = current;
			current = s;

			prev.children.prepend (s);
			symbol.accept_children (this);
			s.children.reverse ();

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
