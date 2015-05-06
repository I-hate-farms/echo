using GLib;

public class Parent: Object
{
	public string name;

	protected string almost_secret;

	public string compute_name (string prefix){
		return prefix + " " + name;
	}
}


public class Child: Parent
{
	public string first_name;

	private string secret;
	public string get_name (string prefix){
		return first_name + " " + name;
	}

	public string compute_first_name (string prefix){
		return first_name + " " + first_name;
	}

	public string print_message () {
		print ();
	}
}

public class HelloVala: GLib.Object {
	public static int main (string[] args) {
		stdout.printf ("Hello world!\n");
		var s = "my string";
		var parent = new Parent ();
		var child = new Child ();
		// child.
		var file = File.new_for_uri ("/tmp");
		// file.
		// var e AppInfoCreateFlags.
		return 0;
	}
}


public class Namespace.OtherChild: Child {

	public void get_middle_name (string prefix) {
		print ( prefix + "Oscar");
	}
}

public static int main (string[] args) {
		var child = new Namespace.OtherChild ();
		// child.
		// var other = new Namespace.
		return 0;
}

