// KhkhkhtSpacer1.0
// 
// For jamming between Pepsi panels and the Pepsi panel ceiling rail

length_chunks = 3;
width = 31.75;
height = 12.7;
hole_diameter = 7.5;
$fn = 48;

module __khkhkhtspacer1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

togmod1_domodule(
	let( inch = 25.4 )
	let( chunk = 38.1 )
	let( hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-width, +width], d=hole_diameter)] )
	["difference",
		tphl1_make_rounded_cuboid([length_chunks*chunk, width, height], r=[5,5,0]),
		
		for( xm=[-length_chunks/2 + 0.5 : 0.5 : length_chunks/2-0.5] )
		["translate", [xm*chunk, 0, 0], hole],
	]
);
