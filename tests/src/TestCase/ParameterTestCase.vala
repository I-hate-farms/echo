using Echo;

namespace Echo.Tests {
	public class ParameterTestCase: EchoTestCase {

		Project project ;
		string file_path ;

		public ParameterTestCase () {
			base ("ParameterTestCase");
			init () ;
			// add test methods

			add_file_test ("test_simple_arrays", "test_parameters.vala", test_simple_arrays);
			add_file_test ("test_double_arrays", "test_parameters.vala", test_double_arrays);
			add_file_test ("test_nullable_list", "test_parameters.vala", test_nullable_list);
			add_file_test ("test_simple_list", "test_parameters.vala", test_simple_list);
			add_file_test ("test_nullable_param", "test_parameters.vala", test_nullable_param);
			add_file_test ("test_simple_param", "test_parameters.vala", test_simple_param);
			add_file_test ("test_ref_param", "test_parameters.vala", test_ref_param);
			add_file_test ("test_out_param", "test_parameters.vala", test_out_param);
		}

		private void init ( ) {
			project = setup_project_for_file ("test-symbol-position",
			"./tests/files/test_parameters.vala", out file_path);
		}


		public override void set_up () {
		// setup your test
		}

		public void test_simple_arrays () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 3, 25) ;
			assert_parameter_type_equals (symbol, "string[]") ;
		}

		public void test_double_arrays () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 10, 36) ;
			assert_parameter_type_equals (symbol, "string[][]") ;
		}

		public void test_nullable_list () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 14, 39) ;
			assert_parameter_type_equals (symbol, "Gee.List<Gee.List>?") ;
		}

		public void test_simple_list () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 18, 38) ;
			assert_parameter_type_equals (symbol, "Gee.List<Gee.List>") ;
		}

		public void test_nullable_param () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 22, 38) ;
			assert_parameter_type_equals (symbol, "string?") ;
		}

		public void test_simple_param () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 26, 38) ;
			assert_parameter_type_equals (symbol, "int") ;
		}

		public void test_ref_param () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 30, 38) ;
			assert_parameter_type_equals (symbol, "int") ;
		}

		public void test_out_param () {
			var symbol = project.get_enclosing_symbol_at_position (file_path, 34, 38) ;
			assert_parameter_type_equals (symbol, "int") ;
		}

		public override void tear_down () {
		}
	}
}