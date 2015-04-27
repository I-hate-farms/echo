using GLib;

namespace MyApp {
	
	public class HelloVala: Object {

		string string1 = "Hello" ; 

		public string prop1 { get ; set ; }
		
		static construct { 
		}

		construct {

		}

		public HelloVala () 
		{

		}	
		
		public string get_message ()
		{
			return "Hello" ;
		}	
	}
