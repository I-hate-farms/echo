class SymbolListingTestCase : Gee.TestCase {
 
  public SymbolListingTestCase() {
    // assign a name for this class
    base("SymbolListingTestCase");
    // add test methods
    add_file_test ("test_simple_main", "(main.vala)", test_simple_main);
    add_file_test ("test_main_namespace", "(main_namespace.vala)", test_main_namespace);
   }

   public override void set_up () {
     // setup your test
   }
 
   public void test_simple_main() {
     assert_symbol_count( get_root_symbols ("./files/main.vala"),  1);
   }
 
  public void test_main_namespace() {
    assert_symbol_count( get_root_symbols ("./files/main_namespace.vala"),  1);
   }

   public override void tear_down () {
     // tear down your test
   }
}