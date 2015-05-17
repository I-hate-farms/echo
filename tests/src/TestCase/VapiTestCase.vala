using Echo;

namespace Echo.Tests {
	public class VapiTestCase: EchoTestCase {

		Project project;
		string file_path;

		public VapiTestCase () {
			base ("VapiTestCase");
			init ();
			// add test methods

			add_file_test ("test_custom_vapi", "noise", test_custom_vapi);
		}

		private void init ( ) {
			var project = new Project ("test-vapi");
			// Sample libs
			project.add_external_package ("glib-2.0");
			project.add_external_package ("gio-2.0");
			project.add_external_package ("gee-0.8");
			project.add_external_package ("gobject-2.0");
			project.add_external_package ("clutter-gtk-1.0");

			var file = File.new_for_path ("./tests/files/noise/noise-core.vapi");
			project.add_external_package (file.get_path ());

			file = File.new_for_path ("./tests/files/noise/ClassUsingNoise.vala");
			file_path = file.get_path ();
			project.add_external_package (file_path);
			project.update_sync ();

		}


		public override void set_up () {
		// setup your test
		}

		public void test_custom_vapi () {
			var symbols = project.get_symbols_for_file (file_path) ;
			assert_symbol_count_not (symbols, 0);
		}

		public override void tear_down () {
		}
	}
}
