
namespace Echo.Utils
{

	/**
 	* Report an error to the console for debugging purpose
  	*/
	public static void report_error (string origin, string message) {
		critical ("echo:: %s: %s", origin, message);
	}

	public static void report_debug (string origin, string message) {
		print ("echo:: %s: %s\n", origin, message);
	}

	// Use prefix = "SYM: " to get the old display
	public static void print_symbol (Symbol? symbol, int indent = 0, string prefix =  "SYM: " )
	{
		if( symbol == null ) {
			print ("<NULL>");
			return;
		}
		var s = "";
		for (var i = 0; i < indent; i++)
			s += "  ";

		print ("%s%s%s\n", prefix, s, symbol.to_string ());

		foreach (var child in symbol.children)
			print_symbol (child, indent + 1);
	}

	public static void print_symbols (Gee.List<Symbol> symbols, int indent = 0, string prefix =  "SYM: " )
	{
		foreach (var symbol in symbols)
			Utils.print_symbol (symbol, 2, prefix);
	}

	public static string to_string_single (Symbol? symbol, int indent = 0, string prefix =  "SYM: " )
	{
		if( symbol == null )
			return "<NULL>";
		var builder = new StringBuilder ();
		build_string (builder, symbol, indent, prefix);
		var result = builder.str;
		return result;
	}

	public static string to_string (Gee.List<Symbol> symbols, int indent = 0, string prefix =  "SYM: ", bool hide_line = false )
	{
		var builder = new StringBuilder ();
		foreach (var symbol in symbols)
			build_string (builder, symbol, indent, prefix, hide_line);
		var result = builder.str;
		return result;
	}

	public static void build_string (StringBuilder builder, Symbol? symbol, int indent = 0, string prefix =  "SYM: ", bool hide_line = false )
	{
		if( symbol == null ) {
			builder.append ("<NULL>");
			return;
		}
		var s = "";
		for (var i = 0; i < indent; i++)
			s += "  ";

		builder.append ("%s%s%s\n".printf (prefix, s, symbol.to_string (hide_line)));

		foreach (var child in symbol.children)
			build_string (builder, child, indent + 1, prefix, hide_line);
	}

	public static Gee.List<string>? get_package_paths (string pkg, Vala.CodeContext? context = null, string[]? vapi_dirs = null)
	{
		var ctx = context;
		if (ctx == null) {
			ctx = new Vala.CodeContext();
		}

		ctx.vapi_directories = vapi_dirs;
		var package_path = ctx.get_vapi_path (pkg);
		if (package_path == null) {
			return null;
		}

		var results = new Gee.ArrayList<string> ();

		var deps_filename = Path.build_filename (Path.get_dirname (package_path), "%s.deps".printf (pkg));
		if (FileUtils.test (deps_filename, FileTest.EXISTS)) {
			try {
				string deps_content;
				ulong deps_len;
				FileUtils.get_contents (deps_filename, out deps_content, out deps_len);
				foreach (string dep in deps_content.split ("\n")) {
					dep.strip ();
					if (dep != "") {
						var deps = get_package_paths (dep, ctx, vapi_dirs);
						if (deps == null) {
							warning ("%s, dependency of %s, not found in specified Vala API directories".printf (dep, pkg));
						} else {
							foreach (string dep_package in deps) {
								results.add (dep_package);
							}
						}
					}
				}
			} catch (FileError e) {
				warning ("Unable to read dependency file: %s".printf (e.message));
			}
		}

		results.add (package_path);
		return results;
	}

	/**
	 * Returns a list of parameters for the given symbol, or %null if the given
	 * symbol has no parameters.
	 *
	 * @param symbol The symbol for which to return a parameter list
	 * @return       A list of parameters or %null
	 */
	public Gee.List<DataType>? extract_parameters (Vala.Symbol symbol)
	{
		Gee.List<Vala.Parameter>? parameters = new Gee.ArrayList<DataType> ();

		if (symbol is Vala.Method) {
			foreach (var p in ((Vala.Method) symbol).get_parameters ())
				parameters.add (p);
		}
		else if (symbol is Vala.Signal)
			foreach (var p in ((Vala.Signal) symbol).get_parameters ())
				parameters.add (p);
		else
			return null;

		var list = new Gee.ArrayList<DataType> ();

		foreach (var param in parameters) {
			var data = new DataType ();
			var type = param.variable_type;
			data.name = param.name;

			if (type == null)
				continue;

			data.type_name = type.to_string ();

			// type.to_string messes the type names
			//   . string[] is shown as string[][]
			//   . List<Symbol> as List<Symbol><>
			data.base_type_name = process_type_name (data);
			list.add (data);
		}

		return list;
	}

	/**
	 * copied from afrodite
	 *
	 * Extracts properties of a type name and assigns those accordingly
	 *
	 * @param data The DataType to analyze and assign attribtes for
	 */
	private string process_type_name (DataType data)
	{
		var sb = new StringBuilder ();
		var type_name = data.type_name;
		// skip_level == 0 --> add char, skip_level > 0
		// --> skip until closed par (,[,<,{ causes a skip until ),],>,}
		int skip_level = 0;

		for (int i = 0; i < type_name.length; i++) {
			unichar ch = type_name[i];

			if (skip_level > 0) {
				if (ch == ']' || ch == '>')
					skip_level--;

				continue;
			}

			if (ch == '*') {
				data.is_pointer = true;
			} else if (ch == '?') {
				data.is_nullable = true;
			} else if (ch == '!') {
				data.is_nullable = false; // very old vala syntax!!!
			} else if (ch == '[') {
				data.is_array = true;
				skip_level++;
			} else if (ch == '<') {
				data.is_generic = true;
				skip_level++;
			} else
				sb.append_unichar (ch);

		}
		return sb.str;
	}

	/**
	 * Gets the name for a given symbol. In case there is none, it tries to return
	 * an appropriate replacement.
	 *
	 * @param symbol The symbol for which to find a name
	 * @return       A name for the symbol
	 */
	public static string symbol_to_name (Vala.Symbol symbol)
	{
		if (symbol is Vala.Constructor)
			return "construct";
		// Replace .new for constructor by the class name
		if (symbol.name == ".new" && symbol.parent_symbol != null )
			return symbol.parent_symbol.name;
		return symbol.name;
	}

	/**
	 * Finds an appropriate string representation for the given ValaSymbol
	 *
	 * @param symbol The vala symbol
	 * @return       A string describing the symbol
	 */
	public static string symbol_to_string (Vala.Symbol symbol)
	{
		if (symbol is Vala.Constant) {
			return "const %s %s".printf (((Vala.Constant) symbol).type_reference.to_string (), symbol.name);
		} else if (symbol is Vala.Variable) {
			var v = (Vala.Variable) symbol;
			// may happen for parameters with ellipsis
			if (v.variable_type == null)
				return "";

			return "%s %s".printf(v.variable_type.to_string (), symbol.name);
		} else if (symbol is Vala.Property) {
			return "%s %s".printf(((Vala.Property) symbol).property_type.to_string (), symbol.name);
		} else if (symbol is Vala.Method) {
			var m = (Vala.Method) symbol;
			var p = "";
			foreach (var param in m.get_parameters ()) {
				if (p != "")
					p += ", ";

				p += symbol_to_string (param);
				if (param.ellipsis)
					p += "...";
			}

			return "%s %s(%s)".printf (m.return_type.to_string (), symbol.name, p);
		} else if (symbol is Vala.Constructor) {
			return "construct";
		} else if (symbol is Vala.Class) {
			var bases = "";
			foreach (var type in ((Vala.Class) symbol).get_base_types ()) {
				if (bases == "")
					bases += " : ";
				else
					bases += ", ";

				bases += type.to_string ();
			}

			return "class " + symbol.name + bases;
		} else if (symbol is Vala.Interface) {
			var bases = "";
			foreach (var type in ((Vala.Interface) symbol).get_prerequisites ()) {
				if (bases == "")
					bases += " : ";
				else
					bases += ", ";

				bases += type.to_string ();
			}

			return "interface " + symbol.name + bases;
		} else if (symbol is Vala.Struct) {
			return "struct " + symbol.name;
		} else if (symbol is Vala.Namespace) {
			return "namespace " + symbol.name;
		} else if (symbol is Vala.Signal) {
			var s = (Vala.Signal) symbol;
			var p = "";
			foreach (var param in s.get_parameters ()) {
				if (p != "")
					p += ", ";

				p += symbol_to_string (param);
				if (param.ellipsis)
					p += "...";
			}

			return "signal %s %s(%s)".printf (s.return_type.to_string (), symbol.name, p);
		} else if (symbol is Vala.Block) {
			return "Block at line %i".printf (symbol.source_reference.begin.line);
		}

		return "::::::: missing: %s <%s>".printf (symbol.name, symbol.type_name);
	}
}
