// PepsiPanelNetWasher1.0
// 
// Washer to hold the netting onto a Pepsi
// panel with a #6 flathead screw.

diameter = 25.4;
thickness = 3.175;
bev = 1;
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

togmod1_domodule(["difference",
	tphl1_make_z_cylinder(zds=[[0, diameter], [thickness-1, diameter], [thickness, diameter-bev*2]]),
	
	["translate", [0,0,thickness], tog_holelib2_hole("THL-1001")],
]);
