// Hinge1.1
// 
// An entirely printable-in-place hinge

$fn = 32;

module hinge1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function hinge1_make_hinge_atom(
	height = 6.35,
	diameter = 6.35,
   width = 12.7,
	cone_length = 2,
	cone_diameter = 3.175,
	offset = -0.1,
	top_cone_mode = 1
) =
	let( cone_d0 = cone_diameter + cone_length/4 )
	let( cone_d1 = cone_diameter - cone_length/4 )
	let( cone_db = cone_d0 - (cone_d1 - cone_d0) )
	let( actual_size = [width+offset*2, height+offset*2] )
	["difference",
		["union",
			togmod1_linear_extrude_z(
				[-height/2-offset, height/2+offset],
				["translate", [(width-height)/2, 0, 0], togmod1_make_rounded_rect(actual_size, r=min(actual_size[0],actual_size[1])/2)]
			),
			if( top_cone_mode == 1 ) tphl1_make_z_cylinder(zds=[[height/2+offset - cone_length, cone_db + offset*2], [height/2+offset + cone_length, cone_d1 + offset*2]]),
		],
		
		tphl1_make_z_cylinder(zds=[[-height/2-offset - cone_length, cone_db - offset*2], [-height/2-offset + cone_length, cone_d1 - offset*2]]),
		if( top_cone_mode == -1 ) tphl1_make_z_cylinder(zds=[[height/2+offset - cone_length, cone_d1 - offset*2], [height/2+offset + cone_length, cone_db - offset*2]]),
	];


togmod1_domodule(
	let( hinge_atom_height = 6.35 )
	let( hinge_outer_diameter = 6.35 )
	let( hinge_atom_width = 12.7 )
	let( offset = -0.1 )
	let( cone_length = 2 )
	let( hinge_atom = hinge1_make_hinge_atom(
		height = hinge_atom_height,
		diameter = hinge_outer_diameter,
		width = hinge_atom_width,
		cone_length = cone_length,
		cone_diameter = hinge_outer_diameter / 2
	))
	let( top_hinge_atom = hinge1_make_hinge_atom(
		height = hinge_atom_height,
		diameter = hinge_outer_diameter,
		width = hinge_atom_width,
		cone_length = cone_length,
		cone_diameter = hinge_outer_diameter / 2,
		top_cone_mode = -1
	))
	let( slab_width = 19.05 )
	let( slab_actual_thickness = hinge_outer_diameter+offset*2 - 1/256 )
	let( slab = togmod1_linear_extrude_z(
		[-2.5*hinge_atom_height - offset + 1/256, 2.5*hinge_atom_height + offset - 1/256],
		togmod1_make_rounded_rect([slab_width + offset*2, slab_actual_thickness], r=slab_actual_thickness/2)
	))

	["union",
		["translate", [0,0,2*hinge_atom_height], top_hinge_atom],
		for( zm = [-2,0] ) ["translate", [0,0,zm*hinge_atom_height], hinge_atom],
		for( zm = [-1,1] ) ["translate", [0,0,zm*hinge_atom_height], ["rotate", [0,0,180], hinge_atom]],
		["translate", [ (slab_width + hinge_outer_diameter)/2, 0, 0], slab],
		["translate", [-(slab_width + hinge_outer_diameter)/2, 0, 0], slab],
	]
	/*
	let( cone_d0 = 4 )
	let( cone_d1 = 2 )
	let( cone_db = cone_d0 - (cone_d1 - cone_d0) )
	["difference",
		["union",
			togmod1_linear_extrude_z(
				[-hinge_atom_height/2-offset, hinge_atom_height/2+offset],
				["translate", [(hinge_atom_width-hinge_atom_height)/2, 0, 0], togmod1_make_rounded_rect([hinge_atom_width, hinge_atom_height], r=hinge_atom_height/2)]
			),
			tphl1_make_z_cylinder(zds=[[hinge_atom_height/2+offset - cone_length, cone_db + offset*2], [hinge_atom_height/2+offset + cone_length, cone_d1 + offset*2]]),
		],
		tphl1_make_z_cylinder(zds=[[-hinge_atom_height/2-offset - cone_length, cone_db - offset*2], [-hinge_atom_height/2-offset + cone_length, cone_d1 - offset*2]]),
	]
*/
);
