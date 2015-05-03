using Echo;

namespace Echo.Tests {
  public class CrashingEchoTestCase : EchoTestCase
	{
		public CrashingEchoTestCase ()
		{
			base ("CrashingEchoTestCase");

			add_file_test ("test_out_of_file_line", "completion_doc_test.vala", test_out_of_file_line);

		}
		public override void set_up ()
		{
		}

		public override void tear_down ()
		{
		}

		public void test_out_of_file_line ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-member-completion",
					"./tests/files/completion_doc_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 60, 11);
			assert_symbols_contains (results, new string [] {"ascii_casecmp", "join", "data", "@get"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

		}

	}
}
