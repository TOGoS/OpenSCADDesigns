// 2020MountableGridfinityTOGridPileCup-v0.4
//
// Gridfinity-on-the-outside, TOGridPile-on-the-inside
// cup with holes for mounting to 2020 T-slot,
// e.g. your 3D printer's framing, probably.
//
// My M3 pan-head screws:
// - threaded diameter: 2.8mm
// - head height: less than 2mm
// - head width: 5.4mm
// 
// Versions:
// v0.2:
// - Height specified in mm instead of dumb gridfinity blocks
// v0.3:
// - Make M3 bores wider and counterbores deeper
// v0.4:
// - Add support for 'back-rect' hole patterns
//   (though OpenSCAD's customizer might not actually let you edit it!)
// - Make proper gridfinity lips

block_size_gfc = [2,1];
block_height   = 19.05; // 0.01
gfc_pitch_gfa  = 6;
gfa_pitch      = 7;
floor_thickness = 6.35;
hole_patterns  = [["bottom-rect", [20,20], "THL-1023"], ["back-rect", [42,21], "THL-1001"]];

debug = "none"; // ["none", "cutaway"]

module __lkasdlkad__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGGridfinityLib-v2.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

$fn = $preview ? 24 : 48;

gfc_pitch  = gfc_pitch_gfa*gfa_pitch;
gfc_size   = [1,1,1] * gfc_pitch;
block_size = [
	block_size_gfc[0] * gfc_pitch,
	block_size_gfc[1] * gfc_pitch,
	block_height
];

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
	togridfinity2_xy_hull([block_size[0], block_size[1], block_size[2]+5]),
];
main_cavity = ["translate", [0,0,cavity_size[2]/2+floor_thickness], tphl1_make_rounded_cuboid(cavity_size, r=[2.5, 2.5, 2.5])];

function hole_positions(pattern_spec, area_size) =
let( spacing = pattern_spec[1] )
[
	for( xm=[-floor(area_size[0]/spacing[0])/2 + 0.5 : 1 : area_size[0]/spacing[0]/2] )
	for( ym=[-floor(area_size[1]/spacing[1])/2 + 0.5 : 1 : area_size[1]/spacing[1]/2] )
	[xm * spacing[0], ym*spacing[1]]
];

all_holes = ["union",
	for( hp=hole_patterns )
	if( hp[0] == "rect" || hp[0] == "bottom-rect" )
	let( hole_type = hp[2] )
	let( hole=tog_holelib2_hole(hole_type, floor_thickness + 1, inset=min(4,floor_thickness*2/3)) )
	each [
		for( pos=hole_positions(hp, block_size) ) ["translate", [pos[0], pos[1], floor_thickness], hole]
	],
	
	for( hp=hole_patterns )
	if( hp[0] == "back-rect" )
	let( hole_type = hp[2] )
	let( hole=["rotate", [90,0,0], tog_holelib2_hole(hole_type, floor_thickness + 1)] )
	each [
		for( pos=hole_positions(hp, block_size) ) ["translate", [pos[0], cavity_size[1]/2, pos[1]], hole]
	]
];

lip_subtraction = ["translate", [0,0,block_size[2]], togridfinity2_lip(block_size)];

block	= ["difference", block_hull, lip_subtraction, main_cavity, all_holes];

// TODO: Screw holes, I suppose on a 20x20mm grid,
// for...pan-head...M3s?

togmod1_domodule(
	debug == "cutaway" ? ["difference", block, ["translate", [0,21,0], ["x-debug", togmod1_make_cuboid([50,42,100])]]] :
	block
);
