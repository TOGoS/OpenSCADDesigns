// "I was going to do this anyway", but inspired by 'It’s Lambdas All the Way Down'
// https://itsbehnam.com/It-s-Lambdas-All-the-Way-Down-eb33012f54bb4708af001e0214910698

// Format a native OpenSCAD value as a string
function toslisp_value_to_string(expr) =
	is_string(expr) ? expr :
	is_num(expr) ? str(expr) : str(expr);
	
function toslisp_reduce(start, items, func, offset=0) =
	len(items) == offset ? start :
   toslisp_reduce(func(start, items[offset]), items, func, offset+1);

function toslisp_format_list_content_as_sexps(list, index=0, first=true) =
	index >= len(list) ? "" :
	str(first ? "" : " ", toslisp_format_as_sexp(list[index]), toslisp_format_list_content_as_sexps(list, index+1, false));

function toslisp_format_quoted_string(str) = str("\"",
	chr([
		for(char = str)
			for(char2 = (
				char == "\\" ? "\\\\" :
				char == "\"" ? "\\\"" :
				char == "\t" ? "\\t" :
				char == "\r" ? "\\r" :
				char == "\n" ? "\\n" :
				char
			)) ord(char2)
	]), "\"");

function toslisp_format_as_sexp(sexp) =
	is_list(sexp) && len(sexp) == 2 && sexp[0] == "quote" && is_string(sexp[1]) ? toslisp_format_quoted_string(sexp[1]) :
	is_list(sexp) ? str("(", toslisp_format_list_content_as_sexps(sexp), ")") :
	str(sexp);

function toslisp_zip(a, b) = [for(i=[0 : 1 : min(len(a),len(b))-1]) [a[i], b[i]]];

function toslisp_compile_lambda(params, body, varlookup) =
	function(argvalues)
		let(_varlookup = toslisp_reduce(varlookup, toslisp_zip(params, argvalues),
		                                function(prev, item) function(name) item[0] == name ? item[1] : prev(name)))
		toslisp_simplify_expression(body, _varlookup);

function toslisp_simplify_expression(expr, varlookup) =
	assert(is_function(varlookup))
	is_num(expr) || is_function(expr) ? expr :
	is_string(expr) ? varlookup(expr) :
	is_list(expr) && len(expr) == 2 && expr[0] == "quote" ? expr :
	is_list(expr) && len(expr) == 3 && expr[0] == "lambda" ? toslisp_compile_lambda(expr[1], expr[2], varlookup) :
	is_list(expr) && len(expr) >= 1 ? (
		let( func=toslisp_simplify_expression(expr[0], varlookup) )
		let( simplified_args=[for(i=[1:1:len(expr)-1]) toslisp_simplify_expression(expr[i], varlookup)] )
		is_function(func) ? func(simplified_args) :
		[func, for(a=simplified_args) a] // Maybe some intrinsic thing; just pass it back
	) :
	expr;

function toslisp_expression_value_to_string(expr, varlookup) =
	assert(!is_undef(expr))
	let(expr = toslisp_simplify_expression(expr, varlookup))
	is_num(expr) ? str(expr) :
	is_list(expr) ? assert(len(expr) > 0, "Can't resolve zero-length list as string") (
		expr[0] == "quote" ? assert(len(expr) == 2, str("Expected 'quote' to have exactly one argument; got: ",expr)) toslisp_value_to_string(expr[1]) :
		assert(false, str("Don't know how to evaluate '", expr[0], "' expression as string"))
	) : assert(false, str("Don't know how to evaluate ",expr," as string"));

toslisp_fn_concat = function(items)
	["quote", toslisp_reduce("", items, function(prev, current) str(prev, toslisp_expression_value_to_string(current,function(name) name)))];

toslisp__test_varlookup = function(name)
	name == "concat" ? toslisp_fn_concat : undef;

assert("foo" == toslisp_expression_value_to_string(["quote", "foo"], toslisp__test_varlookup));
assert("foo" == toslisp_expression_value_to_string(["concat", ["quote", "f"], ["quote", "oo"]], toslisp__test_varlookup));
assert("foo" == toslisp_expression_value_to_string([["lambda", [], ["quote", "foo"]]], toslisp__test_varlookup));
assert("foo" == toslisp_expression_value_to_string([["lambda", ["suffix"], ["concat", ["quote", "f"], "suffix"]], ["quote", "oo"]], toslisp__test_varlookup));
