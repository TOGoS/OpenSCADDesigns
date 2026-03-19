// Gridrail2.1
//
// Simple grid rails; i.e. 2D gridbeam.
// 
// v2.1:
// - Add `width_chunks` and `corner_shape` options
//   (previously hardcoded as 1 and "ovoid1", respectively)

chunk_pitch      = 38.1;  // 0.001
thickness        = 19.05; // 0.01
length_chunks    = 15;    // 1
width_chunks     = 1;
hole_style       = "THL-1006";
xy_corner_radius = 100;  // 0.01
z_corner_radius  =  3.2;  // 0.01
corner_shape     = "ovoid1"; // ["ovoid1","cone2"]

$fn = 32;

module __gridrail2__end_params() { }

echo(str("Length: ",length_chunks," chunks; ",length_chunks*chunk_pitch, "mm; ", length_chunks*chunk_pitch/25.4, "in"));
echo(str("Width: ",width_chunks," chunks; ",width_chunks*chunk_pitch, "mm; ", width_chunks*chunk_pitch/25.4, "in"));

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

hole = tog_holelib2_hole(hole_style, inset=thickness/2);

eff_xy_corner_radius = min(xy_corner_radius, chunk_pitch*127/256);
eff_z_corner_radius  = min(z_corner_radius, thickness/2-0.3, chunk_pitch*127/256);

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([
		chunk_pitch * length_chunks,
		chunk_pitch * width_chunks,
		thickness
	], [eff_xy_corner_radius, eff_xy_corner_radius, eff_z_corner_radius], corner_shape=corner_shape),
	
	for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2] )
	for( ym=[-width_chunks/2+0.5 : 1 : width_chunks/2] )
	["translate", [xm*chunk_pitch, ym*chunk_pitch, thickness/2], hole],
]);
