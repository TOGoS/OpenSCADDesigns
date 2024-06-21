// CounterboreFiller1.3
//
// Changes:
// v1.1: Make parametrically instead of using a DXF
// v1.2: Do it with TOGMod!
// v1.3:
// - hole_style has more options
// - rounding_radius configurable

thickness = 3.175;
bevel_size = 0.5;
hole_style = "THL-1001"; // ["none","THL-1001","THL-1002","THL-1004","THL-1005","THL-1006"]
square_length   = 19.05; // 0.01
circle_diameter = 21.00; // 0.01
rounding_radius =  6.35; // 0.01

// Some approaches to making the rounded square/circle intersection:
// - Use the DXF (v1.0)
// X Minkowski a square/circle intersection
// - Smash the points of a circle-based polygon into a rectangle,
//   smoothed by ~some algorithm~

$fn = $preview ? 24 : 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1Constructors.scad>

function roundify_2d(rounding_radius, shape) =
	rounding_radius <= 0 ? shape : ["minkowski", shape, togmod1_make_circle(r=rounding_radius, $fn=$fn*2)];

function hull_shape_2d(off=0, rounding_radius=rounding_radius) = roundify_2d(rounding_radius, ["intersection",
	togmod1_make_rounded_rect([square_length + off*2 - rounding_radius*2, square_length + off*2 - rounding_radius*2], r=0),
	togmod1_make_circle(d = circle_diameter + off*2 - rounding_radius*2, $fn=$fn*2)
]);

function the_hull() = ["hull",
	["linear-extrude-zs", [0           , thickness           ], hull_shape_2d(off=-bevel_size)],
	["linear-extrude-zs", [0+bevel_size, thickness-bevel_size], hull_shape_2d(off=0)],
];

togmod1_domodule(["difference",
	the_hull(),
	["translate", [0,0,thickness], tog_holelib2_hole(hole_style, depth=thickness+1, inset=0.5)]
]);
