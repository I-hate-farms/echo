
void main (string[] args)
{
	var c = new Project ();
	c.add_file ("./test.vala");
	c.update.begin ();
	try {
		c.complete ("./test.vala", 20, 10);
	} catch (Error e) {
		warning (e.message);
	}
}

