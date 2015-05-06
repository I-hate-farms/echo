using Echo;

namespace Echo.Tests {
  public class CompletionDocumentationTestCase : EchoTestCase
	{
		public CompletionDocumentationTestCase ()
		{
			base ("CompletionDocumentationTestCase");

			// add_file_test ("test_glib_string", "completion_doc_test.vala", test_glib_string);
			// add_file_test ("test_glib_fileutils", "completion_doc_test.vala", test_glib_fileutils);
			add_file_test ("test_glib_action", "completion_doc_test.vala", test_glib_action);

		}
		public override void set_up ()
		{
		}

		public override void tear_down ()
		{
		}

		void print_symbol (Symbol symbol) {
			var description = symbol.description.substring (0, int.min (symbol.description.length, 30));
			//print ("%s  -> '%s'\n", symbol.to_string (), description);

		}
		public void test_glib_string ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-member-completion",
					"./tests/files/completion_doc_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 3, 11);
			assert_symbols_contains (results, new string [] {"ascii_casecmp", "join", "data", "@get"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

			foreach (var symbol in results) {
				print_symbol (symbol);
			}

		}

		public void test_glib_fileutils ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-member-completion",
					"./tests/files/completion_doc_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 4, 11);
			assert_symbols_contains (results, new string [] {"chmod", "close", "get_contents"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

			foreach (var symbol in results) {
				print_symbol (symbol);
			}

		}

		public void test_glib_action ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-member-completion",
					"./tests/files/completion_doc_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 6, 16, "\t\taction.");
			assert_symbols_contains (results, new string [] {"name_is_valid", "name", "state"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

			foreach (var symbol in results) {
				print_symbol (symbol);
			}

		}

	}
}
