// TOGLEGO-v2.1
//
// Versions:
// v1.0:
// - Based on TOGLEGO-v0.5
// - New architecture!  block = intersection(bottom, middle, top section)
// - Block size unit is configurable;
//   LEGO studs and/or TGX9 atoms will be placed symmetrically
//   regardless of block size unit.
// v1.1:
// - Add 'lego-v1.1' bottom style, which spaces out the reinforcements
// v2.1 (based on v1.1):
// - Experimental 'TOGridPile on top' options

block_size_bsu = [4, 3];
block_size_unit = "stud"; // ["stud", "atom", "chunk", "mm"]

// Note: 1.6 = 1.0078740157480315 * 7.9375

// 8 = LEGO standard; 7.9375 = 5/16", a close approximation
lego_stud_pitch = 8; // 0.0001
// Height above top which studs stick
lego_stud_height = 1.8; // 0.01
// 4.8 = ideal diameter according to https://i.stack.imgur.com/OjziU.png
lego_stud_diameter = 4.8;

// Actual outer width of a 1x1 LEGO block
lego_outer_width = 7.80;
// Actual inner width of a 1x1 LEGO block
lego_inner_width = 4.80;

lego_inner_corner_radius = 2;

lego_circle_od = 6.51; // 0.01
lego_circle_id = 4.80;  // 0.01

// 1.5875 = 1/16", 6.35 = 1/4", good for TOGridPile adapters, 3.2 = LEGO plate, 9.6 = regular LEGO brick
block_height = 9.6; // 0.0001

/* [Top] */

top_style = "lego"; // ["lego", "tgx9-atomic", "tgx9-chunk"]

/* [TOGridPile top] */

tg_lip_height = 2.54; // 1.5875;

/* [Bottom] */

bottom_style = "lego"; // ["flat", "tgx9-atomic", "lego", "lego-v1.1"]
$tgx9_mating_offset = -0.1;
$tgx9_chatomic_foot_column_style = "v6.2";
$fn = $preview ? 24 : 64;

module __no_mo_parmsax() { }

use <../lib/TOGShapeLib-v1.scad>
use <../lib/TGx9.4Lib.scad>
use <../lib/TOGridLib3.scad>

regular_unit_table = [
	["stud", [lego_stud_pitch, "mm"], "LEGO stud pitch"],
	each togridlib3_get_default_unit_table()
];
atom_chunk_unit_table = [
	["chunk", [1, "atom"], "chunk (actually atom lol)"],
	each regular_unit_table
];

$togridlib3_unit_table = regular_unit_table;

atom_pitch = togridlib3_decode([1, "atom"]);
block_size_ca = [
	[block_size_bsu[0], block_size_unit],
	[block_size_bsu[1], block_size_unit],
	[block_height, "mm"]
];
block_size = togridlib3_decode_vector(block_size_ca);
block_size_studs = [for(d=block_size_ca) round(togridlib3_decode(d, unit=[1, "stud"]))];
lego_outer_size = [
	block_size[0] - (lego_stud_pitch - lego_outer_width),
	block_size[1] - (lego_stud_pitch - lego_outer_width),
];
lego_inner_size = [
	block_size[0] - (lego_stud_pitch - lego_inner_width),
	block_size[1] - (lego_stud_pitch - lego_inner_width),
];
lego_outer_corner_radius = lego_inner_corner_radius + (block_size[0] - lego_inner_size[0])/2;

module toglego_xy_hull() {
	linear_extrude(block_size[2]*4, center=true) {
		// Assumes LEGO top and bottom, for now
		if( bottom_style == "lego" || bottom_style == "lego-v1.1" ) {
			tog_shapelib_rounded_square(lego_outer_size, lego_outer_corner_radius);
		} else {
			tog_shapelib_rounded_beveled_square(block_size, 3.175, 3.175);
		}
	}
}

module toglego_bottom() {
	if( bottom_style == "flat" ) {
		translate([0,0,500]) cube([1000,1000,1000], center=true);
	} else if( bottom_style == "tgx9-atomic" ) {
		echo(block_size=block_size);
		
		tgx9_block_foot(
			[for(d=block_size_ca) [round(togridlib3_decode(d, unit=[1, "atom"])), "atom"]],
			foot_segmentation = "chatom",
			v6hc_style = "v6.0",
			corner_radius = 6.35,
			offset = $tgx9_mating_offset,
			$togridlib3_unit_table = atom_chunk_unit_table
		);
	} else if( bottom_style == "lego" || bottom_style == "lego-v1.1" ) {
		top_thickness = 1;
		reinforcement_thickness = 0.8;

		reinforcement_skip = bottom_style == "lego" ? 1 : 2;
		
		difference() {
			translate([0,0,500]) cube([1000,1000,1000], center=true);
			
			linear_extrude((block_size[2]-top_thickness)*2, center=true) difference() {
				tog_shapelib_rounded_square(lego_inner_size, lego_inner_corner_radius);
				
				difference() {
					union() {
						// Y-axis reinforcements
						for( xn=[-block_size_studs[0]/2+reinforcement_skip : reinforcement_skip : block_size_studs[0]/2-1] ) {
							translate([xn * lego_stud_pitch, 0]) square([
								reinforcement_thickness,
								lego_inner_size[0] + 0.2
							], center=true);
						}
						// X-axix reinforcements
						for( yn=[-block_size_studs[1]/2+reinforcement_skip : reinforcement_skip : block_size_studs[1]/2-1] ) {
							translate([0, yn * lego_stud_pitch]) square([
								lego_inner_size[0] + 0.2,
								reinforcement_thickness
							], center=true);
						}
						// Circle exteriors
						for( xn=[-block_size_studs[0]/2+1 : 1 : block_size_studs[0]/2-1] )
						for( yn=[-block_size_studs[1]/2+1 : 1 : block_size_studs[1]/2-1] )
						{
							translate([xn * lego_stud_pitch, yn * lego_stud_pitch]) circle(d=lego_circle_od);
						}
					}
						
					// Circle interiors
					for( xn=[-block_size_studs[0]/2+1 : 1 : block_size_studs[0]/2-1] )
					for( yn=[-block_size_studs[1]/2+1 : 1 : block_size_studs[1]/2-1] )
					{
						translate([xn * lego_stud_pitch, yn * lego_stud_pitch]) circle(d=lego_circle_id);
					}
				}
			}
		}
	}
}

module toglego_top() {
	if( top_style == "lego" ) {
		cube([block_size[0]*2, block_size[1]*2, block_size[2]*2], center=true);
		
		translate([0,0,block_height-0.1]) linear_extrude(lego_stud_height + 0.1) {
			for( yc=[-block_size_studs[1]/2+0.5 : 1 : block_size_studs[1]/2] )
			for( xc=[-block_size_studs[0]/2+0.5 : 1 : block_size_studs[0]/2] )
				translate([xc,yc]*lego_stud_pitch) circle(d=lego_stud_diameter);
		}
	} else if( top_style == "tgx9-atomic" || top_style == "tgx9-chunk" ) difference() {
		cube([block_size[0]*2, block_size[1]*2, (block_size[2]+tg_lip_height)*2], center=true);

		top_unit = top_style == "tgx9-atomic" ? "atom" : "chunk";
		foot_segmentation = top_unit == "atom" ? "chatom" : "chunk";
		
		foot_block_size = [
			for(i=[0,1]) [round(togridlib3_decode(block_size_ca[i], unit=[1, top_unit])), top_unit],
			[1, "chunk"]
		];
		foot_v6hcs_block_size = [
			for(i=[0,1]) [round(togridlib3_decode(block_size_ca[i], unit=[1, "atom"]))+2, "atom"],
			[1, "chunk"]
		];
		
		echo(foot_block_size=foot_block_size);
		
		translate([0,0,block_size[2]]) {
			$togridlib3_unit_table = top_style == "tgx9-atomic" ? atom_chunk_unit_table : regular_unit_table;
			
			tgx9_block_foot(
				foot_block_size,
				foot_segmentation = foot_segmentation,
				$tgx9_chatomic_foot_column_style = "v6.1",
				//v6hc_style = "v6.1",
				corner_radius = 3.175,//6.35,
				$tgx9_force_bevel_rounded_corners = false,
				offset = -$tgx9_mating_offset
			);

			tgx9_do_sshape(["tgx1001_v6hc_block_subtractor", foot_v6hcs_block_size]);
		}
	}
}

module toglego_block() {
	intersection() {
		toglego_bottom();
		toglego_xy_hull();
		toglego_top();
	}
}

toglego_block();
