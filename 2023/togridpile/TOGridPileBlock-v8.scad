// TOGridPileBlock-v8.10
//
// v8.2.3:
// - Updates based on TOGridPileLib-v2.2.3;
//   side_segmentation = "chunk" is more useful
// - Atom pitch, chunk pitch, origin parameters
// v8.2.4:
// - Support 'v3' feet, which are the same as v6 but one per chunk,
//   not per atom
// v8.2.5:
// - 'origin' is always "bottom"
// v8.2.6:
// - Default female_column_style = "v3"
// v8.3:
// - Height no longer needs to be an integer multiple of chunk pitch
// - Add 'v3' as a block bottom column style option
// v8.4:
// - Make segmentation of top/female side configurable
// v8.5:
// - Add option of topside magnet holes
// v8.6:
// - Flathead screw holes in topside
// v8.7:
// - Magnet drain hole diameter is customizable
// v8.8:
// - Customizable bulkhead positions to break up the cavity
// v8.9
// - Configurable male/female side column style/placement
// v8.10
// - Configurable cavity bulkhead axis

/* [Block Shape] */

atom_pitch = 12.7;
chunk_pitch_atoms = 3;
column_style = "v8.4"; // ["v3", "v6", "v6.1", "v6.2", "v8", "v8.0", "v8.4"]
chunk_body_style = "v1"; // ["v0.0","v0.1","v1","v2","v8"]
block_size_chunks = [2,3];
// Height, not including lip
height = 25.4; // 0.0001
chunk_column_placement = "grid"; // ["none","corners","grid"]
bottom_segmentation = "atom"; // ["atom","chunk","block"]
side_segmentation = "block"; // ["atom","chunk","block"]
side_column_style = "none"; // ["none", "auto", "v6", "v8"]
side_column_placement = "grid"; // ["none","auto","grid","corners"]

/* [Female Shape] */

female_column_style = "v3"; // ["v3", "v6", "v6.1", "v6.2", "v8", "v8.0", "v8.4"]
female_segmentation = "block"; // ["atom", "chunk", "block"]
female_side_column_style = "auto"; // ["none", "auto", "v6", "v8"]
female_side_column_placement = "grid"; // ["none","auto","grid","corners"]
lip_height = 2.54; // 0.0001

/* [Cavity] */

wall_thickness = 2;
floor_thickness = 6.35;
cavity_bulkhead_positions = [];
cavity_bulkhead_axis = "x"; // ["x", "y"]

// Nonzero value if you want a curve at the bottom to help slide things out; recommended value: 12.7
fingerslide_radius = 0; // 0.001
// Nonzero value if you want a label platform; recommended value: 12.7
label_width = 0; // 0.001

/* [Magnet and screw holes] */

magnet_holes_in_bottom = true;
magnet_holes_in_top = false;
magnet_drain_hole_diameter = 3; // 0.1

small_hole_style = "THL-1001"; // ["none", "THL-1001", "THL-1002"]
large_hole_style = "THL-1001"; // ["none", "THL-1001", "THL-1002"]

/* [Detail] */

margin = 0.1;
$fn = 24;

module hkfyua83g4s__end_params() {}

use <../lib/TOGridPileLib-v2.scad>
use <../lib/TOGHoleLib-v1.scad>

chunk_pitch = atom_pitch*chunk_pitch_atoms;
block_size = [
	block_size_chunks[0]*chunk_pitch,
	block_size_chunks[1]*chunk_pitch,
	height,
];

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

function kasjhd_swapxy(vec, swap=true) = [
	swap ? vec[1] : vec[0],
	swap ? vec[0] : vec[1],
	for( i=[2:1:len(vec)-1] ) vec[i]
];

module the_cup_cavity() if(cavity_size[2] > 0) difference() {
	togridpile2_chunk_body(
		style="v1",
		size=[cavity_size[0], cavity_size[1], cavity_size[2]*2],
		offset=0
	);
	the_sublip();
	the_label_platform();
	translate([0,0,-cavity_size[2]]) the_fingerslide();
	for( i=cavity_bulkhead_positions ) {
		maybeswapxy = cavity_bulkhead_axis == "x" ? function(v) kasjhd_swapxy(v) : function(v) v;
		translate(maybeswapxy([i,0,0])) cube(maybeswapxy([wall_thickness, block_size[1], block_size[2]*2]), center=true);
	}
}

module the_lip_cavity() difference() {
	togridpile2_block(
		block_size_chunks = [
			block_size_chunks[0],
			block_size_chunks[1],
			1
		],
		chunk_pitch_atoms = chunk_pitch_atoms,
		atom_pitch = atom_pitch,
		column_style = female_column_style,
		side_column_style = female_side_column_style,
		chunk_side_column_placement = female_side_column_placement,
		chunk_column_placement = chunk_column_placement,
		chunk_body_style = chunk_body_style,
		bottom_segmentation = female_segmentation,
		side_segmentation = "atom",
		offset = margin,
		origin = "bottom"
	);
}

module the_block_hull() intersection() {
	cube([block_size[0]*2, block_size[1]*2, (block_size[2]+lip_height)*2], center=true);
	togridpile2_block(
		block_size_chunks = [
			block_size_chunks[0],
			block_size_chunks[1],
			ceil(height / chunk_pitch) + 1
		],
		chunk_pitch_atoms = chunk_pitch_atoms,
		atom_pitch = atom_pitch,
		column_style = column_style,
		side_column_style = side_column_style,
		chunk_side_column_placement = side_column_placement,
		chunk_column_placement = chunk_column_placement,
		chunk_body_style = chunk_body_style,
		bottom_segmentation = bottom_segmentation,
		side_segmentation = side_segmentation,
		offset = -margin,
		origin = "bottom"
	);
}

module the_block() difference() {
	// Sometimes you need to fiddle with the order
	// of operations and whether or not different parts
	// are render()ed in order to get this to work without errors.
	render() difference() {
		the_block_hull();
		translate([0, 0, block_size[2]]) the_cup_cavity();
	}
	
	translate([0, 0, block_size[2]]) the_lip_cavity();

	top_hole_z = min(floor_thickness, block_size[2]);

	for( xm=[-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2] )
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
	translate([xm*chunk_pitch, ym*chunk_pitch]) {
		translate([0, 0, top_hole_z]) render() tog_holelib_hole(large_hole_style, depth=floor_thickness+1, overhead_bore_height=floor_thickness);
		for( subpos=[[0,1],[1,0],[0,-1],[-1,0]] ) {
			translate([subpos[0]*atom_pitch, subpos[1]*atom_pitch, top_hole_z]) render()
				tog_holelib_hole(small_hole_style, depth=floor_thickness+1, overhead_bore_height=1);
		}
		for( xcm=[-1,1] ) for( ycm=[-1,1] ) {
			if( magnet_holes_in_bottom ) translate([
				xcm*(chunk_pitch_atoms-1)/2*atom_pitch,
				ycm*(chunk_pitch_atoms-1)/2*atom_pitch,
				0
			]) {
				render() togridpile2_block_magnet_hole(floor_thickness=floor_thickness, magnet_drain_hole_diameter=magnet_drain_hole_diameter);
			}

			if( magnet_holes_in_top ) translate([
				xcm*(chunk_pitch_atoms-1)/2*atom_pitch,
				ycm*(chunk_pitch_atoms-1)/2*atom_pitch,
				top_hole_z
			]) rotate([0,180,0]) {
				render() togridpile2_block_magnet_hole(floor_thickness=floor_thickness);
			}
		}
	}
}

the_block();
