// ClarpNut0.1
// 
// 1+1/4-7 nut inspired by Clarp2605 / p1993,

width_u = 24;
thickness_u = 3;
block_size_chunks = [1,1];

thread_r_offset = 0.2;
$tgx11_offset = -0.1;
preview_fn = 24;
render_fn = 144;

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

$fn = $preview ? preview_fn : render_fn;

$togridlib3_unit_table = tgx11_get_default_unit_table();

u = togridlib3_decode([1, "u"]);

chunk_cavity = ["render", ["union",
	["render",["intersection",
		// Clippable sublip
		tphl1_make_polyhedron_from_layer_function([
			/*
			[             0  , thickness_u-3],
			[thickness_u-3,               -3],
			[thickness_u-2,               -3],
			[thickness_u-1,               -3],
			[thickness_u  ,               -2],
			[thickness_u*2, thickness_u-2],
			*/
			[-2.5*u, -1*u],
			[-0.5*u, -3*u],
			[ 0.5*u, -3*u],
			[ 2.5*u, -1*u],
		], function(zo)
			//let( x2 = (width_u/2 + zo[1])*u )
			let( x2 = width_u*u/2 )
			let( x1 = x2 * tan(22.5) )
			let( cops = [["round",3.1*u], ["offset", zo[1]]] )
			togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [ x1,-x2], each cops],
				["togpath1-rathnode", [ x2,-x1], each cops],
				//["togpath1-rathnode", [ x2, x1], each cops],
				//["togpath1-rathnode", [ x1, x2], each cops],
				["togpath1-rathnode", [ x2, x2], each cops],
				["togpath1-rathnode", [-x2, x2], each cops],
				//["togpath1-rathnode", [-x1, x2], each cops],
				//["togpath1-rathnode", [-x2, x1], each cops],
				["togpath1-rathnode", [-x2,-x1], each cops],
				["togpath1-rathnode", [-x1,-x2], each cops],
			]),
			layer_points_transform = "key0-to-z"
		),
	]],
	togthreads2_make_threads(
	   togthreads2_simple_zparams([
		   [u * -thickness_u, 0],
			[u *  thickness_u, 0],
		], 0, 0),
		"1+1/4-7-UNC",
		r_offset = thread_r_offset,
		thread_origin_z = -thickness_u*u/2,
		$fn = $preview ? $fn : max($fn,48)
	),
]];

togmod1_domodule(
let(chunk = togridlib3_decode([1, "chunk"]))
["difference",
	tphl1_make_rounded_cuboid([
		block_size_chunks[0]*chunk+$tgx11_offset*2,
		block_size_chunks[1]*chunk+$tgx11_offset*2,
		thickness_u*u+$tgx11_offset*2
	], r=[
		3*u+$tgx11_offset,
		3*u+$tgx11_offset,
		1+$tgx11_offset
	], corner_shape="cone2"),
	
	for(yc=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2])
	for(xc=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2])
	["translate", [xc*chunk, yc*chunk], chunk_cavity],
]);
