// Threads2.30
// 
// New screw threads proto-library
// 
// v2.3:
// - Add 3/4-10-UNC to thread options
// - Separate inner/outer thread radius offsets,
//   with the inner one by default +0.3 and the outer -0.1.
// v2.4:
// - Add options for TOGridPile and hex cap
// - Add 3/8-16-UNC thread options
// v2.5:
// - Add 'v3' polyhedron generation algorithm, which is less
//   conceptually simple, but results in much fewer polygons
// - For now, the v3 threads don't taper, but togthreads2_mkthreads_v3
//   does have the option to make 'blunt' or 'flush' thread ends.
// v2.6:
// - outer_threads = "none" means no post
// v2.7:
// - Make 'v3' the default algorith, since it's faster
// v2.8:
// - Add 5/8-11-UNC, 7/8-9-UNC, and 1+1/8-7-UNC thread options
// v2.9:
// - togthreads2_mkthreads_v3 takes thread_origin_z parameter;
//   set to pitch/2 to match v2's thread phase
// - Allow customization of $tphl1_vertex_deduplication_enabled
// v2.10:
// - Fix calculation of bottom_z to never be less than zero
// - Change phase of v2 threads to match v3 (thread sticks out +x at z=origin)
// - Set thread origin = top of cap, if there is one
// v2.11:
// - Implement tapering via zparams for v3 threads
// - Align front edge of polygonal bases with X axis
// v2.12:
// - Add option for floor, and a hole through it
//   floor_thickness, floor_hole_threads
// v2.13:
// - Thread parameters now free-form
// - Allow arbitrary D-P-UNC and straight-Dmm (or other unit) to be used for floor hole
// - Outer/inner threads don't yet support straight threads
// v2.14:
// - Add 'description' parameter so you have a description that shows in customizer
// v2.15:
// - v2_15_test = 'b' (intend to remove along with deadened code for v2.16)
//   uses threads2__to_polyhedron in more places
// - cross_section option; when enabled, cuts out a quarter.
// v2.16:
// - More regular polygon head shapes, from triangle to nonagon
// v2.17:
// - Decagon head shape
// v2.18:
// - Internally, thread_polyhedron_algorithm is now $togthreads2_polyhedron_algorithm
// - Remove v2_15_test option
// - Have spec -> pitch / radius functions do something reasonable-ish for 'straight-d'
//   so that v2 (and some cases of v3)
// - Presets for nuts changed to say outer_threads = "none"
//   - Otherwise e.g. p1666 did weird things for v3!
// v2.20:
// - Put TGP bottom on both ends of head if tall enough
// - Option for headside holes, in case you want to make gridbeam.
//   (though you might want to make one longer than one chunk,
//   and ChunkBeam2 with an option for central threads might
//   be a better place for that).
// v2.21:
// - togridpile-chunk heads have a 0.4mm foot bevel
// v2.22:
// - togthreads2_thread_zparams now takes taper_length instead of
//   taking pitch and deriving it from that
// - Remove togthreads2_inner_thread_zparams, just use togthreads2_thread_zparams directly
// - Delete redundant part of make_the_hole_v2
// v2.23.1:
// - More explanation about what 'type23' means.
// v2.23.2:
// - threads2__to_polyhedron can use v2 or v3 algorithm
// - togthreads2_mkthreads_v2 accepts same parameters as togthreads2_mkthreads_v3,
//   automatically translating type23 into thread radius function
// - Type23 polypoints specified as always being in -Y to +Y order
//   so that lookup(z, polypoints) will work
// - standardize on terminology for different kinds of functions
// - reorganize to put 'type definitions' at top
// v2.23.3:
// - Fix togthreads2__type23_to_ptrfunc to clamp radius to >= min_radius
// - v2 tapering may still not quite match that of v3
// v2.23.4:
// - Fix v2 tapering to clamp between min/max radius adjusted by taper amount
// v2.23.5:
// - More assertions in quantity parsing
// v2.23.6:
// - threads2__to_polyhedron now handles 'none' thread type
// - Define threads2__get_default_taper_length to avoid threads2__get_thread_pitch
//   having to support non-thread cases
// - Delete some dead code
// v2.23.7:
// - Have inner threads' origin be at the top
// - Fix v2 thread generation by applying thread_origin_z in
//   togthreads2__ptrfunc_to_zprfunc instead of togthreads2__zpr_to_layers
// v2.24:
// - Rename some functions from "threads2_" to "togthreads2_"
// - 'threads2__to_polyhedron' is now 'togthreads2_make_threads'
// - double__underscore a few other function names to 'mark as private'
// v2.24.1
// - Also rename togthreads2_thread_zparams to togthreads2_simple_zparams
//   and rewrite its documentation.
// v2.25:
// - Extract thread generation to ../lib/TOGThreads2.scad
// v2.26:
// - Fix height of togridpile-chunk head
// v2.27:
// - Option for 'head M-holes' (head_mhole_diameter, head_mhole_spacing)
// v2.28:
// - Threads don't extend as deep into tall heads
// v2.30:
// - Support (via TOGThreads2.30) 'cylinder-zds:...' thread specs

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

// Put your comment about this preset here
description = "";

handedness = "right"; // ["right","left"]
// e.g. "straight-5mm", "1+1/4-7-UNC"
outer_threads = "1+1/4-7-UNC";
outer_thread_radius_offset = -0.1;
inner_threads = "1/2-13-UNC";
inner_thread_radius_offset =  0.3;
floor_thickness = 0; // 0.01
floor_threads = "3/8-16-UNC";
floor_thread_radius_offset =  0.3;
total_height = 19.05;

head_width   = 38.1;
head_height  =  6.35;
head_shape = "square"; // ["triangle","square","pentagon","hexagon","septagon","octagon","nonagon","decagon","togridpile-chunk"]
headside_threads = "none";
headside_thread_radius_offset =  0.3;
head_surface_offset = -0.1;

// Diameter of 'mounting holes' in head
head_mhole_diameter = 0; // 0.1
head_mhole_spacing = 32; // 0.1

thread_polyhedron_algorithm = "v3"; // ["v2", "v3"]

// This is here so I can see if disabling vertex deduplication speeds things up at all.
$tphl1_vertex_deduplication_enabled = false;
$fn = 32;

/* [Debugging/Testing] */

cross_section = false;

module __threads2_end_params() { }

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = head_surface_offset;
$togthreads2_polyhedron_algorithm = thread_polyhedron_algorithm;

the_post =
	let( spec = togthreads2__get_thread_spec(outer_threads) )
	let( taper_length = togthreads2__get_default_taper_length(spec) )
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2, head_height-1) )
	togthreads2_make_threads(
		togthreads2_simple_zparams([
			[bottom_z, bottom_z == 0 ? -1 : 0],
			[   top_z,                 -1    ],
		], taper_length),
		outer_threads, r_offset=outer_thread_radius_offset, end_mode="blunt", thread_origin_z = head_height
	);

the_hole =
	let( spec = togthreads2__get_thread_spec(inner_threads) )
	let( taper_length = togthreads2__get_default_taper_length(spec) )
	togthreads2_make_threads(
		togthreads2_simple_zparams([
			[floor_thickness, floor_thickness > 0 ? 0 : 1],
			[total_height   ,                           1],
		], taper_length),
		inner_threads, r_offset=inner_thread_radius_offset, end_mode="blunt", thread_origin_z = total_height
	);

the_floor_hole =
	floor_threads == "none" || floor_thickness == 0 ? ["union"] :
	togthreads2_make_threads([-1, floor_thickness+1], floor_threads, r_offset=floor_thread_radius_offset);

the_headside_holes =
	headside_threads == "none" ? ["union"] :
	// Could do a hole in every face, but for now just work for square heads.
	assert(head_shape == "square" || head_shape == "togridpile-chunk", "Head holes currently only implemented for square or togridpile-chunk heads")
	let(headside_hole = togthreads2_make_threads([-head_width/2, head_width/2], headside_threads, r_offset=headside_thread_radius_offset))
	["union",
		["translate", [0,0,head_height/2], ["rotate", [90,0,0], headside_hole]],
		["translate", [0,0,head_height/2], ["rotate", [0,90,0], headside_hole]],
	];

use <../lib/TOGVecLib0.scad>
use <../lib/TOGPath1.scad>

function make_rath_base(rath, height, r=0.6) =
	let(quarterfn=ceil($fn/4))
	let(r3=r+$tgx11_offset)
	tphl1_make_polyhedron_from_layer_function([
		for( a=[0:1:quarterfn] ) [     0 + r + r3 * sin(270 + a*90/quarterfn), -r + r3 * cos(270 + a*90/quarterfn)],
		for( a=[0:1:quarterfn] ) [height - r + r3 * sin(  0 + a*90/quarterfn), -r + r3 * cos(  0 + a*90/quarterfn)],
	], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_offset_rath(rath, zo[1])), zo[0]));

// r to chord = cos(angle/2) * r to point
// so r to point = r to chord / cos(angle/2)

function make_polygon_base(sidecount, width, height) =
	let( r1 = min(3, width/10) )
	let( r2 = min(0.6, r1/2) )
	let( c_to_c_r = width/2 / cos(360/sidecount/2) )
	echo(str("corner-to-center = ", c_to_c_r))
	make_rath_base(
		togpath1_make_polygon_rath(r=c_to_c_r, $fn=sidecount, corner_ops=[["round", r1]], rotation=90+180/sidecount),
		height, r=r2
	);

function make_togridpile_chunk_bottom(width,height) =
	tgx11_block_bottom([[width,"mm"],[width,"mm"],[height,"mm"]], segmentation = "chunk", foot_bevel = 0.4);

function make_togridpile_chunk(width,height) =
	let( bottom = make_togridpile_chunk_bottom(width,height) )
	["intersection",
		tphl1_extrude_polypoints([0-$tgx11_offset,height+$tgx11_offset], tgx11_chunk_xs_points(
			size = [width,width],
			offset = $tgx11_offset
		)),
		bottom,
		if( height >= 8 ) ["translate", [0,0,height], ["rotate",[180,0,0],bottom]],
	];

function make_base(shape, width, height) =
	height <= 0 || width <= 0 ? ["union"] :
	shape == "triangle" ? make_polygon_base(  3, width, height ) :
	shape == "square"   ? make_polygon_base(  4, width, height ) :
	shape == "pentagon" ? make_polygon_base(  5, width, height ) :
	shape == "hexagon"  ? make_polygon_base(  6, width, height ) :
	shape == "septagon" ? make_polygon_base(  7, width, height ) :
	shape == "octagon"  ? make_polygon_base(  8, width, height ) :
	shape == "nonagon"  ? make_polygon_base(  9, width, height ) :
	shape == "decagon"  ? make_polygon_base( 10, width, height ) :
	shape == "togridpile-chunk" ? make_togridpile_chunk(width,height) :
	assert(false, str("Unsupported head shape: '", shape, "'"));

the_cap = make_base(head_shape, head_width, head_height);

the_head_mholes =
	let( cir=togmod1_make_circle(d=head_mhole_diameter) )
	togmod1_linear_extrude_z([-1,100],
		["union",
			for(xm=[-1,1]) for(ym=[-1,1]) ["translate", [xm*head_mhole_spacing/2,ym*head_mhole_spacing/2], cir]
		 ]
	);

togmod1_domodule(["difference",
	["union",
		the_post,
		the_cap
	],
	the_hole,
	the_floor_hole,
	the_headside_holes,
	if(cross_section) ["translate", [50,50], tphl1_make_rounded_cuboid([100,100,200], r=0, $fn=1)],
	the_head_mholes,
]);

// # cylinder(d=10, h=total_height);
