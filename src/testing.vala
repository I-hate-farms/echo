using Echo;

void main (string[] args)
{
	var loop = new MainLoop ();

	var project = new Project ();
	project.add_external_package ("glib-2.0");
	project.add_external_package ("gobject-2.0");
	project.add_external_package ("clutter-gtk-1.0");
	project.add_external_package ("granite");

	// project.add_file ("./test.vala");
	project.add_file ("./tests/files/main_namespace.vala");

	project.update.begin (() => {
		print ("UPDATE FINISHED\n");
		try {
			project.complete ("./tests/files/main_namespace.vala", 20, 10);
		} catch (Error e) {
			warning (e.message);
		}
		loop.quit ();
	});
	loop.run ();
}

