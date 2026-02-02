// DrywallWasher0.1
// 
// Washer, for use with OvalNut0 or similar.
// 
// TODO, if needed:
// Parameters for inner and outer diameters, flange height/width,
// possibly different flange parameters for inside/outside, though
// maybe the simplicity of having them the same is valuable.  

$fn = 144;

module __drywallwasher0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let( inch = 25.4 )
	let( total_height = (7/16)*inch )
	let( inner_diameter = (1+1/4)*inch )
	let( outer_diameter = (1+1/2)*inch )
	let( front_height = (1/8)*inch )
	let( front_inner_diameter = inner_diameter + front_height*2 )
	let( front_outer_diameter = outer_diameter + front_height*2 )
	tphl1_make_z_cylinder(zds=[
		[           0, front_inner_diameter],
		[front_height, inner_diameter],
		[total_height, inner_diameter],
		[total_height, outer_diameter - 2],
		[front_height, outer_diameter],
		[           0, front_outer_diameter],
		[           0, front_inner_diameter],
	], cap_bottom=false, cap_top=false)
);
