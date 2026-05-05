// QManifold0.1
// 
// Splitter for 1/4" irrigation tubing with 'Q ports'.

width  = "3chunk";
height = "1chunk";
$fn = 32;

module qmanifold__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TubePort4.scad>

chunk_mm     = togunits1_decode("1chunk", unit="mm");
width_chunks = togunits1_decode(width, unit="chunk", xf="round");
width_mm     = togunits1_decode(width, unit="mm");
height_mm    = togunits1_decode(height, unit="mm");
depth_mm     = chunk_mm;

cav_diam_mm = 9;

togmod1_domodule(
	let( qport = ["render", tubeport4_make_qport()] )
	let( qportp = ["union", qport, tphl1_make_z_cylinder(zrange=[-height_mm+cav_diam_mm/2+3,2], d=6.35+0.5)] )
	let( mounting_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zds=[
		[-depth_mm/2-2, 5+8],
		[-depth_mm/2+2, 5  ],
		[ depth_mm/2-2, 5  ],
		[ depth_mm/2+2, 5+8],
	])] )
	["difference",
		tphl1_make_rounded_cuboid([width_mm, depth_mm, height_mm], r=5),
		
		for( xm=[-width_chunks/2 + 0.5 : 1 : width_chunks/2] )
		["translate", [xm*chunk_mm, 0, height_mm/2], qportp],
		
		for( xm=[-width_chunks/2 + 1 : 1 : width_chunks/2-1] )
		["translate", [xm*chunk_mm, 0, 0], mounting_hole],
		
		["translate", [0,0,-height_mm/2+cav_diam_mm/2+3], tphl1_make_rounded_cuboid([width_mm - 12.7, cav_diam_mm, cav_diam_mm], r=cav_diam_mm/2)],
		
		// ["translate", [0,-depth_mm/2,0], togmod1_make_cuboid([width_mm*2, depth_mm, height_mm*2])],
	]
);
