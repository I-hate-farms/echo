using Echo;

namespace Echo.Tests {
  public class SymbolListingTestCase : EchoTestCase {
 
    public SymbolListingTestCase () {
      base ("SymbolListingTestCase");
      // add test methods

      add_file_test ("test_simple_main", "(main.vala)", test_simple_main);
      add_file_test ("test_main_namespace", "(main_namespace.vala)", test_main_namespace);
      add_file_test ("test_main_function", "(main_function.vala)", test_main_function);
      add_file_test ("test_complete_class", "(MyClass.vala)", test_complete_class);
      add_file_test ("test_singleton", "(Singleton.vala)", test_singleton);
      add_file_test ("test_sorted_output", "(EnclosingSymbol.vala)", test_sorted_output);
     }

     public override void set_up () {
       // setup your test
     }
   
     public void test_simple_main () {
       var expected = """
            SYM:     HelloVala - Class - 6:1
            SYM:       HelloVala.main - Method - 8:2
            SYM:       HelloVala.HelloVala - Constructor - 6:1
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
            SYM:         MyApp.HelloVala.HelloVala - Constructor - 19:2
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

    public void test_sorted_output () {
       var expected = """
          SYM:     PublicClass - Class - 1:1
          SYM:       PublicClass.str - Field - 3:2
          SYM:       PublicClass.PublicClass - Constructor - 10:2
          SYM:       PublicClass.construct - Constructor - 5:2
          SYM:     sandbox - Namespace - 15:1
          SYM:       sandbox.main_in_sandbox - Method - 16:3
          SYM:     main2 - Method - 25:1
      """;
      var symbols = get_root_symbols ("./tests/files/EnclosingSymbol.vala");
      //Utils.print_symbols (symbols);
      assert_symbols_equals (symbols, expected);
    }

    public void test_complete_class () {
       var expected = """
          SYM:     MyApp - Namespace - 3:1
          SYM:       MyApp.MyClass - Class - 5:2
          SYM:         MyApp.MyClass.string1 - Field - 9:3
          SYM:         MyApp.MyClass._prop1 - Field - 11:3
          SYM:         MyApp.MyClass.MyClass - Constructor - 20:3
          SYM:         MyApp.MyClass.get_message - Method - 25:3
          SYM:         MyApp.MyClass.prop1 - Property - 11:3
          SYM:         MyApp.MyClass.on_event - Signal - 7:3
          SYM:         MyApp.MyClass.construct - Constructor - 16:3
          SYM:         MyApp.MyClass.construct - Constructor - 13:3
      """;
      var symbols = get_root_symbols ("./tests/files/MyClass.vala");
      //Utils.print_symbols (symbols);
      assert_symbols_equals (symbols, expected);
    }

    public void test_singleton () {
       var expected = """
          SYM:     SampleLibrary - Namespace - 1:1
          SYM:       SampleLibrary.MySingle - Class - 5:2
          SYM:         SampleLibrary.MySingle._instance - Field - 6:6
          SYM:         SampleLibrary.MySingle.instance - Method - 8:6
          SYM:         SampleLibrary.MySingle.MySingle - Constructor - 12:3
      """;
      var symbols = get_root_symbols ("./tests/files/Singleton.vala");
      //Utils.print_symbols (symbols);
      assert_symbols_equals (symbols, expected);
     }

     public override void tear_down () {
     }
  }
}