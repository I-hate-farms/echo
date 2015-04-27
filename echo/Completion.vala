namespace Echo
{

	public class Completor {
		
		public Completor (Project project) {

		}

		public CompletionReport complete (string file_full_path, int line, int column) {
			return new CompletionReport () ;
		}
	}

	public class CompletionReport {

	}
}