// Should return 
// - Hello 
//    - main 
using GLib;

public class HelloVala: GLib.Object {

	public static int main (string[] args) {
		// stdout.printf (get_message ());
		stdout.printf ("Hello you!");
		return 0;
	}
	
}
