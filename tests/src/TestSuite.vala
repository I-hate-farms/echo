
using Echo.Tests;

// Always displays symbols to the console

const bool display_symbols = false;

public static int main(string[] args) {
  Test.init (ref args);
  Ivy.Stacktrace.register_handlers ();

  // working ones (update as you go by)
  // add_tests (new FullEchoProjectTestCase ());
  // add_tests (new SymbolListingTestCase ());
  // add_tests (new EnclosingSymbolTestCase ());
  // add_tests (new CompletionDocumentationTestCase ());

  // WIP
  // add_tests (new SymbolPositionTestCase ());
  // add_tests (new TargetGlibTestCase ());

  // failing test cases
  // add_tests (new ParameterTestCase());
  // add_tests (new CompletionTestCase ());
  // add_tests (new ExtraSymbolsTestCase ());
  // add_tests (new CrashingEchoTestCase ());

  var result = Test.run ();
  print_report ();
  return result;
}

public static void add_tests (Gee.TestCase test) {
  TestSuite.get_root().add_suite(test.get_suite());
}
