using GLib;

namespace MyApp {
	
	public class MyClass: Object {

		public signal void on_event (string message);

		string string1 = "Hello";

		public string prop1 { get ; set ; }
		
		static construct { 
		}

		construct {

		}

		public MyClass () 
		{

		}	
		
		public string get_message ()
		{
			return "Hello";
		}	
	}
}
