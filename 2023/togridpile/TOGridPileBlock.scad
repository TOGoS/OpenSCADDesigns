// TOGridPileBlock-v1.4
//
// v1.1:
// - Add bevel option, though I want to change it a little bit...
// v1.2:
// - Improve calculation of lip substraction for nicer shape
// v1.3:
// - hybrid1 and hybrid1-inner styles
// v1.4:
// - Extracted most functions to library

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;
// 4.7625mm = 3/16", 3.175 = 1/8"
//togridpile_rounded_corner_radius = 4.7625;
//togridpile_beveled_corner_radius = 3.175;
// "hybrid1" is beveled but with XZ corners rounded off
togridpile_style = "hybrid1"; // [ "rounded", "beveled", "hybrid1", "minimal" ]
// Style for purposes of lip cutout; "maximal" will accomodate all others; "hybrid1-inner" will accomodate rounded or hybrid1 bottoms
togridpile_lip_style = "hybrid1-inner"; // [ "rounded", "beveled", "hybrid1-inner", "maximal" ]
// How much space to put between adjacent blocks by shrinking them slightly
margin = 0.25;
lip_height = 2.540;
height = 12.7;
wall_thickness = 2;
floor_thickness = 3.175;

$fn = 12;

module __end_params() { }

include <../lib/TOGHoleLib-v1.scad>
include <../lib/TOGridPileLib-v1.scad>

inch = 25.4;

module togridpile_hull(size, beveled_corner_radius=3.175, rounded_corner_radius=4.7625, corner_radius_offset=0, offset=0) {
	togridpile_hull_of_style(togridpile_style, size, corner_radius_offset=corner_radius_offset, offset=offset);
}

module togridpile_hollow_cup_with_lip(size, lip_height, wall_thickness=2, floor_thickness=2, small_holes=false, large_holes=false) {
	difference() {
		intersection() {
			translate([0,0,height]) togridpile_hull([size[0], size[1], size[2]*2], corner_radius_offset=0, offset=-margin/2);
			cube([size[0], size[1], (size[2]+lip_height)*2], center=true);
		}
		// Lip
		translate([0,0,height+size[2]/2]) togridpile_hull_of_style(togridpile_lip_style, size, corner_radius_offset=0, offset=+margin/2);
		// Interior cavity
		translate([0,0,height+floor_thickness]) togridpile_hull([size[0]-wall_thickness*2, size[1]-wall_thickness*2, height*2], corner_radius_offset=-wall_thickness, offset=-margin/2);
		//translate([0,0,height+floor_thickness]) rounded_cube([size[0]-wall_thickness*2, size[1]-wall_thickness*2, height*2], corner_radius_offset=-wall_thickness, offset=-margin/2)
		if(small_holes) for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) {
			translate([ym*12.7, xm*12.7, floor_thickness]) tog_holelib_hole("THL-1001", overhead_bore_height=height*2);
		}
		if(large_holes) {
			translate([0,0,floor_thickness]) tog_holelib_hole("THL-1002", overhead_bore_height=height*2);
		}
	}
}

translate([0*inch, 0, 0]) togridpile_hollow_cup_with_lip([togridpile_pitch, togridpile_pitch, height], lip_height, wall_thickness, floor_thickness,  true, true);
translate([2*inch, 0, 0]) togridpile_hollow_cup_with_lip([togridpile_pitch, togridpile_pitch, height], lip_height, wall_thickness, floor_thickness, false, true);
