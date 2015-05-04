using Echo;

namespace Echo.Tests {
	public class FullEchoProjectTestCase : EchoTestCase {

		Project project;
		Gee.ArrayList<string> files = new Gee.ArrayList<string>();

		public FullEchoProjectTestCase () {
			base ("FullEchoProjectTestCase");
			// add test methods

			//add_file_test ("test_simple_main", "echo project", test_simple_main);
			add_file_test ("test_merged_namespaces", "echo project", test_merged_namespaces);

			init ();
		}

		private void init () {

			project = new Project ("echo");
			// Sample libs
			project.add_external_package ("glib-2.0");
			project.add_external_package ("gobject-2.0");
			project.add_external_package ("libvala-0.28");
			project.add_external_package ("gio-2.0");
			project.add_external_package ("gee-0.8");
			project.target_glib232 = true;

			var full_path = File.new_for_path ("./tests/files/echo");



			var enumerator = full_path.enumerate_children (FileAttribute.STANDARD_NAME, 0);
			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				var path = full_path.get_path () + "/" + file_info.get_name ();
				project.add_file (path);
				files.add (path);
			}

			project.update_sync ();
		}

		public override void set_up () {
		   // setup your test
		}

		public void test_simple_main () {
			foreach (var path in files) {
				//print ("Code for %s\n", path );
				//print ("----------\n");
				var result = project.get_symbols_for_file (path);
				// Utils.print_symbols (result);
				assert_symbol_count_not (result, 0 );
			}
			assert_errors_count (project.parsing_errors, 3);
		  // assert_symbol_type (get_root_symbols ("./files/main.vala"), SymbolType.CLASS);
		 }

		public void test_merged_namespaces () {

			var results = project.get_symbols ();
			assert_symbol_count (results, 1 );
			assert_symbol_count (results.@get (0).children, 12 );

		  // assert_symbol_type (get_root_symbols ("./files/main.vala"), SymbolType.CLASS);
		 }

		public override void tear_down () {
		}
	}
}
