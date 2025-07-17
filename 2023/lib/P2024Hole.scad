// TinyScreenPanel0.2
// 
// Main part of screen
// 27.3mm wide x 19.5mm tall should do for screen
// Maybe leave 12.7mm at top and bottom for pin heads and the cable
// Whole board is 28.5mm wide x 27.6mm tall
// Mounting hole centers are on corners of a ~24mm square
// 
// Changes:
// v0.2:
// - Make thickness configurable

glass_cutout_width_mm   = 27.3;
glass_cutout_height_mm  = 19.5;
extra_cutout_width_mm   = 12.7;
extra_cutout_height_mm  = 26.0;
module_cutout_width_mm  = 28.9;
module_cutout_height_mm = 28.0;
thickness_mm = 3.175;

$fn = 24;

module tinyscreenpanel0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

function p2024__reverse_list(list, mapping=function(item) item) = [for(i=[len(list)-1 : -1 : 0]) mapping(list[i])];

function p2024__mirror_points_r_to_l(points) = p2024__reverse_list(points, function(p) [-p[0],  p[1]]);
function p2024__mirror_points_t_to_b(points) = p2024__reverse_list(points, function(p) [ p[0], -p[1]]);

function p2024__extrapolate_tr(points) =
	let( top = [each points, each p2024__mirror_points_r_to_l(points)] )
	[each top, each p2024__mirror_points_t_to_b(top)];

glass_cutout_2d = togmod1_make_polygon(p2024__extrapolate_tr(
let( b = 1.5 )[
	[glass_cutout_width_mm/2  , glass_cutout_height_mm/2  ],
	[extra_cutout_width_mm/2+b, glass_cutout_height_mm/2  ],
	[extra_cutout_width_mm/2  , glass_cutout_height_mm/2+b],
	[extra_cutout_width_mm/2  , extra_cutout_height_mm/2  ],
]));

module_cutout_2d = togmod1_make_rect([module_cutout_width_mm, module_cutout_height_mm]);
tiny_screw_hole_2d = togmod1_make_circle(d=2);

function p2024_make_hole(zrange, front_thickness=1.6) =
zrange[0] > zrange[1] ? ["translate", [0,0,-zrange[1]-zrange[0]], ["rotate",[180,0,0],p2024_make_hole([zrange[1],zrange[0]], front_thickness=front_thickness)]] :
["union",
	togmod1_linear_extrude_z([zrange[0]-1, zrange[1]+1], ["union",
		glass_cutout_2d,
		for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*12,ym*12], tiny_screw_hole_2d],
	]),
	togmod1_linear_extrude_z([zrange[0] + front_thickness, zrange[1]+2], module_cutout_2d),
];
