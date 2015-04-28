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
		var project = setup_project_for_file ("./files/position_test.vala");

		project.get_symbol_at_position ("./files/position_test.vala", 9, 10);
	}
}

