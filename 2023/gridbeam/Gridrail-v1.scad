// Gridrail-v1.0
//
// Simple grid rails; i.e. 2D gridbeam.

chunk_pitch   = 12.7;   // 0.001
thickness     =  3.2;   // 0.1
length_chunks = 15;
hole_diameter =  4.0;   // 0.01
corner_rounding_radius = 3.2; // 0.1

$fn = 24;

echo(str("Length: ",length_chunks," chunks; ",length_chunks*chunk_pitch, "mm; ", length_chunks*chunk_pitch/25.4, "in"));

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

hole = tphl1_make_z_cylinder(hole_diameter, [-chunk_pitch/2-1, chunk_pitch/2+1]);

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([
		chunk_pitch * length_chunks,
		chunk_pitch,
		thickness
	], [corner_rounding_radius, corner_rounding_radius, min(corner_rounding_radius, thickness/2-0.3)], corner_shape="ovoid1"),
	for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] ) ["translate", [xm*chunk_pitch,0,0], hole],
]);
