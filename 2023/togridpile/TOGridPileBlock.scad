// TOGridPileBlock-v2.1
//
// v1.1:
// - Add bevel option, though I want to change it a little bit...
// v1.2:
// - Improve calculation of lip substraction for nicer shape
// v1.3:
// - hybrid1 and hybrid1-inner styles
// v1.4:
// - Extracted most functions to library
// v2.0:
// - Add 'hybrid2' shape, which is beveled but with rounded faces,
//   and which, when used as lip shape, will accommodate hybrid1 or hybrid2 blocks
// - Allow cavity to be a different shape than the outer hull
// - Cut out corner to show cross-secion in preview
// - Add a hollow cube block, to show off rotatability
// v2.1:
// - Fix offset-to-scale calculation
// - Margin is now simply negative offset, i.e. half the space between perfectly-printed blocks
// - Organize customizable parameters into tabs

/* [Content] */

height = 12.7;           // 0.001
wall_thickness = 2;      // 0.001
cavity_style = "rounded"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "minimal" ]
floor_thickness = 3.175; // 0.001

/* [Grid / Stacking System] */

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;

beveled_corner_radius = 3.175;
rounded_corner_radius = 4.7625;

// 4.7625mm = 3/16", 3.175 = 1/8"
// "hybrid1" is hybrid2 but with XZ corners rounded off
togridpile_style = "hybrid1"; // [ "rounded", "beveled", "hybrid1", "hybrid2", "minimal" ]
// Style for purposes of lip cutout; "maximal" will accomodate all others; "hybrid1-inner" will accomodate rounded or hybrid1 bottoms
togridpile_lip_style = "hybrid2"; // [ "rounded", "beveled", "hybrid1-inner", "hybrid2", "maximal" ]

/* [Sizing Tweaks] */

// How much to shrink blocks and expand cutouts for them for better fits
margin = 0.1;            // 0.01
lip_height = 2.54;       // 0.01

/* [Detail] */

preview_fn = 12; // 4
render_fn  = 48; // 4

module __end_params() { }

$fn = $preview ? preview_fn : render_fn;

include <../lib/TOGHoleLib-v1.scad>
include <../lib/TOGridPileLib-v1.scad>

inch = 25.4;

module togridpile_hull(size, beveled_corner_radius=beveled_corner_radius, rounded_corner_radius=rounded_corner_radius, corner_radius_offset=0, offset=0) {
	togridpile_hull_of_style(
		togridpile_style, size,
		beveled_corner_radius=beveled_corner_radius,
		rounded_corner_radius=rounded_corner_radius,
		corner_radius_offset=corner_radius_offset, offset=offset
	);
}

module togridpile_hollow_cup_with_lip(size, lip_height, wall_thickness=2, floor_thickness=2, small_holes=false, large_holes=false) {
	difference() {
		intersection() {
			translate([0,0,height]) togridpile_hull([size[0], size[1], size[2]*2], corner_radius_offset=0, offset=-margin);
			cube([size[0], size[1], (size[2]+lip_height)*2], center=true);
		}
		// Lip
		translate([0,0,height+size[2]/2]) togridpile_hull_of_style(togridpile_lip_style, size, corner_radius_offset=0, offset=+margin);
		// Interior cavity
		translate([0,0,height+floor_thickness]) togridpile_hull_of_style(cavity_style, [size[0]-wall_thickness*2, size[1]-wall_thickness*2, height*2], corner_radius_offset=-wall_thickness, offset=-margin);
		if(small_holes) for( ym=[-1,0,1] ) for( xm=[-1,0,1] ) {
			translate([ym*12.7, xm*12.7, floor_thickness]) tog_holelib_hole("THL-1001", overhead_bore_height=height*2);
		}
		if(large_holes) {
			translate([0,0,floor_thickness]) tog_holelib_hole("THL-1002", overhead_bore_height=height*2);
		}
		if( $preview ) {
			# translate([-size[0]/2, -size[1]/2, size[2]/2]) cube([size[0]/2, size[1]/2, size[2]*2], center=true);
		}
	}
}

module togridpile_hollow_cube(size, wall_thickness=2) {
	difference() {
		translate([0,0,size[2]/2]) togridpile_hull(size, offset=-margin);
		translate([0,0,size[2]/2]) togridpile_hull_of_style(cavity_style, size, offset=-margin-wall_thickness);
		translate([0,0,size[2]-wall_thickness/2]) togridpile__xy_rounded_cube([size[0]-rounded_corner_radius*1.5, size[1]-rounded_corner_radius*1.5, wall_thickness*2], 2);
		if( $preview ) {
			# translate([-size[0]/2, -size[1]/2, size[2]/2]) cube([size[0]/2, size[1]/2, size[2]*2], center=true);
		}
	}
}

translate([0*inch, 0, 0]) togridpile_hollow_cup_with_lip([togridpile_pitch, togridpile_pitch, height], lip_height, wall_thickness, floor_thickness,  true, true);
translate([2*inch, 0, 0]) togridpile_hollow_cube([togridpile_pitch, togridpile_pitch, togridpile_pitch], wall_thickness);
