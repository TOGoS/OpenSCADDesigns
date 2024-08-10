// Idea:
// Automatically offset polyhedron faces in two dimensions
// by first calculating 

offset = -1;
$fn = 32;

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

// A profile is just the right side of a shape.
// This technique should work with whole polygons,
// too, but for the common case where making a polyhedron
// that is capped on the top and bottom (as opposed to being toroidal),
// you want to ignore the 'tunnel' at the center.

function aop0_offset_polypoints(points0, offset) =
	assert(is_num(offset))
	// Kind of a roundabot way to do this.
	// Could be done more directly without involving raths.
	let(rath = ["togpath1-rath",
		for( p=points0 ) ["togpath1-rathnode", p, ["offset", offset]]
	])
	echo(rath=rath)
	assert(rath[0] == "togpath1-rath")
	togpath1_rath_to_polypoints(rath);

function aop0_polypoints_to_profile(points) = [
	for( i=[1:1:len(points)-2] ) points[i]
];

function aop0_profile_to_polypoints(prof) =
let( z=len(prof)-1 )
[
	[min(0, prof[0][0]-1), prof[0][1]],
	each prof,
	[min(0, prof[z][0]-1), prof[z][1]],
];

function aop0_profile_to_mirrored_polypoints(prof) = [
	for( i=[       0    :  1 : len(prof)-1] ) prof[i],
	for( i=[len(prof)-1 : -1 :      0     ] ) [-prof[i][0], prof[i][1]],
];

function aop0_offset_profile(profile, offset) =
	assert(is_num(offset))
	aop0_polypoints_to_profile(aop0_offset_polypoints(aop0_profile_to_polypoints(profile), offset=offset));

// Given a profile,
// return list of [x, y] offset_multiplier for each layer.
function aop0_calculate_layer_xz_offset_factors_from_polypoints( polypoints ) =
	let( offsetted = aop0_offset_polypoints(polypoints, 1) )
	[
		for( i = [0 : 1 : len(polypoints)-1] )
		let( p = polypoints[i] ) assert( tal1_is_vec_of_num(p, 2) )
		let( o =  offsetted[i] ) assert( tal1_is_vec_of_num(o, 2) )
		[o[0] - p[0], o[1]-p[1]]
	];

function aop0_calculate_layer_xz_offset_factors_from_profile( profile ) =
	aop0_polypoints_to_profile(aop0_calculate_layer_xz_offset_factors_from_polypoints(aop0_profile_to_polypoints(profile)));

function aop0_make_polyhedron_from_profile_rath( profile, rath, offset=0 ) =
	let( layer_xz_offset_factors = aop0_calculate_layer_xz_offset_factors_from_profile(profile) )
	echo( layer_xz_offset_factors=layer_xz_offset_factors )
	let( params = [for( i=[0 : 1 : len(profile)-1] ) [profile[i], layer_xz_offset_factors[i]]] )
	tphl1_make_polyhedron_from_layer_function(params, function(param)
		let( pvec = param[0] )
		let( ofac = param[1] )
		togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_offset_rath(rath, pvec[0] + ofac[0]*offset)),
			pvec[1] + ofac[1]*offset
		)
	);



demo_profile = [
	[10, -20],
	[20, -10],
	[10, - 5],
	[ 5, - 5],
	[ 0,   0],
	[ 5, + 5],
	[10, + 5],
	[20, +10],
	[15, +20],
];

demo_rath = ["togpath1-rath",
	["togpath1-rathnode", [  0, -20], ["round", 5]],
	["togpath1-rathnode", [ 20,   0], ["round", 5]],
	["togpath1-rathnode", [-10,  10], ["round", 5]],
];

cc_cube = ["translate", [30,-30,0], togmod1_make_cuboid([60,60,60])];

togmod1_domodule(["union",
	/*(["translate", [-30, 0, 0], ["union",
		togmod1_linear_extrude_z([ 0,10], togmod1_make_polygon(aop0_profile_to_mirrored_polypoints(aop0_offset_profile(demo_profile, offset=0     )))),
		togmod1_linear_extrude_z([10,20], togmod1_make_polygon(aop0_profile_to_mirrored_polypoints(aop0_offset_profile(demo_profile, offset=offset)))),
	]],*/
	
	["translate", [ 30, 0, 0], ["union",
		["intersection", aop0_make_polyhedron_from_profile_rath( demo_profile, demo_rath, offset=0      ), cc_cube],
		["difference"  , aop0_make_polyhedron_from_profile_rath( demo_profile, demo_rath, offset=offset ), cc_cube],
		// TODO: Cross-section showing original, un-offset
	]],
]);
