// CubeMold-v1.4
//
// v1.1:
// - Set $fn to a reasonable value
// - Add outer_margin parameter
// v1.2:
// - Make the bottom of the to-be-cast cube (+z in this design) TOGridPile-compatible
// v1.3:
// - Correct usage of wall_thickness, and value to compensate
// - Make corners of mold just *barely* connected
// v1.4:
// - Configurable and smaller-by-default mold wall thickness

outer_margin = 0.075;
preview_fn = 16;
render_fn = 64;
mold_wall_thickness = 12.7;
$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TGx9.4Lib.scad>

inch = 25.4;

floor_thickness = 1/16*inch;
wall_thickness = 1/32*inch;
raft_height = 1/16*inch;
cube_size = [1.5*inch, 1.5*inch, 1.5*inch];
cube_hole_diameter = 7.5;
mold_size = [cube_size[0]+wall_thickness*2+mold_wall_thickness*2, cube_size[1]+wall_thickness*2+mold_wall_thickness*2, 2.25*inch];

difference() {
	cc_square_size = [mold_size[0]-wall_thickness*4, mold_size[1]-wall_thickness*4];

	linear_extrude(mold_size[2]) tog_shapelib_rounded_beveled_square(mold_size);
	
	translate([0,0,floor_thickness]) linear_extrude(mold_size[2]) {
		tog_shapelib_rounded_beveled_square(mold_size, offset=-wall_thickness);
		square(cc_square_size, center=true);
	}
}
translate([0,0,floor_thickness]) {
	intersection() {
		linear_extrude(cube_size[2]) difference() {
			tog_shapelib_rounded_beveled_square(cube_size, offset=-outer_margin);
			circle(d=cube_hole_diameter);
		}
		
		translate([0, 0, cube_size[2]]) difference() {
			rotate([180, 0, 0]) tgx9_chunk_foot(segmentation="chatom", $tgx9_chatomic_foot_column_style="v6.0", offset=-outer_margin);
			
			for( pm=[[-1,-1],[-1,1],[1,-1],[1,1]] ) {
				translate( [pm[0]*12.7, pm[1]*12.7] ) cylinder(d=6.2, h=2.4*2, center=true);
			}
		}
	}
}
