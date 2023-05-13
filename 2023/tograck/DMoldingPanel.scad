use <../lib/Prototype.ttf>
include <../lib/TOGHoleLib-v1.scad>

panel_thickness = 3.175;
bar_width     = 1.5875;
bar_thickness = 1.5875;

inch = 25.4;

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

module d_molding_text() {
	/*intersection() {
		translate( [-6*inch, -3.5*1.5*inch, 0] ) scale(16) import(file="Dmolding-lineart.svg");
		square([(12-1/4)*inch, (3.5-1/2)*inch], center=true);
	}*/
	translate([0,-1/16*inch])
		text("D-molding", font="prototype", halign="center", valign="center", size=1.75*inch);
}

module panel() {
	linear_extrude(panel_thickness) {
		difference() {
			rounded_square([12*inch-3, 3.5*inch-3], 1/8*inch);
			d_molding_text();
		}
	}
	for( x=[-4.7*inch,-0.3*inch,40, 4.8*inch] ) {
		translate([x,0,bar_thickness/2]) cube([bar_width, 3*inch, bar_thickness], center=true);
	}
}

module panel_with_mounting_holes() {
	difference() {
		panel();
		for( xi=[-12+0.25 : 0.5 : 12-0.25] ) {
			for( yi=[1.5,-1.5] ) {
				translate([xi*inch, yi*inch, panel_thickness]) render() tog_holelib_hole("THL-1001", depth=panel_thickness*2, $fn=48);
			}
		}
	}
}

panel_with_mounting_holes();
