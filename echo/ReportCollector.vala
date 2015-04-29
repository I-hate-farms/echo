
namespace Echo
{
	enum MessageType
	{
		DEPRECATION,
		NOTE,
		WARNING,
		ERROR
	}

	struct Message
	{
		MessageType type;
		string message;

		string file;
		int line_start;
		int column_start;
		int line_end;
		int column_end;
	}

	class ReportCollector : Vala.Report
	{
		Gee.ArrayList<Message?> deprecation_list = new Gee.ArrayList<Message?> ();
		Gee.ArrayList<Message?> note_list = new Gee.ArrayList<Message?> ();
		Gee.ArrayList<Message?> warning_list = new Gee.ArrayList<Message?> ();
		Gee.ArrayList<Message?> error_list = new Gee.ArrayList<Message?> ();

		public override void depr (Vala.SourceReference? source, string message)
		{
			add_message (deprecation_list, MessageType.DEPRECATION, source, message);
		}

		public override void note (Vala.SourceReference? source, string message)
		{
			add_message (note_list, MessageType.NOTE, source, message);
		}

		public override void warn (Vala.SourceReference? source, string message)
		{
			add_message (warning_list, MessageType.WARNING, source, message);
		}

		public override void err (Vala.SourceReference? source, string message)
		{
			add_message (error_list, MessageType.ERROR, source, message); 
		}

		void add_message (Gee.List<Message?> messages, MessageType type,
				Vala.SourceReference? source, string msg)
		{
			print ("%s: %s\n", type.to_string (), msg);
			messages.add (Message () {
				type = type,
				message = msg,
				file = source.file.filename,
				line_start = source.begin.line,
				column_start = source.begin.column,
				line_end = source.end.line,
				column_end = source.end.column
			});
		}
	}
}

