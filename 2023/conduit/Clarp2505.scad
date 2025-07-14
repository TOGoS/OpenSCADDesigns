// Clarp2505.1.4
// 
// Prototype clippy thing
// 
// v0.2:
// - Parameterize width and thickness
// v1.0:
// - Add some options, complicate things
// v1.1-clurpy
// - Attempt to add support for generating the clurp shape, but:
//   - Some things that are parameters in Clurp2507 are not
//   - I think the hole placement is a little off (forgot to *u, need to override counterbore inset)
// v1.2
// - Fix hole placement
// v1.3:
// - More specific part names
// v1.4:
// - end_offset option

width_u = 24;
length_u = 2;

part = "Clarp2505"; // ["Clarp2505", "Clarp2505-male", "Clarp2505-female", "Clurp2507-female"]
bottom_corner_shape = "footed"; // ["footed","beveled"]
hole_style = "THL-1006"; 
hole_spacing_u = 24;
slot_length_u = 4;
// How far to extend the ends?
end_offset = -0.1; // 0.1
$tgx11_offset = -0.1;
$fn = 24;

module __clarp2505__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

u = 254/160;

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function extend_point_dat(point, offset=[0,0], scale=[1,1]) =
	[
		(point[0] + offset[0])*scale[0],
		(point[1] + offset[1])*scale[1],
		scale[0] * (len(point) > 2 ? point[2] : 0),
		scale[1] * (len(point) > 3 ? point[3] : 0)
	];

function mirror_points(points, offset=[0,0]) = [
	for(p=points) extend_point_dat(p, offset),
	for(p=reverse_list(points)) extend_point_dat(p, offset, [-1,1]),
];

clarp_face_point_data = [
	[ 2,  0],
	[ 3, -1],
	[ 3, -2],
	[ 2, -3],
];

fpd = mirror_points([
	each bottom_corner_shape == "beveled" ? [
		[ 2, -8],
	] : [
		[ 1, -8, -1, 0],
		[ 1, -7, -1, 1],
	],
	
	[ 0, -6],
	[ 0,  2],
	[ 1,  1],
	[ 1,  0],
	each clarp_face_point_data,
	[ 2, -5],
	[ 3, -6],
], [-width_u/2, 0]);

mpd = mirror_points([
	each bottom_corner_shape == "beveled" ? [
		[ 2,  8],
	] : [
		[ 1,  8, -1, 0],
		[ 1,  7, -1, 1],
	],

	[ 0,  6],
	[ 0,  2],
	each clarp_face_point_data,
	[ 2, -4],
	[ 3, -5],
	[ 4, -5],
	[ 5, -4],
	[ 5,  0],
	[ 2,  3],
	[ 2,  5],
	[ 3,  6],
], [-width_u/2, 0]);

function clarp_pd_to_vec2(pd, scale=1, offset=0) =
	[pd[0]*scale + offset*pd[2], pd[1]*scale + offset*pd[3]];

function clarp_pd_to_polypoints(pd) =
	let(u = togridlib3_decode([1, "u"]))
	[for(p=pd) clarp_pd_to_vec2(p, u, $tgx11_offset)];

// floor_posori = [x,y,rotation,thickness] of 'floor' (where mounting holes go)
function make_clgeneric(shape2d, zrange, floor_posori=[0,0,0,1], end_offset=0) =
	let(u = togridlib3_decode([1, "u"]))
	let(counterbore_inset = min(3.175,floor_posori[3]/2))
	let(hole = ["render", ["rotate", [-90,0,0],
		tog_holelib2_slot(
			hole_style,
			[-4*u, 0*u, 4*u], [[0,-slot_length_u*u/2], if(slot_length_u != 0) [0,slot_length_u*u/2]],
			counterbore_inset = counterbore_inset
		)
	]])
	let(hole_spacing = hole_spacing_u*u)
	["difference",
		togmod1_linear_extrude_z([zrange[0]-end_offset, zrange[1]+end_offset], shape2d),
		["union", for(zc=[zrange[0]/hole_spacing + 0.5 : 1 : zrange[1]/hole_spacing]) ["translate", [floor_posori[0], floor_posori[1], zc*hole_spacing], ["rotate", [0,0,floor_posori[2]], hole]]],
	];

function clarp_pd_to_polyhedron(pd, zrange, floor_posori=[0,0,0,u], end_offset=end_offset) =
	make_clgeneric(togmod1_make_polygon(clarp_pd_to_polypoints(pd)), zrange, floor_posori, end_offset=end_offset);

function mirror_point(point) = [-point[0], point[1]];

function translate_rathnode(node, translation) = [
	node[0],
	node[1] + translation,
	for(i=[2:1:len(node)-1]) node[i]
];

function mirror_rathnode(node) = [
	node[0],
	mirror_point(node[1]),
	for(i=[2:1:len(node)-1]) node[i]
];

function reverse_list(list) = [
	for(i=[len(list)-1:-1:0]) list[i]
];

function translate_and_mirror_rathnodes(nodes, translation) = [
	each              [for(n=nodes)                 translate_rathnode(n, translation) ] ,
	each reverse_list([for(n=nodes) mirror_rathnode(translate_rathnode(n, translation))]),
];

function generate_clurp_rath(rail_width, clip_height, inner_corner_extension=0.3, overhang=1) =
	let(x0 = rail_width/2)
	let(y1 = clip_height)
	let(ce = inner_corner_extension)
	let(ov = overhang) // Overhang
	let(otr = (4-ov)*63/128)
	let(obr = (4-ov)*63/128)
	let(rath_data = [
		["togpath1-rathnode", [ 0   , y1-2], ["round", 2]],
		["togpath1-rathnode", [ 2   , y1-4], ["round", 2]],
		["togpath1-rathnode", [ 2   ,    8], ["round", 3]],
		["togpath1-rathnode", [-2   ,    4], ["round", 0.8]],
		if(ce > 0) ["togpath1-rathnode", [ 0,    4], ["round", 0.8]],
		["togpath1-rathnode", [ 2+ce, 4+ce], /*if(ce > 0) ["round", ce/2]*/],
		["togpath1-rathnode", [ 2-ov, 4-ov], ["round", otr]],
		["togpath1-rathnode", [ 2-ov,    0], ["round", obr]],
		["togpath1-rathnode", [ 4   ,    0], ["round", 1.5]],
		["togpath1-rathnode", [ 4   , y1-3], ["round", 3]],
		["togpath1-rathnode", [ 1   , y1-0], ["round", 3]],
	])
	["togpath1-rath", each translate_and_mirror_rathnodes(rath_data, [x0,0])];

function make_clurp_2d() =
	["scale", u, togpath1_rath_to_polygon(
		generate_clurp_rath(
			12, 16 // rail_width_u, height_u
			//inner_corner_extension = inner_corner_extension_u,
			//overhang = clip_overhang_u
		)
	)];

function make_clurp() =
	make_clgeneric(make_clurp_2d(), [0, length_u*u], [0,14*u,180,2*u], end_offset=end_offset);

function make_the_thing(part) =
	part == "Clarp2505" ? ["union",
		["translate", [0, -4*u], make_the_thing("Clarp2505-female")],
		["translate", [0,  4*u], make_the_thing("Clarp2505-male")],
	] :
	part == "Clurp2507-female" ? make_clurp() :
	part == "Clarp2505-male" ? clarp_pd_to_polyhedron(
		mpd, [0, length_u*u], [0, 6*u,180,2*u]
	) :
	part == "Clarp2505-female" ? clarp_pd_to_polyhedron(
		fpd, [0, length_u*u], [0,-6*u,  0,2*u]
	) :
	assert(false, str("Unrecognized part: '", part, "'"));

togmod1_domodule(make_the_thing(part));
