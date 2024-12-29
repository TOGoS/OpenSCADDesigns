// Schonk4.0
// 
// A gridbeam-like beam with hollow chunks.

chunk_pitch = 20;
length_chunks = 3;
floor_hole_diameter =  4;
front_hole_diameter =  4;
back_hole_diameter  = 12;
wall_thickness = 2;
alternate_lateral_hole_direction = true;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function schonk4_make_schonk(
	length_chunks,
	chunk_pitch = 20,
	floor_hole_diameter =  5,
	front_hole_diameter =  4,
	back_hole_diameter  = 12,
	wall_thickness      =  3,
	alternate_lateral_hole_direction = true
) =
let( floor_hole = tphl1_make_z_cylinder(zrange=[-chunk_pitch, chunk_pitch], d=floor_hole_diameter) )
let( front_to_back_hole = ["rotate", [-90,0,0], tphl1_make_z_cylinder(zds=[
	[-chunk_pitch  , front_hole_diameter],
	[-chunk_pitch/2, front_hole_diameter],
	[ chunk_pitch/2,  back_hole_diameter],
	[ chunk_pitch  ,  back_hole_diameter]
])])
let( xy_r = min(3,chunk_pitch/4) )
let( wt = wall_thickness )
let( inner_xy_r = max(1, xy_r-wt) )
let( box_cutout = ["translate", [0,0,chunk_pitch/2], tphl1_make_rounded_cuboid([chunk_pitch-wt*2, chunk_pitch-wt*2, chunk_pitch*2-wt*2], r=[inner_xy_r, inner_xy_r, 0])] )
let( chunk_cutout = ["union",
	floor_hole,
	front_to_back_hole,
	box_cutout
] )
["difference",
	tphl1_make_rounded_cuboid([length_chunks,1,1] * chunk_pitch, r=[xy_r, xy_r, 0]),
	
	for( cx=[-length_chunks/2+0.5:1:length_chunks/2] ) ["translate", [cx*chunk_pitch,0,0],
		["rotate", [0,0,(alternate_lateral_hole_direction?180:0)*floor(cx)], chunk_cutout]],
];

togmod1_domodule(schonk4_make_schonk(
	length_chunks = length_chunks,
	chunk_pitch = chunk_pitch,
	floor_hole_diameter = floor_hole_diameter,
	front_hole_diameter = front_hole_diameter,
	 back_hole_diameter =  back_hole_diameter,
	wall_thickness = wall_thickness,
	alternate_lateral_hole_direction = alternate_lateral_hole_direction
));

