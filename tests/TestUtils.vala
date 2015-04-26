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