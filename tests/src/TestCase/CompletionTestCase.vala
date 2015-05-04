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
			add_file_test ("test_classes_completion", "completion_classes_test.vala", test_classes_completion);

			add_file_test ("test_file_interface_static_constructor", "completion_classes_test.vala", test_file_interface_static_constructor);
			add_file_test ("test_file_interface_methods", "completion_classes_test.vala", test_file_interface_methods);
			add_file_test ("test_file_enum", "completion_classes_test.vala", test_file_enum);
			add_file_test ("test_class_members", "completion_classes_test.vala", test_class_members);


			add_file_test ("test_namespace_class_parameters", "completion_classes_test.vala", test_namespace_class_parameters);
			add_file_test ("test_namespace_class_parameters_more", "completion_classes_test.vala", test_namespace_class_parameters_more);
			add_file_test ("test_namespace_class_method", "completion_classes_test.vala", test_namespace_class_method);
			add_file_test ("test_namespace_class_new_more", "completion_classes_test.vala", test_namespace_class_new_more);

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

		public void test_classes_completion ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test2.vala", out project_file_path);

			var results = project.complete (project_file_path, 39, 15);
			assert_symbols_contains (results, new string [] {"name", "compute_name", "first_name",
				"compute_first_name"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});

		}

		public void test_file_interface_static_constructor ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 40, 25);
			assert_symbols_contains (results, new string [] {"new_for_uri", "new_for_commandline_arg",
				"new_for_path", "new_tmp"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});
		}

		public void test_file_interface_methods ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 41, 14);
			assert_symbols_contains (results, new string [] {"append_to", "append_to_async",
				"copy_attributes", "get_parent"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});
		}

		public void test_file_enum ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 42, 37);
			assert_symbols_contains (results, new string [] {"SUPPORTS_STARTUP_NOTIFICATION",
				"SUPPORTS_URIS", "NEEDS_TERMINAL", "NONE"});
			assert_symbols_doesnt_contain (results, new string [] {"List"});
		}

		public void test_class_members ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 29, 16);
			assert_symbols_contains (results, new string [] {"secret",
				"first_name", "almost_secret", "compute_name"});
			assert_symbols_doesnt_contain (results, new string [] {"List", "not_visible"});
		}

		public void test_namespace_class_parameters ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 51, 17);
			assert_symbols_contains (results, new string [] {"secret",
				"first_name", "almost_secret", "prefix"});
			assert_symbols_doesnt_contain (results, new string [] {"List", "not_visible"});
		}

		public void test_namespace_class_parameters_more ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 51, 19);
			assert_symbols_contains (results, new string [] {"prefix"});
			assert_symbols_doesnt_contain (results, new string [] {"List", "not_visible",
				"secret", "first_name", "almost_secret"});
		}

		public void test_namespace_class_method ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 57, 15);
			assert_symbols_contains (results, new string [] {"get_middle_name"});
			assert_symbols_doesnt_contain (results, new string [] {"List", "not_visible"});
		}

		public void test_namespace_class_new_more ()
		{
			string project_file_path;
			var project = setup_project_for_file ("test-type-completion",
					"./tests/files/completion_classes_test.vala", out project_file_path);

			var results = project.complete (project_file_path, 58, 35);
			assert_symbols_contains (results, new string [] {"OtherChild"});
			assert_symbols_doesnt_contain (results, new string [] {"List", "not_visible"});
		}

	}
}

