using Echo;

const string COLOR_RED           = "\x1b[31m";
const string BOLD_COLOR_RED      = "\033[1m\033[31m";
const string BOLD_COLOR_MAGENTA  = "\033[1m\033[35m";

const string ANSI_COLOR_YELLOW = "\x1B[33m";

const string ANSI_COLOR_GREEN = "\x1b[32m";
const string ANSI_COLOR_WHITE = "\033[1m\033[37m";
const string ANSI_COLOR_RESET = "\x1b[0m";
const string ANSI_COLOR_RED = BOLD_COLOR_RED;

static int error_count = 0;
static int passed_count = 0;
const bool display_symbols = false;

public static Project setup_project_for_file (string project_name, string file_full_path,
		out string project_file_path)
{
		var project = new Project (project_name);
		// Sample libs
		project.target_glib232 = true;
		project.add_external_package ("glib-2.0");
		project.add_external_package ("gobject-2.0");
		project.add_external_package ("clutter-gtk-1.0");

		var file = File.new_for_path (file_full_path);
		project_file_path = file.get_path ();
		project.add_file (project_file_path);

		project.update_sync ();

		return project;
}

public static Vala.List<Symbol> get_root_symbols (string file_full_path) {
		string project_file_path;
		var project = setup_project_for_file ("test-root", file_full_path, out project_file_path);

		return project.get_symbols_for_file (project_file_path);
}

public static Vala.List<Symbol> get_all_symbols_for_file (string file_full_path) {
		string project_file_path;
		var project = setup_project_for_file ("test-all-symbols", file_full_path, out project_file_path);

		return project.get_all_symbols_for_file (project_file_path);
}

public static void printline_error (string message) {
	print ("%s%s%s\n", ANSI_COLOR_RED, message, ANSI_COLOR_RESET);
}

public static void print_message (string message) {
	print (message);
}

public static void printline_message (string message) {
	print (message + "\n");
}

public static void report_error (Vala.List<Symbol> symbols,  string message) {
	error_count ++;
	
	printline_error ("ERROR");
	printline_error (message);
  printline_message ("%sSymbols found:%s".printf(ANSI_COLOR_WHITE, ANSI_COLOR_RESET));
	Utils.print_symbols (symbols, 2);
	// print ("\n");
}

public static void report_passed (Vala.List<Symbol> symbols, bool flat=false) {
	passed_count ++;

	print_message ("%sPASSED%s ".printf(ANSI_COLOR_GREEN, ANSI_COLOR_RESET));
	if( display_symbols ) { 
		print ("\n");
		if( flat )
		{
		  foreach (var symbol in symbols)
				print ("%s - %s", symbol.fully_qualified_name, symbol.symbol_type.to_string ());
		}
		else
		{
			Utils.print_symbols (symbols, 2);
		}
	// assert (true);
	}
	print ("\n");
}

const string[] betters = {
	"You can do #WHITE#better#RESET#, #NAME#.",
	"Your linker is bit #WHITE#miffed#RESET#, but your compiler believes in you (Harvey Dent).",
  "Let's take the tests #RED#a little bit#RESET# more #WHITE#seriously#RESET#.",
  "We got a problem. - And a #WHITE#knife#RESET#.",
  "I'm hungry, please fix this.",
  "There's always next time, #NAME#",
  "This is what you call coding, #WHITE#maggot#RESET#? I mean, #MAGENTA##NAME##RESET#!",  
  "I won't #MAGENTA#tweet#RESET# about it if you promise to #WHITE#fix it#RESET#", 
	"Let's try a more #WHITE#failure-less#RESET# approach",
	"Does your #WHITE#mama know#RESET#?",	
	"Somewhere a French guy is #WHITE#fixing hen#RESET#...",	
	"#YELLOW#Shine#RESET# on you buggy #WHITE#diamond#RESET#.",
	"A  beautiful surprise awaits on the other side.",
	"What we've got here is failure to #WHITE#communicate#RESET#.",
	"I guess there is still #WHITE#one or two things#RESET# to iron out.",
	"Test #YELLOW#united#RESET# we stand, #WHITE#almost#RESET#.",

};

const string[] victorys =  {
	"No error, you #MAGENTA#rock#RESET#!",
	"#MAGENTA#Flawless victory#RESET#",
	"#NAME# is leaving the building! I repeat #WHITE##NAME##RESET# is leaving the building!!", 
	"I can't believe my eyes, this is #WHITE#perfect#RESET#!",
	"*#WHITE#drops the mic*#RESET#",
	"Look #WHITE#ma#RESET#, easy!",
	"That's #WHITE#why#RESET# it's called a Tsu!",
	"The French #WHITE#ladies#RESET# are impressed!",
	"#WHITE#Ouh la la!!#RESET#",
	"#WHITE##success#RESET#",
};

public static string replace (string str)
{
	var result = str;
	result = result.replace ("#NAME#", Environment.get_user_name ());
	result = result.replace ("#REAL_NAME#", Environment.get_real_name ());
	result = result.replace ("#RESET#", ANSI_COLOR_RESET );
	result = result.replace ("#WHITE#", ANSI_COLOR_WHITE);
	result = result.replace ("#RED#", BOLD_COLOR_RED);
	result = result.replace ("#MAGENTA#", BOLD_COLOR_MAGENTA);
	result = result.replace ("#YELLOW#", ANSI_COLOR_YELLOW);
	return result;
}

public static string get_string (string [] strings) {
	var i = Math.lround ((strings.length-1) * Random.next_double ());
	var result = strings[i];
	result = replace (result);
	return result;
}


public static void print_all () {
	foreach( var str in betters) {
		var result = str;
		result = replace (result);
		print ("%s\n", result );
	}
	foreach( var str in victorys) {
		var result = str;
		result = replace (result);
		print ("%s\n", result );
	}
}

public static void print_better () {
	print ( "\n -> %s\n\n", get_string (betters) );
}

public static void print_victory () {
	print ( "\n -> %s\n\n", get_string (victorys) );
}


public static void print_report () { 
	print ("\nResults\n------\n");
	print ("  - Passed: %s%d%s\n", ANSI_COLOR_WHITE, passed_count, ANSI_COLOR_RESET);
	if( error_count > 0) 
	{
		print ("  - Failed: %s%d%s\n", BOLD_COLOR_RED, error_count, ANSI_COLOR_RESET);
		print_better ();
	} 
	else
	{
		print_victory ();
	}
}



public static void assert_symbol_type (Vala.List<Symbol> symbols, SymbolType type) {
	var expected_count = 1;
	if ( symbols.size == expected_count) {
		var actual_type = symbols.@get (0).symbol_type;
		if( actual_type == type) {
			report_passed (symbols);
			return;
		}
		else
		{
			report_error (symbols, "Found symbols or type '%s' instead of expected '%s'".printf (actual_type.to_string (), type.to_string ()));
		}
		return;
	}

	report_error (symbols, "Found '%d' symbols instead of expected '%d'".printf (symbols.size, expected_count));
	// We don't want the program to segfault
	// assert (false);
}

public static void assert_symbol_type_and_name ( Vala.List<Symbol> symbols, string symbol_full_name, SymbolType symbol_type ) 
{
	report_passed (symbols, true);
}

public static void assert_symbol_count (Vala.List<Symbol> symbols, int expected_count) {
	if ( symbols.size == expected_count) {
		report_passed (symbols);
		return;
	}

	report_error (symbols, "Found '%d' symbols instead of expected '%d'".printf (symbols.size, expected_count));
	// We don't want the program to segfault
	// assert (false);
}
