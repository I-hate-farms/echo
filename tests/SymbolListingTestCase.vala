class SymbolListingTestCase : Gee.TestCase {
 
  public SymbolListingTestCase() {
    // assign a name for this class
    base("SymbolListingTestCase");
    // add test methods
    add_test("list_symbols_in_simple_main", list_symbols_in_simple_main);
   }
 
   public override void set_up () {
     // setup your test
   }
 
   public void list_symbols_in_simple_main() {
     // add your expressions
     assert(get_root_symbols ("./files/main.vala").size == 0);
   }
 
   public override void tear_down () {
     // tear down your test
   }
}