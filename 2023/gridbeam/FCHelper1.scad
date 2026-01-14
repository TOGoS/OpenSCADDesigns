// FCHelper1.0
// 
// A bit of gridrail (with non-standard hole spacing)
// to attach to the wall just under where your long FC
// is going to go, so that you don't need quite so many hands.

floor_thickness = "3/16inch";
wall_thickness = "3/16inch";
$fn = 64;

module __fchelper1__end_params() { }

function translation_matrix(pos) =
	[
		[ 1, 0, pos[0]],
		[ 0, 1, pos[1]],
		[ 0, 0,      1],
	];

function rotation_matrix(angle) =
	// Angle?
	is_num(angle) ? [
		[ cos(angle),-sin(angle), 0],
		[ sin(angle), cos(angle), 0],
		[          0,          0, 1],
	] :
	assert(false, str("rotation_matrix argument should be an angle, in degrees; got: ", angle));

function reduce(start, items, func, offset=0) =
	assert(is_list(items))
	len(items) == offset ? start :
	reduce(func(start, items[offset]), items, func, offset+1);

/**
 * Returns true if `vec` is a list of at least min_len items
 * and component_check(each item, even those beyond min_len) is true.
 */
function is_vec_of(vec, expected_len, component_check=function(x) true) =
	assert(is_num(expected_len) && expected_len >= 0)
	assert(is_function(component_check))
	is_list(vec) && len(vec) == expected_len &&
	reduce(true, vec, function(prev,item) prev && component_check(item));

function is_vec_of_num(vec, expected_len) = is_vec_of(vec, expected_len, function(i) is_num(i));

function is_matrix( matrix, expected_row_count, expected_column_count ) =
   is_vec_of(matrix, expected_row_count, function(row) is_vec_of_num(row, expected_column_count));

function matrix_to_rathnode_transform( matrix ) =
	assert( is_matrix(matrix, 3, 3) )
   function(node)
		let( invec3 = [node[1][0], node[1][1], 1] )
		let( outvec3 = matrix * invec3 )
		[node[0], [outvec3[0],outvec3[1]], for(i=[2:1:len(node)-1]) node[i]];

function map( xf, list ) =
	assert( is_function(xf) )
	assert( is_list(list) )
	[for(n=list) xf(n)];

use <../lib/TOGUnits1.scad>

inch = togunits1_to_mm("inch");
floor_thickness_mm = togunits1_to_mm(floor_thickness);
wall_thickness_mm  = togunits1_to_mm(wall_thickness);

min_rad = wall_thickness_mm + 1 + 1/256;

exterior_rath =
let( x1 = inch*3 )
let( y1 = inch*3/4 )
let( notch = inch/8 )
let( ncops = [] )
let( neops = [["round",max(min_rad,inch/4)]] )
let( ocops = [["round",max(min_rad,inch/4)]] )
let( make_notch_nodes = function(pos, normang)
	map( matrix_to_rathnode_transform(translation_matrix(pos) * rotation_matrix(normang)), [
		["togpath1-rathnode", [0        , 0 - notch], each neops],
		["togpath1-rathnode", [0 - notch, 0        ], each ncops],
		["togpath1-rathnode", [0        , 0 + notch], each neops],
	])
)
["togpath1-rath",
	each make_notch_nodes([ x1    ,   0],   0),
	["togpath1-rathnode", [ x1    ,  y1], each ocops],
	each make_notch_nodes([ 2*inch,  y1],  90),
	each make_notch_nodes([ 0*inch,  y1],  90),
	each make_notch_nodes([-2*inch,  y1],  90),
	["togpath1-rathnode", [-x1    ,  y1], each ocops],
	each make_notch_nodes([-x1    ,   0], 180),
	["togpath1-rathnode", [-x1    , -y1], each ocops],
	each make_notch_nodes([-2*inch, -y1], 270),
	each make_notch_nodes([ 0*inch, -y1], 270),
	each make_notch_nodes([ 2*inch, -y1], 270),
	["togpath1-rathnode", [ x1    , -y1], each ocops],
];

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let( z0 = -inch*3/8 )
	let( z1 = z0 + floor_thickness_mm )
	let( z2 = inch*3/8 )
	let( mount_to_wall_hole_positions = [[-2*inch,0,0], [0,0,0], [2*inch,0,0]] )
	let( front_attachment_hole_positions = [[-3/4*inch,0,z0], [ 3/4*inch,0,z0]] )
	let( mount_to_wall_hole = tog_holelib2_slot("THL-1001", [z0-10, z2/2, z2+10], [[0,-2.5], [0,2.5]]) ) 
	let( front_attachment_hole = ["rotate", [180,0,0], tog_holelib2_hole("THL-1002", inset=1.5, depth=(z2-z0+1))] )
	let( the_hull = tphl1_make_polyhedron_from_layer_function(
		[
			[z0       , -inch/8],
			[z0+inch/8,  0],
			[z2       ,  0],
		],
		function(zo) togpath1_rath_to_polypoints(togpath1_offset_rath(exterior_rath, zo[1])),
		layer_points_transform = "key0-to-z"
	))
	let( the_cavity = ["difference",
		tphl1_make_polyhedron_from_layer_function(
			[
				[z1   , -wall_thickness_mm-1],
				[z1+ 1, -wall_thickness_mm],
				[z2+20, -wall_thickness_mm],
			],
			function(zo) togpath1_rath_to_polypoints(togpath1_offset_rath(exterior_rath, zo[1])),
			layer_points_transform = "key0-to-z"
		),
		for( pos=front_attachment_hole_positions ) ["translate", [pos[0],pos[1]], togmod1_make_cuboid([12.7,100,100])],
	])
	["difference",
		the_hull,
		the_cavity,
		for( pos=mount_to_wall_hole_positions) ["translate", pos, mount_to_wall_hole],
		for( pos=front_attachment_hole_positions ) ["translate", pos, front_attachment_hole],
	]
);
