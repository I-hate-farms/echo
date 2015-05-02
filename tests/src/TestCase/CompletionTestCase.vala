using Echo;

namespace Echo.Tests {
  public class CompletionTestCase : EchoTestCase
	{
		public CompletionTestCase ()
		{
			base ("CompletionTestCase");

			add_file_test ("test_member_completion", "completion_member_test.vala", test_member_completion);
			add_file_test ("test_override_completion", "completion_override_test.vala", test_override_completion);
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
			if (!("foreach" in results) || !("nth_data" in results)) {
				report_error (null, "Expecting at least `foreach` and `nth_data` to be proposals for GList type");
				return;
			}

			/*foreach (var sym in results) {
				print ("Proposed: %s\n", sym);
			}*/

			results = project.complete (project_file_path, 8, 19);
			if (!("joinv" in results) || !("split" in results)) {
				report_error (null, "Expecting at least `split` and `joinv` to be proposals for string type");
				return;
			}

			/*foreach (var sym in results) {
				print ("Proposed: %s\n", sym);
			}*/

			report_passed (null);
		}

		public void test_override_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-override-completion",
					"./tests/files/completion_override_test.vala", out project_file_path);

			foreach (var sym in project.complete (project_file_path, 4, 20)) {
				print ("Proposed: %s\n", sym);
			}
		}
	}
}

