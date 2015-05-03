
namespace Echo
{
	public enum SymbolType
	{
		FILE = 1,
		NAMESPACE  = 1 << 1,
		CLASS = 1 << 2,
		CONSTRUCTOR = 1 << 3,
		DESTRUCTOR = 1 << 4,
		ENUM = 1 << 5,
		INTERFACE = 1 << 6,
		METHOD = 1 << 7,
		STRUCT = 1 << 8,
		PROPERTY = 1 << 9,
		FIELD = 1 << 10,
		SIGNAL  = 1 << 11,
		ERRORDOMAIN  = 1 << 12,
		CONSTANT  = 1 << 13,
		DELEGATE = 1 << 14,
		PARAMETER = 1 << 15,
		VARIABLE = 1 << 16;


		public static SymbolType from_vala (Vala.Symbol symbol) {
			// CARL TODO
			if( symbol is Vala.Class)
				return SymbolType.CLASS;
			if( symbol is Vala.Namespace)
				return SymbolType.NAMESPACE;
			if( symbol is Vala.Constructor)
				return SymbolType.CONSTRUCTOR;
			if( symbol is Vala.Destructor)
				return SymbolType.DESTRUCTOR;
			if( symbol is Vala.Enum)
				return SymbolType.ENUM;
			if( symbol is Vala.Interface)
				return SymbolType.INTERFACE;
			if( symbol is Vala.Method)
				return SymbolType.METHOD;
			if( symbol is Vala.Struct)
				return SymbolType.STRUCT;
			if( symbol is Vala.Property)
				return SymbolType.PROPERTY;
			if( symbol is Vala.Field)
				return SymbolType.FIELD;
			if( symbol is Vala.Signal)
				return SymbolType.SIGNAL;
			if( symbol is Vala.ErrorDomain)
				return SymbolType.ERRORDOMAIN;
			if( symbol is Vala.Constant)
				return SymbolType.CONSTANT;
			if( symbol is Vala.Delegate)
				return SymbolType.DELEGATE;
			if( symbol is Vala.Parameter)
				return SymbolType.PARAMETER;
			// CARL FIXME are those the same??
			if( symbol is Vala.TypeParameter)
				return SymbolType.PARAMETER;
			if( symbol is Vala.LocalVariable)
				return SymbolType.VARIABLE;

			var name = Type.from_instance(symbol).name ();
			Utils.report_error ("SymbolType.from_vala", "Symbol '%s' of unknown echo type '%s'".printf(symbol.name, name));
			return SymbolType.METHOD;
		}

		public string to_string () {
			switch(this) {
				case FILE:
					return "File";
				case NAMESPACE:
					return "Namespace";
				case CLASS:
					return "Class";
				case CONSTRUCTOR:
					return "Constructor";
				case DESTRUCTOR:
					return "Destructor";
				case INTERFACE:
					return "Interface";
				case ENUM:
					return "Enum";
				case METHOD:
					return "Method";
				case STRUCT:
					return "Struct";
				case PROPERTY:
					return "Property";
				case FIELD:
					return "Field";
				case SIGNAL:
					return "Signal";
				case CONSTANT:
					return "Constant";
				case ERRORDOMAIN:
					return "ErrorDomain";
				case DELEGATE:
					return "Delegate";
				case PARAMETER:
					return "Parameter";
				case VARIABLE:
					return "Variable";
				default:
					assert_not_reached ();
			}
		}

	}

  [Flags]
	public enum AccessType
	{
		PRIVATE = 1,
		INTERNAL = 1 << 1,
		PROTECTED = 1 << 2,
		PUBLIC = 1 << 3
//	useful?	ANY = SymbolAccessibility.PRIVATE | SymbolAccessibility.INTERNAL | SymbolAccessibility.PROTECTED | SymbolAccessibility.PUBLIC

	}

	public class SourceReference {
		public string file_full_path { get ; set ; }
		public int line { get ; set ; }
		public int column { get ; set ; }
		public int last_line { get ; set ; }

		public SourceReference (string file_full_path, int line, int column, int last_line) {
			this.file_full_path = file_full_path;
			this.line = line;
			this.column = column;
			this.last_line=last_line;
		}
	}

	public class DataType
	{
		/**
		 * Symbol this DataType belongs to
		 */
		public unowned Symbol? symbol  { get ; set ; }

		public string name  { get ; set ; }
		public string type_name  { get ; set ; }
		public string base_type_name  { get ; set ; }

		public bool is_array  { get ; set ; }
		public bool is_pointer  { get ; set ; }
		public bool is_generic  { get ; set ; }
		public bool is_nullable { get ; set ; }
		public bool is_out  { get ; set ; }
		public bool is_ref  { get ; set ; }

		// TODO
		public Gee.List<DataType>? generic_types { get ; set ; }

	}

	public class Symbol
	{
		public SymbolType symbol_type { get ; set ; }
		public AccessType access_type { get ; set ; }
		public string verbose_name { get ; set ; }
		public string name { get ; set ; default = "" ;}
		public string fully_qualified_name { get ; set ; default = "" ;}

		public Symbol? parent { get ; set ; }
		// HACK
		public string completion_parent_name { get ; set ; default = "" ;}
		public Gee.List<Symbol> children { get ; set ; default = new Gee.ArrayList<Symbol> () ; }
		public string source_file_name { get ; set ; default = "" ; }
		public int source_line { get ; set ; }
		public int source_column { get ; set ; }
		public int source_last_line { get ; set ; }
		public Gee.List<DataType>? parameters { get ; set ; }
		public string description { get ; set ; default = "" ;}
		public DataType? return_type { get ; set ; }

		// public Gee.List<Symbol>? symbols;
		public Symbol () {}

		public Symbol.from_vala (Vala.Symbol symbol) {
			// CARL TODO
			name = Utils.symbol_to_name (symbol);
			symbol_type = SymbolType.from_vala (symbol);
			parameters = Utils.extract_parameters (symbol);
			return_type = Utils.extract_return_type (symbol);
			access_type = (AccessType) symbol.access;
			var src = symbol.source_reference;
			if( src != null ) {
				source_file_name = src.file.filename;
				source_line = src.begin.line;
				source_column = src.begin.column;
			}
			if( symbol.parent_node != null)
			{
				var name = Type.from_instance(symbol.parent_node).name ();
				Utils.report_error ("Symbol.from_vala", "Symbol '%s' parent '%s'".printf(symbol.name, name));

				if ( symbol.parent_node is Vala.Symbol) {
					var parent_symbol = (Symbol) symbol.parent_node;
					completion_parent_name = parent_symbol.name;
				}
			}
			if( symbol.owner != null)
			{
				if ( symbol.owner.owner != null ) {
					var parent_symbol = symbol.owner.owner;
					completion_parent_name = parent_symbol.name;
				}
			}
			fully_qualified_name = Utils.extract_fully_qualified_name (symbol);
			if( symbol.comment != null )
				description = symbol.comment.content;
				if( description != "" && description != null)
					Utils.report_debug ("Symbol.from_vala", "DESC: '%s' has '%s'".printf (name, description));
			if( !(description != "" && description != null)) {
				description = DocParser.instance ().find_comment (fully_qualified_name);
			}

		}

		// FIXME
		/*public string fully_qualified_name {
			owned get {
				return parent == null || parent.parent == null ?
					name :
					"%s.%s".printf (parent.fully_qualified_name, name);
			}
		}*/

		private SourceReference _declaration = null;

		public SourceReference declaration {
			owned get {
				var file_name = source_file_name == null ? "unknown" : source_file_name;

				if( _declaration == null)
					_declaration = new SourceReference (file_name, source_line, source_column, source_last_line);
				return _declaration;
			}
		}

		public string to_string (bool hide_line=false) {
			if (hide_line)
				return "%s - %s".printf(fully_qualified_name, symbol_type.to_string ());
			else
				return "%s - %s - %d:%d".printf(fully_qualified_name, symbol_type.to_string (), source_line, source_column);
		}
	}
}