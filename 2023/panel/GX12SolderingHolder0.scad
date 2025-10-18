// GX12SolderingHolder0.1
// 
// Panel for holding GX12 ports (electrically 'male')
// at a convenient angle for soldering the pins.

size_chunks = [4,1];
thickness = "1/8inch";
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>

chunk = togunits1_decode("1chunk");

size_ca      = [for(d=size_chunks) [d,"chunk"]];

thickness_mm = togunits1_to_mm(thickness);
size_mm      = togunits1_vec_to_mms(size_ca);

mounting_hole_2d = togmod1_make_circle(d=togunits1_decode("5/16inch"));
gx12_hole_2d     = togmod1_make_circle(d=12.1);

togmod1_domodule(togmod1_linear_extrude_z([0, thickness_mm], ["difference",
	togmod1_make_rounded_rect(size_mm, r=togunits1_to_mm("3/16inch")),
	
	for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] ) each [
		for( xm=[-size_chunks[0]/2 + 0.5, size_chunks[0]/2 - 0.5] ) ["translate", [xm*chunk,ym*chunk], mounting_hole_2d],
		for( xm=[-size_chunks[0]/2 + 1.5 : 1 : size_chunks[0]/2 - 1.5] ) ["translate", [xm*chunk,ym*chunk], gx12_hole_2d],
	],
]));
