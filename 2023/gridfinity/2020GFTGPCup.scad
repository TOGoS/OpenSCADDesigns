// 2020MountableGridfinityTOGridPileCup-v0.1-dev
//
// Gridfinity-on-the-outside, TOGridPile-on-the-inside
// cup with holes for mounting to 2020 T-slot,
// e.g. your 3D printer's framing, probably.

block_size_gfc = [2,1,1];
gfc_pitch_gfa  = 6;
gfa_pitch      = 7;

debug = "none"; // ["none", "cutaway"]

module __lkasdlkad__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGGridfinityLib-v2.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 24;

gfc_pitch  = gfc_pitch_gfa*gfa_pitch;
gfc_size   = [1,1,1] * gfc_pitch;
block_size = block_size_gfc * gfc_pitch;

cavity_size = [block_size[0]-3.5, block_size[1]-3.5, 100];
echo(cavity_size);

foot = togridfinity2_foot([gfc_pitch,gfc_pitch,block_size[2]]);
feet = ["union",
	for( xm=[-block_size_gfc[0]/2+0.5 : 1 : block_size_gfc[0]/2] )
	for( ym=[-block_size_gfc[1]/2+0.5 : 1 : block_size_gfc[1]/2] )
	["translate", [xm*gfc_pitch, ym*gfc_pitch], foot]
];
block_hull = ["intersection",
	feet,
	togridfinity2_xy_hull(block_size), // Might want to do a proper gridfinity lip!
];
main_cavity = ["translate", [0,0,50+6.35], tphl1_make_rounded_cuboid(cavity_size, r=[2.5, 2.5, 2.5])];
block = ["difference", block_hull, main_cavity];

// TODO: Screw holes, I suppose on a 20x20mm grid,
// for...pan-head...M3s?

togmod1_domodule(
	debug == "cutaway" ? ["difference", block, ["translate", [0,21,0], ["x-debug", togmod1_make_cuboid([50,42,100])]]] :
	block
);
