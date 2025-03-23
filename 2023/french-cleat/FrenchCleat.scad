// FrenchCleat-v1.12
// 
// v1.1:
// - Allow selection of style for each edge
// - Allow extrusion along "X" or "Z" axis; counterbored holes are only cut when "X"
// - Remove tip_bevel_size and corner_bevel_size parameters,
//   as they are not currently used
// v1.2:
// - Rename 'direction' parameter to 'tester'
// - Trimmed style names now end with "-trimmed"
// - Add 'tester' mode
// v1.3:
// - Add option for 'coutnersnuk' holes
// v1.4:
// - Round the ends
// v1.5:
// - Hacked-in support to make TGx11-atom-female textured back
// v1.5.1:
// - Update reference to TGx11.1Lib.scad
// v1.6:
// - Provide some different THL-* hole types
// v1.7:
// - THL-1005-5u option (5/16" deep countersunk holes instead of only 1/8"ish)
// v1.8:
// - Add experimental 'atom-rows-f' backside texture, which is supposed to
//   give some of the grippy benefit of tgx11-atom-f but in a less restrictive way.
// v1.9:
// - Allow vertical slots for THL-1006 holes by setting slot_height > 0
// v1.10:
// - Add 'description' parameter, to help organize presets.
// v1.11:
// - Add 'height_ca' parameter
// - Add 'T' and 'T-trimmedd' options for opposite edge
// - Add 'fc_surface_offset' parameter
//   - set to small negative value like -0.1 to ensure FC is not too big,
//     or hole in tester not too tight
// v1.12:
// - #6-32-UNC and 1/4-20-UNC holes

description = "";

height_ca = [1.5, "inch"];
length_ca = [6, "inch"];
//tip_bevel_size = 2;
//corner_bevel_size = 1;

mating_edge_style = "S-trimmed"; // ["F", "S", "S-trimmed", "S-trimmed-C", "FS", "FFS"]
opposite_edge_style  = "FFS-trimmed"; // ["F", "S", "T", "S-trimmed", "T-trimmed", "FS", "FS-trimmed", "FFS-trimmed", "FFS-trimmed-B"]
hole_style = "GB-counterbored"; // ["GB-counterbored", "coutnersnuk", "THL-1001", "THL-1002", "THL-1003", "THL-1004", "THL-1005", "THL-1005-5u", "#6-32-UNC", "1/4-20-UNC"]
slot_height = 0;

mode = "X"; // ["X", "Z", "tester"]

/* [Experimental] */

// Can use tgx11-atom-f only when -C/-B edge styles are selected and mode = "X"
backside_texture = "flat"; // ["flat", "tgx11-atom-f", "atom-rows-f"]
$tgx11_offset = -0.1;

/* [Detail] */

fc_surface_offset = 0; // 0.1

assert(backside_texture == "flat" || (mating_edge_style == "S-trimmed-C" && opposite_edge_style == "FFS-trimmed-B" && mode == "X"));

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGThreads2.scad>

module __fc202310__end_params() { }

$fn = $preview ? 12 : 72;
$togridlib3_unit_table = tgx11_get_default_unit_table();
$togthreads2_polyhedron_algorithm = "v3";

length               = togridlib3_decode(length_ca);
length_gb            = floor(togridlib3_decode(length_ca, unit=[1.5, "inch"]));
hole_diameter        = togridlib3_decode([5/16, "inch"]);
counterbore_diameter = togridlib3_decode([7/ 8, "inch"]);
counterbore_depth    = togridlib3_decode([3/16, "inch"]);

yn  = togridlib3_decode([-3/4    , "inch"]);
ypn = togridlib3_decode([ 3/4-3/8, "inch"]);
ypp = togridlib3_decode([ 3/4+3/8, "inch"]);
zn  = togridlib3_decode([-3/8, "inch"]);
zp  = togridlib3_decode([+3/8, "inch"]);

// Tip bevel size
//tb = tip_bevel_size;
// Corner bevel size
//cb = corner_bevel_size;

function invert_edge_points(p, off=0) =
	len(p) == off ? [] :
	[
		each invert_edge_points(p, off+1),
		[p[off][0], -p[off][1]],
	];

// Positions of points relative to left edge, in 'u'

edge_profile_s_points = [
	[-6, +6],
	[+6, -6],
];
edge_profile_s_trimmed_points = [
	[-3, +6],
	[-4, +5],
	[-4, +4],
	[+6, -6],
];
edge_profile_s_trimmed_points_c = [
	[-3, +6],
	[-4, +5],
	[-4, +4],
	[+6, -6],
	[+6, -8],
];
edge_profile_f_points = [
	[ 0, +6],
	[ 0, -6],
];
edge_profile_fs_points = [
	[ 0, +6],
	[ 0,  0],
	[+6, -6],
];
// 'FS', but trimmed a bit more
edge_profile_ffs_trimmed_points = [
	[ 1  , +6],
	[ 0  , +5],
	[ 0  ,  2],
	[ 0.5,  1],
	[ 7  , -5.5],
	[ +8 , -6],
];
edge_profile_ffs_trimmed_points_b = [
	//[ 1  , +6],
	[ 0  , +8],
	[ 0  ,  2],
	[ 0.5,  1],
	[ 7  , -5.5],
	[ +8 , -6],
];

function make_cyllish(zd_list) = tphl1_make_polyhedron_from_layer_function(zd_list, function(zd) [
	for( i=[0 : 1 : $fn-1] ) let(r=zd[1]/2) let(a=i*360/$fn) [r*cos(a), r*sin(a), zd[0]]
]);

function make_fc_profile_points(left_x, right_x, left_points, right_points, u=1) =
assert(is_num(left_x))
assert(is_num(right_x))
assert(is_list(left_points))
assert(is_list(right_points))
[
	for( l=left_points  ) u * [ left_x + l[0], 0 + l[1]],
	for( r=right_points ) u * [right_x - r[0], 0 - r[1]],
];

function profile_points_for_style(style) =
	style == "F" ? edge_profile_f_points :
	style == "S" ? edge_profile_s_points :
	style == "T" ? invert_edge_points(edge_profile_s_points) :
	style == "S-trimmed" ? edge_profile_s_trimmed_points :
	style == "T-trimmed" ? invert_edge_points(edge_profile_s_trimmed_points) :
	style == "S-trimmed-C" ? edge_profile_s_trimmed_points_c :
	style == "FS" ? edge_profile_fs_points :
	style == "FFS-trimmed" ? edge_profile_ffs_trimmed_points :
	style == "FFS-trimmed-B" ? edge_profile_ffs_trimmed_points_b :
	assert(false, str("Unknown edge style '", style, "'"));

halfheight_u = togridlib3_decode(height_ca, unit=[1, "u"]) / 2;

fc_points = make_fc_profile_points(-halfheight_u, halfheight_u,
	profile_points_for_style(mating_edge_style),
	profile_points_for_style(opposite_edge_style),
	togridlib3_decode([1,"u"]));

function roundeprof(x0, x1, round) = let(vcount=max(1,ceil($fn/4))) [
	for( angoff=[
		for( am=[0:1:vcount] ) [180 - am*90/vcount, x0+round],
		for( am=[0:1:vcount] ) [ 90 - am*90/vcount, x1-round],
	] ) [ angoff[1] + cos(angoff[0]) * round, (sin(angoff[0])-1) * round ]
];

function offset_points(points, offset) =
	togpath1_rath_to_points(["togpath1-rath", for(p=points) ["togpath1-rathnode", p, ["offset", offset]]]);

function make_fc_hull(direction, length, fc_surface_offset=0) = tphl1_make_polyhedron_from_layer_function(
	roundeprof(-length/2, length/2, 1.5)
	// [-length/2, -1], [-length/2+1, 0], [length/2-1, 0], [length/2, -1]
, function(xo) [
	let(x=xo[0])
	for(point=offset_points(fc_points,xo[1]+fc_surface_offset))
	direction == "X" ? [x, point[0], point[1]] : [point[0], point[1], x]
]);

/*
counterbored_hole = tphl1_make_polyhedron_from_layer_function([
	[zn-1                ,        hole_diameter],
	[zp-counterbore_depth,        hole_diameter],
	[zp-counterbore_depth, counterbore_diameter],
	[zp+1                , counterbore_diameter]
], function(params) togmod1_circle_points(d=params[1], pos=[0,0,params[0]]));
*/

_hole_style = hole_style == "GB-counterbored" ? "THL-1006-3/16in" : hole_style;

function is_thread_hole_style(s) =
	s == "#6-32-UNC" || s == "1/4-20-UNC"; // TODO: Does itend with "-UNC"?

hole =
	_hole_style == "GB-counterbored" ? counterbored_hole :
	_hole_style == "coutnersnuk"     ? ["translate", [0,0,zp], tog_holelib2_countersunk_hole(8, 4, 2, zp-zn+1, inset=3)] :
	_hole_style == "THL-1005-5u"     ? ["translate", [0,0,zp], tog_holelib2_hole("THL-1005", inset=5*25.4/16)] :
	is_thread_hole_style(_hole_style)?
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-zp+1,1], [zp-1,1]], taper_length=1, extend=1.5),
			_hole_style,
			r_offset = 0.2, // Usually good!
			end_mode = "blunt"
		) :
	["translate", [0,0,zp], tog_holelib2_slot(_hole_style, [-20, 0, 20], slot_height == 0 ? [[0,0]] : [[0,slot_height/2],[0,-slot_height/2]])];

hole_spacing =
	(hole_style == "GB-counterbored" || hole_style == "THL-1002") ? 38.1 : 12.7;

hole_rows = [0];

inch = togridlib3_decode([1,"inch"]);

tester_height = togridlib3_decode(height_ca) + togridlib3_decode([1,"chunk"]);
tester_hull = tphl1_make_rounded_cuboid([tester_height, 1.5*inch, length], [1/2*inch, 1/2*inch, 0]);

function fc_atomic_rows_foot(size_ca) =
let(size = togridlib3_decode_vector(size_ca))
["union",
	["translate", [0,   0  , size[2]/2], togmod1_make_cuboid([size[0], size[1]*2, size[2]-inch/8+$tgx11_offset*2])],
	["translate", [0, -25.4, size[2]/2], togmod1_make_cuboid([size[0], 38.1-inch/8+$tgx11_offset*2, size[2]+$tgx11_offset*2])],
	["translate", [0,   0  , size[2]/2], togmod1_make_cuboid([size[0], 12.7-inch/8+$tgx11_offset*2, size[2]+$tgx11_offset*2])],
	["translate", [0,  12.7, size[2]/2], togmod1_make_cuboid([size[0], 12.7-inch/8+$tgx11_offset*2, size[2]+$tgx11_offset*2])],
];

function make_textured_fc_hull(direction, length, backside_texture, fc_surface_offset=0) =
	let(h = make_fc_hull(direction, length, fc_surface_offset=fc_surface_offset))
	backside_texture == "atom-rows-f" ? ["difference", h,
		["translate", [0,0,zn], ["rotate", [180,0,0],
			fc_atomic_rows_foot(
				[[length+25.4, "mm"], [5, "atom"], [20, "mm"]],
				$tgx11_offset = -$tgx11_offset,
				$tgx11_gender = "f"
			)
		]]
	] :
	backside_texture == "tgx11-atom-f" ? ["difference", h,
		["translate", [0,0,zn], ["rotate", [180,0,0],
			// Extend pattern one atom beyond actual extent of cleat
			tgx11_atomic_block_bottom(
				[[length + 25.4, "mm"],[5,"atom"],[20,"mm"]],
				bottom_shape="footed",
				$tgx11_offset = -$tgx11_offset,
				$tgx11_gender = "f"
			)
		]]
	] :
	h;

fc_main =
	mode == "X" ? ["difference",
		make_textured_fc_hull("X", length, backside_texture),
		
		for( y=hole_rows )
		for( xm=[-length/hole_spacing/2 + 0.5 : 1 : length/hole_spacing/2] ) ["x-debug", ["translate", [xm*hole_spacing, y], hole]]
	] :
	mode == "Z" ? make_fc_hull("Z", length, fc_surface_offset=fc_surface_offset) :
	mode == "tester" ? ["difference",
		tester_hull,
		
		make_fc_hull("Z", length*2, fc_surface_offset=-fc_surface_offset),
		
		let( chunk=togridlib3_decode([1,"chunk"]) )
		let( height_chunks=togridlib3_decode(height_ca, unit=[1,"chunk"]) )
		for( xm=[-height_chunks/2+0.5 : 1 : height_chunks/2] )
		for( s=[-1, 1] )
		["scale", [1,s,1], ["translate", [xm*chunk, -3/8*inch, 0], ["rotate", [90, 0, 0], make_cyllish([[-1, 2], [3/8*inch+1, 12]])]]],
		// TODO: Subtract center-marking pencil-tip holes
	] :
	assert(false, str("Unknown mode: '", mode, "'"));

togmod1_domodule(fc_main);
