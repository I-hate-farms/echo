// Should return 
// - Hello 
//    - main 
using GLib;

namespace MyApp {

	public void some_func ()
	{
	}

	namespace Abc
	{
		public void some_func_other ()
		{
		}
	}
	
	public class HelloVala: GLib.Object {

		public static int main (string[] args) {
			// stdout.printf (get_message ());
			stdout.printf ("Hello you!");
			return 0;
		}
		
	}

}
