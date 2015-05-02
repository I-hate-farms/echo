using Echo;

namespace Echo.Tests {
  public class CompletionTestCase : EchoTestCase
	{
		public CompletionTestCase ()
		{
			base ("CompletionTestCase");

			add_file_test ("test_member_completion", "completion_member_test.vala", test_member_completion);
			add_file_test ("test_override_completion", "completion_override_test.vala", test_override_completion);
			add_file_test ("test_type_completion", "completion_override_test.vala", test_type_completion);
		}

		public override void set_up ()
		{
		}

		public override void tear_down ()
		{
		}

		public void test_member_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-member-completion",
					"./tests/files/completion_member_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 5, 9);
			assert_symbols_contains (results, new string [] {"foreach", "nth_data"});

			results = project.complete (project_file_path, 8, 19);
			assert_symbols_contains (results, new string [] {"joinv", "split"});

		}

		public void test_override_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-override-completion",
					"./tests/files/completion_override_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 17, 25);
			assert_symbols_contains (results, new string [] {"button_release_event", "constructed"});

		}

		public void test_type_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_override_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 8, 23);
			assert_symbols_contains (results, new string [] {"MyTestClass", "MainLoop"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

			results = project.complete (project_file_path, 14, 18);
			assert_symbols_contains (results, new string [] {"Timeout", "TraverseType"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

		}
	}
}

