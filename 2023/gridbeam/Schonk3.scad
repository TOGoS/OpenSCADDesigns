// Schonk3.0
// 
// A gridbeam-like beam with three sections,
// where alternating sections are mostly cut out.

chunk_pitch = 20;
regular_hole_diameter = 4;
bulk_hole_diameter = 5;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function schonk3_make_schonk(
	chunk_pitch = 20,
	regular_hole_diameter = 5,
	bulk_hole_diameter = 5,
	wall_thickness = 3,
) =
let( regular_hole = tphl1_make_z_cylinder(zrange=[-chunk_pitch, chunk_pitch], d=regular_hole_diameter) )
let(    bulk_hole = tphl1_make_z_cylinder(zrange=[-chunk_pitch, chunk_pitch], d=   bulk_hole_diameter) )
let( xy_r = min(3,chunk_pitch/4) )
let( wt = wall_thickness )
let( inner_xy_r = max(1, xy_r-wt) )
let( box_cutout = tphl1_make_rounded_cuboid([chunk_pitch-wt*2, chunk_pitch-wt*2, chunk_pitch*2-wt*2], r=[inner_xy_r, inner_xy_r, 0]) )
["difference",
	tphl1_make_rounded_cuboid([3,1,1] * chunk_pitch, r=[xy_r, xy_r, 0]),
	
	for( cx=[-1,1] ) for( r=[0,90] ) ["translate", [cx*chunk_pitch,0,0], ["rotate", [r,0,0], regular_hole]],
	for( cx=[ 0  ] ) for( r=[0,90] ) ["translate", [cx*chunk_pitch,0,0], ["rotate", [r,0,0], bulk_hole]],
	for( cx=[-1,1] ) ["translate", [cx*chunk_pitch,0,chunk_pitch/2], box_cutout],
];

togmod1_domodule(schonk3_make_schonk(
	chunk_pitch = chunk_pitch,
	regular_hole_diameter = regular_hole_diameter,
	bulk_hole_diameter = bulk_hole_diameter
));

