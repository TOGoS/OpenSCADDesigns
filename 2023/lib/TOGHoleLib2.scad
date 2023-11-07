// TOGHoleLib2.0
//
// Library of hole shapes!
// Mostly to accommodate counterbored/countersunk screws.
//
// Changes:
// v2.0:
// - Based on v1.5.1, but generate TOGMod1 shapes
// - Drops support for THL-1013 and THL-1021

use <./TOGMod1Constructors.scad>
use <./TOGPolyHedronLib1.scad>

function tog_holelib2_countersunk_hole_2(surface_d, neck_d, head_h, depth, bore_d, overhead_bore_d, overhead_bore_height, inset=0.01) =
	tphl1_make_polyhedron_from_layer_function([
		[-depth , neck_d],
		[-head_h, neck_d],
		[ -inset, surface_d],
		[   0.01, overhead_bore_d],
		[overhead_bore_height, overhead_bore_d]
	], function(zd) togmod1_circle_points(d=zd[1], pos=[0,0,zd[0]]));

function tog_holelib2_countersunk_hole(surface_d, neck_d, head_h, depth, bore_d=-1, overhead_bore_d=0, overhead_bore_height=1) =
	tog_holelib2_countersunk_hole_2(surface_d, neck_d, head_h, depth, bore_d == -1 ? neck_d : bore_d, max(surface_d, overhead_bore_d), overhead_bore_height);

// Suitable for #6 flatheads
function tog_holelib2_hole1001(depth, overhead_bore_height=1) =
	tog_holelib2_countersunk_hole(7.5, 3.5, 1.7, depth, 4.5, 0, overhead_bore_height);

// Suitable for 1/4" flatheads
function tog_holelib2_hole1002(depth, overhead_bore_height=1) =
	let(inch = 25.4)
	tog_holelib2_countersunk_hole(1/2*inch, 1/4*inch, 1/8*inch, depth, 5/16*inch, 0, overhead_bore_height);

tog_holelib2_hole_types = [
	["THL-1001", "Suitable for #6 flathead"],
	["THL-1002", "Suitable for 1/4\" flathead"],
];

function tog_holelib2_get_hole_types() = tog_holelib2_hole_types;

function tog_holelib2_is_hole_type(type_name, idx=0) =
	idx > len(tog_holelib2_hole_types) ? false :
	tog_holelib2_hole_types[idx][0] == type_name ? true :
	tog_holelib2_is_hole_type(type_name, idx=idx + 1);

function tog_holelib2_hole(type_name, depth=1000, overhead_bore_height=1) =
	type_name == "none" ? ["union"] :
	type_name == "THL-1001" ? tog_holelib2_hole1001(depth, overhead_bore_height) :
	type_name == "THL-1002" ? tog_holelib2_hole1002(depth, overhead_bore_height) :
	assert(false, str("Unknown hole type: '", type_name, "'"));
