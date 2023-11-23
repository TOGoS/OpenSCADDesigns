// JoistCableClip-v1.1
// 
// "w" to be bolted or clamped under a joist, parallel to the joist,
// to hold cables perpendicular to the joist.
//
// v1.1:
// - Reduce X, Y size slightly, by 'xy_margin'
// - Make it skinny in the middle and beveled on all bottom corners

xy_margin = 0.2;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __joisecableclip_end_params() { }

inch = 25.4;
chunk_pitch = 1.5*inch;
bevel_size = 1/8*inch;
block_size = [3*chunk_pitch, 1*chunk_pitch, 1/2*inch];
size = [block_size[0] - xy_margin*2, block_size[1] - xy_margin*2, block_size[2]];

$fn = $preview ? 12 : 48;



// Copied (and simplified--no special 0 case) from togmod1__make_nd_vector_adder;
// maybe this should become a TOGArrayLib function
function joisetcableclip__make_nd_vector_adder(origin=[0,0]) =
	function(vec) [
		for(i=[0:1:max(len(origin),len(vec))-1]) (len(vec) > i ? vec[i] : 0) + (len(origin) > i ? origin[i] : 0),
	];

function joisetcableclip__map(list, fun) = [ for(a=list) fun(a) ];



function scale_vec(v, s) =
	assert(is_list(v))
	is_num(s) ? v * s :
	is_list(s) ? [ for( i=[0 : 1 : min(len(v),len(s))-1] ) v[i]*s[i] ] :
	assert(false, str("Don't know how to scale_vec(", v, ", ", s, ")"));

function _sum(a, init=0, off=0) =
	len(a) == off ? init :
	_sum(a, a[off] + init, off+1);

function sum(a) =
	assert(is_list(a))
	assert(len(a) > 0)
	_sum(a, init=a[0], off=1);

function multiply_point_data(point_data, mults) = [
	for( d=point_data ) sum([for( i=[0 : 1 : min(len(mults), len(d))-1] ) scale_vec(d[i], mults[i])])
];

z41 = sqrt(2)-1; // Approximately 0.414

xy_shape_point_data = [
	// Assumes multipliers: block size, chunk size, center inset size, offset
	[[-0.5, -0.5], [   0, 0], [ 0, 1], [-1  , -z41]],
	[[-0.5, -0.5], [   0, 0], [ 1, 0], [-z41, -1  ]],
	
	[[ 0  , -0.5], [-0.5, 0], [ 0, 0], [ z41, -1  ]],
	[[ 0  , -0.5], [-0.5, 0], [ 1, 1], [ z41, -1  ]],
	[[ 0  , -0.5], [ 0.5, 0], [-1, 1], [-z41, -1  ]],
	[[ 0  , -0.5], [ 0.5, 0], [ 0, 0], [-z41, -1  ]],
	
	[[ 0.5, -0.5], [ 0  , 0], [-1, 0], [ z41, -1  ]],
	[[ 0.5, -0.5], [ 0  , 0], [ 0, 1], [ 1  , -z41]],
	
	[[ 0.5,  0.5], [ 0  , 0], [ 0,-1], [ 1  ,  z41]],
	[[ 0.5,  0.5], [ 0  , 0], [-1, 0], [ z41,  1  ]],
	
	[[ 0  ,  0.5], [ 0.5, 0], [ 0, 0], [-z41,  1  ]],
	[[ 0  ,  0.5], [ 0.5, 0], [-1,-1], [-z41,  1  ]],
	[[ 0  ,  0.5], [-0.5, 0], [ 1,-1], [ z41,  1  ]],
	[[ 0  ,  0.5], [-0.5, 0], [ 0, 0], [ z41,  1  ]],
	
	[[-0.5,  0.5], [ 0  , 0], [ 1, 0], [-z41,  1  ]],
	[[-0.5,  0.5], [ 0  , 0], [ 0,-1], [-1  ,  z41]],
];

// It hink that with a liiitle bit more work, since we already know the insets,
// we could automatically round all the corners!

function fluboid_points(size, b=3.175) =
	[
		[-size[0]/2 + b, -size[1]/2    ],
		[ size[0]/2 - b, -size[1]/2    ],
		[ size[0]/2    , -size[1]/2 + b],
		[ size[0]/2    ,  size[1]/2    ],
		[-size[0]/2    ,  size[1]/2    ],
		[-size[0]/2    , -size[1]/2 + b],
	];

function fluboid_x(size, b=3.175) = // togmod1_make_cuboid(size);
	togmod1_linear_extrude_x([-size[0]/2, size[0]/2], togmod1_make_polygon(fluboid_points([size[1], size[2]], b)));

function fluboid_y(size, b=3.175) = // togmod1_make_cuboid(size);
	togmod1_linear_extrude_y([-size[1]/2, size[1]/2], togmod1_make_polygon(fluboid_points([size[0], size[2]], b)));

function get_shape_points(inset, z) =
	assert(is_num(inset))
	assert(is_num(z))
	joisetcableclip__map(
		multiply_point_data(
			xy_shape_point_data,
			[block_size, chunk_pitch, bevel_size, -xy_margin - inset]
		),
		joisetcableclip__make_nd_vector_adder([0,0,z])
	);

togmod1_domodule(["difference",
	["intersection",
		// Alternatively, or in addition: intersect with a TOGridPile foot!
	 	tphl1_make_polyhedron_from_layers([
			get_shape_points(bevel_size, 0),
			get_shape_points(         0, bevel_size),
			get_shape_points(         0, block_size[2]),
		]),
	],
	
	for( x=[-1.5*inch, 1.5*inch] ) ["translate", [x, 0, size[2]], fluboid_y([1*inch, size[1]*2, 1/2*inch])],
	for( x=[-4/8*inch, 4/8*inch] ) ["translate", [x, 0, size[2]], fluboid_y([3/8*inch, size[1]*2, 1/2*inch])],
	for( y=[-3/8*inch, 3/8*inch] ) ["translate", [0, y, size[2]], fluboid_x([5*inch, 3/8*inch, 1/2*inch])],
	["translate", [0, 0, size[2]], fluboid_y([3/8*inch, 3/4*inch, 1/2*inch])],
	
	togmod1_make_cylinder(d=10, zrange=[-1, size[2]+1])
]);
