// Goal: Come up with an elegant way
// to create a polyhedron that morphs between
// two completely different shapes, such as a square and a circle.
// Or maybe simpler: morph anything to a circle

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

function togrez1_to_circle(polypoints, r) =
	assert(is_num(r))
	let( a0 = atan2(polypoints[0][1], polypoints[0][0]) )
	[
		for( i=[0 : 1 : len(polypoints)-1] ) let( a = a0 + i*360/len(polypoints) ) [r*cos(a), r*sin(a)]
	];

function togrez1__scale( a, t ) =
	is_num(a) ? a*t :
	is_list(a) ? [ for(atem=a) togrez1__scale(atem, t) ] :
	assert(false, str("Don't know how to scale ", a));

function togrez1__lerp( a, b, t ) = togrez1__scale(a, 1-t) + togrez1__scale(b, t);

function togrez1_polytable_sample( shapes, index ) =
	floor(index) == index ? shapes[index] :
	let( i0 = floor(index), i1 = ceil(index) )
	let( s0 = shapes[i0 % len(shapes)], s1 = shapes[i1 % len(shapes)] )
	togrez1__lerp(s0, s1, index - i0 );

function togrez1_morphic_polyhedron_layer_points( shapes, index, position ) =
	togvec0_offset_points(togrez1_polytable_sample(shapes, index), position);

function togrez1_make_morphic_polyhedron( shapes, position_indexes ) =
	tphl1_make_polyhedron_from_layer_function(
		position_indexes,
		function(pi) togrez1_morphic_polyhedron_layer_points( shapes, pi[1], pi[0] )
	);

function togrez1_resample_posts( things, n ) = [
	for( i=[0 : 1 : n-1] ) togrez1_polytable_sample(things, i * (len(things)-1)/(n-1))
];

function togrez1_resample( things, n ) = [
	for( i=[0 : 1 : n-1] ) togrez1_polytable_sample(things, i * len(things)/n)
];

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

function make_thingo(offset, stickout=0, height=38.1, curve_power=1.2, steps=undef) =
	let( eff_steps = !is_undef(steps) ? steps : round(height/4) )
	let( base_shape = make_base_shape(offset) )
	togrez1_make_morphic_polyhedron(
		shapes = [base_shape, togrez1_to_circle(base_shape, r=38.1 + offset)],
		position_indexes = [
			if( stickout > 0 ) [-stickout, 0],
			for( i=[0:eff_steps] ) [ pow(i/eff_steps, curve_power)*38.1, i/eff_steps ],
			if( stickout > 0 ) [38.1+stickout, 1],
		]
	);

// fun :: ( offset, stickout ) -> shape
function make_tube( fun ) = ["difference", fun(0, 0), fun(-3.175, 1)];

togmod1_domodule(make_tube(function(offset,stickout) make_thingo(offset, stickout, curve_power=0.5, $fn=24)));
