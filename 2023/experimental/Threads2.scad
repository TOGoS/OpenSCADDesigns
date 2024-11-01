// New screw threads library

use <../lib/TOGMod1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 32;
threading = "1+1/4-7-UNC"; // ["test", "1+1/4-7-UNC"]
handedness = "right"; // ["right","left"]
side = "external"; // ["external", "internal"]

function togthreads2_mkthreads( zrange, pitch, radius_function, direction="right", taper_function=function(z) 1 ) =
	let( $fn = max(3, $fn) )
	let( $tphl1_quad_split_direction = direction )
	let( layer_height = pitch/$fn )
	tphl1_make_polyhedron_from_layer_function([
		// TODO: evenly divide zrange
		for( z=[zrange[0] : layer_height : zrange[1]] ) [z, (z-zrange[0])*360/pitch]
	], function(za)
		togvec0_offset_points(
			[
				for( j = [0:1:$fn-1] )
				let( a = 360 * j / $fn )
				let( t_raw = (za[1] + a * (direction == "right" ? -1 : 1)) / 360 )
				let( t = t_raw - floor(t_raw) )
				let( r = radius_function(t, taper_function(za[0])) )
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
function togthreads2_unc_external_thread_radius_function(basic_diameter, pitch, side="external", meth="orig") =
	// Based on
	// https://www.machiningdoctor.com/charts/unified-inch-threads-charts/#formulas-for-basic-dimensions
	// https://www.machiningdoctor.com/wp-content/uploads/2022/07/Unfied-Thread-Basic-Dimensions-External.png?ezimgfmt=ng:webp/ngcb1
	// 
	// It looks like the formulas for internal/external threads are the same
	// except that the inner/outer flattening is inverted.
	// 
	// TODO: This seems like it might be wrong.  Figure out and fix.
	let( d = basic_diameter*25.4 )
	let( P = 25.4/pitch )
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

demo_thread_radius_function = function(t, trat=1) max(9, min(10, 9 + trat * (0.5 + 2 * ((2*abs(t-0.5))-0.5)) ));;

togmod1_domodule(
	togthreads2_mkthreads([0, 20], 5,
		threading == "demo" ? demo_thread_radius_function : 
		threading == "1+1/4-7-UNC" ? togthreads2_unc_external_thread_radius_function(1, 7, side) :
		assert(false, str("Unknown threading: ", threading)),
		taper_function = function(z) 1 - max(0, (z - 18)/2)
	)
);
