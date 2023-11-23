// Proof-of-concept tokenization
// 
// Inspired by https://github.com/dinther/pathbuilder/blob/main/pathbuilder.scad

// Notes on some OpenSCAD string/array functions:

echo(ord("hi there"));
// -> 104

echo("foo"[0]);
// -> "f"

echo(str("foo"[0], "foo"[1]));
// "fo"

echo(concat("foo"[0], "foo"[1]));
// -> ["f", "o"]

echo(concat([0,1],[2,3]));
// -> [0, 1, 2, 3]

source = "WSTYPE-4114-H1.5F";

function slice(source, i0, i1) =
	i0 == i1 ? "" :
	str(source[i0], slice(source, i0+1, i1));

function tokenize(source, i=0, tokenstart=0) =
	len(source) == i ? (
		(tokenstart < i) ? [slice(source, tokenstart, i)] : []
	) :
	source[i] == "-" ? (
		(tokenstart < i) ? concat([slice(source, tokenstart, i)], tokenize(source, i+1, i+1)) :
		tokenize(source, i+1, i+1)
	) : tokenize(source, i+1, tokenstart);

echo(tokenized=tokenize(source));
