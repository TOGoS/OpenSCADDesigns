// Gridbeam-v1.0
//
// Simple grid beams.

chunk_pitch   = 12.7;
length_chunks =  8;
hole_diameter =  4.5;
corner_rounding_radius = 1;

$fn = 24;

echo(str("Length: ",length_chunks," chunks; ",length_chunks*chunk_pitch, "mm; ", length_chunks*chunk_pitch/25.4, "in"));

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

hole = tphl1_make_z_cylinder(hole_diameter, [-chunk_pitch/2-1, chunk_pitch/2+1]);

hole_pair = ["union", hole, ["rotate", [90,0,0], hole]];

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([
		chunk_pitch * length_chunks,
		chunk_pitch,
		chunk_pitch
	], corner_rounding_radius),
	for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] ) ["translate", [xm*chunk_pitch,0,0], hole_pair],
]);
