using Echo;

void main (string[] args)
{
	var project = new Project ();
	project.add_external_package ("glib-2.0");
	project.add_external_package ("gobject-2.0");
	project.add_external_package ("clutter-gtk-1.0");
	project.add_external_package ("granite");

	project.add_file ("./test.vala");
	project.add_file ("./tests/main.vala");

	project.update.begin ();
	try {
		project.complete ("./test.vala", 20, 10);
	} catch (Error e) {
		warning (e.message);
	}
  stdout.printf ( "FINDING SYMBOLS\n");
  // Needs a fullpath
  print_symbol_for_file (project, "./test.vala");
  print_symbol_for_file (project, "./tests/main.vala");
}

void print_symbol_for_file (Project project, string file_path) {
	var file_full_path = File.new_for_path (file_path).get_path ();
	stdout.printf ( "%s\n-------\n", file_path);
	var symbols = project.get_symbols_for_file (file_full_path);
	foreach (var symbol in symbols)
		Project.print_node (symbol, 0);
}
