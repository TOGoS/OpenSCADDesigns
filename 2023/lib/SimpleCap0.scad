// SimpleCap0.2
// 
// Library for making very simple caps for things
// whose outline can be described by a rath.
// 
// Versions:
// v0.2:
// - Bevel the bottom somewhat

use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

function simplecap0_decode_rath(shape) =
	assert(is_list(shape) && len(shape) >= 1, str("Shape must be a list of length at least 1, got: ", shape))
	shape[0] == "togpath1-rath" ? shape :
	shape[0] == "circle-d" ? togpath1_make_circle_rath(r=shape[1]/2) :
	shape[0] == "circle-r" ? togpath1_make_circle_rath(r=shape[1]) :
	shape[0] == "oval-wh" ? let(size=shape[1]) togpath1_make_rectangle_rath([size[0],size[1]], [["round", min(size[0],size[1])/2]]) :
	assert(false, str("Unrecognized shape description: ", shape));

function simplecap0_make_cap(inner_shape, total_height=19.05, floor_thickness=3.175, wall_thickness=1.6) =
	let( rath = simplecap0_decode_rath(inner_shape) )
	let( t0 = 0, t1 = wall_thickness )
	let( y0 = 0, yt = total_height, yf = floor_thickness )
	let( bb = max(0.1, floor_thickness*0.6) )
	tphl1_make_polyhedron_from_layer_function([
		[y0   , t1-bb],
		[y0+bb, t1   ],
		[yt   , t1   ],
		[yt   , t0   ],
		[yf   , t0   ],
	], function(zo) let(z = zo[0], wall_offset=zo[1])
		togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_offset_rath(rath, wall_offset)), z));
