// WeMosD1MiniSpacer-v1

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
		tog_bbl1_smooth_block([
			[8, "bb-cell"],
			[1, "bb-cell"],
			[1, "bb-cell"]
		], hole_style="square");
	}
}
