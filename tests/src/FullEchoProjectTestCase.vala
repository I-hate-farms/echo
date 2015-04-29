using Echo;

class FullEchoProjectTestCase : Gee.TestCase {
 
  public FullEchoProjectTestCase () {
    base ("FullEchoProjectTestCase");
    // add test methods

    add_file_test ("test_simple_main", "echo project", test_simple_main);
   }

   public override void set_up () {
     // setup your test
   }
 
   public void test_simple_main () {

    var project = new Project ("echo");
    // project.target_glib232 = true;
    // Sample libs
    project.add_external_package ("glib-2.0");
    project.add_external_package ("gobject-2.0");
    project.add_external_package ("libvala-0.28");
    project.add_external_package ("gio-2.0");
    project.add_external_package ("gee-0.8");

    var full_path = File.new_for_path ("./tests/files/echo");

    var files = new Gee.ArrayList<string>();

    var enumerator = full_path.enumerate_children (FileAttribute.STANDARD_NAME, 0);
    FileInfo file_info;
    while ((file_info = enumerator.next_file ()) != null) {
        var path = full_path.get_path () + "/" + file_info.get_name ();
        project.add_file (path);
        files.add (path);
    }
    

    project.update_sync ();
    foreach (var path in files) {
      print ("Code for %s\n", path );
      print ("----------\n");
      var result = project.get_symbols_for_file (path);
      Utils.print_symbols (result);
    }
    // assert_symbol_type (get_root_symbols ("./files/main.vala"), SymbolType.CLASS);
   }
 
  public void test_main_namespace () {
    assert_symbol_type (get_root_symbols ("./files/main_namespace.vala"), SymbolType.NAMESPACE);
   }

  public void test_main_function () {
    assert_symbol_type (get_root_symbols ("./files/main_function.vala"), SymbolType.METHOD);
   }

   public override void tear_down () {
   }
}
