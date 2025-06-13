// Clarp2505.0.2
// 
// Prototype clippy thing
// 
// v0.2:
// - Parameterize width and thickness

width_u = 24;
thickness_u = 2;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

u = 254/160;

thickness = thickness_u * u;

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_points(points, offset=[0,0]) = [
	for(p=points) p + offset,
	for(p=reverse_list(points)) [-p[0], p[1]] - offset
];

pd1 = mirror_points([
	[ 2, -8],
	[ 0, -6],
	[ 0,  2],
	[ 1,  1],
	[ 1,  0],
	[ 2,  0],
	[ 3, -1],
	[ 3, -2],
	[ 2, -3],
	[ 2, -5],
	[ 3, -6],
], [-width_u/2, 0]);

pd2 = mirror_points([
	[ 2,  8],
	[ 0,  6],
	[ 0,  2],
	[ 2,  0],
	[ 3, -1],
	[ 3, -2],
	[ 2, -3],
	[ 2, -4],
	[ 3, -5],
	[ 4, -5],
	[ 5, -4],
	[ 5,  0],
	[ 2,  3],
	[ 2,  5],
	[ 3,  6],
], [-width_u/2, 0]);


togmod1_domodule(togmod1_linear_extrude_z([0, thickness], togmod1_make_polygon([for(p=pd1) p*254/160])));

translate([0,8*u]) togmod1_domodule(togmod1_linear_extrude_z([0, thickness], togmod1_make_polygon([for(p=pd2) p*254/160])));
