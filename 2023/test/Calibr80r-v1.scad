// Calibr80r-v1.1
// 
// Versions:
// v1.0:
// - Created in the hope that this will help me figure out the exact x/y scale and offset to use
//   for things like LEGO-compatible bricks and TOGridPile thingamabobs.
// v1.1:
// - Add diamond-shaped holes on 1/2" grid, to more easily check scale without regard to offset

use <../lib/TOGShapeLib-v1.scad>

inch = 25.4;

$fn = $preview ? 16 : 64;

intersection() {
	linear_extrude(1/2*inch) {
		difference() {
			tog_shapelib_rounded_beveled_square([3*inch, 1.5*inch]);
			
			tog_shapelib_rounded_beveled_square([2*inch, 0.5*inch], 1/16*inch);

			for( xm=[-2.5 : 1 : 2.5] ) for( ym=[-1 : 1 : 1] ) {
					translate([xm,ym]*1/2*inch) rotate([0,0,45]) square([2,2], center=true);
			}
		}
	}

	union() {
		linear_extrude(1/4*inch) {
			square([3*inch, 1.5*inch], center=true);
		}
		for( x=[-1.5*inch, 1.5*inch] ) {
			translate([x, 0, 0]) linear_extrude([0, 0, 1/2*inch]) {
				tog_shapelib_rounded_beveled_square([1.5*inch, 1.5*inch], 1/16*inch);
			}
		}
	}
}
