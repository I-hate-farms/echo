using Echo;

namespace Echo.Tests {
  public class EnclosingSymbolTestCase: EchoTestCase {

    Project project;
    string project_file_path;

    Project project_namespace;
    string file_path;
    
    public EnclosingSymbolTestCase () {
      base ("EnclosingSymbolTestCase");
      // add test methods

      add_file_test ("test_main", "(EnclosingSymbol.vala)", test_main);
      add_file_test ("test_namespaced_main", "(EnclosingSymbol.vala)", test_namespaced_main);
      add_file_test ("test_class_construct", "(EnclosingSymbol.vala)", test_class_construct);
      add_file_test ("test_class_field", "(EnclosingSymbol.vala)", test_class_field);

      add_file_test ("test_nested_namespace", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace);
      add_file_test ("test_nested_namespace_method", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace_method);
      add_file_test ("test_nested_namespace_other_method", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace_other_method);
      add_file_test ("test_nested_namespace_single_method", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace_single_method);
      // FIXME CARL add_file_test ("test_nested_namespace_annotation", "(EnclosingSymbolNestedNamespace.vala)", test_nested_namespace_annotation);
 
      init ();
     }

    private void init ( ) {

        // FIXME
        project = setup_project_for_file ("test-symbol-position",
          "./tests/files/EnclosingSymbol.vala", out project_file_path);

        project_namespace = setup_project_for_file ("test-symbol-position",
              "./tests/files/EnclosingSymbolNestedNamespace.vala", out file_path);
    }
    
    public override void set_up () {
    }
   
    public void test_main () {

      var expected = "";
      Symbol symbol;

       expected = """
          SYM: main2 - Method - 25:1
       """;
       symbol = project.get_enclosing_symbol_at_position (project_file_path, 25, 21);
       assert_symbol_equals (symbol, expected);
   }

    public void test_namespaced_main () {

      var expected = "";
      Symbol symbol;

       expected = """
          SYM: sandbox.main_in_sandbox - Method - ??       
       """;
       symbol = project.get_enclosing_symbol_at_position (project_file_path, 16, 28);
       assert_symbol_equals (symbol, expected);
       //Utils.print_symbols (project.get_symbols_for_file (project_file_path)) ;
   }

    public void test_class_construct () {

      var expected = "";
      Symbol symbol;
       expected = """
          SYM: PublicClass..new - Constructor - ??
       """;
       symbol = project.get_enclosing_symbol_at_position (project_file_path, 10, 18);
       assert_symbol_equals (symbol, expected);
     }
   
    public void test_class_field () {

      var expected = "";
      Symbol symbol;
       expected = """
          SYM: PublicClass.str - Field - ??
       """;
       symbol = project.get_enclosing_symbol_at_position (project_file_path, 3, 18);
       assert_symbol_equals (symbol, expected);
     }

    public void test_nested_namespace () {
        var expected = "";
        Symbol symbol;
        
        expected = """
              SYM: A.B.ValaCompletion.get_name - Method - ??
           """;
        symbol = project_namespace.get_enclosing_symbol_at_position (file_path, 7, 23);
        assert_symbol_equals (symbol, expected);
    }

    public void test_nested_namespace_method () {
        var expected = "";
        Symbol symbol;
        expected = """
              SYM: A.B.ValaCompletion.Provider.populate - Method - ??
           """;
        symbol = project_namespace.get_enclosing_symbol_at_position (file_path, 22, 25);
        assert_symbol_equals (symbol, expected);
    }

    public void test_nested_namespace_other_method () {
        var expected = "";
        Symbol symbol;
        expected = """
              SYM: A.B.ValaCompletion.Provider.activate_proposal - Method - ??
           """;
        symbol = project_namespace.get_enclosing_symbol_at_position (file_path, 31, 3);
        assert_symbol_equals (symbol, expected);
    }

    public void test_nested_namespace_single_method () {
        var expected = "";
        Symbol symbol;
        expected = """
              SYM: peas_register_types - Method - ??
           """;
        symbol = project_namespace.get_enclosing_symbol_at_position (file_path, 63, 20);
        assert_symbol_equals (symbol, expected);

    }
    public void test_nested_namespace_annotation () {
        var expected = "";
        Symbol symbol;
        expected = """
              SYM: ?? - ?? - ??
           """;
        symbol = project_namespace.get_enclosing_symbol_at_position (file_path, 62, 4);
        assert_symbol_equals (symbol, expected);
        
    }

     public override void tear_down () {
     }
  }
}
