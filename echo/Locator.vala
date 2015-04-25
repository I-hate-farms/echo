
namespace Echo
{
	class Locator : Vala.CodeVisitor
	{
		Vala.Symbol? closest;
		int current_line;
		int current_column;

		public Vala.Symbol? find_closest_block (Vala.SourceFile src, int line, int column)
		{
			closest = null;
			current_line = line;
			current_column = column;

			// we now run through the doc and have check_location called repeatedly
			src.accept_children (this);

			return closest;
		}

		bool location_before (Vala.SourceLocation a, Vala.SourceLocation b)
		{
			return a.line < b.line || (a.line == b.line && a.column < b.column);
		}

		bool reference_inside (Vala.SourceReference r, int line, int column)
		{
			if (r.begin.line > line || r.end.line < line)
				return false;

			if (r.begin.line == line && r.begin.column < column)
				return false;

			if (r.end.line == line && r.end.column > column)
				return false;

			return true;
		}

		void check_location (Vala.Symbol symbol)
		{
			if (!reference_inside (symbol.source_reference, current_line, current_column))
				return;

			if (closest == null ||
				(location_before (closest.source_reference.begin,
								  symbol.source_reference.begin) &&
				 location_before (symbol.source_reference.end,
								  closest.source_reference.end))) {
				closest = symbol;
			}
		}

		public override void visit_namespace (Vala.Namespace symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_class (Vala.Class symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_block (Vala.Block symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_constructor (Vala.Constructor symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_creation_method (Vala.CreationMethod symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_destructor (Vala.Destructor symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_enum (Vala.Enum symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_interface (Vala.Interface symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_method (Vala.Method symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_struct (Vala.Struct symbol)
		{
			check_location (symbol);
			symbol.accept_children (this);
		}

		// those are just here to descend deeper into the structure
		public override void visit_property (Vala.Property prop) {
			prop.accept_children(this);
		}
		public override void visit_property_accessor (Vala.PropertyAccessor acc) {
			acc.accept_children(this);
		}
		public override void visit_if_statement (Vala.IfStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_switch_statement (Vala.SwitchStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_switch_section (Vala.SwitchSection section) {
			visit_block (section);
		}
		public override void visit_while_statement (Vala.WhileStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_do_statement (Vala.DoStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_for_statement (Vala.ForStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_try_statement (Vala.TryStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_catch_clause (Vala.CatchClause clause) {
			clause.accept_children(this);
		}
		public override void visit_lock_statement (Vala.LockStatement stmt) {
			stmt.accept_children(this);
		}
		public override void visit_lambda_expression (Vala.LambdaExpression expr) {
			expr.accept_children(this);
		}
	}
}

