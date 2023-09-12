// TGx10.1: Can I make a chunky block relatively efficiently?
//
// 10.1.0:
// - Here is something
// 10.1.1:
// - Reformat, refactor
// - Add horizontal columns
// - Add a marker magnet hole in the top left of the front

use <../lib/TOGridLib3.scad>
use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridPileLib-v2.scad>

block_size_chunks = [4, 4, 4];
chunk_pitch_atoms = 1;
foot_column_style = "none"; // ["none","v6.0","v6.1","v6.2","v8.0","v8.4"]

$fn = $preview ? 16 : 64;
$tgx9_mating_offset = -0.075;
$togridlib3_unit_table = [
	["chunk", [chunk_pitch_atoms, "atom"], "chunk"],
	each togridlib3_get_unit_table(),
];

block_size_ca = [
	[block_size_chunks[0], "chunk"],
	[block_size_chunks[1], "chunk"],
	[block_size_chunks[2], "chunk"]
];

module tgx10_linear_extrude_x_nicked(h, d, bevel_size=3.175) {
	if( bevel_size <= 0 ) {
		rotate([0,90,0]) linear_extrude(h, center=true) children();
	} else difference() {
		nickube_size = bevel_size*1.415;
		rotate([0,90,0]) linear_extrude(h, center=true) children();
		
		for(x=[-h/2,h/2]) translate([x,0,-d/2]) rotate([0,45,0]) cube([nickube_size, d*2, nickube_size], center=true);		
	}
}

function tgx10_grid_centers_xy(size, pitch=1) = [
	for( x=[(-size[0]+pitch)/2 : pitch : size[0]/2] )
	for( y=[(-size[1]+pitch)/2 : pitch : size[1]/2] )
		[x, y]
];
function tgx10_grid_centers_xyz(size, pitch=1) = [
	for( x=[(-size[0]+pitch)/2 : pitch : size[0]/2] )
	for( y=[(-size[1]+pitch)/2 : pitch : size[1]/2] )
	for( z=[(-size[2]+pitch)/2 : pitch : size[2]/2] )
		[x, y, z]
];

module tgx10_cbunky_block(block_size_ca) intersection() {
	u = togridlib3_decode([1, "u"]);
	atom_pitch = togridlib3_decode([1, "atom"]);
	block_size = togridlib3_decode_vector(block_size_ca);
	block_size_atoms = [
		block_size_chunks[0] * chunk_pitch_atoms,
		block_size_chunks[1] * chunk_pitch_atoms,
		block_size_chunks[2] * chunk_pitch_atoms,
	];

	translate([0, 0, block_size[2]/2]) cube([
		block_size[0] + $tgx9_mating_offset*2,
		block_size[1] + $tgx9_mating_offset*2,
		block_size[2] + $tgx9_mating_offset*2,
	], center=true);
	
	union() {
		intersection() {
			render() tgx9_block_foot(
				block_size_ca,
				corner_radius     = togridlib3_decode([1, "m-outer-corner-radius"]),
				foot_segmentation = "atom",
				$tgx9_chatomic_foot_column_style = "none",
				offset = $tgx9_mating_offset
			);
			
			intersection_for(xm=[-1,1]) {
				scale([xm,1,1]) translate([block_size[0]/2, 0, block_size[2]/2]) rotate([0,-90,0]) render() tgx9_block_foot(
					[
						block_size_ca[2],
						block_size_ca[1],
						block_size_ca[0]
					],
					corner_radius     = togridlib3_decode([1, "m-outer-corner-radius"]),
					foot_segmentation = "atom",
					$tgx9_chatomic_foot_column_style = "none",
					offset = $tgx9_mating_offset
				);
			}
			
			intersection_for(ym=[-1,1]) {
				scale([1,ym,1]) translate([0, block_size[1]/2, block_size[2]/2]) rotate([90,0,0]) render() tgx9_block_foot(
					[
						block_size_ca[0],
						block_size_ca[2],
						block_size_ca[1]
					],
					corner_radius     = togridlib3_decode([1, "m-outer-corner-radius"]),
					foot_segmentation = "atom",
					$tgx9_chatomic_foot_column_style = "none",
					offset = $tgx9_mating_offset
				);
			}
		}

		column_diameter = atom_pitch - 2*u;
		
		translate([0,0,block_size[2]/2])
		linear_extrude(block_size[2] + $tgx9_mating_offset*2, center=true)
		for( posa=tgx10_grid_centers_xy(block_size_atoms) )
		{
			translate(posa*atom_pitch) {
				togridpile2_atom_column_footprint(
					foot_column_style,
					atom_pitch=atom_pitch,
					column_diameter=column_diameter,
					min_corner_radius=u,
					offset = $tgx9_mating_offset
				);
			}
		}

		translate([0,0,block_size[2]/2])
		for( rotsize=[
			// rotation, grid size Y, length
			[[0,0, 0], block_size_atoms[1], block_size[0]],
			[[0,0,90], block_size_atoms[0], block_size[1]]
		] )
		rotate( rotsize[0] )
		for( posa=tgx10_grid_centers_xyz([1, rotsize[1], block_size_atoms[2]]) )
		translate(posa*atom_pitch) tgx10_linear_extrude_x_nicked(rotsize[2], column_diameter, 1.5875)
		{
			togridpile2_atom_column_footprint(
				foot_column_style,
				atom_pitch=atom_pitch,
				column_diameter=column_diameter,
				min_corner_radius=u,
				offset = $tgx9_mating_offset
			);
		}
	
		translate([0,0,block_size[2]]) cube([
			block_size[0] - 4*u,
			block_size[1] - 4*u,
			block_size[2],
		], center=true);
	}
}

difference() {
	atom_pitch = togridlib3_decode([1, "atom"]);
	block_size = togridlib3_decode_vector(block_size_ca);
	
	tgx10_cbunky_block(block_size_ca);

	translate([0,0,block_size[2]]) tgx9_cavity_cube([
		block_size[0] - 10,
		block_size[1] - 10,
		block_size[2] - 6,
	], top_bevel_width = 0);

	translate([
		(-block_size[0]+atom_pitch)/2,
		-block_size[1]/2,
		block_size[2]-atom_pitch/2
	]) rotate([90,0,0]) cylinder(d=6.2, h=4.8, center=true);
}
