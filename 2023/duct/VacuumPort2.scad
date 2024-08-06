// VacuumPort2.0
// 
// This one uses morphing polygons
// to make a polyhedron suitable for the blahblahblah

tube_wall_thickness = 3.175;

use <../lib/TOGFDMod.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGRez1.scad>
use <../lib/TOGVecLib0.scad>

module __ui32dfiyub__end_params() { }

atom_pitch = 12.7;

// PortSpec = [mid_d, dd/dx]

function vacuum_port_d(portspec, z, zmid=0) = portspec[0] + portspec[1] * (z-zmid);


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

function make_circle(diameter, offset=0) = togmod1_circle_points(r=diameter/2+offset);

function shift(list, by) = [
	for( i=[0 : 1 : len(list)-1] ) list[togfdmod(i+by, len(list))]
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

function make_column(zshapes, stickout=0, subdiv=4) =
	polymorph_make_morphic_polyhedron(
		shapes = [for(s = zshapes) s[1]],
		position_indexes = [
			if( stickout > 0 ) [-stickout, 0],
			
			for( i=[0:1:len(zshapes)-2] )
				let( zs0=zshapes[i] )
				// Each layer can override the subdivisions and power
				// for the span between it and the next
				let( subdivi = len(zs0) >= 3 ? zs0[2] : subdiv )
				let( powe    = len(zs0) >= 4 ? zs0[3] : 1      )
				for( t=[0:1:subdivi] )
					let(zs1=zshapes[i+1]) [togrez1__lerp(zs0[0], zs1[0], pow(t/subdivi, powe)), i + t/subdivi],
			
			let( i=len(zshapes)-1 )
				let(zs=zshapes[i]) [zs[0], i],
			
			if( stickout > 0 ) [38.1+stickout, len(zshapes)-1],
		]
	);

mounting_hole = tog_holelib2_hole("THL-1005", depth=10, overhead_bore_height=25);
inch = 25.4;

taper_1_75_inch = [1.78*inch, 0.016];

// fun :: ( offset, stickout ) -> shape
function make_tube( fun ) =
let( w = tube_wall_thickness )
let( u = inch/16 )
let( taper_center_z = 18*u )
["difference",
	make_column([
		[ 0   ,  make_full_square(offset=0)],
		[ 2*u ,  make_full_square(offset=0), 8, 2],
		//[12*u ,  make_circle(2.5*inch)],
		//[18*u ,  make_circle(2*inch)],
		[24*u ,  make_circle(2*inch)],
	]),
	make_column([
		[ 0   , make_cross(offset=-w), 8, 1.4],
		[12*u , make_circle(vacuum_port_d(taper_1_75_inch, 12*u, taper_center_z))],
		[24*u , make_circle(vacuum_port_d(taper_1_75_inch, 24*u, taper_center_z))],
	], 1),
	for( xm=[-2.5, 2.5] ) for( ym=[-2.5, 2.5] ) ["translate", [xm*atom_pitch, ym*atom_pitch, 6.35], mounting_hole],
];

togmod1_domodule(["difference",
	make_tube($fn=(12*8)+4),
	if( $preview ) ["translate", [25,25,0], togmod1_make_cuboid([50,50,100])]
]);
