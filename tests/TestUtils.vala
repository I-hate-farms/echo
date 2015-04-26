using Echo ;

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

public static void print_error (string message) {
	print (message) ; 
}

public static void print_message (string message) {
	print (message) ; 
}

public static void assert_symbol_count (Vala.List<Symbol> symbols, int expected_count) {
	if ( symbols.size == expected_count) {
		assert (true) ;
		return ;
	}
	print_error ("ERROR\n") ;
	print_error ("Found '%d' symbols instead of '%d'\n".printf (symbols.size, expected_count)) ;
  print_message ("Symbols found:\n") ;
  foreach (var symbol in symbols)
		Project.print_node (symbol, 4);

	assert (false) ;
}