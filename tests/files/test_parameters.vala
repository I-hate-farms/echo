

	public static int main (string[] args) {
		// stdout.printf (get_message ());
		stdout.printf ("Hello you!");
		return 0;
	}


	public static List<string>? main2 (string[][] args) {
		return null;
	}

	public static Gee.List<string> main3 (Gee.List<Gee.List>? args) {
		return new Gee.ArrayList<string>();
	}

	public static Gee.List<string> main4 (Gee.List<Gee.List> args) {
		return new Gee.ArrayList<string>();
	}

	public static Gee.List<string> main5 (string? args) {
		return new Gee.ArrayList<string>();
	}

	public static Gee.List<string> main6 (int args) {
		return new Gee.ArrayList<string>();
	}

	public static Gee.List<string> main7 (ref int args) {
		return new Gee.ArrayList<string>();
	}

	public static Gee.List<string> main8 (out int args) {
		args = 4;
		return new Gee.ArrayList<string>();
	}
