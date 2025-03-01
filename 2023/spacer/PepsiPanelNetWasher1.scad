// PepsiPanelNetWasher1.1
// 
// Washer to hold the netting onto a Pepsi
// panel with a #6 flathead screw.
// 
// v1.1:
// - Make hole_style and hole_insert configurable

diameter = 25.4;
thickness = 3.175;
hole_style = "THL-1001";
hole_inset = 0.1;
bev = 1;
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

togmod1_domodule(["difference",
	tphl1_make_z_cylinder(zds=[[0, diameter], [thickness-1, diameter], [thickness, diameter-bev*2]]),
	
	["translate", [0,0,thickness], tog_holelib2_hole(hole_style, inset=hole_inset)],
]);
