
namespace Echo.Utils
{

	/**
 	* Report an error to the console for debugging purpose
  	*/
	public static void report_error (string origin, string message) {
		critical ("echo:: %s: %s", origin, message);
	}

	public static void report_debug (string origin, string message) {
		debug ("echo:: %s: %s", origin, message);
	}

	public static void print_node (Symbol symbol, int indent = 0)
	{
		var s = "";
		for (var i = 0; i < indent; i++)
			s += "  ";

		print ("SYM: %s%s - %s\n", s, symbol.fully_qualified_name, symbol.symbol_type.to_string ());

		foreach (var child in symbol.children)
			print_node (child, indent + 1);
	}
	
	/**
	 * Returns a list of parameters for the given symbol, or %null if the given
	 * symbol has no parameters.
	 *
	 * @param symbol The symbol for which to return a parameter list
	 * @return       A list of parameters or %null
	 */
	public Vala.List<DataType>? extract_parameters (Vala.Symbol symbol)
	{
		Vala.List<Vala.Parameter>? parameters = null;

		if (symbol is Vala.Method)
			parameters = ((Vala.Method) symbol).get_parameters ();
		else if (symbol is Vala.Signal)
			parameters = ((Vala.Signal) symbol).get_parameters ();
		else
			return null;

		var list = new Vala.ArrayList<DataType> ();

		foreach (var param in parameters) {
			var data = new DataType ();
			var type = param.variable_type;
			data.name = symbol.name;

			if (type == null)
				continue;

			data.type_name = type.to_string ();
			process_type_name (data);
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
	private void process_type_name (DataType data)
	{
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
			}
		}
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
		}

		return "::::::: missing: %s <%s>".printf (symbol.name, symbol.type_name);
	}
}
