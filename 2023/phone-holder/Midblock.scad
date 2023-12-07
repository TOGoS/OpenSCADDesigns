height = 25.4; // 0.01
z_bevel_size = 1.5875; // 0.001

hole_style = "straight-4mm"; // ["straight-4mm", "THL-1001", "coutnersnuk","THL-1003"]

block_shape = "stubby-l-48"; // ["stubby-l-48", "straight-24", "rect-16x16", "rect-48x10", "rect-48x12"]

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
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

function make_rect_blockspec(size_u) = ["midblock-sh", [
	"shapespec",
	[[-size_u[0]/2, -size_u[1]/2], 2, [-1,-1]],
	[[ size_u[0]/2, -size_u[1]/2], 2, [ 1,-1]],
	[[ size_u[0]/2,  size_u[1]/2], 2, [ 1, 1]],
	[[-size_u[0]/2,  size_u[1]/2], 2, [-1, 1]],
], [
	for( xm=[-size_u[0]/2 + 4 : 8 : size_u[0]/2-2] )
	for( ym=[-size_u[1]/2 + 4 : 8 : size_u[1]/2-2] )
	[xm, ym]
]];


function shapespec_to_rath(shapespec, xy_bevel_size, z_bevel_offset) =
assert(shapespec[0] == "shapespec")
["togpath1-rath",
	for( i=[1:1:len(shapespec)-1] ) let( cs=shapespec[i] )
	let( cpos=cs[0] ) let( cbev=cs[1] ) let( czbevoff=cs[2] )
	let( ops = cs[1] == 0 ? [["round", xy_bevel_size]] : [["bevel", cbev*xy_bevel_size], ["round", cbev*xy_bevel_size]] )
	["togpath1-rathnode", cpos*u + czbevoff*z_bevel_offset, each ops]
];

function blockspec_to_tmod(blockspec, height, hole) =
	let( block_hull = tphl1_make_polyhedron_from_layer_function(
		[[0, -z_bevel_size], [z_bevel_size,0], [height-z_bevel_size,0], [height,-z_bevel_size]],
		function(zo)
			let( rath = shapespec_to_rath(blockspec[1], 1*u, zo[1]) )
			[
				for(p=togpath1_rath_to_points(rath)) [p[0], p[1], zo[0]]
			])
	)
	["difference",
		block_hull,
		for( hp=blockspec[2] ) ["translate", hp*u, hole]
	];

$fn = 24;

hole =
	hole_style == "straight-4mm" ? tphl1_make_z_cylinder(4, [-1,height+1]) :
	hole_style == "THL-1001"     ? ["translate", [0,0,height], tog_holelib2_hole(hole_style, depth=height+1, overhead_bore_height=2, inset=1)] :
	hole_style == "coutnersnuk"  ? ["translate", [0,0,height], tog_holelib2_countersunk_hole(8, 4, 2, height+1, inset=3)] :
	                               ["translate", [0,0,height], tog_holelib2_hole(hole_style, depth=height+1, overhead_bore_height=2)];

spec =
	block_shape == "stubby-l-48" ? l_midblock_spec :
	block_shape == "straight-24" ? straight3_midblock_spec :
	// TODO: Parse so that any size is block
	block_shape == "rect-16x16" ? make_rect_blockspec([16,16]) :
	block_shape == "rect-48x10" ? make_rect_blockspec([48,10]) :
	block_shape == "rect-48x12" ? make_rect_blockspec([48,12]) :
	assert(false, str("Unknown block style: '", block_shape, "'"));

togmod1_domodule(blockspec_to_tmod(spec, height, hole));
