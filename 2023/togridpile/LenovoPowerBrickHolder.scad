// [2023-07-01]: This is work in progress.
// I dislike how I had to include the entire TGx9.2.scad inline.
// Also not sure how useful this whole dang shape is.

v6hc_subtraction_enabled = false;
floor_thickness = 6.32;
bottom_magnet_holes_enabled = true;
lip_magnet_holes_enabled = false;
top_magnet_holes_enabled = false;
block_size_chunks = [3, 2];
block_height_u = 24;
wall_thickness = 2;
lip_height = 2.54;

use <../lib/TOGUnitTable-v1.scad>
use <../lib/TOGridPileLib-v3.scad>
use <./TGx9.2.scad>

block_size_ca = [
	[block_size_chunks[0], "chunk"],
	[block_size_chunks[1], "chunk"],
	[block_height_u      ,     "u"],
];
block_size = togridpile3_decode_vector(block_size_ca);

brick_size_ca = [
	[5+3/32, "inch"],
	[2+7/64, "inch"],
	[1+7/32, "inch"],
];
brick_size = togridpile3_decode_vector(brick_size_ca);
cord_slot_width_ca = [ 15/32, "inch"];
cord_slot_depth_ca = [  3/4 , "inch"];

// cube(decode_dims(block_size_ca));

atom_pitch  = togridpile3_decode([1,  "atom"]);
chunk_pitch = togridpile3_decode([1, "chunk"]);

module tgx9_usermod_1(what) {
	if( what == "chunk-magnet-holes" ) {
		for( pos=[[-1,-1],[1,-1],[-1,1],[1,1]] ) {
			translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
		}
	} else if( what == "chunk-screw-holes" ) {
		for( pos=[[0,-1],[-1,0],[0,1],[1,0],[0,0]] ) {
			translate(pos*atom_pitch) tog_holelib_hole(screw_hole_style);
		}
	} else if( what == "label-magnet-holes" ) {
		for( xm=[-block_size_chunks[0]/2+0.5] )
		for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] ) {
			translate([xm*chunk_pitch, ym*chunk_pitch, 0])
			for( pos=[[-1,-1],[-1,1]] ) {
				translate(pos*atom_pitch) cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
			}
		}
	} else {
		assert(false, str("Unrecognized user module argument: '", what, "'"));
	}
}

if( v6hc_subtraction_enabled && lip_height <= u-margin ) {
	echo("v6hc_subtraction_enabled enabled but not needed due to low lip (assuming column inset=1u, which is standard), so I won't bother to actually subtract it");
}

cord_slot_width = togridpile3_decode(cord_slot_width_ca);
cord_slot_depth = togridpile3_decode(cord_slot_depth_ca);

module tgx9_usermod_2(what) {
	if( what == "brick-cavity" ) {
		brick_size = togridpile3_decode_vector(brick_size_ca);
		translate([block_size[0]/2, 0, 0]) cube([
			//brick_size[0]*2,
			togridpile3_decode([4, "inch"])*2,
			brick_size[1],
			brick_size[2]*2
		], center=true);
		translate([-block_size[0]/2, 0, 0]) cube([40, cord_slot_width, (brick_size[2]+cord_slot_depth)], center=true);
	}
}

tgx9_1_6_cup(
	block_size_ca = block_size_ca,
	lip_height    = lip_height,
	floor_thickness = floor_thickness,
	wall_thickness = wall_thickness,
	block_top_ops = [
		["subtract", ["tgx9_usermod_2", "brick-cavity"]],
		// if( floor_thickness < block_size[2]) ["subtract",["the_cup_cavity"]],
		// if( label_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "label-magnet-holes"]],
		// TODO (maybe, if it increases performance): If lip segmentation = "chunk", do this in lip_chunk_ops instead of for the whole block
		if( v6hc_subtraction_enabled && lip_height > u-margin ) ["subtract", ["tgx1001_v6hc_block_subtractor", block_size_ca]],
	],
	lip_chunk_ops = [
		if( top_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]],
	],
	bottom_chunk_ops = [
		["subtract",["translate", [0, 0, floor_thickness], ["tgx9_usermod_1", "chunk-screw-holes"]]],
		if( bottom_magnet_holes_enabled ) ["subtract",["tgx9_usermod_1", "chunk-magnet-holes"]],
	]
);
