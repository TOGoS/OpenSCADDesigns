// TOGLEGO-v0.3
// 
// Experiment to see if I can print LEGO bricks
// precisely enough with a simple SCAD design.
// 
// See https://i.stack.imgur.com/OjziU.png for basic LEGO dimensions
// Mirror: http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:RWKDHKYVSJVWUSPW3Y4KKMIMTPOD4HZA.VMCQTN2VYTDMM4JQJOWZGMPIQMTPQERBIBMD2SA/OjziU.png
//
// Versions:
// v0.1:
// - Basic plate with nubbins
// - Note that outer_margin is currently ignored; set it to 0.0 for forward compatibility
// v0.2:
// - Option to have a TOGridPile foot,
//   change default size to 8x8
// - outer_margin still ignored
// v0.3
// - Fix parameter precision

block_size_nubs = [8, 8];
// 8 = LEGO standard; 7.9375 = 5/16", a close approximation 1.0078740157480315
nub_pitch = 8; // 0.0001
outer_margin = 0.0; // 0.01
nubbin_height = 1.8; // 0.01
// 4.8 = ideal diameter according to https://i.stack.imgur.com/OjziU.png
nubbin_diameter = 4.8;
// 1.5875 = 1/16", 6.35 = 1/4", good for TOGridPile adapters
plate_thickness = 6.35; // 0.0001

base_style = "flat"; // ["flat", "tgx9-atomic"]
$tgx9_mating_offset = -0.1;
$tgx9_chatomic_foot_column_style = "v6.2";
$fn = $preview ? 24 : 64;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>

module toglego_base_xy_hull(size) {
	linear_extrude(size[2]) {
		tog_shapelib_rounded_beveled_square(size, 3.175, 3.175);
	}
}

$togridlib3_unit_table = [
	["nub", [nub_pitch, "mm"], "LEGO nubbin pitch"],
	["chunk", [1, "atom"], "chunk"],
	each togridlib3_get_unit_table()
];

atom_pitch = togridlib3_decode([1, "atom"]);
block_size_1 = togridlib3_decode_vector([
	[block_size_nubs[0], "nub"],
	[block_size_nubs[1], "nub"],
	[plate_thickness, "mm"]
]);
// Outer size of block, not taking offset into account
block_size = base_style == "tgx9-atomic" ?
	[
		floor(block_size_1[0] / atom_pitch) * atom_pitch,
		floor(block_size_1[1] / atom_pitch) * atom_pitch,
		block_size_1[2]
	] : block_size_1;
block_size_ca = [
	for( dim=block_size ) [dim, "mm"]
];

intersection() {
	toglego_base_xy_hull(block_size);

	if( base_style == "tgx9-atomic" ) {
		echo(block_size=block_size);
		
		tgx9_block_foot(
			block_size_ca,
			foot_segmentation = "chatom",
			v6hc_style = "v6.0",
			corner_radius = 6.35,
			offset = $tgx9_mating_offset
		);
	}
}

translate([0,0,plate_thickness-1]) linear_extrude(nubbin_height + 1) {
	for( yc=[-block_size_nubs[1]/2+0.5 : 1 : block_size_nubs[1]/2] )
	for( xc=[-block_size_nubs[0]/2+0.5 : 1 : block_size_nubs[0]/2] )
		translate([xc,yc]*nub_pitch) circle(d=nubbin_diameter);
}
