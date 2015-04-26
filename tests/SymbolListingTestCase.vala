using Echo ; 

class SymbolListingTestCase : Gee.TestCase {
 
  public SymbolListingTestCase () {
    base ("SymbolListingTestCase");
    // add test methods

    add_file_test ("test_simple_main", "(main.vala)", test_simple_main);
    add_file_test ("test_main_namespace", "(main_namespace.vala)", test_main_namespace);
    add_file_test ("test_main_function", "(main_function.vala)", test_main_function);
   }

   public override void set_up () {
     // setup your test
   }
 
   public void test_simple_main () {
     assert_symbol_type (get_root_symbols ("./files/main.vala"), SymbolType.CLASS);
   }
 
  public void test_main_namespace () {
    assert_symbol_type (get_root_symbols ("./files/main_namespace.vala"), SymbolType.NAMESPACE);
   }

  public void test_main_function () {
    assert_symbol_type (get_root_symbols ("./files/main_function.vala"), SymbolType.FUNCTION);
   }

   public override void tear_down () {
   }
}