// Threads2.15
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
// 
// TODO: Maybe thread_polyhedron_algorithm should be $thread_polyhedron_algorithm
// TODO: Have threads2__to_polyhedron support generating using v2 algorithm
// TODO: threads2__to_polyhedron could support spec = 'none'.
// TODO: Update v2 to do tapering using same parameters as v3, remove taper_function.
//       Use OpenSCAD's built-in `lookup(z, [[z0, v0], ...])` function!
// TODO: Rename some functions, e.g. threads2__to_polyhedron maybe should be public
//       and named, uhm...something that hints at the inputs.
// TODO: Extract high-level functions to library

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>

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
head_shape = "square"; // ["square","hexagon","togridpile-chunk"]
head_surface_offset = -0.1;
thread_polyhedron_algorithm = "v3"; // ["v2", "v3"]

// This is here so I can see if disabling vertex deduplication speeds things up at all.
$tphl1_vertex_deduplication_enabled = false;
$fn = 32;

/* [Debugging/Testing] */
// Use old (a) or new (b) code path for polyhedron generation (assumes v3 algorithm)
v2_15_test = "b"; // ["a","b"]
cross_section = false;

module __threads2_end_params() { }

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = head_surface_offset;

// [[z, param], ...] -> [[z, angle, param], ...]
// Also supports just [z0, ..., zn] as input
// Interpolating param for each actual layer.
// TODO: Actually calculate that third parameter!
function togthreads2_layer_params( zparams, pitch ) =
	let( layer_height = pitch/$fn )
	let( zparams1 = [
		for( zp = zparams )
			is_num(zp) ? [zp,zp] :
			is_list(zp) ? zp :
			assert(false, str("Expected number or list for Z parameters, got ", zp))
	] )
	[
		for( z=[zparams1[0][0] : layer_height : zparams1[len(zparams1)-1][0]] ) [z, z*360/pitch, undef] // TODO: calculate that extra parammeter
	];

function togthreads2__to_list(x) = [for(i=x) i];

// rfunc :: z -> phase (0...1) -> r|[x,y]|[x,y,z]
function togthreads2_zp_to_layers(zs, rfunc, thread_origin_z=0) =
	assert( len(togthreads2__to_list(zs)) >= 2 )
	let($fn = max(3, $fn))
	let(fixpoint = function(n, p, z)
		is_num(n) ? [cos(p*360)*n, sin(p*360)*n, z] :
		is_list(n) && len(n) == 1 ? fixpoint(n[0], p, z) :
		is_list(n) && len(n) == 2 ? [n[0], n[1], z] :
		is_list(n) && len(n) == 3 ? n :
		assert(false, str("Rfunc should return 1..3 values, but it returned ", n)))
	[
		for( z=zs ) [
			for( p=[0:1:$fn-1] ) fixpoint(rfunc(z - thread_origin_z, p/$fn), p/$fn, z)
		]
	];

// TODO: Instead of just accepting a z range,
// accept a list of [z, param],
// and interpolate param values between Zs.
// TODO: Remove taper_function
togthreads2_mkthreads_v1 = function( zparams, pitch, radius_function, direction="right", taper_function=function(z) 1, r_offset=0 )
	let( $fn = max(3, $fn) )
	let( $tphl1_quad_split_direction = direction )
	tphl1_make_polyhedron_from_layer_function(
		togthreads2_layer_params(zparams, pitch),
		function(za)
			togvec0_offset_points(
				[
					for( j = [0:1:$fn-1] )
					let( a = 360 * j / $fn )
					let( t_raw = (za[1] + a * (direction == "right" ? -1 : 1)) / 360 )
					let( t = t_raw - floor(t_raw) )
					let( r = radius_function(t, taper_function(za[0])) + r_offset )
					[r * cos(a), r * sin(a)]
				],
				za[0]
			)
	);

function togthreads2_threadradfunc_to_zpfunc(trfunc, pitch, direction="right", taper_function=function(z) 1, r_offset=0) =
	function(z,p)
		let(t_raw = p + z * (direction == "right" ? -1 : 1) / pitch)
		let(t = t_raw - floor(t_raw))
		trfunc(t, taper_function(z)) + r_offset;

// V2: Based on the idea of using a function like z -> phase -> r
// to make it simpler to transform r at a given z
togthreads2_mkthreads_v2 = function( zrange, pitch, radius_function, direction="right", taper_function=function(z) 1, r_offset=0, thread_origin_z=0 )
	let( layer_height = pitch/$fn )
	let( layers = togthreads2_zp_to_layers(
		[zrange[0] : layer_height : zrange[1]],
		togthreads2_threadradfunc_to_zpfunc(radius_function, pitch, direction, taper_function=taper_function, r_offset=r_offset),
		thread_origin_z = thread_origin_z
	) )
	tphl1_make_polyhedron_from_layers(layers);

togthreads2_mkthreads = togthreads2_mkthreads_v2;

function togthreads2__clamp(x, lower, upper) = min(upper, max(lower, x));

// 0 -> 0, 0.5 -> 1, 1 -> 0
function togthreads2__ridge(t) =
	let( trem = t - floor(t) )
	let( dtrem = trem * 2 )
	dtrem > 1 ? 2 - dtrem : dtrem;

// basic_diameter = inches
// pitch = threads per inch
function togthreads2_unc_external_thread_radius_function(basic_diameter, tpi, side="external", meth="orig") =
	// Based on
	// https://www.machiningdoctor.com/charts/unified-inch-threads-charts/#formulas-for-basic-dimensions
	// https://www.machiningdoctor.com/wp-content/uploads/2022/07/Unfied-Thread-Basic-Dimensions-External.png?ezimgfmt=ng:webp/ngcb1
	// 
	// It looks like the formulas for internal/external threads are the same
	// except that the inner/outer flattening is inverted.
	// 
	// TODO: This seems like it might be wrong.  Figure out and fix.
	let( d = basic_diameter*25.4 )
	let( P = 25.4/tpi )
	let( H = P * sqrt(3)/2 ) // difference in radius between unclamped min and max
	let( hs = H*5/8 )
	let( has = H*3/8 )
	let( han = H*1/4 )
	let( r = d/2 )
	let( r2 = r - has ) // Mid point
	let( r0 = r2 - H/2 ) // unclamped min radius
	// let( r1 = r - hs )
	let( rmin = r2 - han )
	let( rmax = r2 + has )
	function(t, trat=1)
		let( x = t*2 )
		togthreads2__clamp(
		   r0 + trat*H/2 + H*togthreads2__ridge(t - 0.5),
			rmin, rmax
		);

function togthreads2_demo_thread_radius_function(diam,pitch) =
	function(t, trat=0) max(9, min(10, 9 + trat + (0.5 + 2 * ((2*abs(t-0.5))-0.5)) ));;

////

function togthreads2__zparam_to_z(zp) =
	is_list(zp) ? zp[0] :
	is_num(zp) ? zp :
	assert(false, str("Expected [z,t] or z for zparam, got ", zp, "'"));

function togthreads2__zparam_to_t(zp) =
	is_list(zp) ? zp[1] :
	is_num(zp) ? 0 :
	assert(false, str("Expected [z,t] or z for zparam, got ", zp, "'"));

function togthreads2__zparams_to_zrange(zparams) =
	assert( is_list(zparams) && len(zparams) >= 2, str("zparams must be list of length >= 2; got ", zparams) )
	[togthreads2__zparam_to_z(zparams[0]), togthreads2__zparam_to_z(zparams[len(zparams)-1])];

function togthreads2__normalize_zparams(zparams) =
	[ for(zp=zparams) is_list(zp) ? zp : is_num(zp) ? [zp, 0] : assert(false, str("Expected [z,t] or z for zparam, got ", zp, "'")) ];

// Type23 = ["togthreads2.3-type", pitch, cross_section_polypoints, min_radius, max_radius]

// zparams: [z0, z1] (z range) or [[z0, t0], ...., [zn, tn]] (z,t control points, where t = -1..1)
// type23: a Type23 thread spec
// direction: "right" or "left"-handed threads
// r_offset: radial vertex offset
// end_mode:
// - "blunt" to have threads end abruptly when the center reaches the end of the zrange
//   - You probably want this for outer threads
// - "flush" to have threads continue all the way to the end
//   - You probably want this for inner threads
function togthreads2_mkthreads_v3(zparams, type23, direction="right", r_offset=0, end_mode="flush", thread_origin_z=0) =
	assert( !is_undef(r_offset) )
	assert( is_list(type23) )
	let( zrange = togthreads2__zparams_to_zrange(zparams) )
	let( zps = togthreads2__normalize_zparams(zparams) )
	assert( zrange[1] > zrange[0] )
	assert( is_num(type23[1]) )
	assert( is_list(type23[2]) )
	assert( is_num(type23[3]) )
	assert( is_list(type23) && type23[0] == "togthreads2.3-type" )
	let( reverse = function(arr) [ for(i=[len(arr)-1 : -1 : 0]) arr[i]] )
	let( pitch = type23[1] )
	assert( pitch < 99999, str("[Effectively] infinite pitch: ", pitch) )
	let( xspolypoints = direction == "right" ? reverse(type23[2]) : type23[2] )
	let( min_radius = type23[3] )
	let( max_radius = type23[4] )
	echo( ceil(zrange[1]-zrange[0])*$fn/pitch )
	let( thread_zrange = end_mode == "blunt" ? zrange : [zrange[0]-pitch/2, zrange[1]+pitch/2] )
	assert(thread_zrange[1] > thread_zrange[0])
	// layer_count = total number of layers, including both the top and bottom;
	// i.e. this is the 'fencepost count'
	let( layer_count = ceil((thread_zrange[1]-thread_zrange[0])*$fn/pitch) + 1 )
	assert(layer_count >= 2, str(
		"Must have at least 2 layers",
		"; layer_count = ", layer_count,
		"; total height = ", thread_zrange[1] - thread_zrange[0],
		"; $fn = ", $fn,
		"; pitch = ", pitch,
		"; $fn/pitch = ", $fn/pitch,
		"; height * $fn/pitch = ", (thread_zrange[1]-thread_zrange[0])*$fn/pitch
	))
	let( outer_zds = [
		for(zp=zps) let(outer_r = r_offset + max_radius + min(0, zp[1]) * (max_radius-min_radius)) [zp[0], outer_r*2]
	])
	let( inner_zds = [
		let(zp=zps[0]         ) let(inner_r = r_offset + min_radius + max(0, zp[1]) * (max_radius-min_radius)) [zp[0]-10, inner_r*2],
		for(zp=zps            ) let(inner_r = r_offset + min_radius + max(0, zp[1]) * (max_radius-min_radius)) [zp[0], inner_r*2],
		let(zp=zps[len(zps)-1]) let(inner_r = r_offset + min_radius + max(0, zp[1]) * (max_radius-min_radius)) [zp[0]+10, inner_r*2],
	])
	["intersection",
		tphl1_make_z_cylinder(zds=outer_zds),
		["union",
			tphl1_make_polyhedron_from_layer_function(
				[
					for( i=[0 : 1 : layer_count-1] ) let( z=thread_zrange[0] + (thread_zrange[1]-thread_zrange[0])*i/layer_count )
					[ z, (direction == "right" ? 1 : -1) * 360 * (z - thread_origin_z)/pitch ]
				],
				function( za ) let(ang=za[1]) let(sina = sin(ang), cosa = cos(ang)) [
					for( pp=xspolypoints ) let( ppx = pp[0] + r_offset, ppy = za[0] + pp[1] ) [cosa*ppx, sina*ppx, ppy]
				]
			),
			if(min_radius > 0) tphl1_make_z_cylinder(zds=inner_zds),
		]
	];

function togthreads2_demo_to_type23(diam, pitch) =
	let( outer_r = diam/2 )
	let( bev = pitch/3 )
	let( inner_r = outer_r - bev )
	["togthreads2.3-type", pitch, [[outer_r,pitch/8], [inner_r,pitch/8+bev], [inner_r,-pitch/8-bev], [outer_r,-pitch/8]], outer_r-pitch/4, outer_r];

function togthreads2_unc_to_type23(basic_diameter, tpi) =
	// Based on
	// https://www.machiningdoctor.com/charts/unified-inch-threads-charts/#formulas-for-basic-dimensions
	// https://www.machiningdoctor.com/wp-content/uploads/2022/07/Unfied-Thread-Basic-Dimensions-External.png?ezimgfmt=ng:webp/ngcb1
	// 
	// It looks like the formulas for internal/external threads are the same
	// except that the inner/outer flattening is inverted.
	assert( is_num(basic_diameter), str("basic_diameter must be a number; got ", basic_diameter) )
	assert( is_num(tpi), str("TPI must be a number; got ", tpi) )
	assert( tpi < 99999, str("TPI suspiciously large: ", tpi) )
	assert( tpi > 0, str("Non-positive TPI: ", tpi) )
	let( d = basic_diameter*25.4 )
	let( P = 25.4/tpi )
	let( H = P * sqrt(3)/2 ) // difference in radius between unclamped min and max
	let( hs = H*5/8 )
	let( has = H*3/8 )
	let( han = H*1/4 )
	let( r = d/2 )
	let( r2 = r - has ) // Mid point
	let( r0 = r2 - H/2 ) // unclamped min radius
	// let( r1 = r - hs )
	let( rmint= r2 - has )
	let( rmin = r2 - han )
	let( rmax = r2 + has )
	["togthreads2.3-type", P, [[rmax, P/16], [rmint, P*7/16], [rmint, -P*7/16], [rmax, -P/16]], rmin, d/2];

////

threads2_thread_types = [
	["threads2-demo", ["demo", 20, 5]],
	["#6-32-UNC", ["unc", 0.138, 32]],
	["#8-32-UNC", ["unc", 0.168, 32]],
];

use <../lib/TOGStringLib1.scad>
use <../lib/TOGridLib3.scad>

function threads2__parse_num(feh, index=0) =
	let(ratr = togstr1_parse_rational_number(feh, index))
	ratr[1] == index ? [undef, index] :
	let(rn = ratr[0])
	let(num = rn[0] / rn[1])
	assert(is_num(num))
	[num, ratr[1]];

function threads2__decode_num(feh) =
	let(numr = threads2__parse_num(feh))
	assert(numr[1] > 0, str("Failed to parse rational number from '", feh, "'"))
	numr[0];

function threads2__decode_dim(feh) =
	let(qr = togstr1_parse_quantity(feh))
	let(rq = qr[0])
	togridlib3_decode([rq[0][0], rq[1]]) / rq[0][1];

function threads2__get_thread_spec(name, index=0) =
	threads2_thread_types[index][0] == name ? threads2_thread_types[index][1] :
	index+1 < len(threads2_thread_types) ? threads2__get_thread_spec(name, index+1) :
	let( kq = togstr1_tokenize(name, "-", 3) )
	kq[0] == "straight" ? ["straight-d", threads2__decode_dim(kq[1])] :
	let(uncdiam =
		len(kq) == 3 && kq[2] == "UNC" ?	let( diamr = threads2__parse_num(kq[0]) ) diamr[0] :
		undef
	)
	is_num(uncdiam) ? ["unc", uncdiam, threads2__decode_num(kq[1])] :
	assert(false, str("Failed to parse thread spec ''", name, "' (not in list or recognized format)"));

function threads2__get_thread_pitch(spec) =
	is_string(spec) ? threads2__get_thread_pitch(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc" ? 25.4 / spec[2] :
	is_list(spec) && spec[0] == "demo" ? spec[2] :
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__get_thread_radius_function(spec) =
	is_string(spec) ? threads2__get_thread_radius_function(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2_unc_external_thread_radius_function(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2_demo_thread_radius_function(spec[1], spec[2]) :
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__get_thread_type23(spec) = 
	is_string(spec) ? threads2__get_thread_type23(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2_unc_to_type23(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2_demo_to_type23(spec[1], spec[2]) :
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__to_polyhedron(zparams, spec, r_offset=0, end_mode="flush", thread_origin_z=0) =
	let( spec1 = is_string(spec) ? threads2__get_thread_spec(spec) : spec )
	let( zrange = togthreads2__zparams_to_zrange(zparams) )
	spec1[0] == "straight-d" ? tphl1_make_z_cylinder(zrange=zrange, d=spec1[1]+r_offset) :
	assert(thread_polyhedron_algorithm == "v3", "threads2__to_polyhedron only supports v3 currently")
	let( type23 = threads2__get_thread_type23(spec1) )
	togthreads2_mkthreads_v3(zparams, type23,
		r_offset = r_offset,
		end_mode = end_mode,
		thread_origin_z = thread_origin_z
	);

/**
 * Generate zparams for threads with ends tapered appropriately
 * given the pitch and whether the bottom and/or top is open
 * (taper = -1 or +1 for external/internal threads) or closed (taper = 0).
 *
 * Assumes that positive taper means inner threads, and will extend
 * a bit beyond the end.
 *
 * end_zts = [[bottom_z, bottom_taper], [top_z, top_taper]]
 */
function togthreads2_thread_zparams(end_zts, pitch) =
	let( z0 = end_zts[0][0], z1 = end_zts[1][0] )
	let( t0 = end_zts[0][1], t1 = end_zts[1][1] )
	let( taper_amt = 1 )
	[
		each t0 == 0 ? [
			[z0        ,  0],
		] : [
			if( t0 > 0 )
			[z0-1      , t0],
			[z0        , t0],
			[z0+pitch/2,  0],
		],
		each t1 == 0 ? [
			[z1        ,  0],
		] : [
			[z1-pitch/2,  0],
			[z1        , t1],
			if( t1 > 0 )
			[z1+1      , t1],
		],
	];


// Generate zparams for threads with ends tapered appropriately
// depending on whether they are open or closed.
// 
// outer_zrange = exact Z position of [bottom, top] of object to be subtracted from.
// inner_zrange = exact Z position of [botton, top] of hole.
// spec = thread spec of the inner threads
// 
// this function will automatically extend zrange and adjust taper
// depending if inner hole extends beyond outer hole on bottom and top.
// 
// TODO: Probably change to use [[bottom_z, bottom_is_open], [top_z, top_is_open]] or something
// Maybe just use taper_amt to indicate open/closedness; then this could be used for outer threads, too.
// 
// TODO: Delete; use togthreads2_thread_zparams directly.
function togthreads2_inner_thread_zparams(outer_zrange, inner_zrange, spec) =
	togthreads2_thread_zparams([
		[inner_zrange[0], inner_zrange[0] <= outer_zrange[0] ? 1 : 0],
		[inner_zrange[1], inner_zrange[1] >= outer_zrange[1] ? 1 : 0],
	], threads2__get_thread_pitch(spec));
	/*
	let( oz0 = outer_zrange[0], oz1 = outer_zrange[1] )
	let( iz0 = inner_zrange[0], iz1 = inner_zrange[1] )
	let( taper_amt = 1 )
	let( pitch = threads2__get_thread_pitch(spec) )
	[
		each iz0 <= oz0 ? [
			[iz0-1      , taper_amt],
			[iz0        , taper_amt],
			[iz0+pitch/2,         0],
		] : [
			[iz0        ,         0],
		],
		each iz1 >= oz1 ? [
			[iz1-pitch/2,         0],
			[iz1        , taper_amt],
			[iz1+1      , taper_amt],
		] : [
			[iz1        ,         0],
		],
	];
	*/

function make_the_post_v2() =
	total_height <= head_height || outer_threads == "none" ? ["union"] :
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2) )
	let( taper_length = 2 )
	let( specs = threads2__get_thread_spec(outer_threads) )
	let( pitch = threads2__get_thread_pitch(specs) )
	let( rfunc = threads2__get_thread_radius_function(specs) )
	togthreads2_mkthreads([bottom_z, top_z], pitch, rfunc,
		taper_function = function(z) 0 - max(0, (z - (top_z - taper_length))/taper_length),
		r_offset = outer_thread_radius_offset,
		thread_origin_z = head_height
	);

function make_the_post_v3a() =
	total_height <= head_height || outer_threads == "none" ? ["union"] :
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2) )
	// let( type23 = ["togthreads2.3-type", 10, [[12,0],[10,2],[8,0],[10,-2]], 10.1] )
	let( type23 = threads2__get_thread_type23(outer_threads) )
	let( pitch = type23[1] )
	togthreads2_mkthreads_v3(
		[
			each bottom_z == 0 ? [[bottom_z, -1], [bottom_z+pitch/2, 0]] : [[bottom_z, 0]],
			[top_z-pitch/2, 0], [top_z, -1]
		],
		type23,
		r_offset = outer_thread_radius_offset,
		end_mode = "blunt",
		thread_origin_z = head_height
	);

function make_the_post_v3b() =
	outer_threads == "none" ? ["union"] :
	let( spec = threads2__get_thread_spec(outer_threads) )
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2) )
	threads2__to_polyhedron(
		togthreads2_thread_zparams([
			[bottom_z, bottom_z == 0 ? -1 : 0],
			[   top_z,                 -1    ],
		], threads2__get_thread_pitch(spec)),
		outer_threads, r_offset=outer_thread_radius_offset, end_mode="blunt", thread_origin_z = head_height
	);

	// TODO: Use threads2__to_polyhedron
	// TODO: Make sure straight and none work
/*
	total_height <= head_height || outer_threads == "none" ? ["union"] :
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2) )
	// let( type23 = ["togthreads2.3-type", 10, [[12,0],[10,2],[8,0],[10,-2]], 10.1] )
	let( type23 = threads2__get_thread_type23(outer_threads) )
	let( pitch = type23[1] )
	togthreads2_mkthreads_v3(
		[
			each bottom_z == 0 ? [[bottom_z, -1], [bottom_z+pitch/2, 0]] : [[bottom_z, 0]],
			[top_z-pitch/2, 0], [top_z, -1]
		],
		type23,
		r_offset = outer_thread_radius_offset,
		end_mode = "blunt",
		thread_origin_z = head_height
	);
*/

the_post =
	thread_polyhedron_algorithm == "v2" ? make_the_post_v2() :
	v2_15_test == "a" ? make_the_post_v3a() :
	make_the_post_v3b();

the_hole_a =
	inner_threads == "none" ? ["union"] :
	let( spec = threads2__get_thread_spec(inner_threads) )
	let( bottom_z = floor_thickness )
	let( top_z = total_height )
	let( taper_amt = 1 )
	thread_polyhedron_algorithm == "v2" ? (
		let( taper_length = 4 )
		let( pitch = threads2__get_thread_pitch(spec) )
		let( rfunc = threads2__get_thread_radius_function(spec) )
		togthreads2_mkthreads([bottom_z-1, top_z+1], pitch, rfunc,
			taper_function = function(z) taper_amt * max(1-z/taper_length, 0, 1 - (top_z-z)/taper_length),
			r_offset = inner_thread_radius_offset
		)
	) : (
		let( type23 = threads2__get_thread_type23(inner_threads) )
		let( pitch = type23[1] )
		togthreads2_mkthreads_v3(
			togthreads2_inner_thread_zparams([0, top_z], [bottom_z, top_z], spec),
			type23, r_offset = inner_thread_radius_offset
		)
	);

the_hole = (thread_polyhedron_algorithm == "v2" || v2_15_test == "a") ? the_hole_a :
	inner_threads == "none" ? ["union"] :
	// the_hole_b:
	let( spec = threads2__get_thread_spec(inner_threads) )
	threads2__to_polyhedron(togthreads2_inner_thread_zparams([0, total_height], [floor_thickness, total_height], spec), inner_threads, r_offset=inner_thread_radius_offset);	

the_floor_hole =
	floor_threads == "none" || floor_thickness == 0 ? ["union"] :
	threads2__to_polyhedron([-1, floor_thickness+1], floor_threads, r_offset=floor_thread_radius_offset);

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

function make_base(shape, width, height) =
	height <= 0 || width <= 0 ? ["union"] :
	shape == "square" ? make_polygon_base(4,width,height) :
	shape == "hexagon" ? make_polygon_base(6,width,height) :
	shape == "togridpile-chunk" ? tgx11_block([[width,"mm"],[width,"mm"],[height,"mm"]], lip_height=0, bottom_segmentation = "chunk") :
	assert(false, str("Unsupported head shape: '", shape, "'"));

the_cap = make_base(head_shape, head_width, head_height);

togmod1_domodule(["difference",
	["union",
		the_post,
		the_cap
	],
	the_hole,
	the_floor_hole,
	
	if(cross_section) ["translate", [50,50], tphl1_make_rounded_cuboid([100,100,200], r=0, $fn=1)],
]);

// # cylinder(d=10, h=total_height);
