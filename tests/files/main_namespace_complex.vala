// Should return 
// - Hello 
//    - main 
using GLib;

namespace MyApp {
	
	public class HelloVala: GLib.Object {

		public static int main (string[] args) {
			// stdout.printf (get_message ());
			stdout.printf ("Hello you!");
			return 0;
		}
		
	}

	public class LoneClass: GLib.Object {

		public static int main (string[] args) {
			// stdout.printf (get_message ());
			stdout.printf ("Hello you!");
			return 0;
		}
		

}
