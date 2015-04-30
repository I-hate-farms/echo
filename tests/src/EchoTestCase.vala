using Echo;

public abstract class EchoTestCase : Gee.TestCase {

	public EchoTestCase (string name) {
		base (name);
	}

	public Project setup_project_for_file (string project_name, string file_full_path,
		out string project_file_path)
	{
			var project = new Project (project_name);
			// Sample libs
			project.add_external_package ("glib-2.0");
			project.add_external_package ("gobject-2.0");
			project.add_external_package ("clutter-gtk-1.0");

			var file = File.new_for_path (file_full_path);
			project_file_path = file.get_path ();
			project.add_file (project_file_path);

			project.update_sync ();

			return project;
	}

	public Vala.List<Symbol> get_root_symbols (string file_full_path) {
			string project_file_path;
			var project = setup_project_for_file ("test-root", file_full_path, out project_file_path);

			return project.get_symbols_for_file (project_file_path);
	}

	public Vala.List<Symbol> get_all_symbols_for_file (string file_full_path) {
			string project_file_path;
			var project = setup_project_for_file ("test-all-symbols", file_full_path, out project_file_path);

			return project.get_all_symbols_for_file (project_file_path);
	}

}