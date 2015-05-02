namespace Echo
{

	public enum ErrorType {
		NOTE = 1,
		DEPRECATED = 1 << 1,
		WARNING = 1 << 2,
		ERROR = 1 << 3 ;

		public string to_string () {
			switch(this) {
				case NOTE:
					return "note";
				case DEPRECATED:
					return "deprecated";
				case WARNING:
					return "warning";
				case ERROR:
					return "error";
				default:
					assert_not_reached ();
			}
		}
	}

	public class ParsingError: Object
	{
		public string message { get ; private set ; default = "" ; }

		// VALAC BUG: remove default value and everything blows
		public ErrorType error_type { get ; private set ; default = ErrorType.ERROR ; }

		public int line { get ; private set ; default = 0 ; }

		public int column { get ; private set ; default = 0 ; }

		public string file_full_path { get ; private set ; default = "" ;}

		//public ParsingError () {}

		public ParsingError (ErrorType? type, Vala.SourceReference? source, string message) {
			this.message = message;
			if( type != null )
				this.error_type = type;
			if (source != null )
			{
				this.line = source.begin.line;
				this.column = source.begin.column;
				this.file_full_path = source.file.filename;
			}
			// print ("ADDING : %s\n", to_string ()) ;

		}

		public string to_string () {
			return "%s:%d:%d: %s: %s".printf (file_full_path, line, column, error_type.to_string (), message);
		}

	}

	public class Reporter : Vala.Report
	{

		public Gee.ArrayList<ParsingError> error_list = new Gee.ArrayList<ParsingError> ();

		/**
		 * Remove all the errors for the file `file_full_path`
		 */

		public void clear_errors (string file_full_path) {
			for (int i= error_list.size -1; i >= 0 ; i--) {
				var error = error_list.@get (i);
				if (error.file_full_path == file_full_path)
					error_list.remove_at (i);

			}
		}

		public override void note (Vala.SourceReference? source, string message) {
				error_list.add (new ParsingError( ErrorType.NOTE, source, message));
		}

		public override void depr (Vala.SourceReference? source, string message) {
				error_list.add (new ParsingError( ErrorType.DEPRECATED, source, message));
		}

		public override void warn (Vala.SourceReference? source, string message) {
				error_list.add (new ParsingError( ErrorType.WARNING, source, message));
		}

		public override void err (Vala.SourceReference? source, string message) {
				error_list.add (new ParsingError( ErrorType.ERROR, source, message));
		}

	}
}