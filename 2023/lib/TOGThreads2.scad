// TOGThreads2.25.1
// 
// Versions:
// v2.25:
// - Extract to library from ../experimental/Threads2.scad
// v2.25.1
// - Remove an echo
// 
// To use this library, set the following dynamic variables:
// 
//   $togridlib3_unit_table = tgx11_get_default_unit_table();
//   $tgx11_offset          = -0.1;
//   $togthreads2_polyhedron_algorithm = "v3"

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>

//// On 'thread Z origin'

// Threads stick out to the right at z = thread_origin_z.
// Since v2 specifies ridge at phase = 0.5 and groove at 0 and 1,
// that means that phase = z / pitch - floor(z / pitch) + 0.5

function togthreads2__clamp(x, lower, upper) = min(upper, max(lower, x));

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
function togthreads2__ptrfunc_to_zprfunc(
	ptrfunc,
	pitch,
	direction       = "right",
	taper_function  = function(z) 1,
	r_offset        = 0,
	thread_origin_z = 0
) =
	let( zmul = direction == "right" ? -1 : 1 )
	function(z, phase_offset)
		let( phase = togthreads2__z_to_phase(z - thread_origin_z, pitch, phase_offset=phase_offset, zmul=zmul) )
		assert( phase >= 0 ) assert( phase <= 1 )
		r_offset + ptrfunc(
			phase,
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
	function(phase, t=0)
		let( taper_offset = t*(max_radius-min_radius) )
		togthreads2__clamp(
			lookup(phase, remapped),
			min_radius + taper_offset,
			max_radius + taper_offset
		);

function togthreads2__to_list(x) = [for(i=x) i];

// v2 layer-generation
// rfunc :: z -> phase (0...1) -> r|[x,y]|[x,y,z]
function togthreads2__zpr_to_layers(zs, zprfunc) =
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
			for( p=[0:1:$fn-1] ) fixpoint(zprfunc(z, p/$fn), p/$fn, z)
		]
	];

// V2: Based on the idea of using a function like z -> phase -> r
// to make it simpler to transform r at a given z
function togthreads2__mkthreads_v2(zparams, type23, direction="right", r_offset=0, end_mode="flush", thread_origin_z=0) =
//function( zparams, type23, direction="right", r_offset=0, thread_origin_z=0 )
	let( pitch = type23[1] )
	let( ptrfunc = togthreads2__type23_to_ptrfunc(type23) )
	let( zrange = [zparams[0][0], zparams[len(zparams)-1][0]] )
	let( layer_height = pitch/$fn )
	let( taper_function = function(z) lookup(z, zparams) )
	let( layers = togthreads2__zpr_to_layers(
		[zrange[0] : layer_height : zrange[1]],
		zprfunc = togthreads2__ptrfunc_to_zprfunc(
			ptrfunc, pitch, direction,
			taper_function = taper_function,
			r_offset = r_offset,
			thread_origin_z = thread_origin_z
		)
	) )
	tphl1_make_polyhedron_from_layers(layers);

// 0 -> 0, 0.5 -> 1, 1 -> 0
function togthreads2__ridge(t) =
	let( trem = t - floor(t) )
	let( dtrem = trem * 2 )
	dtrem > 1 ? 2 - dtrem : dtrem;

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
function togthreads2__mkthreads_v3(zparams, type23, direction="right", r_offset=0, end_mode="flush", thread_origin_z=0) =
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

function togthreads2__demo_to_type23(diam, pitch) =
	let( outer_r = diam/2 )
	let( bev = pitch/3 )
	let( inner_r = outer_r - bev )
	["togthreads2.3-type", pitch, [[inner_r,-pitch/8-bev], [outer_r,-pitch/8], [outer_r,pitch/8], [inner_r,pitch/8+bev]], outer_r-pitch/4, outer_r];

function togthreads2__unc_to_type23(basic_diameter, tpi) =
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

use <../lib/TOGStringLib1.scad>
use <../lib/TOGridLib3.scad>

function togthreads2__parse_num(feh, index=0) =
	let(ratr = togstr1_parse_rational_number(feh, index))
	ratr[1] == index ? [undef, index] :
	let(rn = ratr[0])
	let(num = rn[0] / rn[1])
	assert(is_num(num))
	[num, ratr[1]];

function togthreads2__decode_num(feh) =
	let(numr = togthreads2__parse_num(feh))
	assert(numr[1] > 0, str("Failed to parse rational number from '", feh, "'"))
	numr[0];

function togthreads2__decode_dim(feh) =
	let(qr = togstr1_parse_quantity(feh))
	assert(qr[1] > 0, str("Failed to parse quantity from '", feh, "'"))
	let(rq = qr[0])
	togridlib3_decode([rq[0][0], rq[1]]) / rq[0][1];

// A few hardcoded thread types
togthreads2_thread_types = [
	["none", ["none"]],
	["threads2-demo", ["demo", 20, 5]],
	["#6-32-UNC", ["unc", 0.138, 32]],
	["#8-32-UNC", ["unc", 0.168, 32]],
];

function togthreads2__get_thread_spec(name, index=0) =
	togthreads2_thread_types[index][0] == name ? togthreads2_thread_types[index][1] :
	index+1 < len(togthreads2_thread_types) ? togthreads2__get_thread_spec(name, index+1) :
	let( kq = togstr1_tokenize(name, "-", 3) )
	kq[0] == "straight" && len(kq) == 2 ? ["straight-d", togthreads2__decode_dim(kq[1])] :
	let(uncdiam =
		len(kq) == 3 && kq[2] == "UNC" ?	let( diamr = togthreads2__parse_num(kq[0]) ) diamr[0] :
		undef
	)
	is_num(uncdiam) ? ["unc", uncdiam, togthreads2__decode_num(kq[1])] :
	assert(false, str("Failed to parse thread spec ''", name, "' (not in list or recognized format)"));

function togthreads2__get_thread_pitch(spec) =
	is_string(spec) ? togthreads2__get_thread_pitch(togthreads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc" ? 25.4 / spec[2] :
	is_list(spec) && spec[0] == "demo" ? spec[2] :
	assert(false, str("Unrecognized thread spec: ", spec));

function togthreads2__get_default_taper_length(spec) =
	is_string(spec) ? togthreads2__get_thread_pitch(togthreads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "straight-d" ? spec[1] :
	is_list(spec) && spec[0] == "none"       ? 1       :
	togthreads2__get_thread_pitch(spec)/2;

function togthreads2__get_thread_type23(spec) =
	is_string(spec) ? togthreads2__get_thread_type23(togthreads2__gegt_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2__unc_to_type23(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2__demo_to_type23(spec[1], spec[2]) :
	assert(false, str("Unrecognized thread spec: ", spec));

// TODO: Allow 'spec' to be a type23
function togthreads2_make_threads(zparams, spec, r_offset=0, direction="right", end_mode="flush", thread_origin_z=0) =
	let( spec1 = is_string(spec) ? togthreads2__get_thread_spec(spec) : spec )
	spec1[0] == "none" ? ["union"] :
	let( zrange = togthreads2__zparams_to_zrange(zparams) )
	spec1[0] == "straight-d" ? tphl1_make_z_cylinder(zrange=zrange, d=spec1[1]+r_offset) :
	let( type23 = togthreads2__get_thread_type23(spec1) )
	$togthreads2_polyhedron_algorithm == "v2" ?
		togthreads2__mkthreads_v2(
			zparams, type23,
			direction = direction,
			r_offset = r_offset,
			end_mode = end_mode,
			thread_origin_z = thread_origin_z
		) : togthreads2__mkthreads_v3(
			zparams, type23,
			direction = direction,
			r_offset = r_offset,
			end_mode = end_mode,
			thread_origin_z = thread_origin_z
		);

/**
 * Generate zparams for threads with ends tapered appropriately
 * given the taper direction (separately for bottom/top) and length.
 *
 * Assumes that positive taper means inner threads,
 * which will be extended a bit beyond the stated end.
 * 
 * - end_zts = [[bottom_z, bottom_taper_direction], [top_z, top_taper_direction]]
 *   where taper_direction = -1 (inward), 0 (straight), or 1 (outward)
 * - taper_length = vertical length of taper, in mm
 */
function togthreads2_simple_zparams(end_zts, taper_length) =
	let( z0 = end_zts[0][0], z1 = end_zts[1][0] )
	let( t0 = end_zts[0][1], t1 = end_zts[1][1] )
	let( taper_amt = 1 )
	let( taper_l   = taper_length ) // Make it fit in the column
	[
		each t0 == 0 ? [
			[z0        ,  0],
		] : [
			if( t0 > 0 )
			[z0-1      , t0*2],
			[z0        , t0],
			[z0+taper_l,  0],
		],
		each t1 == 0 ? [
			[z1        ,  0],
		] : [
			[z1-taper_l,  0],
			[z1        , t1],
			if( t1 > 0 )
			[z1+1      , t1*2],
		],
	];
