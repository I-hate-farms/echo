using Echo ;

public static Vala.List<Symbol> get_root_symbols (string file_full_path) {
		var full_path = File.new_for_path (file_full_path).get_path ();
		var result = new Vala.ArrayList<Symbol>();
		// TODO 
		return result;
}