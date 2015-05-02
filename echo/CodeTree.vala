
namespace Echo
{
	public class CodeTree
	{
		Vala.CodeContext context;

		HashTable<string, Symbol> trees =
				new HashTable<string, Symbol> (str_hash, str_equal);
		HashTable<string, Gee.List<Symbol>> lists =
				new HashTable<string, Gee.List<Symbol>> (str_hash, str_equal);

		public CodeTree (Vala.CodeContext context)
		{
			this.context = context;
		}

		public void update_code_tree (Vala.SourceFile src)
		{
			//message ("update_code_tree (%s)", src.filename);
			var symbols = new Gee.ArrayList<Symbol> ();
			var root = new Symbol ();
			root.symbol_type = SymbolType.FILE;
			root.verbose_name = root.name = src.filename;
			// root.symbols = symbols;
			//symbols.add (root);

			//current_symbol_list = new Gee.ArrayList<Symbol> ();

			//current_file = src;
			//current = root;
			var visitor = new Visitor (root, src);
			var reporter = (Reporter) context.report;
			// reporter.clear_errors (src.filename);

			//context.accept (this);
			context.accept (visitor);
			// FIXME : sort the symbol tree also
			sort_symbols (root.children);
			sort_symbols (visitor.current_symbol_list, true);
			trees[src.filename] = root;
			lists[src.filename] = visitor.current_symbol_list;
		}

		private void sort_symbols (Gee.List<Symbol> symbols, bool flat = false) {
			symbols.sort((a,b) => {
			    return a.source_line - b.source_line;
			});
			if (!flat)
				foreach (var sym in symbols)
					sort_symbols (sym.children, flat);
		}

		public Symbol? get_code_tree (Vala.SourceFile src)
		{
			var tree = trees[src.filename];
			if (tree == null)
				update_code_tree (src);

			return trees[src.filename];
		}

		public Symbol? find_root_symbol (Vala.SourceFile src) {
			var result = get_code_tree (src);
			if (result == null)
				message ("find_root_symbol: NULL for '%s'", src.filename);

			return result;
		}

		public Gee.List<Symbol>? find_symbols (Vala.SourceFile src) {
			var list = lists[src.filename];
			if (list == null)
				update_code_tree (src);

			return lists[src.filename];
		}


	}
}

