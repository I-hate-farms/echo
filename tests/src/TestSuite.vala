
using Echo.Tests;

// Always displays symbols to the console

const bool display_symbols = false;

public static int main(string[] args) {
  Test.init (ref args);
  Ivy.Stacktrace.register_handlers ();
  
  // add any of your test cases here
  add_tests (new SymbolListingTestCase ());
  add_tests (new EnclosingSymbolTestCase ());
  //add_tests (new SymbolPositionTestCase ());
  // Hey could you have a look at the next one?
  //add_tests (new FullEchoProjectTestCase ());
  //add_tests (new ExtraSymbolsTestCase ());
  
  var result = Test.run ();
  print_report ();
  return result;
}

public static void add_tests (Gee.TestCase test) {
  TestSuite.get_root().add_suite(test.get_suite());
}