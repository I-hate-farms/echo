using Echo;

public static void assert_symbol_type (Gee.List<Symbol> symbols, SymbolType type) {
	var expected_count = 1;
	if ( symbols.size == expected_count) {
		var actual_type = symbols.@get (0).symbol_type;
		if( actual_type == type) {
			report_passed (symbols);
			return;
		}
		else
		{
			report_error (symbols, "Found symbols or type '%s' instead of expected '%s'".printf (actual_type.to_string (), type.to_string ()));
		}
		return;
	}

	report_error (symbols, "Found '%d' symbols instead of expected '%d'".printf (symbols.size, expected_count));
	// We don't want the program to segfault
	// assert (false);
}

public static void assert_symbol_type_and_name ( Gee.List<Symbol> symbols, string symbol_full_name, SymbolType symbol_type )
{
	report_passed (symbols, true);
}

public static void assert_symbol_count (Gee.List<Symbol> symbols, int expected_count) {
	if ( symbols.size == expected_count) {
		report_passed (symbols);
		return;
	}

	report_error (symbols, "Found '%d' symbols instead of expected '%d'".printf (symbols.size, expected_count));
	// We don't want the program to segfault
	// assert (false);
}

public static void assert_symbol_count_not (Gee.List<Symbol> symbols, int unexpected_count) {
	if ( symbols.size != unexpected_count) {
		report_passed (symbols);
		return;
	}

	report_error (symbols, "Found '%d' symbols while it was forbidden".printf (symbols.size));
	// We don't want the program to segfault
	// assert (false);
}

public static void assert_symbol_equals (Symbol? symbol, string expected, bool ignore_line = false) {
	var symbols = new Gee.ArrayList<Symbol> ();
	symbols.add (symbol);
	assert_symbols_equals (symbols, expected, ignore_line);
}

public static void assert_symbols_equals (Gee.List<Symbol> symbols, string expected, bool ignore_line = false) {
	var str = expected;
	var builder = new StringBuilder ();
	var strings = expected.split ("\n");
	int start_pos = -1;
	foreach (var line in strings) {
		// Strip the
		// message ("line : %s", line);
		//if( line.strip() == "" )
		//	continue;
		if( start_pos == -1) {
			var index = line.index_of ("SYM:");
			if( index >= 0 )
			{
				var new_line = line.substring (index +4);
				new_line = new_line.strip ();
				start_pos = line.index_of (new_line);
				// message ("START_POS: %d" , start_pos);
				line = new_line;
			}
		}
		else
		{
			if (line.length > start_pos)
				line = line.substring (start_pos);
		}
		if( ignore_line)
		{
			var index = line.last_index_of ("-");
			if( index >= 0 ) {
				line = line.substring (0, index-1);
			}
		}
		var stripped = line.strip ();
		if( stripped != "" /*&& stripped != "\n"*/) {
			builder.append (line);
			builder.append ("\n");
		}
	}
	str = builder.str;
	var actual = Utils.to_string (symbols, 0, "", ignore_line);
	if (actual == str )
	{
			report_passed (symbols);
	}
	else
	{
		FileUtils.set_contents ("/tmp/expected", str);
		FileUtils.set_contents ("/tmp/actual", actual);

		// string[] spawn_args = {"diff", "-u", "/tmp/expected", "/tmp/actual"};
		string[] spawn_args = {"diff", "--side-by-side", "/tmp/expected", "/tmp/actual"};
		string[] spawn_env = Environ.get ();
		string ls_stdout;
		string ls_stderr;
		int ls_status;

		Process.spawn_sync ("/",
						spawn_args,
						spawn_env,
						SpawnFlags.SEARCH_PATH,
						null,
						out ls_stdout,
						out ls_stderr,
						out ls_status);
		report_error (symbols, "The expected symbols differ from the actual", true);

		// display_unified_result (ls_stdout);
		display_side_by_side_result (ls_stdout);
	}
}

static void display_side_by_side_result (string diff)  {
	print ("   EXPECTED                                                   |   ACTUAL \n");
	print ("--------------------------------------------------------------+----------------------------------------------\n");

	foreach (var line in diff.split ("\n")) {
		if( "|" in line )
		{
				print ( ANSI_COLOR_RED + line + ANSI_COLOR_RESET + "\n");
		} else if( ">" in line || "<" in line)
		{
				print ( ANSI_COLOR_GREEN + line + ANSI_COLOR_RESET + "\n");
		} else
		{
			print (line + "\n");
		}

	}
}

static void display_unified_result (string diff)  {
	var i = 0;
	foreach (var line in diff.split ("\n")) {
		i++;
		if( i < 4)
			continue;
		if( line.has_prefix ("-"))
		{
				print ( ANSI_COLOR_RED + line + ANSI_COLOR_RESET + "\n");
		}
		else if( line.has_prefix ("+"))
		{
				print ( ANSI_COLOR_GREEN + line + ANSI_COLOR_RESET + "\n");
		} else
		{
			print (line + "\n");
		}
	}
}

public static void assert_parameter_type_equals (Symbol? symbol, string expected_parameter_type) {
	if ( symbol == null) {
		report_error (null, "Symbol is NULL.");
		return;
	}
	var symbols = new Gee.ArrayList<Symbol> ();
	symbols.add (symbol);
	if( symbol.parameters.size == 0 )
	{
		report_error (symbols, "Symbol has no parameter while at least one is expected.");
		return;
	}
	var parameter = symbol.parameters.@get (0);
	if( parameter.type_name == expected_parameter_type) {
		report_passed (symbols);
		return;
	}
	report_error (symbols, "Found parameter of type '%s' [base: '%s'] when '%s' was expected".printf (
		parameter.type_name, parameter.base_type_name, expected_parameter_type));


}

// TODO
public static void assert_errors_count (Gee.List<ParsingError> errors, int expected_count) {
	if( errors.size > 0 ) {
		print ("Parsing errors\n");
		print ("----------------------\n");
		foreach (var err in errors )
			print (err.to_string () );
	}
}

public static void assert_symbols_contains (Gee.List<Symbol> symbols, string[] names) {

	var missing_symbols = "";
	foreach( var name in names) {
		var symbol = Utils.find_symbol (symbols, name);
		if( symbol == null)
			missing_symbols += " '" + name + "'";
	}
	if( missing_symbols == "")
	{
		report_passed (symbols);
	}
	else
	{
		report_error (symbols, "The symbols doesn't contain the list of expected symbols %s".printf (missing_symbols));
	}
}

public static void assert_symbols_doesnt_contain (Gee.List<Symbol> symbols, string[] names) {
	var missing_symbols = "";
	foreach( var name in names) {
		var symbol = Utils.find_symbol (symbols, name);
		if( symbol != null)
			missing_symbols += " '" + name + "'";
	}
	if( missing_symbols == "")
	{
		report_passed (symbols);
	}
	else
	{
		report_error (symbols, "The symbols contain the list of unexpected symbols %s".printf (missing_symbols));
	}
}
