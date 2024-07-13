// Goal: Come up with an elegant way
// to create a polyhedron that morphs between
// two completely different shapes, such as a square and a circle.
// Or maybe simpler: morph anything to a circle

top_shape = "circle"; // ["circle", "diamond"]

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGRez1.scad>
use <../lib/TOGVecLib0.scad>

function polymorph_morphic_polyhedron_layer_points( shapes, index, position ) =
	togvec0_offset_points(togrez1_table_sample(shapes, index), position);

function polymorph_make_morphic_polyhedron( shapes, position_indexes ) =
	tphl1_make_polyhedron_from_layer_function(
		position_indexes,
		function(pi) polymorph_morphic_polyhedron_layer_points( shapes, pi[1], pi[0] )
	);

//base_shape = togmod1_rounded_rect_points([76.2, 76.2], r=3.185, $fn=48);
function make_base_shape(offset=0) =
let( nops=[["offset", offset]], iops=[["offset", offset], ["round", 3.175]], eops=[["offset", offset], ["round", 6.35]] )
togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-38.1     ,   0       ], each nops],
	["togpath1-rathnode", [-38.1     , -38.1+12.7], each eops],
	["togpath1-rathnode", [-38.1+12.7, -38.1+12.7], each iops],
	["togpath1-rathnode", [-38.1+12.7, -38.1     ], each eops],
	["togpath1-rathnode", [+38.1-12.7, -38.1     ], each eops],
	["togpath1-rathnode", [+38.1-12.7, -38.1+12.7], each iops],
	["togpath1-rathnode", [+38.1     , -38.1+12.7], each eops],
	["togpath1-rathnode", [+38.1     ,   0       ], each nops],
	["togpath1-rathnode", [+38.1     , +38.1-12.7], each eops],
	["togpath1-rathnode", [+38.1-12.7, +38.1-12.7], each iops],
	["togpath1-rathnode", [+38.1-12.7, +38.1     ], each eops],
	["togpath1-rathnode", [-38.1+12.7, +38.1     ], each eops],
	["togpath1-rathnode", [-38.1+12.7, +38.1-12.7], each iops],
	["togpath1-rathnode", [-38.1     , +38.1-12.7], each eops],
]);

function fdmod(a, b) = a - (b * floor(a / b));

assert( fdmod( 0,  5) == 0 );
assert( fdmod( 3,  5) == 3 );
assert( fdmod( 5,  5) == 0 );
assert( fdmod(-3,  5) == 2 );
assert( fdmod(-5,  5) == 0 );
assert( fdmod(-6,  5) == 4 );

assert( fdmod( 5, -5) ==  0 );
assert( fdmod( 1, -5) == -4 );
assert( fdmod(-6, -5) == -1 );

function shift(list, by) = [
	for( i=[0 : 1 : len(list)-1] ) list[fdmod(i+by, len(list))]
];

function make_diamond(offset=0) =
let( nops=[["offset", offset]], iops=[["offset", offset], ["round", 3.175]], eops=[["offset", offset], ["round", 6.35]] )
togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [-38.1     ,   0       ], each eops],
	["togpath1-rathnode", [  0       , -38.1     ], each eops],
	["togpath1-rathnode", [+38.1     ,   0       ], each eops],
	["togpath1-rathnode", [  0       , +38.1     ], each eops],
]);

function get_max_pointcount(shapes, index=0) =
	len(shapes) == index ? 0 :
	max(len(shapes[index]), get_max_pointcount(shapes, index+1));

// Return a new list of shapes where they all have the same number of points
function fix_shapes(shapes) =
	let( npoints = get_max_pointcount(shapes) )
	[
		for( s = shapes ) togrez1_resample(s, npoints)
	];

function make_thingo(offset, stickout=0, height=38.1, curve_power=1.2, steps=undef) =
	let( eff_steps = !is_undef(steps) ? steps : round(height/4) )
	let( base_shape = make_base_shape(offset) )
	let( eff_top_shape =
		top_shape == "diamond" ? shift(make_diamond(offset), 4) :
		togrez1_to_circle(base_shape, r=38.1 + offset) )
	polymorph_make_morphic_polyhedron(
		shapes = fix_shapes([base_shape, eff_top_shape]),
		position_indexes = [
			if( stickout > 0 ) [-stickout, 0],
			for( i=[0:eff_steps] ) [ pow(i/eff_steps, curve_power)*38.1, i/eff_steps ],
			if( stickout > 0 ) [38.1+stickout, 1],
		]
	);

// fun :: ( offset, stickout ) -> shape
function make_tube( fun ) = ["difference", fun(0, 0), fun(-3.175, 1)];

togmod1_domodule(make_tube(function(offset,stickout) make_thingo(offset, stickout, curve_power=0.5, $fn=24)));
