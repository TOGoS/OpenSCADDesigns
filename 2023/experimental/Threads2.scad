// Threads2.23.3
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
//
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
head_shape = "square"; // ["triangle","square","pentagon","hexagon","septagon","octagon","nonagon","decagon","togridpile-chunk"]
headside_threads = "none";
headside_thread_radius_offset =  0.3;
head_surface_offset = -0.1;
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

//// On 'thread Z origin'

// Threads stick out to the right at z = thread_origin_z.
// Since v2 specifies ridge at phase = 0.5 and groove at 0 and 1,
// that means that phase = z / pitch - floor(z / pitch) + 0.5

//// Type definitions

// ptrfunc = PhaseTaperRadiusFunction = (phase, taper) -> radius
// zprfunc = ZPhaseRadiusFunction     = (z, phase) -> radius

// Translate a Z offset into the appropriate phase, given pitch, handedness, and phase offset
// - z = Z position at which to sample
// - pitch = Z distance between threads
// - phase_offset = additional phase offset
// - zmul = -1 for right-handed threads, +1 for left-handed
function togthreads2__z_to_phase(z, pitch, phase_offset=0, zmul=-1) =
	let(phase_raw = 0.5 + phase_offset + z * zmul / pitch)
	phase_raw - floor(phase_raw);

// Turn a PhaseTaperRadiusFunction into a ZPhaseRadiusFunction.
function togthreads2__ptrfunc_to_zprfunc(ptrfunc, pitch, direction="right", taper_function=function(z) 1, r_offset=0) =
	let( zmul = direction == "right" ? -1 : 1 )
	function(z,phase_offset)
		r_offset + ptrfunc(
		   togthreads2__z_to_phase(z, pitch, phase_offset=phase_offset, zmul=zmul),
			taper_function(z)
		);

// Type23 = ["togthreads2.3-type", pitch, cross_section_polypoints, min_radius, max_radius]
// Where:
// - pitch = distance between threads
// - cross_section_polypoints = points of a polygon centered at y=0, x=min_radius
//   that represents the vertical shape of the threads; must be listed from -y to +y
//   so that they can be used by lookup(z, polypoints)
// - min_radius = radius of solid center section of bolt
// - max_radius = radius of hole (probably = half the nominal diameter of the bolt)

function togthreads2_type23_pitch(type23) = type23[1];
function togthreads2_type23_polypoints(type23) = type23[2];
function togthreads2_type23_min_radius(type23) = type23[3];
function togthreads2_type23_max_radius(type23) = type23[4];

function togthreads2__type23_to_ptrfunc(type23) =
	let( pitch      = togthreads2_type23_pitch(type23)      )
	let( polypoints = togthreads2_type23_polypoints(type23) )
	let( min_radius = togthreads2_type23_min_radius(type23) )
	let( max_radius = togthreads2_type23_max_radius(type23) )
	let( remapped = [[-10, 0], for(p=polypoints) [p[1]/pitch + 0.5, p[0]], [11, 0]] )
	function(phase, t=0) max(min_radius, lookup(phase, remapped)) + t*(max_radius-min_radius); // TODO put back


function togthreads2__to_list(x) = [for(i=x) i];

// v2 layer-generation
// rfunc :: z -> phase (0...1) -> r|[x,y]|[x,y,z]
function togthreads2__zpr_to_layers(zs, zprfunc, thread_origin_z=0) =
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
			for( p=[0:1:$fn-1] ) fixpoint(zprfunc(z - thread_origin_z, p/$fn), p/$fn, z)
		]
	];

// V2: Based on the idea of using a function like z -> phase -> r
// to make it simpler to transform r at a given z
function togthreads2_mkthreads_v2(zparams, type23, direction="right", r_offset=0, end_mode="flush", thread_origin_z=0) =
//function( zparams, type23, direction="right", r_offset=0, thread_origin_z=0 )
	let( pitch = type23[1] )
	let( ptrfunc = togthreads2__type23_to_ptrfunc(type23) )
	let( zrange = [zparams[0][0], zparams[len(zparams)-1][0]] )
	let( layer_height = pitch/$fn )
	let( taper_function = function(z) 0 /* lookup(z, zparams) */ ) // TODO Put back
	let( layers = togthreads2__zpr_to_layers(
		[zrange[0] : layer_height : zrange[1]],
		zprfunc = togthreads2__ptrfunc_to_zprfunc(ptrfunc, pitch, direction, taper_function=taper_function, r_offset=r_offset),
		thread_origin_z = thread_origin_z
	) )
	tphl1_make_polyhedron_from_layers(layers);

function togthreads2__clamp(x, lower, upper) = min(upper, max(lower, x));

// 0 -> 0, 0.5 -> 1, 1 -> 0
function togthreads2__ridge(t) =
	let( trem = t - floor(t) )
	let( dtrem = trem * 2 )
	dtrem > 1 ? 2 - dtrem : dtrem;

// basic_diameter = inches
// pitch = threads per inch
function togthreads2_unc_external_ptrfunc(basic_diameter, tpi, side="external", meth="orig") =
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
	function(phase, trat=1)
		let( x = t*2 )
		togthreads2__clamp(
		   r0 + trat*H/2 + H*togthreads2__ridge(phase - 0.5),
			rmin, rmax
		);

function togthreads2_demo_ptrfunc(diam, pitch) =
	function(phase, trat=0) max(9, min(10, 9 + trat + (0.5 + 2 * ((2*abs(phase-0.5))-0.5)) ));;

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
	let( pitch = togthreads2_type23_pitch(type23) )
	assert( pitch < 99999, str("[Effectively] infinite pitch: ", pitch) )
	let( polypoints = togthreads2_type23_polypoints(type23) )
	let( xspolypoints = direction == "right" ? reverse(polypoints) : polypoints )
	let( min_radius = togthreads2_type23_min_radius(type23) )
	let( max_radius = togthreads2_type23_max_radius(type23) )
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
	["togthreads2.3-type", pitch, [[inner_r,-pitch/8-bev], [outer_r,-pitch/8], [outer_r,pitch/8], [inner_r,pitch/8+bev]], outer_r-pitch/4, outer_r];

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
	["togthreads2.3-type", P, [[rmint, -P*7/16], [rmax, -P/16], [rmax, P/16], [rmint, P*7/16]], rmin, r];

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
	is_list(spec) && spec[0] == "straight-d" ? spec[1] : // Hack.  Straight doesn't have a pitch!
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__get_ptrfunc(spec) =
	is_string(spec) ? threads2__get_ptrfunc(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2_unc_external_ptrfunc(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2_demo_ptrfunc(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "straight-d" ? function(x, trat=1) spec[1]/2 + trat*spec[1]/8 : // Hack.
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__get_thread_type23(spec) = 
	is_string(spec) ? threads2__get_thread_type23(threads2__gegt_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2_unc_to_type23(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2_demo_to_type23(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "straight-d" ? ["togthreads2.3-type", spec[1], [], spec[1]*3/8, spec[1]*5/8] : // Hack.
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__to_polyhedron(zparams, spec, r_offset=0, direction="right", end_mode="flush", thread_origin_z=0) =
	let( spec1 = is_string(spec) ? threads2__get_thread_spec(spec) : spec )
	let( zrange = togthreads2__zparams_to_zrange(zparams) )
	spec1[0] == "straight-d" ? tphl1_make_z_cylinder(zrange=zrange, d=spec1[1]+r_offset) :
	// assert($togthreads2_polyhedron_algorithm == "v3", "threads2__to_polyhedron only supports v3 currently")
	let( type23 = threads2__get_thread_type23(spec1) )
	$togthreads2_polyhedron_algorithm == "v2" ?
		togthreads2_mkthreads_v2(
			zparams, type23,
			direction = direction,
			r_offset = r_offset,
			end_mode = end_mode,
			thread_origin_z = thread_origin_z
		) : togthreads2_mkthreads_v3(
			zparams, type23,
			direction = direction,
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
 * I've been using pitch/2 for taper_length, but idk what's best.
 *
 * end_zts = [[bottom_z, bottom_taper], [top_z, top_taper]]
 */
function togthreads2_thread_zparams(end_zts, taper_length) =
	let( z0 = end_zts[0][0], z1 = end_zts[1][0] )
	let( t0 = end_zts[0][1], t1 = end_zts[1][1] )
	let( taper_amt = 1 )
	let( taper_l   = taper_length ) // Make it fit in the column
	[
		each t0 == 0 ? [
			[z0        ,  0],
		] : [
			if( t0 > 0 )
			[z0-1      , t0],
			[z0        , t0],
			[z0+taper_l,  0],
		],
		each t1 == 0 ? [
			[z1        ,  0],
		] : [
			[z1-taper_l,  0],
			[z1        , t1],
			if( t1 > 0 )
			[z1+1      , t1],
		],
	];

the_post =
	outer_threads == "none" ? ["union"] :
	let( spec = threads2__get_thread_spec(outer_threads) )
	let( top_z = total_height )
	let( bottom_z = max(0, head_height/2) )
	threads2__to_polyhedron(
		togthreads2_thread_zparams([
			[bottom_z, bottom_z == 0 ? -1 : 0],
			[   top_z,                 -1    ],
		], threads2__get_thread_pitch(spec)/2),
		outer_threads, r_offset=outer_thread_radius_offset, end_mode="blunt", thread_origin_z = head_height
	);

the_hole =
	inner_threads == "none" ? ["union"] :
	let( spec = threads2__get_thread_spec(inner_threads) )
	let( taper_length = threads2__get_thread_pitch(spec)/2 )
	threads2__to_polyhedron(
	   togthreads2_thread_zparams([
		   [floor_thickness, floor_thickness > 0 ? 0 : 1],
			[total_height   ,                           1],
		], taper_length),
		inner_threads, r_offset=inner_thread_radius_offset
	);

the_floor_hole =
	floor_threads == "none" || floor_thickness == 0 ? ["union"] :
	threads2__to_polyhedron([-1, floor_thickness+1], floor_threads, r_offset=floor_thread_radius_offset);

the_headside_holes =
	headside_threads == "none" ? ["union"] :
	// Could do a hole in every face, but for now just work for square heads.
	assert(head_shape == "square" || head_shape == "togridpile-chunk", "Head holes currently only implemented for square or togridpile-chunk heads")
	let(headside_hole = threads2__to_polyhedron([-head_width/2, head_width/2], headside_threads, r_offset=headside_thread_radius_offset))
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
		tphl1_extrude_polypoints([-1,height+1], tgx11_chunk_xs_points(
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

togmod1_domodule(["difference",
	["union",
		the_post,
		the_cap
	],
	the_hole,
	the_floor_hole,
	the_headside_holes,
	if(cross_section) ["translate", [50,50], tphl1_make_rounded_cuboid([100,100,200], r=0, $fn=1)],
]);

// # cylinder(d=10, h=total_height);
