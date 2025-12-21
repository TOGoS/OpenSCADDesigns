// WeMosPanel2.0
//
// v2.0
// - Based on CompHolePanel2.3

/* [Metadata] */

description = "";

/* [Panel Hull] */

size = ["3atom","9atom"];
panel_basic_offset = "-1u";
panel_thickness = "2u";

/* [Panel Mounting Holes] */

mounting_hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
mounting_hole_frequency = 1; // [1,2]

/* [Component Holes] */

// Module 'long way' will be: 0 = along the rack, 90 = across the rack
pincav_angle   = 90;
pincav_length  = "8/10inch";
pincav_depth   = "6u";

/* [Detail] */
outer_offset = "-0.1mm";
$fn = 24;

module __wemospanel2__end_params() { }

use <../lib/TGPSCC0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGRackPanel1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

$togunits1_default_unit = "mm";

basic_offset_mm    = togunits1_to_mm(panel_basic_offset);
panel_thickness_mm = togunits1_to_mm(panel_thickness);
pincav_depth_mm    = togunits1_to_mm(pincav_depth);

total_thickness_mm = max(panel_thickness_mm, pincav_depth_mm + 1);

back_fat_mm = total_thickness_mm - panel_thickness_mm;
bottom_z = -back_fat_mm;
top_z    =  panel_thickness_mm;

nominal_size = [
	togunits1_to_mm(size[0]),
	togunits1_to_mm(size[1]),
	top_z,
];

togmod1_domodule(
	let( cav = tgpscc0_make_wemos_cutout(deck_z=0) )
	tograckpanel1_panel(
		nominal_size,
		outer_offset = togunits1_to_mm(panel_basic_offset)+togunits1_to_mm(outer_offset),
		back_fat = back_fat_mm,
		mounting_hole_style = mounting_hole_style,
		mounting_hole_frequency = mounting_hole_frequency,
		3d_mod = function(panel) ["difference",
			panel,
			
			["translate", [0,0,bottom_z], ["rotate", [180,0,pincav_angle], cav]],
		]
	)
);
