// MatchfitHexHeadNut-v1.2
//
// v1.1:
// - Default bottom_margin reduced to 0.5mm,
//   hex_head_diameter increased by 0.4mm
// v1.2:
// - Make hex_head_depth configurable,
//   default to 4.7mm

bottom_margin     =  0.5; // 0.1
top_margin        =  1.0; // 0.1
hex_head_diameter = 11.7; // 0.1
hex_head_depth    =  4.7; // 0.1

inch = 25.4;
hole_diameter = 1/4*inch + 0.5;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 24;

z0 = bottom_margin;
z2 = 3/8*inch - top_margin;
z1 = z2 - 1;

function nut_hull() = tphl1_make_polyhedron_from_layer_function([
	[z0, -3/32*inch + (z0*0.25)],
	[z1, 0 - (3/8*inch - z1)*0.25],
	[z2, 0 - (3/8*inch - z1)*0.25],
],
	function(params)
	let(z=params[0])
	let(offset=params[1])
	[ for( p = togpath1_rath_to_points(["togpath1-rath",
		["togpath1-rathnode", [-3/4*inch, -1/4*inch], ["round", 1/4*inch-1], ["offset", offset]],
		["togpath1-rathnode", [ 3/4*inch, -1/4*inch], ["round", 1/4*inch-1], ["offset", offset]],
		["togpath1-rathnode", [ 3/4*inch,  1/4*inch], ["round", 1/4*inch-1], ["offset", offset]],
		["togpath1-rathnode", [-3/4*inch,  1/4*inch], ["round", 1/4*inch-1], ["offset", offset]],
	])) [p[0], p[1], z] ]
);

function head_hole() = ["union",
	tphl1_make_z_cylinder(d=hole_diameter, zrange=[-1, 3/8*inch+1]),
	tphl1_extrude_polypoints([z2-hex_head_depth, z2+1], [
		[-hex_head_diameter/cos(30)/2, 0],
		[                           0, -hex_head_diameter/cos(60)/2],
		[+hex_head_diameter/cos(30)/2, 0],
		[                           0, +hex_head_diameter/cos(60)/2],
	]),
	// tphl1_make_z_cylinder(d=hex_head_diameter/cos(30), zrange=[3/8*inch-5, 3/8*inch+1], $fn=6), // (cos (* pi 2 (/ 30 360.0)))
];

togmod1_domodule(["difference",
	nut_hull(),
	head_hole()
]);
