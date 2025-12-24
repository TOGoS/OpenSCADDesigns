// BroomHandleMender1.0
// 
// It's just a sliced cylinder with screw holes
// you can stick inside the broom handle.

length = "6inch";
diameter = "20.5mm";
slicey_mcthickness = "";
hole_diameter = "4.5mm";
$fn = 64;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

inf = 65536; // 4294967296; // Nice round 'close enough to infinity' number

length_mm = togunits1_to_mm(length);
length_chunks = togunits1_decode(length, unit="chunk", xf="round");
chunk = togunits1_to_mm("chunk");
diameter_mm = togunits1_to_mm(diameter);
slicey_mcthickness_mm = slicey_mcthickness == "" ? inf : togunits1_to_mm(slicey_mcthickness);
hole_diameter_mm = togunits1_to_mm(hole_diameter);

togmod1_domodule(
	let( slicey_mcintersector = slicey_mcthickness_mm == inf ? ["intersection"] : togmod1_make_cuboid([inf, slicey_mcthickness_mm, inf]) )
	let( hole = ["rotate", [0,90,0], tphl1_make_z_cylinder(zrange=[-diameter_mm, diameter_mm], d=hole_diameter_mm)] )
	["difference",
		["intersection",
			slicey_mcintersector,
			tphl1_make_z_cylinder(zds=[
				[-length_mm/2  , diameter_mm-2],
				[-length_mm/2+8, diameter_mm  ],
				[ length_mm/2-8, diameter_mm  ],
				[ length_mm/2  , diameter_mm-2],
			])
		],
		
		for( zm=[-length_chunks/2+0.5 : 1 : length_chunks/2-0.5] )
		["translate", [0,0,zm*chunk], hole],
	]
);
