// CubeMold-v1.2
//
// v1.1:
// - Set $fn to a reasonable value
// - Add outer_margin parameter
// v1.2:
// - Make the bottom of the to-be-cast cube (+z in this design) TOGridPile-compatible

outer_margin = 0.075;
preview_fn = 16;
render_fn = 64;
$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TGx9.4Lib.scad>

inch = 25.4;

floor_thickness = 1/16*inch;
wall_thickness = 1/16*inch;
mold_size = [3*inch, 3*inch, 2.25*inch];
raft_height = 1/16*inch;
cube_size = [1.5*inch, 1.5*inch, 1.5*inch];
cube_hole_diameter = 7.5;

difference() {
	linear_extrude(mold_size[2]) tog_shapelib_rounded_beveled_square(mold_size);
	
	translate([0,0,floor_thickness+mold_size[2]/2]) cube([mold_size[0]-wall_thickness, mold_size[1]-wall_thickness, mold_size[2]], center=true);
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
