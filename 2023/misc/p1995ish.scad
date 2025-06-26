// p1995ish, v0.2
// 
// Something Renee asked for.

input_offset = [-128,-102]; // 0.1
hole_position = [0.0,0.0,3.0]; // 0.1
hole_scale = 1.00; // 0.01

$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib2.scad>


difference() {
	translate(input_offset) import("./p1994-obj_4_Hook-v10.stl");
	
	translate(hole_position) scale(hole_scale) togmod1_domodule(tog_holelib2_hole("THL-1001"));
}
