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


use <../lib/TOGStringLib1.scad>
use <../lib/TOGridLib3.scad>

function decode_rational_quantity(rq, qdecoder=function(x) togridlib3_decode(x)) =
	togridlib3_decode([rq[0][0], rq[1]]) / rq[0][1];

function parse_straight(feh) =
	let(qr = togstr1_parse_quantity(feh))
	let(diam_rq = qr[0])
	let(diam = decode_rational_quantity(diam_rq))
	["zds", [[0,-1],diam], [[1,1],diam]];

function parse_hole(nem) =
	let( kq = togstr1_tokenize(nem, "-", 2) )
	kq[0] == "straight" ? parse_straight(kq[1]) :
	assert(false, str("Unrecognized hole type: '", nem, "'"));

hole_style = "straight-3mm";

echo(hole_style=hole_style, decoded=parse_hole(hole_style));
