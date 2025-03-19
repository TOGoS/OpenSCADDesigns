// ThreadConnector2.2
// 
// Double-headed bolt
// 
// Versions:
// v2.0:
// - Created based on Threads2.25
// v2.1:
// - More 'reasonable' defaults
// v2.2:
// - thread_radius_offset options

lower_outer_threads = "1+1/4-7-UNC";
lower_outer_thread_radius_offset = -0.1;
lower_outer_thread_height   = 15.875; // 0.01
upper_outer_threads = "1+1/4-7-UNC";
upper_outer_thread_radius_offset = -0.1;
upper_outer_thread_height   = 15.875; // 0.01
inner_threads = "3/4-10-UNC";
inner_thread_radius_offset = 0.1;
ring_width      = 38.1 ; // 0.01
ring_height     =  6.35; // 0.01
ring_side_count =  8;

/* [Detail] */

preview_fn = 24;
render_fn = 48;

/* [Debugging/Testing] */

cross_section_z0   = 999; // 0.1

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

module __threads2_end_params() { }

$fn = $preview ? preview_fn : render_fn;

$tphl1_vertex_deduplication_enabled = false;
$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = -0.1;
$togthreads2_polyhedron_algorithm = "v3";

function make_rath_ring(rath, height, depth, r=0.6) =
	let(quarterfn=ceil($fn/4))
	let(r3=r+$tgx11_offset)
	tphl1_make_polyhedron_from_layer_function([
		//for( a=[0:1:quarterfn] ) [     0 + r + r3 * sin(270 + a*90/quarterfn), -r + r3 * cos(270 + a*90/quarterfn)],
		[-height/2 - depth, 0, 0],
		[-height/2        , 0, 1],
		for( a=[0:1:quarterfn] ) [height/2 - r + r3 * sin(  0 + a*90/quarterfn), -r + r3 * cos(  0 + a*90/quarterfn), 1],
	], function(zom)
		let(z=zom[0], o=zom[1], m=zom[2])
		[
			for(p=togpath1_rath_to_polypoints(togpath1_offset_rath(rath, o))) [p[0]*m, p[1]*m, z]
		]
	);

function make_polygon_ring(sidecount, width, height) =
	let( r1 = min(3, width/10) )
	let( r2 = min(0.6, r1/2) )
	let( c_to_c_r = width/2 / cos(360/sidecount/2) )
	echo(str("corner-to-center = ", c_to_c_r))
	make_rath_ring(
		togpath1_make_polygon_rath(r=c_to_c_r, $fn=sidecount, corner_ops=[["round", r1]], rotation=90+180/sidecount),
		height, width/3, r=r2
	);

togmod1_domodule(
	let( the_ring = make_polygon_ring( ring_side_count, ring_width, ring_height ) )
	let( the_lower_outer_threads = togthreads2_make_threads(togthreads2_simple_zparams([
		[ -ring_height/2 - lower_outer_thread_height, -1],
		[ -ring_height/4                            ,  0],
	], 5), lower_outer_threads, r_offset=lower_outer_thread_radius_offset) )
	let( the_upper_outer_threads = togthreads2_make_threads(togthreads2_simple_zparams([
		[  ring_height/4                            ,  0],
		[  ring_height/2 + upper_outer_thread_height, -1],
	], 5), upper_outer_threads, r_offset=upper_outer_thread_radius_offset) )
	let( the_inner_threads = togthreads2_make_threads(togthreads2_simple_zparams([
		[ -ring_height/2 - upper_outer_thread_height,  1],
		[  ring_height/2 + upper_outer_thread_height,  1],
	], 5), inner_threads, r_offset=inner_thread_radius_offset) )
	["difference",
		["union",
			the_lower_outer_threads,
			the_upper_outer_threads,
			the_ring
		],
		the_inner_threads,
		["translate", [50,50,cross_section_z0+100], tphl1_make_rounded_cuboid([100,100,200], r=0, $fn=1)],
	]
);
