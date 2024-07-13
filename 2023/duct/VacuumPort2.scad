// WORK IN PROGRESS

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGRez1.scad>
use <../lib/TOGVecLib0.scad>

module __ui32dfiyub__end_params() { }

atom_pitch = 12.7;

function polymorph_morphic_polyhedron_layer_points( shapes, index, position ) =
	togvec0_offset_points(togrez1_table_sample(shapes, index), position);

function polymorph_make_morphic_polyhedron( shapes, position_indexes ) =
	tphl1_make_polyhedron_from_layer_function(
		position_indexes,
		function(pi) polymorph_morphic_polyhedron_layer_points( shapes, pi[1], pi[0] )
	);

function make_full_square(offset=0) =
assert(is_num(offset))
let( corner_vcount = ($fn-4)/4 )
assert( round(corner_vcount) == corner_vcount )
let( nops=[["offset", offset]] )
let( iops=[["round", 3.175, corner_vcount], ["offset", offset]] )
let( eops=[["round", 6.35 , corner_vcount], ["offset", offset]] )
let( polypoints = togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [ 38.1 ,   0  ], each nops],
	["togpath1-rathnode", [ 38.1 ,  38.1], each eops],
	["togpath1-rathnode", [  0   ,  38.1], each nops],
	["togpath1-rathnode", [-38.1 ,  38.1], each eops],
	["togpath1-rathnode", [-38.1 ,   0  ], each nops],
	["togpath1-rathnode", [-38.1 , -38.1], each eops],
	["togpath1-rathnode", [  0   , -38.1], each nops],
	["togpath1-rathnode", [ 38.1 , -38.1], each eops],
]))
assert( len(polypoints) == $fn, str("Expected ", $fn, " polypoints, but got ", len(polypoints)))
polypoints;

//base_shape = togmod1_rounded_rect_points([76.2, 76.2], r=3.185, $fn=48);
function make_cross(offset=0) =
assert(is_num(offset))
let( corner_vcount = ($fn-4)/12 )
assert( round(corner_vcount) == corner_vcount )
let( nops=[["offset", offset]] )
let( iops=[["round", max(1, 3.175), corner_vcount], ["offset", offset]] )
let( eops=[["round", max(1, 6.35 ), corner_vcount], ["offset", offset]] )
let( polypoints = togpath1_rath_to_polypoints(["togpath1-rath",
	["togpath1-rathnode", [+38.1     ,   0       ], each nops],
	["togpath1-rathnode", [+38.1     , +38.1-12.7], each eops],
	["togpath1-rathnode", [+38.1-12.7, +38.1-12.7], each iops],
	["togpath1-rathnode", [+38.1-12.7, +38.1     ], each eops],
	["togpath1-rathnode", [  0       , +38.1     ], each nops],
	["togpath1-rathnode", [-38.1+12.7, +38.1     ], each eops],
	["togpath1-rathnode", [-38.1+12.7, +38.1-12.7], each iops],
	["togpath1-rathnode", [-38.1     , +38.1-12.7], each eops],
	["togpath1-rathnode", [-38.1     ,   0       ], each nops],
	["togpath1-rathnode", [-38.1     , -38.1+12.7], each eops],
	["togpath1-rathnode", [-38.1+12.7, -38.1+12.7], each iops],
	["togpath1-rathnode", [-38.1+12.7, -38.1     ], each eops],
	["togpath1-rathnode", [  0       , -38.1     ], each nops],
	["togpath1-rathnode", [+38.1-12.7, -38.1     ], each eops],
	["togpath1-rathnode", [+38.1-12.7, -38.1+12.7], each iops],
	["togpath1-rathnode", [+38.1     , -38.1+12.7], each eops],
]))
assert( len(polypoints) == $fn, str("Expected ", $fn, " polypoints, but got ", len(polypoints)))
polypoints;

function make_circle(offset=0) = togmod1_circle_points(r=38.1+offset);

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

function get_max_pointcount(shapes, index=0) =
	len(shapes) == index ? 0 :
	max(len(shapes[index]), get_max_pointcount(shapes, index+1));

// Return a new list of shapes where they all have the same number of points
function fix_shapes(shapes) =
	let( npoints = get_max_pointcount(shapes) )
	[
		for( s = shapes ) togrez1_resample(s, npoints)
	];

function decode_shape(name, offset=0) =
	name == "full-square" ? make_full_square(offset) :
	name == "cross" ? make_cross(offset) :
	name == "circle" ? make_circle(offset) :
	assert(false, str("Unrecognized shape: '", name, "'"));

function make_column(shapes, offset=0, stickout=0, height=38.1, curve_power=1.2, steps=undef) =
	let( eff_steps = !is_undef(steps) ? steps : round(height/4) )
	polymorph_make_morphic_polyhedron(
		shapes = [for(s = shapes) decode_shape(s, offset=offset)],
		position_indexes = [
			if( stickout > 0 ) [-stickout, 0],
			for( i=[0:eff_steps] ) [ pow(i/eff_steps, curve_power)*38.1, i*(len(shapes)-1)/eff_steps ],
			if( stickout > 0 ) [38.1+stickout, 1],
		]
	);

mounting_hole = tog_holelib2_hole("THL-1005", depth=10, overhead_bore_height=25);

// fun :: ( offset, stickout ) -> shape
function make_tube( fun ) = ["difference",
	make_column(["full-square", "circle"]),
	make_column(["cross", "circle"], offset=-3.175, stickout=1),
	for( xm=[-2.5, 2.5] ) for( ym=[-2.5, 2.5] ) ["translate", [xm*atom_pitch, ym*atom_pitch, 6.35], mounting_hole],
];

togmod1_domodule(make_tube($fn=(12*5)+4));
