use <../lib/TOSLisp-v1.scad>

assert(toslisp_expression_value_to_string("foo") == "foo");
assert(toslisp_expression_value_to_string(123) == "123");
assert(toslisp_expression_value_to_string(["quote","foo"]) == "foo");
assert(toslisp_expression_value_to_string(["concat","abc","123","def"]) == "abc123def");
//echo(toslisp_expression_value_to_string(["quote",["foo"]]));

// cube([100,200,300]);

text(toslisp_expression_value_to_string(["concat","Hello, ","World","!"]));
