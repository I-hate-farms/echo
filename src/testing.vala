using Echo ;

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
  stdout.printf ( "FINDING SYMBOLS\n");
	var symbols = c.get_symbols_for_file ("/home/cran/Documents/Projects/i-hate-farms/ide/echo/test.vala") ;
	foreach( var sym in symbols) {
		stdout.printf ( "%s\n", sym.to_string ());
		foreach( var child in sym.children) {
			stdout.printf ( "  - %s\n", child.to_string ());
			
		}

	}
}

