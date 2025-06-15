// Clarp2506.0.4
// 
// The Clarp2505 profile, but in an octagon!
// And maybe with 1+1/4-7 threads
// 
// v0.1:
// - Illustrate basic idea
// v0.2:
// - Fix some indentation
// v0.3:
// - 1+1/4-7-UNC threads!
// v0.4:
// - Make it a TOGridPile block

width_u = 24;
block_height_u = 12;
thickness_u = 2;
block_size_chunks = [1,1];

atom_hole_style = "none"; // ["none","straight-5mm","THL-1001-bottom","deep-THL-1001-bottom","magnet-hole"]
chunk_hole_style = "none";

/* [Bottom] */

bottom_magnet_hole_diameter = 6.3;
bottom_magnet_hole_depth    = 2.4;

/* [detail] */

thread_r_offset = 0.2;
bottom_foot_bevel = 0.4; // 0.1

$tgx11_offset = -0.1;
$fn = 24;
thread_render_fn = 48;

module __clarp2506__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGThreads2.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

u = togridlib3_decode([1, "u"]);

thickness = thickness_u * u;

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_points(points, offset=[0,0]) = [
	for(p=points) p + offset,
	for(p=reverse_list(points)) [-p[0], p[1]] - offset
];

pd1 = mirror_points([
	[ 2, -8],
	[ 0, -6],
	[ 0,  2],
	[ 1,  1],
	[ 1,  0],
	[ 2,  0],
	[ 3, -1],
	[ 3, -2],
	[ 2, -3],
	[ 2, -5],
	[ 3, -6],
], [-width_u/2, 0]);

pd2 = mirror_points([
	[ 2,  8],
	[ 0,  6],
	[ 0,  2],
	[ 2,  0],
	[ 3, -1],
	[ 3, -2],
	[ 2, -3],
	[ 2, -4],
	[ 3, -5],
	[ 4, -5],
	[ 5, -4],
	[ 5,  0],
	[ 2,  3],
	[ 2,  5],
	[ 3,  6],
], [-width_u/2, 0]);

// togmod1_linear_extrude_z([0, thickness], togmod1_make_polygon([for(p=pd1) p*254/160])));

// Bunch of stuff copypastad from p1944.scad

block_size = [for(t=togridlib3_decode_vector(block_size_chunks)) t, block_height_u*u];

atom_bottom_subtractions = [
	if( atom_hole_style == "magnet-hole" ) tphl1_make_z_cylinder(d=bottom_magnet_hole_diameter, zrange=[-1, bottom_magnet_hole_depth]),
	if( atom_hole_style == "straight-5mm" ) tphl1_make_z_cylinder(d=5, zrange=[-20, block_size[2]+20]),
   if( atom_hole_style == "THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20)],
	if( atom_hole_style == "deep-THL-1001-bottom" ) ["rotate", [180,0,0], tog_holelib2_hole("THL-1001", depth=block_size[2]+20, inset=3)],
];

function bottom_hole_positions(size_chunks) =
let( chunk = togridlib3_decode([1,"chunk"]) )
let(  atom = togridlib3_decode([1,"atom" ]) )
[
	for(yc=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2])
	for(xc=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2])
	for(apos=[[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1]])
	[xc*chunk + apos[0]*atom, yc*chunk + apos[1]*atom]
];

floor_thickness_u = 3;

chunk_cavity = ["render", ["union",
	["render",["intersection",
		// Main cavity
		tphl1_make_polyhedron_from_layer_function([
			[floor_thickness_u  , -4],
			[floor_thickness_u+2, -2],
			[block_height_u * 2 , -2]
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_make_rectangle_rath(
				let(w=(width_u)*u)
				[w, w],
				assert(zo[1] >= -4, str("offset too big; zo = ", zo))
				[["bevel", 3*u], ["round", 4*u], ["offset", zo[1]*u + 0.1]]
			)),
			zo[0]*u
		)),
		// Clippable sublip
		tphl1_make_polyhedron_from_layer_function([
			[             0  , block_height_u-3],
			[block_height_u-2,               -3],
			[block_height_u-1,               -3],
			[block_height_u  ,               -2],
			[block_height_u*2, block_height_u-2],
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_make_polygon_rath(
				(width_u/2 + zo[1])*u / cos(22.5),
				rotation = 22.5,
				$fn = 8
			)),
			zo[0]*u
		)),
	]],
	togthreads2_make_threads(
	   togthreads2_simple_zparams([
		   [u * (block_height_u - 6), 0],
			[u *  block_height_u + 1 , 0],
		], 0, 0),
		"1+1/4-7-UNC",
		r_offset = thread_r_offset,
		thread_origin_z = block_height_u *u,
		$fn = $preview ? $fn : max($fn,thread_render_fn)
	),
	["translate", [0,0,floor_thickness_u*u], ["render", tog_holelib2_hole(chunk_hole_style, counterbore_inset=min(1*u, floor_thickness_u*u/2), depth=5*u)]],
]];

togmod1_domodule(
let(chunk = togridlib3_decode([1, "chunk"]))
["difference",
	tgx11_block(
		[[block_size_chunks[0], "chunk"], [block_size_chunks[1], "chunk"], [block_height_u, "u"]],
		bottom_segmentation = "chatom",
		bottom_foot_bevel   = bottom_foot_bevel,
		top_segmentation    = "block",
		atom_bottom_subtractions = atom_bottom_subtractions,
		lip_height = 1.6
	),
	
	for(yc=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2])
	for(xc=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2])
	["translate", [xc*chunk, yc*chunk], chunk_cavity],
]);
