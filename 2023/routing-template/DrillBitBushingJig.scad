// DrillBitBushingJig-v1.2
// 
// Holds a metal bushing
// (or can itself *be* the bushing, if you don't mind having to routinely re-print it)
// so you can drill straight
//
// Changes:
// v1.1:
// - 1/2" hole grid instead of 3/4"
// - Offset fins to mostly miss the holes
// v1.2:
// - Mounting holes on the 1/2" grid, but only in the corners
// - Add this riser thing which you could bolt under the thing
//   to give all the woodchips somewhere to go

// Grid cell size, used for things expressed in grid units
gc_size = 3.175;
base_size_gc = [12, 12, 1];
base_corner_radius = 4.7625;

fin_thickness = 3.175;
fin_rotation_offset = 22.5;
fin_count = 4;

height = 38.1;
inner_diameter = 12.7;
outer_diameter = 19.05;

// 1/8" = 3.175, 1/4" = 6.35, 3/8" = 9.525
riser_thickness = 6.35;
riser_inner_diameter = 7.9375;

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

mounting_hole_positions = [for( ym=[-1,1] ) for( xm=[-1,1] ) [xm*12.7, ym*12.7]];

module jig() {
       difference() {
		union() {
			translate([0,0,base_size[2]/2]) xy_rounded_cube(base_size, base_corner_radius);
			
			cylinder(d=outer_diameter, h=height, center=false);
			
			intersection() {
				translate([0,0,50]) xy_rounded_cube([base_size[0], base_size[1], 100], base_corner_radius);
				union() for( r=[0:1:fin_count-1] ) rotate([0,0,fin_rotation_offset+r*360/fin_count]) {
					rotate([90,0,0]) linear_extrude(fin_thickness, center=true) polygon([
						[0, 0],
						[0, height],
						[height, 0],
					]);
				}
			}
		}
		translate([0,0,height/2]) cylinder(d=inner_diameter, h=height*2, center=true);
		// TODO: Make configurable, base on base size
		for( pos=mounting_hole_positions ) {
			translate([pos[0], pos[1], base_size[2]]) tog_holelib_hole("THL-1001", depth=100, overhead_bore_height=100);
		}
	}
}

riser_slot_height = riser_thickness-3.175;

module riser() {
	difference() {
		translate([0,0,riser_thickness/2]) xy_rounded_cube([base_size[0], base_size[1], riser_thickness], base_corner_radius);
		translate([0,0,riser_thickness/2]) cylinder(d=riser_inner_diameter, h=100, center=true);
		translate([0,0,riser_thickness]) cube([base_size[0]*2, 12.7, riser_slot_height*2], center=true);
		translate([0,0,riser_thickness]) cube([12.7, base_size[1]*2, riser_slot_height*2], center=true);
		for( pos=mounting_hole_positions ) {
			translate([pos[0], pos[1], riser_thickness]) tog_holelib_hole("THL-1001", depth=100, overhead_bore_height=100);
		}
	}
}

jig();
translate([base_size[0]*2, 0, 0]) riser();
