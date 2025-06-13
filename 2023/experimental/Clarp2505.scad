// Clarp2505.0.1
// 
// Prototype clippy thing

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

u = 254/160;

thickness = 2*u;

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_points(points) = [
	for(p=points) p,
	for(p=reverse_list(points)) [-p[0], p[1]]
];

pd1 = mirror_points([
	[-10, -8],
	[-12, -6],
	[-12,  2],
	[-11,  1],
	[-11,  0],
	[-10,  0],
	[- 9, -1],
	[- 9, -2],
	[-10, -3],
	[-10, -5],
	[- 9, -6],
]);

pd2 = mirror_points([
	[-10,  8],
	[-12,  6],
	[-12,  2],
	[-10,  0],
	[- 9, -1],
	[- 9, -2],
	[-10, -3],
	[-10, -4],
	[- 9, -5],
	[- 8, -5],
	[- 7, -4],
	[- 7,  0],
	[-10,  3],
	[-10,  5],
	[- 9,  6],
]);


togmod1_domodule(togmod1_linear_extrude_z([0, thickness], togmod1_make_polygon([for(p=pd1) p*254/160])));

translate([0,8*u]) togmod1_domodule(togmod1_linear_extrude_z([0, thickness], togmod1_make_polygon([for(p=pd2) p*254/160])));
