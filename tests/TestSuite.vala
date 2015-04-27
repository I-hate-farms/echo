public static int main(string[] args) {
  Test.init (ref args);

  // add any of your test cases here
  TestSuite.get_root().add_suite(new SymbolListingTestCase ().get_suite());
  TestSuite.get_root().add_suite(new EnclosingSymbolTestCase ().get_suite());

  var result =  Test.run ();

  print_report () ; 

  return result ; 
}