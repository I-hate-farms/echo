
namespace Echo
{
	public enum ParsingStatus {
		NOT_PARSED,
		PARSING,
		PARSED
	}

	public class SourceFile
	{
		public Vala.SourceFile source_file ;

		public ParsingStatus status = ParsingStatus.NOT_PARSED ;

		public SourceFile (Vala.SourceFile source_file) {
			this.source_file = source_file ;
		}
	}
}