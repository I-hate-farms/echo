namespace Echo
{

		public enum ErrorType {
			NOTE = 0, 
			DEPRECATED,
			WARNING,
			ERROR
		}

		public class ParsingError: Object 
		{
			public string message { get ; private set ; } 

			public ErrorType error_type { get ; private set ; } 

			public int line { get ; private set ; }

			public int column { get ; private set ; }

			public string file_full_path { get ; private set ; } 

			public ParsingError (ErrorType type, Vala.SourceReference? source, string message) {
				this.message = message ;
				this.error_type = type ;
				this.line = source.begin.line ; 
				this.column = source.begin.column ; 
				this.file_full_path = source.file.filename ;
			}

			public string to_string () {
				return "%s:%d:%d: %s".printf (file_full_path, line, column, message) ;
			}
		
		}

		public class Reporter : Vala.Report
		{

			public Gee.ArrayList<ParsingError> error_list = new Gee.ArrayList<ParsingError> () ; 

			/**
			 * Remove all the errors for the file `file_full_path`
			 */

			public void clear_errors (string file_full_path) {
				int i = 0 ;
				foreach (var error in error_list) {
					if (error.file_full_path == file_full_path)
						error_list.remove_at (i) ;
					i++ ;
				}
			}

			public override void note (Vala.SourceReference? source, string message) {
					error_list.add (new ParsingError( ErrorType.NOTE, source, message)) ;
			}

			public override void depr (Vala.SourceReference? source, string message) {
					error_list.add (new ParsingError( ErrorType.DEPRECATED, source, message)) ;
			}
			
			public override void warn (Vala.SourceReference? source, string message) {
					error_list.add (new ParsingError( ErrorType.WARNING, source, message)) ;
			}
			
			public override void err (Vala.SourceReference? source, string message) {
					error_list.add (new ParsingError( ErrorType.ERROR, source, message)) ;
			}

		}
}