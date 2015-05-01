using Echo;

namespace Echo.Tests {
    public class ParameterTestCase: EchoTestCase {
   
    public ParameterTestCase () {
      base ("ParameterTestCase");
      // add test methods

//      add_file_test ("test_error_domain", "test_parameter.vala", test_error_domain);
     }

     public override void set_up () {
       // setup your test
     }

    public void test_error_domain () {
      assert_symbol_type (get_root_symbols ("./tests/files/main_error_domain.vala"), SymbolType.ERRORDOMAIN);
     }

     public override void tear_down () {
     }
  }
}