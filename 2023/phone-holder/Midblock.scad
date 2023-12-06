height = 25.4;
z_bevel_size = 1.5875; // 0.001
hole_diameter = 4;

block_shape = "stubby-l-6"; // ["stubby-l-6", "straight-3"]

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>

module __end_params() { }

// MidblockSpec = ["midblock-sh", ShapeSpec, HolePositions]
// ShapeSpec = ["shapespec", [[x,y], xy_bevel_factor, z_bevel_offset_vector]]
// - z_bevel_offset_vector is the vector by the opposite of which the corner
//   should be offset for bevels (or roundings) along the top and bottom edges
// HolePositions = [[x,y], ...]

inch = 25.4;
u = inch / 16;

l_midblock_spec = ["midblock-sh", [
	"shapespec",
	[[-8, - 4], 2, [-1,-1]],
	[[ 4, - 4], 2, [ 1,-1]],
	[[ 4,  44], 2, [ 1, 1]],
	[[-2,  44], 1, [ 0, 1]],
	[[-2,   4], 0, [ 0, 1]],
	[[-8,   4], 1, [-1, 1]],
], [
	[ 0,0],
	[ 0,8],
	[ 0,16],
	[ 0,24],
	[ 0,32],
	[ 0,40],
]];
straight3_midblock_spec = ["midblock-sh", [
	"shapespec",
	[[-4, - 4], 2, [-1,-1]],
	[[ 4, - 4], 2, [ 1,-1]],
	[[ 4,  20], 2, [ 1, 1]],
	[[-4,  20], 2, [-1, 1]],
], [
	[ 0,0],
	[ 0,8],
	[ 0,16],
]];

function shapespec_to_rath(shapespec, xy_bevel_size, z_bevel_offset) =
assert(shapespec[0] == "shapespec")
["togpath1-rath",
	for( i=[1:1:len(shapespec)-1] ) let( cs=shapespec[i] )
	let( cpos=cs[0] ) let( cbev=cs[1] ) let( czbevoff=cs[2] )
	let( ops = cs[1] == 0 ? [["round", xy_bevel_size]] : [["bevel", cbev*xy_bevel_size], ["round", cbev*xy_bevel_size]] )
	["togpath1-rathnode", cpos*u + czbevoff*z_bevel_offset, each ops]
];

function blockspec_to_tmod(blockspec) =
	let( block_hull = tphl1_make_polyhedron_from_layer_function(
		[[0, -z_bevel_size], [z_bevel_size,0], [height-z_bevel_size,0], [height,-z_bevel_size]],
		function(zo)
			let( rath = shapespec_to_rath(blockspec[1], 1*u, zo[1]) )
			[
				for(p=togpath1_rath_to_points(rath)) [p[0], p[1], zo[0]]
			])
	)
	let( hole = tphl1_make_z_cylinder(hole_diameter, [-1,height+1]) )
	["difference",
		block_hull,
		for( hp=blockspec[2] ) ["translate", hp*u, hole]
	];

$fn = 24;

spec =
	block_shape == "stubby-l-6" ? l_midblock_spec :
	block_shape == "straight-3" ? straight3_midblock_spec :
	assert(false, str("Unknown block style: '", block_shape, "'"));

togmod1_domodule(blockspec_to_tmod(spec));
