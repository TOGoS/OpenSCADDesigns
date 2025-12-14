// BarHolder0.1

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

inch = 25.4;
chunk = 38.1;
$fn = 144;

togmod1_domodule(
	let( zbev = 3 )
	let( center_hole_diameter = 38.3 )
	let( mounting_hole = tog_holelib2_hole("THL-1006", inset=0, depth=chunk, overhead_bore_height=chunk) ) // Could be fancy and make rounded corners...

	["difference",
		tphl1_make_rounded_cuboid([2*chunk, 2*chunk, 1*chunk], r=[5,5,zbev], corner_shape="cone2"),
		
		tphl1_make_z_cylinder(zds=[
			[-chunk/2-zbev, center_hole_diameter+zbev*4],
			[-chunk/2+zbev, center_hole_diameter       ],
			[ chunk/2-zbev, center_hole_diameter       ],
			[ chunk/2+zbev, center_hole_diameter+zbev*4],
		]),
		// tphl1_make_polyhedron_from
		
		for( ym=[-1,1] ) for( xm=[-1,1] )
		["translate", [xm,ym,0]*chunk/2, mounting_hole],
	]
);
