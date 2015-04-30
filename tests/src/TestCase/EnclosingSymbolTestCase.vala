using Echo;

namespace Echo.Tests {
  public class EnclosingSymbolTestCase: EchoTestCase {
   
    public EnclosingSymbolTestCase () {
      base ("EnclosingSymbolTestCase");
      // add test methods

      add_file_test ("test_simple_method", "(EnclosingSymbol.vala)", test_simple_method);
      add_file_test ("test_nested_namespace", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace);

      //add_file_test ("test_main_namespace", "(main_namespace.vala)", test_main_namespace);
      //add_file_test ("test_main_function", "(main_function.vala)", test_main_function);
     }

     public override void set_up () {
       message ("EnclosingSymbolTestCase SETUP");
     }
   
     public void test_simple_method () {
       // FIXME
       assert_symbol_count (get_all_symbols_for_file ("./tests/files/EnclosingSymbol.vala"), 3);
     }
   
    public void test_nested_namespace () {
       // FIXME
       assert_symbol_count (get_all_symbols_for_file ("./tests/files/EnclosingSymbolNestedNamespace.vala" ), 3);
     }

     public override void tear_down () {
     }
  }
}
