// Clarp2505.1.0
// 
// Prototype clippy thing
// 
// v0.2:
// - Parameterize width and thickness
// v1.0:
// - Add some options, complicate things

width_u = 24;
length_u = 2;

part = "both"; // ["male", "female", "both"]
bottom_corner_shape = "footed"; // ["footed","beveled"]
hole_style = "THL-1006"; 
hole_spacing_u = 24;
slot_length_u = 4;
$tgx11_offset = -0.1;
$fn = 24;

module __clarp2505__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1Constructors.scad>

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

function clarp_pd_to_polyhedron(pd, zrange, floor_posori=[0,0,0]) =
	let(u = togridlib3_decode([1, "u"]))
	let(hole = ["render", ["rotate", [-90,0,0], tog_holelib2_slot(hole_style, [-4*u, 0*u, 4*u], [[0,-slot_length_u*u/2], [0,slot_length_u*u/2]])]])
	let(hole_spacing = hole_spacing_u*u)
	["difference",
		togmod1_linear_extrude_z(zrange, togmod1_make_polygon(clarp_pd_to_polypoints(pd))),
		["union", for(zc=[zrange[0]/hole_spacing + 0.5 : 1 : zrange[1]/hole_spacing]) ["translate", [floor_posori[0], floor_posori[1], zc*hole_spacing], ["rotate", [0,0,floor_posori[2]], hole]]],
	];

function make_the_thing(part) =
	part == "both" ? ["union",
		["translate", [0, -4*u], make_the_thing("female")],
		["translate", [0,  4*u], make_the_thing("male")],
	] :
	clarp_pd_to_polyhedron(
		part == "male" ? mpd : fpd,
		[0, length_u*u],
		part == "male" ? [0,8,180] : [0,-8,0]
	);

togmod1_domodule(make_the_thing(part));
