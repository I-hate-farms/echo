public class PublicClass : Object {
	
	public string str;

	construct {
		str = "Construct";

	}	

	public PublicClass () {
		str = "This auto tab thing is dumb";
	}
}

namespace sandbox {
		public static int main_in_sandbox (string[] args) {
		stdout.printf ("Hello world!\n");
		
		return 0;
	}
}

const string BIG = "BIG";

public static int main2 (string[] args) {
	stdout.printf ("Hello world!\n");

	return 0;
}