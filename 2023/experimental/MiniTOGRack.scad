// MiniTOGRack0
// 
// "What if TOGRack, but on a 1/4-inch grid and #4 screws?"

countersink_inset = 0.1;
atom_pitch_u = 4;
panel_thickness_u = 2;
panel_size_atoms = [11,11];
panel_hole_style = "number4-straight"; // ["none","number4-straight", "number4-counterbored"]
panel_edge_offset = -0.2;

module __1oij2eo1in__end_params() { }

$fn = $preview ? 16 : 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

function u_to_mm(u) =
	is_list(u) ? [for(v=u) u_to_mm(v)] : u * 25.4 / 16;
function atom_to_mm(a) =
	is_list(a) ? [for(b=a) atom_to_mm(b)] : u_to_mm(atom_pitch_u*a);

// First things first; if we're going to use #4 flathead screws,
// figure out what kind of holes they need.
// 
// http://www.clecofasteners.com/Cleco-Specs/flathhead.gif says
// head top = 0.225"; height = 0.067"
// 
// https://monsterbolts.com/pages/us-screw-sizes says that a #4 screw's diameter
// is 0.112" or 2.84mm.

function make_number4_counterbored_hole(depth=100, overhead_bore_height=10, inset=0.1) =
	tog_holelib2_countersunk_hole(surface_d=6, neck_d = 3, bore_d=3.5, head_h = 1.7, depth=depth, overhead_bore_height=overhead_bore_height, inset=inset);

panel_actual_size = [
	atom_to_mm(panel_size_atoms[0]) + panel_edge_offset*2,
	atom_to_mm(panel_size_atoms[1]) + panel_edge_offset*2,
	u_to_mm(panel_thickness_u)
];

phole =
	panel_hole_style == "none" ? ["union"] :
	panel_hole_style == "number4-straight" ? tphl1_make_z_cylinder(d=3.5, zrange=[-100,100]) :
	make_number4_counterbored_hole(inset=countersink_inset);

inch = 25.4;

function make_panel(size, corner_ops) =
	let(panel_rath = ["togpath1-rath",
		["togpath1-rathnode", [-size[0]/2,-size[1]/2], each corner_ops],
		["togpath1-rathnode", [ size[0]/2,-size[1]/2], each corner_ops],
		["togpath1-rathnode", [ size[0]/2, size[1]/2], each corner_ops],
		["togpath1-rathnode", [-size[0]/2, size[1]/2], each corner_ops],
	])
	let(panel_polypoints = togpath1_rath_to_polypoints(panel_rath))
	tphl1_make_polyhedron_from_layer_function([
		0, size[2]
	], function(z) 
		togvec0_offset_points(panel_polypoints, z)
	);

panel = ["difference",
	make_panel(panel_actual_size, corner_ops=[["round", u_to_mm(atom_pitch_u)/2+panel_edge_offset]]),
	
	for( ym=[-panel_size_atoms[1]/2+0.5, panel_size_atoms[1]/2-0.5] )
	for( xm=[-panel_size_atoms[0]/2+0.5 : 1 : panel_size_atoms[0]/2] )
	["translate", [
		atom_to_mm(xm),
		atom_to_mm(ym),
		panel_actual_size[2]
	], phole]
];

togmod1_domodule(panel);

// Good atom size divides into gridbeam sizes - 1/4".
// That seems to limit us to 1/4".  :-P
// 68 = 4 x 17
// 44 = 4 x 11
