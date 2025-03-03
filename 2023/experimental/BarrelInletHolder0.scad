// BarrelInletHolder0.1
// 
// Demonstration of counterbored hole for one of these panel-mount 2.1mm barrel inlets
// that can be printed on the bottom of something.
// 
// Basically this is a test of the counterbored bottom-side hole with
// 'overhang remedy', and whether I got the dimensions right.
// 
// Measurements:
// Head: 4.25mm tall, up to 10.5mm wide
// Shaft: about 7.7mm in diameter
// Total height: 17.75mm

counterbore_depth    = 5;
counterbore_diameter = 11;
shaft_diameter = 8.5;
block_size = [19.05,19.05,19.05];
block_outer_offset = -0.05;
$fn = 64;

module barrelinletholder0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([-block_size[2]/2-block_outer_offset, block_size[2]/2+block_outer_offset], togpath1_make_rounded_beveled_rect([block_size[0], block_size[1]], 3.175, 3.175, offset=block_outer_offset)),
	//tphl1_make_rounded_cuboid(block_size, r=[3,3,0]),
	
	["translate", [0,0,-block_size[2]/2], ["rotate", [180,0,0], tog_holelib2_counterbored_with_remedy_hole(
		counterbore_d = counterbore_diameter,
		shaft_d = shaft_diameter,
		depth = 50,
		overhead_bore_height = 1,
		remedy_depth=0.4,
		inset = counterbore_depth
	)]]
]);
