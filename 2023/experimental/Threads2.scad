// Threads2.4
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

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>

$fn = 32;
outer_threads = "1+1/4-7-UNC"; // ["threads2-demo", "1/4-20-UNC", "3/8-16-UNC", "1/2-13-UNC", "3/4-10-UNC", "1+1/4-7-UNC"]
inner_threads = "1/2-13-UNC"; // ["threads2-demo", "1/4-20-UNC", "3/8-16-UNC", "1/2-13-UNC", "3/4-10-UNC", "1+1/4-7-UNC"]
total_height = 19.05;
head_width   = 38.1;
head_height  =  6.35;
head_shape = "square"; // ["square","hexagon","togridpile-chunk"]
handedness = "right"; // ["right","left"]
head_surface_offset = -0.1;
outer_thread_radius_offset = -0.1;
inner_thread_radius_offset =  0.3;

module __threads2_end_params() { }

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

// rfunc :: z -> phase (0...1) -> r|[x,y]|[x,y,z]
function togthreads2_zp_to_layers(zs, rfunc) =
	let($fn = max(3, $fn))
	let(fixpoint = function(n, p, z)
		is_num(n) ? [cos(p*360)*n, sin(p*360)*n, z] :
		is_list(n) && len(n) == 1 ? fixpoint(n[0], p, z) :
		is_list(n) && len(n) == 2 ? [n[0], n[1], z] :
		is_list(n) && len(n) == 3 ? n :
		assert(false, str("Rfunc should return 1..3 values, but it returned ", n)))
	[
		for( z=zs ) [
			for( p=[0:1:$fn-1] ) fixpoint(rfunc(z,p/$fn), p/$fn, z)
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
togthreads2_mkthreads_v2 = function( zrange, pitch, radius_function, direction="right", taper_function=function(z) 1, r_offset=0 )
	let( layer_height = pitch/$fn )
	let( layers = togthreads2_zp_to_layers(
		[zrange[0] : layer_height : zrange[1]],
		togthreads2_threadradfunc_to_zpfunc(radius_function, pitch, direction, taper_function=taper_function, r_offset=r_offset)
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
		   r0 + trat*H/2 + H*togthreads2__ridge(t),
			rmin, rmax
		);

function togthreads2_demo_thread_radius_function(diam,pitch) =
	function(t, trat=0) max(9, min(10, 9 + trat + (0.5 + 2 * ((2*abs(t-0.5))-0.5)) ));;

threads2_thread_types = [
	["threads2-demo", ["demo", 10, 5]],
	["#6-32-UNC", ["unc", 0.138, 32]],
	["#8-32-UNC", ["unc", 0.168, 32]],
	["1/4-20-UNC", ["unc", 0.25, 20]],
	["3/8-16-UNC", ["unc", 3/8, 16]],
	["1/2-13-UNC", ["unc", 0.5, 13]],
	["7/16-14-UNC", ["unc", 7/16, 14]],
	["3/4-10-UNC", ["unc", 3/4, 10]],
	["1+1/4-7-UNC", ["unc", 1.25, 7]],
];

function threads2__get_thread_spec(name, index=0) =
	assert(len(threads2_thread_types) > index, str("Didn't find '", name, "' in thread types list"))
	threads2_thread_types[index][0] == name ? threads2_thread_types[index][1] :
	threads2__get_thread_spec(name, index+1);

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

the_post =
	total_height <= head_height ? ["union"] :
	let( top_z = total_height )
	let( taper_length = 2 )
	let( specs = threads2__get_thread_spec(outer_threads) )
	let( pitch = threads2__get_thread_pitch(specs) )
	let( rfunc = threads2__get_thread_radius_function(specs) )
	togthreads2_mkthreads([head_height-1, top_z], pitch, rfunc,
		taper_function = function(z) 0 - max(0, (z - (top_z - taper_length))/taper_length),
		r_offset = outer_thread_radius_offset
	);

the_hole =
	let( top_z = total_height )
	let( taper_length = 4 )
	let( specs = threads2__get_thread_spec(inner_threads) )
	let( pitch = threads2__get_thread_pitch(specs) )
	let( rfunc = threads2__get_thread_radius_function(specs) )
	togthreads2_mkthreads([-1, top_z+1], pitch, rfunc,
		taper_function = function(z) max(1-z/taper_length, 0, 1 - (top_z-z)/taper_length),
		r_offset = inner_thread_radius_offset
	);

use <../lib/TOGVecLib0.scad>
use <../lib/TOGPath1.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = head_surface_offset;

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
		togpath1_make_polygon_rath(r=c_to_c_r, $fn=sidecount, corner_ops=[["round", r1]]),
		height, r=r2
	);

function make_base(shape, width, height) =
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
	the_hole
]);
