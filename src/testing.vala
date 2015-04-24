
void main (string[] args)
{
	var c = new Project ();
	c.add_external_package ("glib-2.0");
	c.add_external_package ("gobject-2.0");
	c.add_external_package ("clutter-gtk-1.0");
	c.add_external_package ("granite");
	
	c.add_file ("./test.vala");
	c.update.begin ();
	try {
		c.complete ("./test.vala", 20, 10);
	} catch (Error e) {
		warning (e.message);
	}
}

