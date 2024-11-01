// New screw threads library

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;
threading = "1+1/4-7-UNC"; // ["threads2-demo", "1/4-20-UNC", "1+1/4-7-UNC"]
total_height = 20;
head_height  = 6.35;
handedness = "right"; // ["right","left"]
head_surface_offset = -0.1;
thread_radius_offset = -0.2;

module __threads2_end_params() { }

side = "external"; // ["external", "internal"]

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

// TODO: Instead of just accepting a z range,
// accept a list of [z, param],
// and interpolate param values between Zs.
// TODO: Remove taper_function
function togthreads2_mkthreads( zparams, pitch, radius_function, direction="right", taper_function=function(z) 1, r_offset=0 ) =
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
		   r0 + trat*H*togthreads2__ridge(t),
			rmin, rmax
		);

function togthreads2_demo_thread_radius_function(diam,pitch) =
	function(t, trat=1) max(9, min(10, 9 + trat * (0.5 + 2 * ((2*abs(t-0.5))-0.5)) ));;

threads2_thread_types = [
	["threads2-demo", ["demo", 10, 5]],
	["#6-32-UNC", ["unc", 0.138, 32]],
	["#8-32-UNC", ["unc", 0.168, 32]],
	["1/4-20-UNC", ["unc", 0.25, 20]],
	["1+1/4-7-UNC", ["unc", 1.25, 7]],
];

function threads2__get_thread_spec(name, index=0) =
	assert(len(threads2_thread_types) > index, str("Didn't find '", name, "' in thread types list"))
	threads2_thread_types[index][0] == name ? threads2_thread_types[index][1] :
	threads2__get_thread_spec(name, index+1);

function threads2__get_thread_pitch(spec) =
	is_string(spec) ? threads2__get_thread_radius_function(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc" ? 25.4 / spec[2] :
	is_list(spec) && spec[0] == "demo" ? spec[2] :
	assert(false, str("Unrecognized thread spec: ", spec));

function threads2__get_thread_radius_function(spec) =
	is_string(spec) ? threads2__get_thread_radius_function(threads2__get_thread_spec(spec)) :
	is_list(spec) && spec[0] == "unc"  ? togthreads2_unc_external_thread_radius_function(spec[1], spec[2]) :
	is_list(spec) && spec[0] == "demo" ? togthreads2_demo_thread_radius_function(spec[1], spec[2]) :
	assert(false, str("Unrecognized thread spec: ", spec));

togmod1_domodule(["union",
	let( specs = threads2__get_thread_spec(threading) )
	let( pitch = threads2__get_thread_pitch(specs) )
	let( rfunc = threads2__get_thread_radius_function(specs) )
	let( top_z = total_height )
	let( taper_length = 2 )
	togthreads2_mkthreads([head_height-1, top_z], pitch, rfunc,
		taper_function = function(z) 1 - max(0, (z - (top_z - taper_length))/taper_length),
		r_offset = thread_radius_offset
	),
	
	["translate", [0,0,head_height/2], tphl1_make_rounded_cuboid([
		38.1 + head_surface_offset*2,
		38.1 + head_surface_offset*2,
		head_height + head_surface_offset*2
	], 2)],
]);
