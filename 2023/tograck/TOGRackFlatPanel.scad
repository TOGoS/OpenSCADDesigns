// TOGRackFlatPanel-v1.0

panel_thickness = 3.175;
interior_thickness = 1;
panel_width_inches = 12;
panel_height_inches = 3.5;
panel_xy_margin = 1.5;

/* [Detail levels] */

preview_fn = 12;
render_fn = 48;

module __end_params() { }

use <../lib/TOGHoleLib-v1.scad>

inch = 25.4;
panel_width = panel_width_inches * inch;
panel_height = panel_height_inches * inch;

$fn = $preview ? preview_fn : render_fn;

module rounded_square(size, corner_radius, offset=0) {
	hull() for( ym=[-1,1] ) for( xm=[-1,1] ) {
		translate([
			xm*(size[0]/2-corner_radius),
			ym*(size[1]/2-corner_radius),
		]) circle(r=corner_radius+offset);
	}
}
module xy_rounded_cube(size, corner_radius) {
	linear_extrude(size[2], center=true) rounded_square(size, corner_radius);
}

module panel() {
	translate([0,0,panel_thickness/2]) xy_rounded_cube([panel_width-panel_xy_margin*2, panel_height-panel_xy_margin*2, panel_thickness], 1/8*inch);
}

module panel_with_mounting_holes() {
	difference() {
		panel();
		for( xi=[-panel_width_inches/2+0.25 : 0.5 : panel_width_inches/2-0.25] ) {
			for( yi=[-(panel_height_inches-0.5)/2, +(panel_height_inches-0.5)/2] ) {
				translate([xi*inch, yi*inch, panel_thickness]) render() tog_holelib_hole("THL-1001", depth=panel_thickness*2);
			}
		}
		translate([0,0,panel_thickness]) {
			xy_rounded_cube([(panel_width_inches-1)*inch, (panel_height_inches-1)*inch, (panel_thickness-interior_thickness)*2], 1/16*inch);
		}
	}
}

panel_with_mounting_holes();
