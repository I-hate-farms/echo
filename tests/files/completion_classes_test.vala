using GLib;

public class Parent: Object
{
	public string name;

	public string compute_name (string prefix){
		return prefix + " " + name;
	}
}


public class Child: Parent
{
	public string first_name;

	public string get_name (string prefix){
		return first_name + " " + name;
	}

	public string compute_first_name (string prefix){
		return first_name + " " + first_name;
	}
}

public class HelloVala: GLib.Object {
	public static int main (string[] args) {
		stdout.printf ("Hello world!\n");
		var s = "my string";
		var parent = new Parent ();
		var child = new Child ();
		child.
		return 0;
	}
}