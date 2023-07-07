// TOGridPileBracketShelf-v1.3
// 
// Changes:
// v1.1:
// - Cut 'window' out of top of front edge
// - Cut off extra bit at top so hull_size[2] = capacity[2] + wall_thickness
// v1.2:
// - Options for different lip segmentation
// v1.3:
// - Apply margin to exterior hull
// - Add separate inner_margin option for interior cavity

margin = 0.075;
// Margin for the main cavity, x, and y
inner_margin = [1.5, 0.3]; // 0.1
capacity_chunks = [6, 1];

lip_segmentation = "none"; // ["none","chunk","block"]

preview_fn = 12;
render_fn = 36;

include <../lib/TOGridPileLib-v3.scad>

capacity_ca = [[capacity_chunks[0], "chunk"], [capacity_chunks[1], "chunk"], [1, "chunk"]];
capacity = togridpile3_decode_vector(capacity_ca);

wall_thickness = 6.35;
outer_bevel_size = wall_thickness/2;

hull_size = [
	capacity[0] + wall_thickness*2,
	capacity[1] + wall_thickness*2,
	capacity[2] + wall_thickness
];

$fn = $preview ? preview_fn : render_fn;

use <TGx9.2.scad>
use <../lib/TOGHoleLib-v1.scad>
use <../lib/TOGShapeLib-v1.scad>

module block_subtraction(block_size_ca) intersection() {
	block_size = togridpile3_decode_vector(block_size_ca);
	// TODO: Make TOGridPileLib-v3 do this stuff for us
	linear_extrude(block_size[2]*3, center=true) tog_shapelib_rounded_square(
		[block_size[0]+inner_margin[0]*2, block_size[1]+inner_margin[1]*2],
		togridpile3_decode([1, "tgp-standard-bevel"])
	);
	
	tgx9_1_0_block_foot(
		block_size_ca,
		corner_radius     = "f",
		foot_segmentation = lip_segmentation,
		chunk_ops         = [
			["add", ["tgx9_usermod_1", "chunk-magnet-holes"]],
			["add", ["tgx9_usermod_1", "chunk-screw-holes", "THL-1001"]]
		],
		$tgx9_unit_table  = togridpile3_get_unit_table(),
		offset = margin
	);
}

translate([0,0,(hull_size[2]+wall_thickness)/2]) difference() {
	translate([0, 0, -wall_thickness/2]) tog_shapelib_xy_rounded_cube(hull_size, outer_bevel_size, margin);
	
	// Bevel the top by some arbitrary amount
	translate([0, -hull_size[1]/2, hull_size[2]/2]) rotate([45, 0, 0]) cube([hull_size[0]+2, hull_size[2]*1.2, hull_size[2]*1.2], center=true);
	
	// TOGridPile block cavity
	translate([0, 0, -capacity[2]/2]) block_subtraction(capacity_ca);

	// Front 'window'
	translate([0, -hull_size[1]/2, 0]) tog_shapelib_xz_rounded_cube(
		[capacity[0], wall_thickness*4, togridpile3_decode([2, "atom"])],
		tgx9_decode_corner_radius("f"), margin);

	for( xc=[-capacity_chunks[0]/2+0.5 : 1 : capacity_chunks[0]/2] ) {
		x = togridpile3_decode([xc, "chunk"]);
		echo(hole_pos=x);
		translate([x, capacity[1]/2+margin, 0]) {
			rotate([90, 0, 0]) {
				tog_holelib_hole("THL-1002");
				for(subpos_atom=[[-1,0],[1,0],[0,-1],[0,1]]) {
					subpos = togridpile3_decode_vector([[subpos_atom[0], "atom"], [subpos_atom[1], "atom"]]);
					translate(subpos) tog_holelib_hole("THL-1001");
				}
			}
		}
	}
}
