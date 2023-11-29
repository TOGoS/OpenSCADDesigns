// TGx11
//
// Attenot at re-implementation of TGx9 shapes
// using TOGMod1 S-shapes and cleaner APIs with better defaults.

// TGx11Path = ["tgx11-path", TGx11PathSegment, ...]
// TGx11PathSegment =
//   ["tgx11-line", [x0,y0], [x1,y1]] |
//   ["tgx11-curve-right"|"tgx11-curve-left", [x0,y0], [x1,y1], [xa,ya]]

// Simpler: a 'qath', which is just a list of the curved parts
// TGx11QathSegment = ["tgx11-qathseg", [x,y], a0, a1, r]
// TGx11Qath = ["tgx11-qath", TGx11QathSegment, ...]

// function tgx11_rounded_offset_path(pn, offset) =

// TGx11QathInfo = ["tgx11-qath-info"|"invalid", min_radius|undef, ["error message", "error message", ...]]

preview_fn = 12;
offset = 0;

$fn = $preview ? preview_fn : 72;

function tgx11_merge_qath_info(i0, i1) =
	let(type = i0[0] == "tgx11-qath-info" && i1[0] == "tgx11-qath-info" ? "tgx11-qath-info" : "invalid")
	let(min_radius = is_undef(i0[1]) || is_undef(i1[1]) ? undef : min(i0[1],i1[1]))
	let(errs = concat(i0[2],i1[2]))
	[type, min_radius, errs];

assert(["tgx11-qath-info", 3, []] == tgx11_merge_qath_info(
	["tgx11-qath-info", 4, []],
	["tgx11-qath-info", 3, []]
));
assert(["invalid", undef, ["An error"]] == tgx11_merge_qath_info(
	["tgx11-qath-info", 4, []],
	["invalid", undef, ["An error"]]
));

function tgx11_qathseg_info(seg) =
	!is_list(seg) ? ["invalid", undef, [str("Segment is not a list: ", seg)]] :
	len(seg) != 5 ? ["invalid", undef, [str("Segment is not a list of length 5: ", seg)]] :
	seg[0] != "tgx11-qathseg" ? ["invalid", undef, [str("Segment[0] != \"tgx11-qathseg\": ", seg)]] :
	!is_list(seg[1]) || len(seg[1]) != 2 || !is_num(seg[1][0]) || !is_num(seg[1][1]) ?
		["invalid", undef, [str("Segment[1] is not [number,number]: ", seg)]] :
	!is_num(seg[2]) ? ["invalid", undef, [str("Segment[2] (angle 0) is not a number: ", seg)]] :
	!is_num(seg[3]) ? ["invalid", undef, [str("Segment[3] (angle 1) is not a number: ", seg)]] :
	!is_num(seg[4]) ? ["invalid", undef, [str("Segment[4] (radius) is not a number: ", seg)]] :
	["tgx11-qath-info", seg[4], []];

assert(["tgx11-qath-info", 3, []] == tgx11_qathseg_info(["tgx11-qathseg", [0,0], 0, 90, 3]));

function tgx11_qath_info(qath, off=0) =
	!is_list(qath) ? ["invalid", undef, ["Not a list"]] :
	len(qath) == 0 ? ["invalid", undef, ["Empty list"]] :
	len(qath) == off ? ["tgx11-qath-info", 1/0, []] :
	off == 0 && qath[off] == "tgx11-qath" ? tgx11_qath_info(qath, 1) :
	off == 0 ? ["invalid", undef, ["Not a tgx11-qath"]] :
	tgx11_merge_qath_info(tgx11_qathseg_info(qath[off]), tgx11_qath_info(qath, off+1));

assert(["tgx11-qath-info", 3, []] == tgx11_qath_info(["tgx11-qath",
	["tgx11-qathseg", [0,0], 0, 90, 3],
	["tgx11-qathseg", [0,0], 90, 180, 4],
	["tgx11-qathseg", [0,0], 180, 270, 5],
]));
assert("invalid" == tgx11_qath_info(["tgx11-qath",
	["tgx11-qathseg", [0,0], 0, 90, 3],
	["tgx11-qathseg-typo", [0,0], 90, 180, 4],
	["tgx11-qathseg", [0,0], 180, 270, 5],
])[0]);

function tgx11__fold(init, folder, list, off=0) =
	off == len(list) ? init :
	tgx11__fold(folder(init, list[off]), folder, list, off+1);

assert(6 == tgx11__fold(0, function(a,b) a+b, [1,2,3]));

function tgx11_offset_qath(qath, off) =
assert(tgx11_qath_info(qath)[0] == "tgx11-qath-info")
[
	"tgx11-qath",
	for( i=[1:1:len(qath)-1] )
	let( seg=qath[i] )
	// TODO: Maybe if a1 < a0, that means the curve is clockwise/concave, and we should subtract offset
	// (regardless of turn direction, negative offset means a kink which needs to be fixed)
	[seg[0], seg[1], seg[2], seg[3], seg[4] + off]
];

function tgx11_qathseg_points(seg) =
	let( a0 = seg[2] )
	let( a1 = seg[3] )
	let( rad = seg[4] )
	assert( rad >= 0 )
	assert( a1 - a0 > 0 || rad == 0 ) // For now, only allow left turns!
	let( vcount = ceil((a1 - a0) * max($fn,1) / 360) )
	echo(a1=a1, a0=a0, diff=(a1-a0), fn=$fn, vcount=vcount) 
	assert( vcount >= 1 )
[
	for( vi = [0:1:vcount] )
	// Calculate angles in such a way that first and last are exact
	let( a = a0 * (vcount-vi)/vcount + a1 * vi/vcount )
	[seg[1][0] + cos(a) * rad, seg[1][1] + sin(a) * rad]
];

function tgx11_qath_points(qath) =
let(qathinfo = tgx11_qath_info(qath))
assert(qathinfo[0] == "tgx11-qath-info")
assert(qathinfo[1] >= 0, str("Can't turn qath into points because minimum radius is < 0: ", qathinfo[1]))
[
	for( si = [1:1:len(qath)-1] )
	each tgx11_qathseg_points(qath[si])
];

a_path = tgx11_offset_qath(["tgx11-qath",
	["tgx11-qathseg", [ 10, 5],    0,  45, 5],
	["tgx11-qathseg", [ 5, 10],   45,  90, 5],
	["tgx11-qathseg", [-10, 10],  90, 180, 5],
	["tgx11-qathseg", [-10,-10], 180, 270, 5],
	["tgx11-qathseg", [ 10,-10], 270, 360, 5],
], offset);

a_path_points = tgx11_qath_points(a_path);

echo(a_path_points);

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(togmod1_make_polygon(a_path_points));
