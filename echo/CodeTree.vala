
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
			var symbols = new Gee.ArrayList<Symbol> ();
			var root = new Symbol ();
			root.symbol_type = SymbolType.FILE;
			root.verbose_name = root.name = src.filename;

			var visitor = new Visitor (root, src);

			Gee.List<Symbol> symbol_list = new Gee.ArrayList<Symbol> ();

			context.accept (visitor);
			sort_symbols (root.children);
			post_process (root, ref symbol_list);

			trees[src.filename] = root;
			lists[src.filename] = symbol_list;
		}

		private void post_process (Symbol parent, ref Gee.List<Symbol> global_collection)
		{
			var it = parent.children.list_iterator ();

			while (it.next ()) {
				var symbol = it.@get ();

				// FIXME we need to visit all namespaces, or all children from that
				//       namespace will not be reported to our visitor. This results
				//       in a number of superfluous namespaces, which we need to remove
				//       in a second pass. Only problem is that actually empty namespaces
				//       won't appear anywhere.
				if (symbol.symbol_type == SymbolType.NAMESPACE && symbol.children.size == 0)
					it.remove ();
				else {
					global_collection.add (symbol);
					post_process (symbol, ref global_collection);
				}
			}
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

