using Noise ;

public class HelloVala: GLib.Object {

	public static int main (string[] args) {
		var libs = new LibrariesManager () ;
		stdout.printf ("Current operation : " + lib.current_operation);
		stdout.printf ("Hello you!");
		return 0;
	}

}