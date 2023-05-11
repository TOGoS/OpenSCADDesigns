// DrillBitBushingJig-v1.0
// 
// Holds a metal bushing
// (or can itself *be* the bushing, if you don't mind having to routinely re-print it)
// so you can drill straight

// Grid cell size, used for things expressed in grid units
gc_size = 3.175;
base_size_gc = [12, 12, 1];
base_corner_radius = 4.7625;

fin_thickness = 3.175;
fin_count = 6;

height = 38.1;
inner_diameter = 13;
outer_diameter = 19.05;

$fn = 16;

include <../lib/TOGHoleLib-v1.scad>

function map(arr, fn) = [for(v=arr) fn(v)];

base_size = map(base_size_gc, function(gc) gc * gc_size);

function tovec2(v) = [v[0], v[1]];

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

difference() {
	union() {
		translate([0,0,base_size[2]/2]) xy_rounded_cube(base_size, base_corner_radius);
		
		cylinder(d=outer_diameter, h=height, center=false);
		
		intersection() {
			translate([0,0,50]) xy_rounded_cube([base_size[0], base_size[1], 100], base_corner_radius);
			union() for( r=[0:1:fin_count-1] ) rotate([0,0,r*360/fin_count]) {
				rotate([90,0,0]) linear_extrude(fin_thickness) polygon([
					[0, 0],
					[0, height],
					[height, 0],
				]);
			}
		}
	}
	translate([0,0,height/2]) cylinder(d=inner_diameter, h=height*2, center=true);
	// TODO: Make configurable, base on base size
	for( ym=[-3.5:1:3.5] ) for( xm=[-3.5:1:3.5] ) {
		translate([xm*19.05, ym*19.05, base_size[2]]) tog_holelib_hole("THL-1001", depth=100, overhead_bore_height=100);
	}
}
