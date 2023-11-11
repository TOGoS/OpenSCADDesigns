// FrenchCleat-v1.1
// 
// v1.1:
// - Allow selection of style for each edge
// - Allow extrusion along "X" or "Z" axis; counterbored holes are only cut when "X"
// - Remove tip_bevel_size and corner_bevel_size parameters,
//   as they are not currently used

length_ca = [6, "inch"];
//tip_bevel_size = 2;
//corner_bevel_size = 1;

mating_edge_style = "S"; // ["F", "S", "FS", "FFS"]
opposite_edge_style  = "FFS"; // ["F", "S", "FS", "FFS"]

direction = "X"; // ["X", "Z"]

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 12 : 72;

module __fc202310__end_params() { }

length               = togridlib3_decode(length_ca);
length_gb            = floor(togridlib3_decode(length_ca, unit=[1.5, "inch"]));
hole_diameter        = togridlib3_decode([5/16, "inch"]);
counterbore_diameter = togridlib3_decode([7/ 8, "inch"]);
counterbore_depth    = togridlib3_decode([3/16, "inch"]);

yn  = togridlib3_decode([-3/4    , "inch"]);
ypn = togridlib3_decode([ 3/4-3/8, "inch"]);
ypp = togridlib3_decode([ 3/4+3/8, "inch"]);
zn = togridlib3_decode([-3/8, "inch"]);
zp = togridlib3_decode([+3/8, "inch"]);

// Tip bevel size
//tb = tip_bevel_size;
// Corner bevel size
//cb = corner_bevel_size;

// Positions of points relative to left edge, in 'u'

edge_profile_s_points = [
	[-3, +6],
	[-4, +5],
	[-4, +4],
	[+6, -6],
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
edge_profile_ffs_points = [
	[ 1  , +6],
	[ 0  , +5],
	[ 0  ,  2],
	[ 0.5,  1],
	[ 7  , -5.5],
	[ +8 , -6],
];

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
	style == "FS" ? edge_profile_fs_points :
	style == "FFS" ? edge_profile_ffs_points :
	assert(false, str("Unknown edge style '", style, "'"));

fc_hull = tphl1_make_polyhedron_from_layer_function(direction == "X" ? [-length/2, length/2] : [0, length], function(x) [
	for(point=make_fc_profile_points(-12, 12,
		profile_points_for_style(mating_edge_style),
		profile_points_for_style(opposite_edge_style),
		togridlib3_decode([1,"u"])))
	direction == "X" ? [x, point[0], point[1]] : [point[0], point[1], x]
]);

counterbored_hole = tphl1_make_polyhedron_from_layer_function([
	[zn-1                ,        hole_diameter],
	[zp-counterbore_depth,        hole_diameter],
	[zp-counterbore_depth, counterbore_diameter],
	[zp+1                , counterbore_diameter]
], function(params) togmod1_circle_points(d=params[1], pos=[0,0,params[0]]));

togmod1_domodule(["difference",
	fc_hull,
	
	if( direction == "X" ) for( xm=[-length_gb/2 + 0.5 : 1 : length_gb/2] ) ["x-debug", ["translate", [xm*38.1, 0], counterbored_hole]]
]);
