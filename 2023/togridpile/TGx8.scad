// TOGridPile [experimental] shape 8.4.2
//
// Changes:
// v8.2:
// - Rename 'max_lip_height' to 'max_flat_lip_height'; lip can be taller;
//   is just can't be completely flat after that
// - Add various body style options
// - Add columns on x and y axes, nicked to avoid overhang
// v8.4:
// - Rename 'atom_size' to 'atom_pitch' to reflect that it's a scalar value
// - Rename 'block_size_atoms' to 'block_pitch_atoms' to reflect that it's a scalar value
// - Add column style options, including
//   - v6.1 (which matches nothing else that exists, but corrects a math error)
//   - v6.2 (which trims corners more to allow in-between-diagonally columns)
//   - v8.4 (3/8" circules but with trimmed corners to allow in-between-diagonally columns, similar to v6.2)
// - Add 'none' body style, to make a block that's just columns
// - Add 'swiss' body style, which puts space for an entire column diagonally between the columns
// - Put screw holes through along X and Y axes
// v8.4.2:
// - Actually apply size parameters to column shape

margin = 0.1;

block_pitch_atoms = 3;
body_style = "segmented"; // ["none","swiss","segmented","atomic-hull","rounded-3/16","rounded-beveled","beveled"]
column_style = "v8.4"; // ["v6", "v6.1", "v6.2", "v8.0", "v8.4"]
use_legacy_v6_function = false;

atom_render_fn   = 48;
column_render_fn = 48;
hole_render_fn   = 24;

preview_fn_multiplier = 0.5;

atom_pitch = 12.7;
// 9.525 = 3/8"
column_diameter = 9.525;
segmented_body_inset = 3.175; // 1.5875;
block_column_axes = [1,1,1];
baseplate_floor_thickness = 3.175;

// Radius of small corners
min_corner_radius = 1.5875;

use <../lib/TOGridPileLib-v1.scad>
use <../lib/TOGridPileLib-v2.scad>
use <../lib/TOGHoleLib-v1.scad>

module __end_params() { }

inch = 25.4;

fn_multiplier = $preview ? preview_fn_multiplier : 1;

atom_fn   =   atom_render_fn * fn_multiplier;
column_fn = column_render_fn * fn_multiplier;
hole_fn   =   hole_render_fn * fn_multiplier;

rounded_cube_corner_radius = atom_pitch/2;
column_corner_radius = column_diameter/2;

column_inset = rounded_cube_corner_radius-column_corner_radius;
blangle = acos(column_corner_radius/rounded_cube_corner_radius); // Angle from uh
max_flat_lip_height = min(column_inset, column_corner_radius * (1-sin(blangle)));

echo(str("Blangle = ", blangle, " = acos(", column_corner_radius/rounded_cube_corner_radius, ")"));
echo("Max lip height:", max_flat_lip_height);


module togridpile_shape8_atom_sphere(offset=0) {
	sphere(d=atom_pitch+offset*2, $fn=atom_fn);
}

module togridpile_shape8_atom(offset) {
	togridpile_shape8_atom_sphere(offset=offset);
	cylinder(h=atom_pitch+offset*2, d=column_diameter+offset*2, center=true, $fn=column_fn);
}

function line_end_segment_center_positions(size_atoms, atom_pitch) = [
	for( x=[-(size_atoms-1)/2, (size_atoms-1)/2] ) x*atom_pitch
];

function line_segment_center_positions(size_atoms, atom_pitch) = [
	for( x=[-(size_atoms-1)/2 : 1 : (size_atoms-1)/2] ) x*atom_pitch
];

function cube_corner_segment_center_positions(size_atoms, atom_pitch) = [
	for( x=line_end_segment_center_positions(size_atoms[0], atom_pitch) )
	for( y=line_end_segment_center_positions(size_atoms[1], atom_pitch) )
	for( z=line_end_segment_center_positions(size_atoms[2], atom_pitch) )
	[x,y,z]
];

function cube_segment_center_positions(size_atoms, atom_pitch) = [
	for( x=line_segment_center_positions(size_atoms[0], atom_pitch) )
	for( y=line_segment_center_positions(size_atoms[1], atom_pitch) )
	for( z=line_segment_center_positions(size_atoms[2], atom_pitch) )
	[x,y,z]
];

function tovec3(v) = is_list(v) ? v : [v,v,v];

module linear_extrude_x_nicked(h, d, bevel_size=1/16*inch) {
	if( bevel_size <= 0 ) {
		rotate([0,90,0]) linear_extrude(h, center=true) children();
	} else difference() {
		nickube_size = bevel_size*1.415;
		rotate([0,90,0]) linear_extrude(h, center=true) children();
		
		for(x=[-h/2,h/2]) translate([x,0,-d/2]) rotate([0,45,0]) cube([nickube_size, d*2, nickube_size], center=true);		
	}
}

module horizontal_nicked_cylinder(h, d, bevel_size=1/16*inch) {
       linear_extrude_x_nicked(h, d, bevel_size=bevel_size) circle(d=d);
}

module togridpile_shape8_block(block_pitch_atoms=block_pitch_atoms, body_style=body_style, column_axes=[1,1,1], nick_overhangs=false, offset=0) {
	column_length_offset = offset; // for now
	block_size = block_pitch_atoms*atom_pitch;

	block_size_atoms = tovec3(block_pitch_atoms);

	if( body_style == "none" || body_style == "swiss" ) {
	} else if( body_style == "segmented" ) {
		// Atoms
		for( pos=cube_segment_center_positions(block_size_atoms, atom_pitch) ) {
			translate(pos) togridpile_shape8_atom_sphere(offset=offset);
		}
		
		body_size = block_size - segmented_body_inset*2;
		// Body
		togridpile__rounded_cube(tovec3(body_size), atom_pitch/2 - segmented_body_inset, offset=offset, $fn=atom_fn);
	} else if( body_style == "rounded-beveled" ) {
		togridpile__facerounded_beveled_cube(tovec3(block_size), 1/8*inch, 1/16*inch, offset=offset, $fn=atom_render_fn);
	} else if( body_style == "beveled" ) {
		togridpile__beveled_cube(tovec3(block_size), 1/8*inch, offset=offset, $fn=atom_render_fn);
	} else if( body_style == "rounded-3/16" ) {
		togridpile__rounded_cube(tovec3(block_size), 3/16*inch, offset=offset, $fn=atom_render_fn);
	} else if( body_style == "atomic-hull" ) {
		hull() for( pos=cube_corner_segment_center_positions(block_size_atoms, atom_pitch) ) {
			translate(pos) togridpile_shape8_atom_sphere(offset=offset);
		}
	} else {
		assert(false, str("Unrecognized body style: ", body_style));
	}
	
	overhang_nick_size = nick_overhangs ? (atom_pitch - column_diameter)/2 : 0;
	
	if( column_axes[0] )
	for( y=line_segment_center_positions(block_size_atoms[0], atom_pitch) )
	for( z=line_segment_center_positions(block_size_atoms[2], atom_pitch) )
	translate([0,y,z])
		linear_extrude_x_nicked(atom_pitch*block_size_atoms[2]+column_length_offset*2, d=column_diameter+offset*2, bevel_size=overhang_nick_size)
			the_atom_column_footprint();
	
	if( column_axes[1] )
	for( x=line_segment_center_positions(block_size_atoms[0], atom_pitch) )
	for( z=line_segment_center_positions(block_size_atoms[2], atom_pitch) )
	translate([x,0,z]) rotate([0,0,90])
		linear_extrude_x_nicked(atom_pitch*block_size_atoms[2]+column_length_offset*2, d=column_diameter+offset*2, bevel_size=overhang_nick_size)
			the_atom_column_footprint();
	
	if( column_axes[2] )
	for( x=line_segment_center_positions(block_size_atoms[0], atom_pitch) )
	for( y=line_segment_center_positions(block_size_atoms[1], atom_pitch) )
	translate([x,y,0])
		linear_extrude(atom_pitch*block_size_atoms[2]+column_length_offset*2, center=true)
			the_atom_column_footprint();
}

module togridpile_shape8_extruded_baseplate(size_blocks, block_pitch_atoms) {
	lip_height = min(3.175, max_flat_lip_height);
	size_atoms = [
		size_blocks[0]*block_pitch_atoms,
		size_blocks[1]*block_pitch_atoms,
	];
	size = [
		size_blocks[0]*block_size,
		size_blocks[1]*block_size,
	];

	linear_extrude(lip_height, center=false) {
		difference() {
			togridpile__rounded_square(size, rounded_cube_corner_radius, $fn=atom_fn);
			
			for( x=line_segment_center_positions(size_atoms[0], atom_pitch) )
			for( y=line_segment_center_positions(size_atoms[1], atom_pitch) )
			translate([x,y]) circle(d=column_diameter-margin*2, $fn=column_fn);
		}
	}
}

module togridpile_shape8_3d_baseplate(size_blocks, floor_thickness=0, lip_height=3.175, block_pitch_atoms=block_pitch_atoms) {
	// lip_height = min(3.175, max_flat_lip_height);
	size_atoms = [
		size_blocks[0]*block_pitch_atoms,
		size_blocks[1]*block_pitch_atoms,
	];
	size = [
		size_blocks[0]*block_size,
		size_blocks[1]*block_size,
	];

	translate([0,0,floor_thickness]) difference() {
		translate([0,0,-floor_thickness]) linear_extrude(floor_thickness+lip_height, center=false) {
			togridpile__rounded_square(size, rounded_cube_corner_radius);
		}
		
		for( x=line_segment_center_positions(size_blocks[0], block_size) )
	     	for( y=line_segment_center_positions(size_blocks[1], block_size) )
		translate([x,y,block_size/2]) togridpile_shape8_block(block_pitch_atoms, body_style="atomic-hull", offset=margin);
	}
}

module the_atom_column_footprint() {
	togridpile2_atom_column_footprint(
		column_style      = column_style,
		atom_pitch        = atom_pitch,
		column_diameter   = column_diameter,
		min_corner_radius = min_corner_radius,
		offset            = -margin,
		$fn               = column_fn
	);
}

block_size = block_pitch_atoms*atom_pitch;

translate([0,0,block_size/2]) difference() {
	togridpile_shape8_block(block_pitch_atoms, column_axes=block_column_axes, nick_overhangs=true, offset=-margin);

	for( rot=[[0,0,0],[90,0,0],[0,90,0]] )
	rotate(rot)
	for( x=line_segment_center_positions(block_pitch_atoms, atom_pitch) )
	for( y=line_segment_center_positions(block_pitch_atoms, atom_pitch) )
	translate([x,y,0]) cylinder(h=atom_pitch*block_pitch_atoms+2, d=3.5, center=true, $fn=hole_fn);
	
	if( body_style == "swiss" ) {
		for( rot=[[0,0,0],[90,0,0],[0,90,0]] )
		rotate(rot)
		for( x=line_segment_center_positions(block_pitch_atoms-1, atom_pitch) )
		for( y=line_segment_center_positions(block_pitch_atoms-1, atom_pitch) )
		translate([x,y,0])
			linear_extrude(atom_pitch*block_pitch_atoms*2, center=true) the_atom_column_footprint();
	}
}

baseplate_size_blocks = [1,2];

translate([block_size*2, 0, 0]) difference() {
	togridpile_shape8_3d_baseplate(baseplate_size_blocks, floor_thickness=baseplate_floor_thickness, lip_height=2.54, block_pitch_atoms);
	
	for( x=line_segment_center_positions(baseplate_size_blocks[0]*block_pitch_atoms, atom_pitch) )
	for( y=line_segment_center_positions(baseplate_size_blocks[1]*block_pitch_atoms, atom_pitch) )
	translate([x,y,baseplate_floor_thickness]) tog_holelib_hole("THL-1001", depth=baseplate_floor_thickness*2, $fn=hole_fn);
}
