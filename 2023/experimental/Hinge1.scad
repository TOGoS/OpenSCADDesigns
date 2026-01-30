// Hinge1.4.2
// 
// An entirely printable-in-place hinge
// 
// v1.2:
// - Fix cone slope to be more reasonable 2/1 instead of 4/1
// v1.3:
// - hinge_offset and outer_offset parameters; mostly only hinge_offset is used
// v1.4:
// - hinge1_make_hinge_atom: top_gender and bottom_gender may each be "f", "m", or "none"
// v1.4.1:
// - Rename functions to have `toghinge1` prefix
// v1.4.2:
// - More refactoring and changing of toghinge1_make_hinge_atom's parameters
//   - `body`, `body_2d`, or `body_x1` may be specified (or not)
//   - body size/shape, width, and cone_length/diameter may be undef[ined],
//     in which case reasonable defaults will be used
// - Add `hinge_thickness` and `atom_width` parameters
// 
// TODO: Round cone ends?

hinge_thickness = "1/4inch";
atom_width      = "1/4inch";
bottom_gender   = "f"; // ["none","f","m"]
top_gender      = "f"; // ["none","f","m"]

hinge_offset = -0.1;
outer_offset = -0.1;

$fn = 32;

module hinge1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

hinge_thickness_mm = togunits1_to_mm(hinge_thickness);
atom_width_mm      = togunits1_to_mm(atom_width     );

// Generate a cone where Z=0 is the base, Z=length is the top.
function toghinge1_make_cone(
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

function toghinge1_make_hinge_atom(
	thickness = 6.35,
	width = undef,
	offset = -0.1,
	bottom_gender = "f",
	top_gender = "m",
	// Body can be specified directly, by 2D shape, or by max X
	body    = undef, // In case you want to provide your own
	body_2d = undef, // In case you want to provide your own 2D outline
	body_x1 = undef, // In case you don't, but want to specify where the right end should be
	// Cone size will be derived from atom thickness unless overridden:
	cone_length = undef,
	cone_diameter = undef,
) =
	let( d2c = function(x) is_undef(x) ? 0 : 1 )
	assert(
		d2c(body) + d2c(body_2d) + d2c(body_x1) <= 1,
		str(
			"Only one of body, body_2d, or body_x1 may be specified; given: ",
			"body=", body, ", ",
			"body_2d=", body_2d, ", ",
			"body_x1=", body_x1
		)
	)
	let( eff_width = !is_undef(width) ? width : thickness )
	let( eff_cone_diameter = !is_undef(cone_diameter) ? cone_diameter : thickness/2 )
	let( eff_cone_length   = !is_undef(cone_length) ? cone_length : thickness/3 )
	let( cone_d0 = eff_cone_diameter + eff_cone_length/2 )
	let( cone_d1 = eff_cone_diameter - eff_cone_length/2 )
	let( cone_db = cone_d0 - (cone_d1 - cone_d0) )
	let( eff_body =
		!is_undef(body) ? body :
		let( eff_body_2d =
			!is_undef(body_2d) ? body_2d :
			let( body_x0 = -thickness/2-offset )
			let( eff_body_x1 = !is_undef(body_x1) ? body_x1 : body_x0 + 2*thickness )
			let( actual_size = [(body_x1-body_x0)+offset*2, thickness+offset*2] )
			["translate", [(body_x0+body_x1)/2, 0, 0],
				togmod1_make_rounded_rect(actual_size, r=min(actual_size[0],actual_size[1])/2)]
		)
		togmod1_linear_extrude_z([-eff_width/2-offset, eff_width/2+offset], eff_body_2d)
	)
	let( m_cone = toghinge1_make_cone(
		length=eff_cone_length, diameter=eff_cone_diameter,
		r_offset= offset, z_offset= offset ) )
	let( f_cone = toghinge1_make_cone(
		length=eff_cone_length, diameter=eff_cone_diameter,
		r_offset=-offset, z_offset=-offset ) )
	["difference",
		["union",
			eff_body,
			if( bottom_gender == "m" ) ["translate", [0,0,-eff_width/2], ["rotate", [180,0,0], m_cone]],
			if(    top_gender == "m" ) ["translate", [0,0, eff_width/2], ["rotate", [  0,0,0],m_cone]],
		],
		
		if( bottom_gender == "f" ) ["translate", [0,0,-eff_width/2], ["rotate", [  0,0,0], f_cone]],
		if(    top_gender == "f" ) ["translate", [0,0, eff_width/2], ["rotate", [180,0,0], f_cone]],
	];

togmod1_domodule(
	// let( atom_width = atom_width_mm )
	// let( hinge_outer_diameter = 6.35 )
	// let( atom_width_mm = 12.7 )
	let( bottom_hinge_atom = toghinge1_make_hinge_atom(
		width = atom_width_mm,
		thickness = hinge_thickness_mm,
		body_x1 = hinge_thickness_mm*3/2,
		bottom_gender = bottom_gender,
		offset = hinge_offset
	))
	let( mid_hinge_atom = toghinge1_make_hinge_atom(
		width = atom_width_mm,
		thickness = hinge_thickness_mm,
		body_x1 = hinge_thickness_mm*3/2,
		offset = hinge_offset
	))
	let( top_hinge_atom = toghinge1_make_hinge_atom(
		width = atom_width_mm,
		thickness = hinge_thickness_mm,
		body_x1 = hinge_thickness_mm*3/2,
		top_gender = top_gender,
		offset = hinge_offset
	))
	let( slab_width = 19.05 )
	let( slab_actual_thickness = hinge_thickness_mm+hinge_offset*2 - 1/256 ) // offset has to match that of hinge atoms' thickness
	let( slab = togmod1_linear_extrude_z(
		[-2.5*atom_width_mm - hinge_offset + 1/256, 2.5*atom_width_mm + hinge_offset - 1/256],
		togmod1_make_rounded_rect([slab_width + outer_offset*2, slab_actual_thickness], r=slab_actual_thickness/2)
	))

	["union",
		["translate", [0,0,-2*atom_width_mm], bottom_hinge_atom],
		for( zm = [0] ) ["translate", [0,0,zm*atom_width_mm], mid_hinge_atom],
		for( zm = [-1,1] ) ["translate", [0,0,zm*atom_width_mm], ["rotate", [0,0,180], mid_hinge_atom]],
		["translate", [0,0,2*atom_width_mm], top_hinge_atom],
		
		["translate", [ (slab_width + hinge_thickness_mm)/2, 0, 0], slab],
		["translate", [-(slab_width + hinge_thickness_mm)/2, 0, 0], slab],
	]
);
