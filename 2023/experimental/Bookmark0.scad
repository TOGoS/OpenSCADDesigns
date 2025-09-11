thickness = "0.4mm";
width = "1.5inch";

slot_inset_x = "1/4inch";
slot_inset_y = "1/2inch";

$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

thickness_mm = togunits1_decode(thickness);
width_mm = togunits1_decode(width);
slot_inset_x_mm = togunits1_decode(slot_inset_x);
slot_inset_y_mm = togunits1_decode(slot_inset_y);

inch = togunits1_decode("1inch");

length_mm = 6*inch;

togmod1_domodule(togmod1_linear_extrude_z([0, thickness_mm], ["difference",
	togmod1_make_rounded_rect([1.5*inch, length_mm], r=12.7),
	
	togpath1_rath_to_polygon(togpath1_polyline_to_rath(togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [-width_mm/2+slot_inset_x_mm,  length_mm/2-slot_inset_y_mm]],
		["togpath1-rathnode", [-width_mm/2+slot_inset_x_mm, -length_mm/2+slot_inset_y_mm], ["round", 6.35]],
		["togpath1-rathnode", [ width_mm/2-slot_inset_x_mm, -length_mm/2+slot_inset_y_mm], ["round", 6.35]],
		["togpath1-rathnode", [ width_mm/2-slot_inset_x_mm,  length_mm/2-slot_inset_y_mm]],
	]), r=2)),
]));
