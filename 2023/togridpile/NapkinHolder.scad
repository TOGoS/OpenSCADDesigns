preview_fn = 12; // 4
render_fn  = 48; // 4
block_style = "hybrid5-rounded";

module __end_params() { }

$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGridPileLib-v1.scad>

module magnet_hole() {
	cylinder(d=6, h=4, center=true);
}

magnet_hole_positions = [
	[-12.7,-12.7],[-12.7, 12.7],
	[ 12.7,-12.7],[ 12.7, 12.7],
];

module magnet_hole_pattern() {
	for( p=magnet_hole_positions ) translate(p) magnet_hole();
}

translate([0,0,19.05]) difference() {
	togridpile_chunky_multiblock([2, 2, 1], style=block_style);
	cylinder(d=50.8, h=50, center=true, $fn=max($fn, 48));
	for(zm=[-1,1]) scale([1,1,zm]) translate([0,0,-18]) cylinder(d1=0, d2=76.2, h=50.8, center=false, $fn=max($fn, 48));
	for(rz=[0,90]) rotate([0,0,rz]) for(ym=[-1,1]) for(zm=[-1,1]) for(xm=[-1, 1]) {
		scale([xm,ym,zm]) translate( [-19.05, -38.1, 0] ) rotate([90,0,0]) magnet_hole_pattern();
	}
	for( zm=[-1,1] ) for( xb=[-0.5, 0.5] ) for( yb=[-0.5, 0.5] ) {
		scale([1,1,zm]) translate([xb*38.1, yb*38.1, 19.05]) magnet_hole_pattern();
	}
}
