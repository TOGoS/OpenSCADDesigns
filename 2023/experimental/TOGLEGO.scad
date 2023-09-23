// TOGLEGO-v0.4
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
// v0.4:
// - Rename 'plate_thickness' to 'block_height'
// - Add option for LEGO bottom

block_size_nubs = [8, 8];
// 8 = LEGO standard; 7.9375 = 5/16", a close approximation 1.0078740157480315
nub_pitch = 8; // 0.0001
outer_margin = 0.0; // 0.01
nubbin_height = 1.8; // 0.01
// 4.8 = ideal diameter according to https://i.stack.imgur.com/OjziU.png
nubbin_diameter = 4.8;
// 1.5875 = 1/16", 6.35 = 1/4", good for TOGridPile adapters, 3.2 = LEGO plate, 9.6 = regular LEGO brick
block_height = 6.35; // 0.0001

base_style = "flat"; // ["flat", "tgx9-atomic", "lego"]
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
	[block_height, "mm"]
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

	if( base_style == "flat" ) {
		cube(block_size*10, center=true);
	} else if( base_style == "tgx9-atomic" ) {
		echo(block_size=block_size);
		
		tgx9_block_foot(
			block_size_ca,
			foot_segmentation = "chatom",
			v6hc_style = "v6.0",
			corner_radius = 6.35,
			offset = $tgx9_mating_offset
		);
	} else if( base_style == "lego" ) {
		margin = 0.1;
		wall_thickness = 1.2 + 0.1;
		top_thickness = 1;
		reinforcement_thickness = 0.8;
		circle_od = 6.51;
		circle_id = 4.8;
		
		difference() {
			linear_extrude(block_size[2]) tog_shapelib_rounded_square([
				block_size_nubs[0] * nub_pitch - margin*2,
				block_size_nubs[1] * nub_pitch - margin*2,
			], nub_pitch/2 - margin);

			translate([0,0,-top_thickness]) linear_extrude(block_size[2]) {
				difference() {
					tog_shapelib_rounded_square([
						block_size_nubs[0] * nub_pitch - margin*2 - wall_thickness*2,
						block_size_nubs[1] * nub_pitch - margin*2 - wall_thickness*2,
					], nub_pitch/2 - margin - wall_thickness);

					difference() {
						union() {
							// Y-axis reinforcements
							for( xn=[-block_size_nubs[0]/2+1 : 1 : block_size_nubs[0]/2-1] ) {
								translate([xn * nub_pitch, 0]) square([
									reinforcement_thickness,
									block_size_nubs[1] * nub_pitch - margin*2 - wall_thickness
								], center=true);
							}
							// X-axix reinforcements
							for( yn=[-block_size_nubs[1]/2+1 : 1 : block_size_nubs[1]/2-1] ) {
								translate([0, yn * nub_pitch]) square([
									block_size_nubs[0] * nub_pitch - margin*2 - wall_thickness,
									reinforcement_thickness
								], center=true);
							}
							// Circle exteriors
							for( xn=[-block_size_nubs[0]/2+1 : 1 : block_size_nubs[0]/2-1] )
							for( yn=[-block_size_nubs[1]/2+1 : 1 : block_size_nubs[1]/2-1] )
							{
								translate([xn * nub_pitch, yn * nub_pitch]) circle(d=circle_od);
							}
						}
						
						// Circle interiors
						for( xn=[-block_size_nubs[0]/2+1 : 1 : block_size_nubs[0]/2-1] )
						for( yn=[-block_size_nubs[1]/2+1 : 1 : block_size_nubs[1]/2-1] )
						{
							translate([xn * nub_pitch, yn * nub_pitch]) circle(d=circle_id);
						}
					}
				}
			}
		}
	}
}

translate([0,0,block_height-0.1]) linear_extrude(nubbin_height + 0.1) {
	for( yc=[-block_size_nubs[1]/2+0.5 : 1 : block_size_nubs[1]/2] )
	for( xc=[-block_size_nubs[0]/2+0.5 : 1 : block_size_nubs[0]/2] )
		translate([xc,yc]*nub_pitch) circle(d=nubbin_diameter);
}
