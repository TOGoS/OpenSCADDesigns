// DrillBitBushingJig3.1
// 
// v3.1:
// - Parameters for stuff

width = "3.5inch";
height = "2inch";

main_hole_floor_diameter = "17mm";
main_hole_floor_thickness = "1/8inch";
main_hole_diameter = "18.97mm";

lateral_hole_spacing = "2inch";
lateral_hole_diameter = "8.5mm";

$fn = 48;

module __drillbibushingjjig3__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

main_hole_floor_diameter_mm = togunits1_to_mm(main_hole_floor_diameter);
main_hole_floor_thickness_mm = togunits1_to_mm(main_hole_floor_thickness);
main_hole_diameter_mm = togunits1_to_mm(main_hole_diameter);
width_mm = togunits1_to_mm(width);
height_mm = togunits1_to_mm(height);
lateral_hole_spacing_mm = togunits1_to_mm(lateral_hole_spacing);
lateral_hole_diameter_mm = togunits1_to_mm(lateral_hole_diameter);

togmod1_domodule(
	let(inch = 25.4)
	let(lateral_hole = tphl1_make_z_cylinder(zrange=[-100,100], d=lateral_hole_diameter_mm))
	["difference",
		togmod1_linear_extrude_z([0, height_mm], togmod1_make_rounded_rect([width_mm, 1.5*inch], r=5)),
		
		let(d0 = main_hole_floor_diameter_mm)
		let(d1 = main_hole_diameter_mm)
		let(ft = main_hole_floor_thickness_mm)
		tphl1_make_z_cylinder(zds=[
			               [  0        - 1, d0],
			if( d1 != d0 ) [ ft           , d0],
			if( d1 != d0 ) [ ft           , d1],
			               [ height_mm + 1, d1]
		]),
		
		for( xm=[-1,+1] ) ["translate", [xm*lateral_hole_spacing_mm/2, 0, 3/4*inch], ["rotate", [90,0,0], lateral_hole]],
	]
);
