use <../lib/TOSLisp-v1.scad>

varlookup = function(name)
	name == "x" ? ["quote", "ecks"] :
	name == "concat" ? function(things) togslisp_fn_concat(things) :
	name;

assert("foo"  == toslisp_expression_value_to_string(["quote","foo"], varlookup));
assert("ecks" == toslisp_expression_value_to_string("x", varlookup));
assert("123"  == toslisp_expression_value_to_string(123, varlookup));
assert("abc123def" == toslisp_expression_value_to_string(["concat",["quote","abc"],["quote","123"],["quote","def"]], varlookup));
//echo(toslisp_expression_value_to_string(["quote",["foo"]]));

assert("(foo)" == toslisp_format_as_sexp(["foo"]));

// Test that special sequences are escaped in quoted strings:
expected_quoted = "\"Hello, \\\"World\\\"!\"";
echo(expected_quoted=expected_quoted, quoted=toslisp_format_as_sexp(["quote","Hello, \"World\"!"]));
assert(expected_quoted == toslisp_format_as_sexp(["quote","Hello, \"World\"!"]));

echo(more_quoted_chars=toslisp_format_as_sexp(["quote","\t\r\n"]));
assert("\"\\t\\r\\n\"" == toslisp_format_as_sexp(["quote","\t\r\n"]));

hello_world_expr = ["concat",["quote","Hello, "],["quote","World"],["quote","!"]];

assert("(concat \"Hello, \" \"World\" \"!\")" == toslisp_format_as_sexp(hello_world_expr));

text(toslisp_expression_value_to_string(hello_world_expr, varlookup));
translate([0,-20]) text(toslisp_format_as_sexp(hello_world_expr));

