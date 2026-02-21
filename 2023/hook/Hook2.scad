// Hook2.5
//
// Changes:
// v2.1
// - Front/back curve radii separately configurable
// v2.2
// - Front tips rounded
// - Front and back tips' rounding will be limited
//   to keep the shape valid even when hook is very short
// v2.3:
// - Changes to hole position calculation;
//   should be the same for wide hooks (like p1418 and p1419)
//   but work better for narrow hooks (like p1609)
// v2.4:
// - Option for back_curve_inner_radius_u separate from outer radius
// - Fix front lip height to avoid invalid shapes
// v2.5:
// - Option for holes at multiple Y positions.

total_height_u = 48;
front_height_u = 16;
thickness_u    =  2;
outer_depth_u  = 24;
front_curve_radius_u = 999; // 0.01
// Will be clamped as necessary based on hook depth
back_curve_radius_u  = 999; // 0.01
// Will be clamped as necessary based on outer radius and hook depth; 0 to follow outer
back_curve_inner_radius_u = 0; // 0.01
width_u        = 24;
// e.g. "3/4inch"; if non-blank, will make multiple holes at different Y position
hole_y_spacing = "";

module __asdmlkaslkd__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGUnits1.scad>

$fn = $preview ? 24 : 64;

hole_y_spacing_mm = hole_y_spacing == "" ? -1 : togunits1_to_mm(hole_y_spacing);

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
r_bo_max = min(y3-y0 - r_c - 0.25, (x2-x0)/2 - 0.25);
r_bo = min( back_curve_radius_u * u, r_bo_max);
r_fo = min(front_curve_radius_u * u, y2-y0 - r_c - 0.25, (x2-x0)/2 - 0.25);
r_bi = min(r_bo_max - thickness, max(back_curve_inner_radius_u * u, r_bo - thickness, 0));
r_fi = max(r_fo - thickness, 0);

function make_hook_rath(y2, y3) = ["togpath1-rath",
	["togpath1-rathnode", [x3, y0], ["round", r_bo]],
	["togpath1-rathnode", [x3, y3], ["round", r_c]],
	["togpath1-rathnode", [x2, y3], ["round", r_c]],
	["togpath1-rathnode", [x2, y1], ["round", r_bi]],
	["togpath1-rathnode", [x1, y1], ["round", r_fi]],
	["togpath1-rathnode", [x1, y2], ["round", r_c]],
	["togpath1-rathnode", [x0, y2], ["round", r_c]],
	["togpath1-rathnode", [x0, y0], ["round", r_fo]],
];

z_corner_radius = min(hole_spacing, width/2-0.5);



body = tphl1_make_polyhedron_from_layer_function([
	for(am=[0 : 1 : ceil($fn/4)]) let(ang=180 - 90*am/ceil($fn/4)) [    0 + z_corner_radius + z_corner_radius*cos(ang), sin(ang)-1],
	for(am=[0 : 1 : ceil($fn/4)]) let(ang= 90 - 90*am/ceil($fn/4)) [width - z_corner_radius + z_corner_radius*cos(ang), sin(ang)-1],
], function(p)
	// Ideally YZ curves are r=z_corner_radius, but since the front or back could be very short,
	// the curve might need to be smashed down, which for now I just do by scaling.
	// It might be better to calculate the back and front points completely separately!
	// This would complicate the 3Dification of the raths, though.
	let(front_rounding_depth = min(z_corner_radius, max(0, y2 - r_fo - r_c - 0.25))) // Not sure this is right?
	let( back_rounding_depth = min(z_corner_radius, max(0, y3 - r_bo - 0.25)))
	let(polypoints = togpath1_rath_to_polypoints(make_hook_rath(
		y2 + p[1] * front_rounding_depth,
		y3 + p[1] *  back_rounding_depth
	)))
	togvec0_offset_points(polypoints, p[0])
);

hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zrange=[-thickness, +thickness], d=hole_diameter)];

first_hole_y_position = y3 - min(width/2, hole_spacing);
hole_y_positions =
	hole_y_spacing_mm <= 0 ? [first_hole_y_position] :
	[for( y=[first_hole_y_position : -hole_y_spacing_mm : r_bo] ) y];

// Old logic; gives 'wrong' result when width is small:
//hole_z_positions_hs = [round(-width/2/hole_spacing)+1 : 1 : width/2/hole_spacing-0.4];
hole_z_positions_hs = [round(-width/hole_spacing)/2+0.5 : 1 : width/hole_spacing/2-0.4];
hole_z_positions = [for(zm=hole_z_positions_hs) hole_spacing*zm];
holes = ["union", for(z=hole_z_positions) for(y=hole_y_positions)
	["translate", [-thickness/2, y, width/2 + z], hole]];

thing = ["difference", body, ["x-debug", holes]];

togmod1_domodule(thing);
