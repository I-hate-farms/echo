using Echo;

class SymbolPositionTestCase : Gee.TestCase
{
	public SymbolPositionTestCase ()
	{
		base ("SymbolListingTestCase");

		add_file_test ("test_symbol_position", "(main.vala)", test_symbol_position);
	}

	public override void set_up ()
	{
	}

	public override void tear_down ()
	{
	}

	public void test_symbol_position ()
	{
		string project_file_path;
		var project = setup_project_for_file ("test-symbol-position",
				"./tests/files/position_test.vala", out project_file_path);

		project.get_symbol_at_position (project_file_path, 9, 10);
	}
}

