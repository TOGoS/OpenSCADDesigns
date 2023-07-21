// WeMosD1MiniSpacer-v1.1
//
// Versions:
// v1.0:
// - Initial, too tight
// v1.1:
// - Options for hole size and margin, and default to a lot more of it

// 1/32" = 0.79375, 3/64" = 1.19
hole_size = 1.0; // 0.1
// Shrink blocks and enlarge holes by this much; basically x/y offset, so better to do it using your slicer
margin    = 0.0; // 0.025

use <../lib/TOGBreadBoardLib1.scad>

cell = tog_bbl1_decode([1, "bb-cell"]);

for( asd=[[0,1],[9,0]] ) translate([asd[0]*cell, 0, 1/2*cell]) {
	difference() {
		tog_bbl1_smooth_block([
			[8, "bb-cell"],
			[9, "bb-cell"],
			[1, "bb-cell"]
		], hole_style="square");

		if( asd[1] == 1 ) {
			translate([0,0,1/2*cell]) cube([9*cell, 7*cell, 1*cell], center=true);
		}
	}
	
	for( yc=[-5.5, -7, -8.5, -10] ) translate([0, yc*cell]) {
		tog_bbl1_smooth_block(
			[
				[8, "bb-cell"],
				[1, "bb-cell"],
				[1, "bb-cell"]
			],
			hole_style="square",
			offset = -margin
		);
	}
}
