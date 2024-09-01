// SmallHemisphere1.0
// 
// Hemisphere for making a rounded end on something, or something.

diameter = 12.7;
hole_style = "THL-1005"; // ["THL-1005","straight-3mm","straight-4mm","straight-5mm"]

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __smallhemisphere1__end_params() { }

inch = 25.4;

sphere_fn = $preview ? 32 : 64;

$fn = 24;

d = diameter;

hemi = ["intersection",
	tphl1_make_rounded_cuboid([d, d, d], r=d/2-0.1, $fn=sphere_fn),
	["translate", [0,0,d], togmod1_make_cuboid([d*2, d*2, d*2])],
];

hole =
	hole_style == "straight-3mm" ? tphl1_make_z_cylinder(d=3, zrange=[-d, +d]) :
	hole_style == "straight-4mm" ? tphl1_make_z_cylinder(d=4, zrange=[-d, +d]) :
	hole_style == "straight-5mm" ? tphl1_make_z_cylinder(d=5, zrange=[-d, +d]) :
	tog_holelib2_hole(hole_style, depth=d, overhead_bore_height=d, inset=0);

thing1 = ["difference",
	hemi,
	
	["translate", [0,0,d/4], hole],
];

togmod1_domodule(thing1);
