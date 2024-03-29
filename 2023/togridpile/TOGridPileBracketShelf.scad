// TOGridPileBracketShelf-v1.4.0
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
// v1.3.1:
// - Switch to TGx9.4.scad
// v1.3.2:
// - Update `togridpile3` -> `togridlib3` prefixes
// v1.4.0:
// - Reduce default inner margin to 0.6, 0.3
// - Remove configuration option for outer corner 'bevel', which was actually rounding radius
// - Make front top bevel size configurable, default to 38.1mm

margin = 0.075;
// Margin for the main cavity, x, and y
inner_margin = [0.6, 0.3]; // 0.1
capacity_chunks = [6, 1];

lip_segmentation = "none"; // ["none","chunk","block"]

preview_fn = 12;
render_fn = 36;

front_top_bevel_size = 38.1;// 44.45;

include <../lib/TOGridLib3.scad>

capacity_ca = [[capacity_chunks[0], "chunk"], [capacity_chunks[1], "chunk"], [1, "chunk"]];
capacity = togridlib3_decode_vector(capacity_ca);

wall_thickness = 6.35;

hull_size = [
	capacity[0] + wall_thickness*2,
	capacity[1] + wall_thickness*2,
	capacity[2] + wall_thickness
];

$fn = $preview ? preview_fn : render_fn;

// include <../lib/TGx9.4Lib.scad>
use <./TGx9.4.scad> // Defines tgx9_usermod_1, which this script uses
use <../lib/TOGHoleLib-v1.scad>
use <../lib/TOGShapeLib-v1.scad>

module block_subtraction(block_size_ca) intersection() {
	block_size = togridlib3_decode_vector(block_size_ca);
	// TODO: Make TOGridPileLib-v3 do this stuff for us
	linear_extrude(block_size[2]*3, center=true) tog_shapelib_rounded_square(
		[block_size[0]+inner_margin[0]*2, block_size[1]+inner_margin[1]*2],
		togridlib3_decode([1, "tgp-standard-bevel"])
	);
	
	tgx9_block_foot(
		block_size_ca,
		corner_radius     = "f",
		foot_segmentation = lip_segmentation,
		chunk_ops         = [
			["add", ["tgx9_usermod_1", "chunk-magnet-holes"]],
			["add", ["tgx9_usermod_1", "chunk-screw-holes", "THL-1001"]]
		],
		$tgx9_unit_table  = togridlib3_get_unit_table(),
		offset = margin
	);
}

translate([0,0,(hull_size[2]+wall_thickness)/2]) difference() {
	translate([0, 0, -wall_thickness/2]) linear_extrude(hull_size[2], center=true) intersection() {
		tog_shapelib_rounded_square(hull_size, wall_thickness, offset=-margin);
		tog_shapelib_rounded_beveled_square(hull_size, 3.175, 3.175, offset=-margin);
	}
	
	// Bevel the top by some arbitrary amount
	translate([0, -hull_size[1]/2, hull_size[2]/2]) rotate([45, 0, 0])
		cube([hull_size[0]+2, front_top_bevel_size*sqrt(2)+margin*2, front_top_bevel_size*sqrt(2)+margin*2], center=true);
	
	// TOGridPile block cavity
	translate([0, 0, -capacity[2]/2]) block_subtraction(capacity_ca);

	// Front 'window'
	translate([0, -hull_size[1]/2, 0]) tog_shapelib_xz_rounded_cube(
		[capacity[0], wall_thickness*4, togridlib3_decode([2, "atom"])],
		tgx9_decode_corner_radius("f"), margin);
	
	for( xc=[-capacity_chunks[0]/2+0.5 : 1 : capacity_chunks[0]/2] ) {
		x = togridlib3_decode([xc, "chunk"]);
		echo(hole_pos=x);
		translate([x, capacity[1]/2+margin, 0]) {
			rotate([90, 0, 0]) {
				tog_holelib_hole("THL-1002");
				for(subpos_atom=[[-1,0],[1,0],[0,-1],[0,1]]) {
					subpos = togridlib3_decode_vector([[subpos_atom[0], "atom"], [subpos_atom[1], "atom"]]);
					translate(subpos) tog_holelib_hole("THL-1001");
				}
			}
		}
	}
}
