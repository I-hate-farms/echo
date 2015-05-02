using Echo;

namespace Echo.Tests {
	public class TargetGlibTestCase: EchoTestCase {

		public TargetGlibTestCase () {
			base ("TargetGlibTestCase");
			// add test methods

			add_file_test ("test_targeting_new_glib", "ThreadTargetGlib.vala", test_targeting_new_glib);
			add_file_test ("test_targeting_old_glib", "ThreadTargetOldGlib.vala", test_targeting_old_glib);
			add_file_test ("test_failing", "ThreadTargetGlib.vala", test_failing);
		}

		public override void set_up () {
		 // setup your test
		}

		public void test_targeting_new_glib () {
			assert_symbol_type (get_root_symbols ("./tests/files/ThreadTargetGlib.vala"), SymbolType.ERRORDOMAIN);
		}

		public void test_targeting_old_glib () {
			assert_symbol_type (get_root_symbols ("./tests/files/ThreadTargetOldGlib.vala"), SymbolType.CONSTANT);
		}

		public void test_failing () {
			assert_symbol_type (get_root_symbols ("./tests/files/ThreadTargetGlib.vala"), SymbolType.DELEGATE);
		}

		public override void tear_down () {
		}
	}
}