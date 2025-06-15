// Clarp2506.0.3
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
// 
// TODO: Make it a TOGridPile block

width_u = 24;
block_height_u = 12;
thickness_u = 2;
$fn = 24;
thread_render_fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGThreads2.scad>

u = 254/160;

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

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, block_height_u*u], togmod1_make_rounded_rect([width_u*u, width_u*u], 3*u)),
	["intersection",
		// Main cavity
		tphl1_make_polyhedron_from_layer_function([
			[2, -4],
			[4, -2],
			[block_height_u * 2, -2]
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_make_rectangle_rath(
				let(w=(width_u)*u)
				[w, w],
				[["bevel", 3*u], ["round", 3*u], ["offset", zo[1]*u]]
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
	],
	togthreads2_make_threads(
	   togthreads2_simple_zparams([
		   [u * (block_height_u - 6), 0],
			[u *  block_height_u + 1 , 0],
		], 0, 0),
		"1+1/4-7-UNC",
		r_offset = 0.2,
		$fn = $preview ? $fn : max($fn,thread_render_fn)
	),
]);
