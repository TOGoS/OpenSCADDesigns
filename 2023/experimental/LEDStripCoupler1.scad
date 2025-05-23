// LEDStripBeam1.3
// 
// Gridrail with:
// - One flat edge
// - Holes for both bolts and for T-nuts
// - Grooves for wires and/or string
// 
// Versions:
// v1.2:
// - Remove flat_edge_inset parameter, replace with height_u
// v1.3:
// - Make bowtie floor and hat thicknesses configurable.

size_chunks = [1,1];
height_u = 22;

bowtie_floor_thickness_u = 0;
bowtie_hat_thickness_u = 1;

hull_offset = -0.05;
bowtie_offset = -0.075;

$fn = 24;

use <../lib/RoundBowtie0.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

$togridlib2_unit_table = tgx11_get_default_unit_table();

togmod1_domodule(
	let( chunk = togridlib3_decode([1, "chunk"]) )
	let( size_ca = [[size_chunks[0], "chunk"], [size_chunks[1], "chunk"], [height_u, "u"]] )
	let( size = togridlib3_decode_vector(size_ca) )
	let( bowtie_floor_thickness = togridlib3_decode([bowtie_floor_thickness_u,"u"]) )
	let( bowtie_hat_thickness   = togridlib3_decode([bowtie_hat_thickness_u  ,"u"]) )
	let( bowtie_cutout = ["union",
		togmod1_linear_extrude_z([
			bowtie_floor_thickness > 0 ? bowtie_floor_thickness : -1,
			size[2]+1
		], roundbowtie0_make_bowtie_2d(6.35, offset=-bowtie_offset)),
		
		if( bowtie_floor_thickness > 0 ) for(y=[-6.35,6.35])
			["translate", [y, 0, 0],
				togmod1_linear_extrude_z([-1, bowtie_floor_thickness+1], togmod1_make_circle(d=5))],
		if( bowtie_hat_thickness_u > 0 )
			["translate", [0,0,size[2]],
				tphl1_make_rounded_cuboid([25.4-bowtie_offset*2,12.7-bowtie_offset*2, bowtie_hat_thickness*2], r=[1,1,0])],
	])
	let( gridbeam_hole = tphl1_make_z_cylinder(zrange=[-1, size[2]+1], d=8) )
	["difference",
		togmod1_linear_extrude_z([0, size[2]],
			togmod1_make_rounded_rect(size, r=2)
		),
		
		for( cx=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( cy=[-size_chunks[1]/2, size_chunks[1]/2] )
		["translate", [cx*chunk, cy*chunk, 0], ["rotate", [0,0,90], bowtie_cutout]],

		for( cy=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		for( cx=[-size_chunks[0]/2, size_chunks[0]/2] )
		["translate", [cx*chunk, cy*chunk, 0], ["rotate", [0,0,0], bowtie_cutout]],

		for( cx=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] )
		for( cy=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2 - 0.5] )
		["translate", [cx*chunk, cy*chunk, 0], gridbeam_hole],
	]
);
