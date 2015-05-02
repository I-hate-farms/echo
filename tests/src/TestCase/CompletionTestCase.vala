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
			if (!("foreach" in results) || !("nth_data" in results)) {
				report_error (null, "Expecting at least `foreach` and `nth_data` to be proposals for GList type");
				return;
			}

			results = project.complete (project_file_path, 8, 19);
			if (!("joinv" in results) || !("split" in results)) {
				report_error (null, "Expecting at least `split` and `joinv` to be proposals for string type");
				return;
			}

			report_passed (null);
		}

		public void test_override_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-override-completion",
					"./tests/files/completion_override_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 17, 25);
			if (!("button_release_event" in results) || !("constructed" in results)) {
				report_error (null, "Expecting at least `button_release_event` and `constructed` to be proposals for GtkEventBox type");
				return;
			}

			report_passed (null);
		}

		public void test_type_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_override_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 8, 23);
			if (!("MyTestClass" in results) || !("MainLoop" in results) || ("List" in results)) {
				report_error (null, "Expecting at least `MyTestClass` and `MainLoop` and not `List` to be proposals for new objects in the test's context that start with M");
				return;
			}

			results = project.complete (project_file_path, 14, 18);
			if (!("Timeout" in results) || !("TraverseType" in results) || ("List" in results)) {
				report_error (null, "Expecting at least `Timeout` and `TraverseType` and not `List` to be proposals for new objects in the test's context that start with T");
				return;
			}

			report_passed (null);
		}
	}
}

