namespace Echo {
	/**
     * Purpose of the class
     **/
	public class DocParser: Object {
	    private static Once<DocParser> _instance;

	    //private Vala.GirParser parser = new Vala.GirParser () ;
	    public static unowned DocParser instance () {
	        return _instance.once (() => { return new DocParser (); });
	    }

		private DocParser () {
		}

		public void load_file (string gir_file_full_path) {
			//var source = new Vala.SourceFile (gir_file_full_path) ;
			//parser.parse_file (source) ;
		}

		public string get_description (string package, string symbol_full_name) {
			return "" ;
		}
	}
}