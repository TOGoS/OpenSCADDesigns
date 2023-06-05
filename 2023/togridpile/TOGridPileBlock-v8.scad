// TOGridPileBlock-v8.2.3
//
// v8.2.3:
// - Updates based on TOGridPileLib-v2.2.3;
//   side_segmentation = "chunk" is more useful
// - Atom pitch, chunk pitch, origin parameters

use <../lib/TOGridPileLib-v2.scad>

/* [Block Shape] */

atom_pitch = 12.7;
chunk_pitch_atoms = 3;
column_style = "v8.4"; // ["v6", "v6.1", "v6.2", "v8", "v8.0", "v8.4"]
female_column_style = "v6.1"; // ["v3", "v6", "v6.1", "v6.2", "v8", "v8.0", "v8.4"]
chunk_body_style = "v1"; // ["v0.0","v0.1","v1","v2","v8"]
block_size_chunks = [2,3,1];
chunk_column_placement = "grid"; // ["none","corners","grid"]
bottom_segmentation = "chunk"; // ["atom","chunk","block"]
side_segmentation = "block"; // ["atom","chunk","block"]
origin = "bottom"; // ["center","bottom"]

/* [Cavity] */

wall_thickness = 2;
floor_thickness = 6.35;

// Nonzero value if you want a curve at the bottom to help slide things out; recommended value: 12.7
fingerslide_radius = 0; // 0.001
// Nonzero value if you want a label platform; recommended value: 12.7
label_width = 0; // 0.001

/* [Detail] */

margin = 0.1;
$fn = 24;

module hkfyua83g4s__end_params() {}

chunk_pitch = atom_pitch*chunk_pitch_atoms;
block_size = block_size_chunks*chunk_pitch;

cavity_size = [
	block_size[0]-(margin+wall_thickness)*2,
	block_size[1]-(margin+wall_thickness)*2,
	block_size[2]-floor_thickness
];

cs1 = [cavity_size[0]+0.1, cavity_size[1]+0.1]; // For sticking things in the walls

module the_sublip() {
	sublip_width = 2;
	sublip_angwid = sublip_width/sin(45);
	sublip_angwid2 = sublip_angwid*2*1.414;
	for(xm=[-1,1]) translate([xm*cs1[0]/2, 0, 0]) rotate([0,45,0])
		cube([sublip_angwid,block_size[1],sublip_angwid], center=true);
	for(ym=[-1,1]) translate([0, ym*cs1[1]/2, 0]) rotate([45,0,0])
		cube([block_size[0],sublip_angwid,sublip_angwid], center=true);
	for(ym=[-1,1]) for(xm=[-1,1]) translate([xm*cs1[0]/2, ym*cs1[1]/2, 0]) rotate([0,0,ym*xm*45]) rotate([0,45,0])
		cube([sublip_angwid2,sublip_angwid2,sublip_angwid2], center=true);
}

module the_label_platform() {
	if( label_width > 0 ) {
		label_angwid = label_width*2*sin(45);
		translate([-cs1[0]/2, 0, 0]) rotate([0,45,0]) cube([label_angwid,block_size[1],label_angwid], center=true);
	}
}

module the_fingerslide() {
	if( fingerslide_radius > 0 ) difference() {
		translate([cavity_size[0]/2, 0, 0])
			cube([fingerslide_radius*2, cavity_size[1]*2, fingerslide_radius*2], center=true);
		translate([cavity_size[0]/2-fingerslide_radius, 0, fingerslide_radius])
			rotate([90,0,0]) cylinder(r=fingerslide_radius, h=cavity_size[1]*3, center=true, $fn=max(24,$fn));
	}
}

module the_cup_cavity() difference() {
	togridpile2_chunk_body(
		style="v1",
		size=[cavity_size[0], cavity_size[1], cavity_size[2]*2],
		offset=0
	);
	the_sublip();
	the_label_platform();
	translate([0,0,-cavity_size[2]]) the_fingerslide();
}

module the_lip_cavity() difference() {
	togridpile2_block(
		block_size_chunks = [
			block_size_chunks[0],
			block_size_chunks[1],
			block_size_chunks[2]*2
		],
		chunk_pitch_atoms = chunk_pitch_atoms,
		atom_pitch = atom_pitch,
		column_style = female_column_style,
		chunk_column_placement = chunk_column_placement,
		chunk_body_style = chunk_body_style,
		bottom_segmentation = "block",
		side_segmentation = "atom",
		offset = margin,
		origin = origin
	);
}

module the_block_hull() intersection() {
	lip_height = 2.54;

	cube([block_size[0]*2, block_size[1]*2, (block_size[2]+lip_height)*2], center=true);
	togridpile2_block(
		block_size_chunks = [
			block_size_chunks[0],
			block_size_chunks[1],
			block_size_chunks[2]*2
		],
		chunk_pitch_atoms = chunk_pitch_atoms,
		atom_pitch = atom_pitch,
		column_style = column_style,
		chunk_column_placement = chunk_column_placement,
		chunk_body_style = chunk_body_style,
		bottom_segmentation = bottom_segmentation,
		side_segmentation = side_segmentation,
		offset = -margin,
		origin = origin
	);
}

module the_block() difference() {
	render() the_block_hull();

	translate([0, 0, block_size[2]]) render() the_lip_cavity();
	translate([0, 0, block_size[2]]) render() the_cup_cavity();
	
	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2] )
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
	for( xcm=[-1,1] ) for( ycm=[-1,1] ) {
		translate([
			xm*chunk_pitch + xcm*(chunk_pitch_atoms-1)/2*atom_pitch,
			ym*chunk_pitch + ycm*(chunk_pitch_atoms-1)/2*atom_pitch,
			0
		]) {
			render() togridpile2_block_magnet_hole(floor_thickness=floor_thickness);
		}
	}
}

the_block();
