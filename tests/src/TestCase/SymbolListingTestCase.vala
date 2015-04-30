using Echo;

namespace Echo.Tests {
  public class SymbolListingTestCase : EchoTestCase {
 
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
       var expected = """
            SYM:     HelloVala - Class - 6:1
            SYM:       HelloVala.main - Method - 8:2
            SYM:       HelloVala..new - Constructor - 6:1
        """;
        assert_symbols_equals (get_root_symbols ("./tests/files/main.vala"), expected);
     }
   
    public void test_main_namespace () {
       var expected = """
            SYM:     MyApp - Namespace - 6:1
            SYM:       MyApp.Abc - Namespace - 12:2
            SYM:         MyApp.Abc.some_func_other - Method - 14:3
            SYM:       MyApp.HelloVala - Class - 19:2
            SYM:         MyApp.HelloVala.main - Method - 21:3
            SYM:         MyApp.HelloVala..new - Constructor - 19:2
            SYM:       MyApp.some_func - Method - 8:2
        """;
      //assert_symbol_type (get_root_symbols ("./tests/files/main_namespace.vala"), SymbolType.NAMESPACE);
      assert_symbols_equals (get_root_symbols ("./tests/files/main_namespace.vala"), expected);
     }

    public void test_main_function () {
       var expected = """
             SYM:     main - Method - 2:2
         """;
      assert_symbols_equals (get_root_symbols ("./tests/files/main_function.vala"), expected);
     }

    public void test_error_domain () {
      assert_symbol_type (get_root_symbols ("./tests/files/main_error_domain.vala"), SymbolType.ERRORDOMAIN);
     }

    public void test_error_constant () {
      assert_symbol_type (get_root_symbols ("./tests/files/main_error_constant.vala"), SymbolType.CONSTANT);
     }

     public override void tear_down () {
     }
  }
}