// Gridrail2.0
//
// Simple grid rails; i.e. 2D gridbeam.

chunk_pitch      = 38.1;  // 0.001
thickness        = 19.05; // 0.01
length_chunks    = 15;    // 1
hole_style       = "THL-1006";
xy_corner_radius = 100;  // 0.01
z_corner_radius  =  3.2;  // 0.01

$fn = 32;

module __gridrail2__end_params() { }

echo(str("Length: ",length_chunks," chunks; ",length_chunks*chunk_pitch, "mm; ", length_chunks*chunk_pitch/25.4, "in"));

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

hole = tog_holelib2_hole(hole_style, inset=thickness/2);

eff_xy_corner_radius = min(xy_corner_radius, chunk_pitch*127/256);
eff_z_corner_radius  = min(z_corner_radius, thickness/2-0.3, chunk_pitch*127/256);

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([
		chunk_pitch * length_chunks,
		chunk_pitch,
		thickness
	], [eff_xy_corner_radius, eff_xy_corner_radius, eff_z_corner_radius], corner_shape="ovoid1"),
	
	for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] ) ["translate", [xm*chunk_pitch,0,thickness/2], hole],
]);
