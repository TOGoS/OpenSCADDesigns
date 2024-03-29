// 2020Baseplate - DRAFT
// 
// TOGridPile base plate to be attached to 2x20mm V-slot rails,
// which seem to be what my 3D printers are made of.
//
// TODO: For this to work, need to work out what size flathead
// screws can be used to fasten these to the rails,
// and what shape hole to make for them.
//
// Versions:
// 0.1: Initial attempt
// 0.2: Round the corners

size = [76.2, 40];

floor_thickness = 3.175;
lip_height = 1.6;

$tgx9_mating_offset = -0.075;
$fn = 32;

use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib-v1.scad>

chunk_magnet_hole_positions = [for(xm=[-1,1]) for(ym=[-1,1]) [xm*12.7,ym*12.7]];

function rounded_square_points(size, r) = [
	for( i=[  0 : 15 :  90] ) [ size[0]/2 - r + r*cos(i),  size[1]/2 - r + r*sin(i)],
	for( i=[ 90 : 15 : 180] ) [-size[0]/2 + r + r*cos(i),  size[1]/2 - r + r*sin(i)],
	for( i=[180 : 15 : 270] ) [-size[0]/2 + r + r*cos(i), -size[1]/2 + r + r*sin(i)],
	for( i=[270 : 15 : 360] ) [ size[0]/2 - r + r*cos(i), -size[1]/2 + r + r*sin(i)],
];

module rounded_square(size, r) {
	polygon(rounded_square_points(size, r));
}

difference() {
	linear_extrude(floor_thickness+lip_height) {
		rounded_square([size[0], size[1]], 3.175);
	}

	corner_radius     = togridlib3_decode([1, "f-outer-corner-radius"]);
	translate([0,0,floor_thickness]) {
		tgx9_block_foot(
			[[floor(size[0]/38.1), "chunk"], [floor(size[1]/38.1), "chunk"], [1, "chunk"]],
			corner_radius = corner_radius,
			foot_segmentation = "chunk",
			offset = -$tgx9_mating_offset,
			$tgx9_force_bevel_rounded_corners = false,
			chunk_ops = [
				for(p=chunk_magnet_hole_positions)
				["add", ["translate", p, ["cylinder", 6.2, 4.8]]]
			]
		);
	}

	for( x=[-floor(size[0]/38.1)+0.5 : 1 : size[1]/20/2] ) {
		for( y=[-10,10] ) translate([x*38.1, y, floor_thickness]) {
			// TODO: Figure out what kind of M-whats
			// need to be used with those V-slot nuts,
			// figure out their head profile, replace:
			tog_holelib_hole("THL-1001");
		}
	}
}
