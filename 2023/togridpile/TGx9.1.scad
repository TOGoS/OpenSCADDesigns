// TGx9.1.0 - experimental simplified (for OpenSCAD rendering purposes) TOGridPile shape

inch = 25.4;

use <../lib/TOGShapeLib-v1.scad>

module tgx9_atom_foot(height=100) {
	u = inch * 1 / 16;
	rotate_extrude() {
		polygon([
			[ 0*u, 0*u],
			[-3*u, 0*u],
			[-3*u, 1*u],
			[-6*u, 4*u],
			[-6*u, height],
			[ 0*u, height],
		]);
	}
}

module tgx9_chunk_foot() {
	for( xm=[-1,0,1] ) for( ym=[-1,0,1] ) {
		translate([xm*inch/2, ym*inch/2, 0]) tgx9_atom_foot();
	}
}

intersection() {
	tgx9_chunk_foot();
	translate([0,0,3/4*inch]) //cube([3/2*inch, 3/2*inch, 3/2*inch], center=true);
		tog_shapelib_xy_rounded_cube([3/2*inch, 3/2*inch, 3/2*inch], 1/4*inch);
}