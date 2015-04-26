using Echo ;

const string COLOR_RED           = "\x1b[31m" ;
const string BOLD_COLOR_RED      = "\033[1m\033[31m"  ;
const string BOLD_COLOR_MAGENTA  = "\033[1m\033[35m" ;

const string ANSI_COLOR_GREEN = "\x1b[32m" ;
const string ANSI_COLOR_WHITE = "\033[1m\033[37m" ;
const string ANSI_COLOR_RESET = "\x1b[0m" ;
const string ANSI_COLOR_RED = BOLD_COLOR_RED ; 

public static Vala.List<Symbol> get_root_symbols (string file_full_path) {
		var project = new Project ();
		// Sample libs
		project.add_external_package ("glib-2.0");
		project.add_external_package ("gobject-2.0");
		project.add_external_package ("clutter-gtk-1.0");
		//foreach( var file_full_path in file_full_paths) {
		var full_path = File.new_for_path (file_full_path).get_path ();
		project.add_file (full_path);
		//}
		project.update_sync ();

		return project.get_symbols_for_file (full_path);
}

public static void printline_error (string message) {
	print ("%s%s%s\n", ANSI_COLOR_RED, message, ANSI_COLOR_RESET) ; 
}

public static void print_message (string message) {
	print (message) ; 
}

public static void printline_message (string message) {
	print (message + "\n") ; 
}

public static void assert_symbol_count (Vala.List<Symbol> symbols, int expected_count) {
	if ( symbols.size == expected_count) {
		print_message ("%sPASSED%s ".printf(ANSI_COLOR_GREEN, ANSI_COLOR_RESET)) ;
		assert (true) ;
		return ;
	}
	printline_error ("ERROR") ;
	printline_error ("Found '%d' symbols instead of '%d'".printf (symbols.size, expected_count)) ;
  printline_message ("%sSymbols found:%s".printf(ANSI_COLOR_WHITE, ANSI_COLOR_RESET)) ;
  foreach (var symbol in symbols)
		Project.print_node (symbol, 2);

	assert (false) ;
}