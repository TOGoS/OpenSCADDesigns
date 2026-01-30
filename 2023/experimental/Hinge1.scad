// Hinge1.4
// 
// An entirely printable-in-place hinge
// 
// v1.2:
// - Fix cone slope to be more reasonable 2/1 instead of 4/1
// v1.3:
// - hinge_offset and outer_offset parameters; mostly only hinge_offset is used
// v1.4:
// - hinge1_make_hinge_atom: top_gender and bottom_gender may each be "f", "m", or "none"
// 
// TODO: Round cone ends?

hinge_offset = -0.1;
outer_offset = -0.1;

$fn = 32;

module hinge1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

// Generate a cone where Z=0 is the base, Z=length is the top.
function hinge1_make_cone(
	length,
	diameter,
	r_offset = 0,
	z_offset = 0
) =
	let( cone_dd_dz = 1 )
	let( cone_db = diameter + cone_dd_dz * length   ) // Base: extends 50% of length below Z=0
	let( cone_d0 = diameter - cone_dd_dz * length/2 )
	let( cone_d1 = diameter - cone_dd_dz * length/2 )
	tphl1_make_z_cylinder(zds=[[-length/2 + z_offset, cone_db + r_offset*2], [length + z_offset, cone_d1 + r_offset*2]]);

function hinge1_make_hinge_atom(
	height = 6.35,
	diameter = 6.35,
   width = 12.7,
	cone_length = 2,
	cone_diameter = 3.175,
	offset = -0.1,
	bottom_gender = "f",
	top_gender = "m"
) =
	let( cone_d0 = cone_diameter + cone_length/2 )
	let( cone_d1 = cone_diameter - cone_length/2 )
	let( cone_db = cone_d0 - (cone_d1 - cone_d0) )
	let( actual_size = [width+offset*2, height+offset*2] )
	let( m_cone = hinge1_make_cone( length=cone_length, diameter=cone_diameter, r_offset= offset, z_offset= offset ) )
	let( f_cone = hinge1_make_cone( length=cone_length, diameter=cone_diameter, r_offset=-offset, z_offset=-offset ) )
	["difference",
		["union",
			togmod1_linear_extrude_z(
				[-height/2-offset, height/2+offset],
				["translate", [(width-height)/2, 0, 0], togmod1_make_rounded_rect(actual_size, r=min(actual_size[0],actual_size[1])/2)]
			),
			if( bottom_gender == "m" ) ["translate", [0,0,-height/2], ["rotate", [180,0,0], m_cone]],
			if(    top_gender == "m" ) ["translate", [0,0, height/2], ["rotate", [  0,0,0],m_cone]],
			// if(    top_gender == "m" ) tphl1_make_z_cylinder(zds=[[height/2+offset - cone_length, cone_db + offset*2], [height/2+offset + cone_length, cone_d1 + offset*2]]),
		],
		
		if( bottom_gender == "f" ) ["translate", [0,0,-height/2], ["rotate", [  0,0,0], f_cone]],
		if(    top_gender == "f" ) ["translate", [0,0, height/2], ["rotate", [180,0,0], f_cone]],
	];


togmod1_domodule(
	let( hinge_atom_height = 6.35 )
	let( hinge_outer_diameter = 6.35 )
	let( hinge_atom_width = 12.7 )
	let( cone_length = 2 )
	let( hinge_atom = hinge1_make_hinge_atom(
		height = hinge_atom_height,
		diameter = hinge_outer_diameter,
		width = hinge_atom_width,
		cone_length = cone_length,
		cone_diameter = hinge_outer_diameter / 2,
		offset = hinge_offset
	))
	let( top_hinge_atom = hinge1_make_hinge_atom(
		height = hinge_atom_height,
		diameter = hinge_outer_diameter,
		width = hinge_atom_width,
		cone_length = cone_length,
		cone_diameter = hinge_outer_diameter / 2,
		top_gender = "f",
		offset = hinge_offset
	))
	let( slab_width = 19.05 )
	let( slab_actual_thickness = hinge_outer_diameter+hinge_offset*2 - 1/256 ) // offset has to match that of hinge atoms' thickness
	let( slab = togmod1_linear_extrude_z(
		[-2.5*hinge_atom_height - hinge_offset + 1/256, 2.5*hinge_atom_height + hinge_offset - 1/256],
		togmod1_make_rounded_rect([slab_width + outer_offset*2, slab_actual_thickness], r=slab_actual_thickness/2)
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
