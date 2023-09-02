use <../lib/TOSLisp-v1.scad>

assert(toslisp_expression_value_to_string("foo") == "foo");
assert(toslisp_expression_value_to_string(123) == "123");
assert(toslisp_expression_value_to_string(["quote","foo"]) == "foo");
assert(toslisp_expression_value_to_string(["concat",["quote","abc"],["quote","123"],["quote","def"]]) == "abc123def");
//echo(toslisp_expression_value_to_string(["quote",["foo"]]));

hello_world_expr = ["concat",["quote","Hello, "],["quote","World"],["quote","!"]];

assert("(foo)" == toslisp_format_as_sexp(["foo"]));
assert("(concat \"Hello, \" \"World\" \"!\")" == toslisp_format_as_sexp(hello_world_expr));

// cube([100,200,300]);

text(toslisp_expression_value_to_string(hello_world_expr));
