height = 25.4;
z_bevel_size = 1.5875; // 0.001
hole_diameter = 4;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>

module __end_params() { }

inch = 25.4;
u = inch / 16;
shapespec = [
	[[-8, - 4], 2, [-1,-1]],
	[[ 4, - 4], 2, [ 1,-1]],
	[[ 4,  44], 2, [ 1, 1]],
	[[-2,  44], 1, [ 0, 1]],
	[[-2,   4], 0, [ 0, 1]],
	[[-8,   4], 1, [-1, 1]],
];
hole_positions_u = [
	[ 0,0],
	[ 0,8],
	[ 0,16],
	[ 0,24],
	[ 0,32],
	[ 0,40],
];

$fn = 24;

function block_layer_rath(shapespec, xy_bevel_size, z_bevel_offset) = ["togpath1-rath",
	for( cs=shapespec )
	let( cpos=cs[0] ) let( cbev=cs[1] ) let( czbevoff=cs[2] )
	let( ops = cs[1] == 0 ? [["round", xy_bevel_size]] : [["bevel", cbev*xy_bevel_size], ["round", cbev*xy_bevel_size]] )
	["togpath1-rathnode", cpos*u + czbevoff*z_bevel_offset, each ops]
];
// points = togpath1_rath_to_points(rath);
block_hull = tphl1_make_polyhedron_from_layer_function([[0, -z_bevel_size], [z_bevel_size,0], [height-z_bevel_size,0], [height,-z_bevel_size]], function(zo)
	let( rath = block_layer_rath(shapespec, 1*u, zo[1]) )
	[
		for(p=togpath1_rath_to_points(rath)) [p[0], p[1], zo[0]]
	]);

hole = tphl1_make_z_cylinder(hole_diameter, [-1,height+1]);
block = ["difference",
	block_hull,
	for( hp=hole_positions_u ) ["translate", hp*u, hole]
];

togmod1_domodule(block);
