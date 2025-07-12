// Main part of screen
// 27.3mm wide x 19.5mm tall should do for screen
// Maybe leave 12.7mm at top and bottom for pin heads and the cable
// Whole board is 28.5mm wide x 27.6mm tall
// Mounting hole centers are on corners of a ~24mm square

glass_cutout_width_mm   = 27.3;
glass_cutout_height_mm  = 19.5;
extra_cutout_width_mm   = 12.7;
extra_cutout_height_mm  = 26.0;
module_cutout_width_mm  = 28.9;
module_cutout_height_mm = 28.0;

$fn = 24;

module tinyscreenpanel0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>

function reverse_list(list, mapping=function(item) item) = [for(i=[len(list)-1 : -1 : 0]) mapping(list[i])];

function mirror_points_r_to_l(points) = reverse_list(points, function(p) [-p[0],  p[1]]);
function mirror_points_t_to_b(points) = reverse_list(points, function(p) [ p[0], -p[1]]);

function extrapolate_tr(points) =
	let( top = [each points, each mirror_points_r_to_l(points)] )
	[each top, each mirror_points_t_to_b(top)];

glass_cutout_2d = togmod1_make_polygon(extrapolate_tr(
let( b = 1.5 )[
	[glass_cutout_width_mm/2, glass_cutout_height_mm/2],
	[extra_cutout_width_mm/2+b, glass_cutout_height_mm/2],
	[extra_cutout_width_mm/2, glass_cutout_height_mm/2+b],
	[extra_cutout_width_mm/2, extra_cutout_height_mm/2],
]));

block_2d = togmod1_make_rounded_rect([38.1, 38.1], r=5);
module_cutout_2d = togmod1_make_rect([module_cutout_width_mm, module_cutout_height_mm]);
tiny_screw_hole_2d = togmod1_make_circle(d=2);

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0,3.175], ["difference",
		block_2d,
		glass_cutout_2d,
		for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*12,ym*12], tiny_screw_hole_2d],
	]),
	togmod1_linear_extrude_z([3.175/2,3.175*2], module_cutout_2d),
]);
