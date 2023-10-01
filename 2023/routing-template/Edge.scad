// Edge-v1.0

size_inches = [3.5, 1, 0.375];

module __ksudfnj_edge_end_params() { }

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TOGHoleLib-v1.scad>

inch = 25.4;
size = size_inches * inch;
$fn = $preview ? 12 : 64;

echo(size=size);

difference() {
	linear_extrude(size[2]) {
		tog_shapelib_rounded_beveled_square(size, 1/8*inch, 1/8*inch);
	}

	for( xm=[-1.5,-0.5,0.5,1.5] ) for ( ym=[-1,1] ) {
			translate([xm*inch, ym*(size_inches[1]-0.5)/2*inch, size[2]]) {
			tog_holelib_hole("THL-1001", depth=size[2]*2, overhead_bore_height=1);
		}
	}
}
