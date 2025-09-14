// Bookmark0.2
// 
// v0.2:
// - Add options for slot_width, length, outer_offset, and corner_radius
// - Fix to actually mind width option

thickness = "0.4mm";
width = "1.5inch";
length = "6inch";
corner_radius = "1/2inch";
slot_width = "4mm";

slot_inset_x = "1/4inch";
slot_inset_y = "1/2inch";

$fn = 48;
// Extend the outer edges outward by this much
outer_offset = "-0.1mm";

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

outer_offset_mm  = togunits1_decode(outer_offset);
thickness_mm     = togunits1_decode(thickness);
width_mm         = togunits1_decode(width);
length_mm        = togunits1_decode(length);
corner_radius_mm = togunits1_decode(corner_radius);
slot_width_mm    = togunits1_decode(slot_width);
slot_inset_x_mm  = togunits1_decode(slot_inset_x);
slot_inset_y_mm  = togunits1_decode(slot_inset_y);

togmod1_domodule(togmod1_linear_extrude_z([0, thickness_mm], ["difference",
	togmod1_make_rounded_rect([width_mm + outer_offset_mm*2, length_mm + outer_offset_mm*2], r=corner_radius_mm + outer_offset_mm),
	
	togpath1_rath_to_polygon(togpath1_polyline_to_rath(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [-width_mm/2+slot_inset_x_mm,  length_mm/2-slot_inset_y_mm]],
		["togpath1-rathnode", [-width_mm/2+slot_inset_x_mm, -length_mm/2+slot_inset_y_mm], ["round", 6.35]],
		["togpath1-rathnode", [ width_mm/2-slot_inset_x_mm, -length_mm/2+slot_inset_y_mm], ["round", 6.35]],
		["togpath1-rathnode", [ width_mm/2-slot_inset_x_mm,  length_mm/2-slot_inset_y_mm]],
	]), r=slot_width_mm/2)),
]));
