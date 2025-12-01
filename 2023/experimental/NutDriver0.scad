// NutDriver0.1
// 
// Asa needs a long 9/16" socket to get a nut
// off a bolt, but we don't have one, so let's make one.

total_height = "2inch";
hex_depth = "3/8inch";
square_depth = "1.5inch";
hex_offset = 0.1;
square_offset = 0.2;
$fn = 144;

module __nutdriver0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>

hex_depth_mm    = togunits1_decode(hex_depth);
square_depth_mm = togunits1_decode(square_depth);

togmod1_domodule(
	// sizes (mm)
	let( hex_ff = togunits1_to_mm("9/16inch") + hex_offset*2 )
	let( hex_depth_mm = togunits1_to_mm(hex_depth) )
	let( square_ff_mm = togunits1_to_mm("1.5inch") + square_offset*2 )
	let( square_depth_mm = togunits1_to_mm(square_depth) )
	let( total_h = togunits1_to_mm(total_height) )
	let( outer = togunits1_to_mm("2inch") )
	["difference",
		togmod1_linear_extrude_z([0,total_h], togmod1_make_rounded_rect([outer,outer], 5)),
		
		let( hex_c_to_c_r = hex_ff/2 / cos(360/6/2) )
		echo( hex_c_to_c_r = hex_c_to_c_r )
		togmod1_linear_extrude_z([-1,hex_depth_mm+1], togmod1_make_circle(r=hex_c_to_c_r, $fn=6)),
		
		togmod1_linear_extrude_z([hex_depth_mm,total_h+1], togmod1_make_rect([square_ff_mm,square_ff_mm])),
	]
);
