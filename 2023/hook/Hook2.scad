// Hook2.0

total_height_u = 48;
front_height_u = 16;
thickness_u    =  2;
outer_depth_u  = 24;
outer_curve_radius_u = 999;
width_u        = 24;

module __asdmlkaslkd__end_params() { }

hole_spacing = 19.05;
hole_diameter = 7.9375;

u = 1.5875;
width = width_u*u;
thickness = thickness_u*u;

x0 = (-outer_depth_u              )*u;
x1 = (-outer_depth_u + thickness_u)*u;
x2 = (               - thickness_u)*u;
x3 = (                           0)*u;

y0 = 0;
y1 = thickness_u*u;
y2 = front_height_u*u;
y3 = total_height_u*u;

r_c = thickness/3;
r_o = min(outer_curve_radius_u, y2-y0 - r_c - 0.25, (x2-x0)/2 - 0.25);
r_i = max(r_o - thickness, 0);

function make_hook_rath(y3) = ["togpath1-rath",
	["togpath1-rathnode", [x3, y0], ["round", r_o]],
	["togpath1-rathnode", [x3, y3], ["round", r_c]],
	["togpath1-rathnode", [x2, y3], ["round", r_c]],
	["togpath1-rathnode", [x2, y1], ["round", r_i]],
	["togpath1-rathnode", [x1, y1], ["round", r_i]],
	["togpath1-rathnode", [x1, y2], ["round", r_c]],
	["togpath1-rathnode", [x0, y2], ["round", r_c]],
	["togpath1-rathnode", [x0, y0], ["round", r_o]],
];

z_corner_radius = min(hole_spacing, width/2-0.5);

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

$fn = $preview ? 24 : 64;

body = tphl1_make_polyhedron_from_layer_function([
	for(am=[0 : 1 : ceil($fn/4)]) let(ang=180 - 90*am/ceil($fn/4)) [    0 + z_corner_radius + z_corner_radius*cos(ang), z_corner_radius*(sin(ang)-1)],
	for(am=[0 : 1 : ceil($fn/4)]) let(ang= 90 - 90*am/ceil($fn/4)) [width - z_corner_radius + z_corner_radius*cos(ang), z_corner_radius*(sin(ang)-1)],
], function(p)
	let(polypoints = togpath1_rath_to_polypoints(make_hook_rath(y3 + p[1])))
	togvec0_offset_points(polypoints, p[0])
);

hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zrange=[-thickness, +thickness], d=hole_diameter)];

holes = ["union", for(zm=[round(-width/2/hole_spacing)+1 : 1 : width/2/hole_spacing-0.4])
	echo(zm)
	["translate", [-thickness/2, y3-hole_spacing, width/2 + zm*hole_spacing], hole]];

thing = ["difference", body, ["x-debug", holes]];

togmod1_domodule(thing);
