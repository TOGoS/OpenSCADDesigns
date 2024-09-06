// Hinge0.2
// 
// Use to make hinges off the ends of 1/2" boards.
// 
// Changes:
// v0.2:
// - Customizable mounting hole height
// - one-legged or two-legged style
// - Round end corners a little

height = 19.05;
style = "two-legged"; // ["two-legged", "one-legged"]
mounting_hole_height = "6u"; // ["none","center","4u","6u"]
pin_hole_diameter = 6.5;
$fn = 32;

module __hinge0_end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>


function arc_points(a0, a1, offset=[0,0], scale=[1,1]) =
	let(facecount = round($fn / 4))
	facecount == 0 ?
	[
		let( amid = (a1+a0)/2 )
		let( vecmid = [cos(amid),sin(amid)] )
		let( norm = function(x) x < 0 ? -1 : x > 0 ? 1 : 0 )
		[
			offset[0] + scale[0] * norm(vecmid[0]),
			offset[1] + scale[1] * norm(vecmid[1])
		]
	] :
	let( angspan = a1 - a0 )
	[
		for( p=[0 : 1 : facecount] )
		let( ang = a0 + p * angspan / facecount )
		[
			offset[0] + scale[0] * cos(ang),
			offset[1] + scale[1] * sin(ang),
		]
	];

u = 25.4/16;

function hinge0_shape_polypoints(style, end_offset) =
	let( x0 = -18*u - end_offset )
	togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [- 6*u, -4*u]],
		["togpath1-rathnode", [   x0, -4*u], ["round", 0.9*u]],
		["togpath1-rathnode", [   x0, -6*u], ["round", 0.9*u]],
		["togpath1-rathnode", [  5*u, -6*u], ["round", 5.9*u]],
		["togpath1-rathnode", [  5*u,  6*u], ["round", 5.9*u]],
		each style == "two-legged" ? [
			["togpath1-rathnode", [   x0,  6*u], ["round", 0.9*u]],
			["togpath1-rathnode", [   x0,  4*u], ["round", 0.9*u]],
			["togpath1-rathnode", [- 6*u,  4*u]],
		] : [
			["togpath1-rathnode", [- 6*u,  6*u], ["round", 2*u]],
		]
	]);

hole_height =
	mounting_hole_height == "center" ? height/2 :
	mounting_hole_height == "4u" ? 4*u :
	mounting_hole_height == "6u" ? 6*u :
	-height;

thing = ["difference",
	//togmod1_linear_extrude_z([0, height], shape),
	tphl1_make_polyhedron_from_layer_function([
		//each swoop_down([       0,      u], [180, 270], -u, -u),
		each arc_points(180, 270, [u       , -u], [u, -u]),
		[height/2, 0],
		each arc_points(270, 360, [height-u, -u], [u, -u]),
	], function(z_eo) togvec0_offset_points(hinge0_shape_polypoints(style, z_eo[1]), z_eo[0])),
	
	tphl1_make_z_cylinder(d=pin_hole_diameter, zrange=[-1, +height+1]),
	
	["translate", [-12*u, 6*u, hole_height], ["rotate", [-90,0,0], tog_holelib2_hole("THL-1001", depth=30*u)]]
];

togmod1_domodule(thing);
