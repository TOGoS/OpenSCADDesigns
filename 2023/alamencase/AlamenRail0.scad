// AlamenRail0.1

length_inches = 11.5;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

function make_alamenrail0(length) =
let( rail_side_padding = 3.175 )
let( width = 12.7 + rail_side_padding )
let( height = 12.7 )
//let( y_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-width, width], d=5, $fn=24)] )
let( y_hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1005", depth=width+1, $fn=24)] )
let( z_hole = tphl1_make_z_cylinder(zrange=[-height, height], d=5, $fn=24) )
let( rail_hull = ["translate", [0, rail_side_padding/2,0], tphl1_make_rounded_cuboid([length, width, height], r=[3.175, 3.175, 0.5], corner_shape="ovoid1", $fn=24)] )
["difference",
	rail_hull,
	for( xm = [-round(length/12.7)/2 + 1.5 : 2 : length/12.7/2] ) ["translate", [xm*12.7, 0, 0], z_hole],
	for( xm = [-round(length/12.7)/2 + 0.5 : 2 : length/12.7/2] ) ["translate", [xm*12.7, -6.35, 0], y_hole],
];

togmod1_domodule(make_alamenrail0(11.5*25.4));
