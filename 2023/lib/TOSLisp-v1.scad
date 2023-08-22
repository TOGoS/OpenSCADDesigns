// "I was going to do this anyway", but inspired by 'It’s Lambdas All the Way Down'
// https://itsbehnam.com/It-s-Lambdas-All-the-Way-Down-eb33012f54bb4708af001e0214910698

function toslisp_value_to_string(expr) =
	is_string(expr) ? expr :
	is_num(expr) ? str(expr) : str(expr);
	
function toslisp_reduce(start, items, offset, func) =
	len(items) == offset ? start :
   toslisp_reduce(func(start, items[offset]), items, offset+1, func);

// Note: Currently strings are treated as literals *unless* they
// are the first item in an expression.
// It might be more consistent to always treat them as symbols
// unless quoted.
function toslisp_expression_value_to_string(expr) =
	is_string(expr) ? expr :
	is_num(expr) ? str(expr) :
	is_list(expr) ? assert(len(expr) > 0, "Can't resolve zero-length list as string") (
		expr[0] == "quote" ? assert(len(expr) == 2, str("Expected 'quote' to have exactly one argument; got: ",expr)) toslisp_value_to_string(expr[1]) :
		expr[0] == "concat" ? toslisp_reduce("", expr, 1, function(prev, subexpr) str(prev,toslisp_expression_value_to_string(subexpr))) :
		assert(false, str("Don't know how to evaluate '", expr[0], "' expression as string"))
	) : assert(false, str("Don't know how to evaluate ",expr," as string"));
