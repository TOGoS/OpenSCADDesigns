// ExtensionCordBracket-v1.0
//
// This is a bracket for holding the outlet end of
// one of those extension cords with a block of 3 outlets on the
// end and a flangey bit along the sides.

inch = 25.4;

outlet_flange_depth = 32;
outlet_flange_thickness = 4;
outlet_body_width = 27;
outlet_body_depth = 26.5; // side-to-side

block_height = 3*inch;
block_width = 1.5*inch;
block_depth = 1.5*inch;
cord_slot_width = 5;
flange_distance_from_bottom = 33;
left_wall_height = 1.5*inch;
right_wall_height = 0.5*inch;
bottom_thickness = 10;
$fn = 24;
outer_margin = 0.1;

use <../lib/TOGHoleLib-v1.scad>
use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGridPileLib-v2.scad>

difference() {
	union() {
		tog_shapelib_rounded_cube([block_width, block_depth, block_height], corner_radius=3/16*inch, offset=-outer_margin);
		translate([0,0,-block_height/2]) linear_extrude(bottom_thickness/2) {
			for( xm=[-1,1] ) for( ym=[-1,1] ) translate([xm*inch/2, ym*inch/2]) {
				togridpile2_atom_column_footprint(offset=-outer_margin);
			}
		}
	}
	
	translate([0,0, bottom_thickness]) cube([outlet_body_width, outlet_body_depth, block_height], center=true);
	translate([0,0,-block_height/2 + bottom_thickness]) cylinder(d=18, h=8, center=true);
	translate([0,0,-block_height/2 + bottom_thickness/2]) cylinder(d=cord_slot_width, h=50, center=true);
	translate([0,block_depth/2,0]) cube([cord_slot_width, block_depth, block_height+2], center=true);
	translate([0,0,-block_height/2 + bottom_thickness + flange_distance_from_bottom+block_height/2])
		cube([outlet_flange_thickness, outlet_flange_depth, block_height], center=true);
	translate([-block_width/2, 0, bottom_thickness + left_wall_height])
		cube([block_width, outlet_body_depth, block_height], center=true);
	translate([ block_width/2, 0, bottom_thickness + right_wall_height])
		cube([block_width, outlet_body_depth, block_height], center=true);

	for( zm=[-1, 0, 1] ) translate([0, -block_depth/2 + (block_depth-outlet_flange_depth)/2, zm*19.05]) {
		rotate([-90,0,0]) tog_holelib_hole("THL-1001", overhead_bore_height=100);
	}
}
