
namespace Echo
{
	public class Locator : Vala.CodeVisitor
	{
		Vala.Symbol? closest;
		int current_line;
		int current_column;
		bool exact_symbol;

		public Vala.Symbol? find_closest_block (Vala.SourceFile src, int line, int column)
		{
			closest = null;
			current_line = line;
			current_column = column;
			exact_symbol = false;

			// we now run through the doc and have check_location called repeatedly
			src.accept_children (this);

			return closest;
		}

		public Vala.Symbol? find_symbol_at_position (Vala.SourceFile src, int line, int column)
		{
			closest = null;
			current_line = line;
			current_column = column;
			exact_symbol = true;

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

		/*
		 * non block types from here on, for exact matching
		 */

		/*public override void visit_addressof_expression (Vala.AddressofExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_array_creation_expression (Vala.ArrayCreationExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_assignment (Vala.Assignment symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_base_access (Vala.BaseAccess symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_binary_expression (Vala.BinaryExpression expr)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_boolean_literal (Vala.BooleanLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_cast_expression (Vala.CastExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_catch_clause (Vala.CatchClause symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_character_literal (Vala.CharacterLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_conditional_expression (Vala.ConditionalExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_constant (Vala.Constant symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_continue_statement (Vala.ContinueStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_data_type (Vala.DataType symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_declaration_statement (Vala.DeclarationStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_delegate (Vala.Delegate symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_delete_statement (Vala.DeleteStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_do_statement (Vala.DoStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_element_access (Vala.ElementAccess symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_empty_statement (Vala.EmptyStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_end_full_expression (Vala.Expression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_enum_value (Vala.EnumValue symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_error_code (Vala.ErrorCode symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_error_domain (Vala.ErrorDomain symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_expression (Vala.Expression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_expression_statement (Vala.ExpressionStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_field (Vala.Field symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_for_statement (Vala.ForStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_foreach_statement (Vala.ForeachStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_formal_parameter (Vala.Parameter symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_if_statement (Vala.IfStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_initializer_list (Vala.InitializerList symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_integer_literal (Vala.IntegerLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_lambda_expression (Vala.LambdaExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_local_variable (Vala.LocalVariable symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_lock_statement (Vala.LockStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_loop (Vala.Loop symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_member_access (Vala.MemberAccess symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_method_call (Vala.MethodCall symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_named_argument (Vala.NamedArgument symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_null_literal (Vala.NullLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_object_creation_expression (Vala.ObjectCreationExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_pointer_indirection (Vala.PointerIndirection symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_postfix_expression (Vala.PostfixExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_property (Vala.Property symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_property_accessor (Vala.PropertyAccessor symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_real_literal (Vala.RealLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_reference_transfer_expression (Vala.ReferenceTransferExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_regex_literal (Vala.RegexLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_return_statement (Vala.ReturnStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_signal (Vala.Signal symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_sizeof_expression (Vala.SizeofExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_slice_expression (Vala.SliceExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_source_file (Vala.SourceFile symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_string_literal (Vala.StringLiteral symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_switch_label (Vala.SwitchLabel symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_switch_section (Vala.SwitchSection symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_switch_statement (Vala.SwitchStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_template (Vala.Template symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_throw_statement (Vala.ThrowStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_try_statement (Vala.TryStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_tuple (Vala.Tuple symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_type_check (Vala.TypeCheck symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_type_parameter (Vala.TypeParameter symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_typeof_expression (Vala.TypeofExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_unary_expression (Vala.UnaryExpression symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_unlock_statement (Vala.UnlockStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_using_directive (Vala.UsingDirective symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_while_statement (Vala.WhileStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}
		public override void visit_yield_statement (Vala.YieldStatement symbol)
		{
			if (exact_symbol)
				check_location (symbol);
			symbol.accept_children (this);
		}*/
	}
}

