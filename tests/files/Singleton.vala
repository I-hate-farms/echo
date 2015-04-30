namespace SampleLibrary {
	/** 
     * Purpose of the class
     **/ 
	public class MySingle: Object {
	    private static Once<MySingle> _instance;

	    public static unowned MySingle instance () {
	        return _instance.once (() => { return new MySingle (); });
	    }

		private MySingle () {
		}
		
	}
}