// TwoPartPortLid0.1
// 
// Idea: Something that fits onto the end of a hollow screw (e.g. p1689)
// to hold a smaller cord or port of some sort (e.g. a GX12 port),
// in two parts, so that it can be removed.
// This two-part 'lid' would be attached with a separate 'ring',
// similar to a mason jar lid.

outer_diameter    = "1+3/32inch";
hole_diameter     = "1/2inch";
total_thickness   = "1/12inch";
slot_bevel        =  0.5; // 0.01
slot_bevel_offset = "-0.12mm"; 
$fn = 48;

use <../lib/TOGUnits1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

total_thickness_mm = togunits1_to_mm(total_thickness);
half_thickness_mm  = total_thickness_mm/2;
outer_diameter_mm  = togunits1_to_mm(outer_diameter);
hole_diameter_mm   = togunits1_to_mm(hole_diameter);
slot_bevel_offset_mm = togunits1_to_mm(slot_bevel_offset);



togmod1_domodule(["intersection",
	togmod1_linear_extrude_z([-half_thickness_mm-100, half_thickness_mm+100], togmod1_make_circle(d=outer_diameter_mm)),
	
	["difference",
		["union",
			togmod1_linear_extrude_z([-half_thickness_mm, 0], togmod1_make_rect([outer_diameter_mm*2, outer_diameter_mm*2])),
			togmod1_linear_extrude_x([0, outer_diameter_mm+1], togmod1_make_polygon([
				[ hole_diameter_mm/2 - half_thickness_mm*slot_bevel + slot_bevel_offset_mm, -half_thickness_mm],
				[ hole_diameter_mm/2 + half_thickness_mm*slot_bevel + slot_bevel_offset_mm, +half_thickness_mm],
				[-hole_diameter_mm/2 - half_thickness_mm*slot_bevel - slot_bevel_offset_mm, +half_thickness_mm],
				[-hole_diameter_mm/2 + half_thickness_mm*slot_bevel - slot_bevel_offset_mm, -half_thickness_mm],
			])),
		],
		
		tphl1_make_polyhedron_from_layer_function([
			[-half_thickness_mm - 1, hole_diameter_mm/2 + (half_thickness_mm+1)*slot_bevel + slot_bevel_offset_mm],
			[                 0    , hole_diameter_mm/2                                    + slot_bevel_offset_mm],
			[ half_thickness_mm + 1, hole_diameter_mm/2 + (half_thickness_mm+1)*slot_bevel + slot_bevel_offset_mm],
		], function(zr) togvec0_offset_points(
			togpath1_qath_to_polypoints(["togpath1-qath",
				["togpath1-qathseg", [    0,0], -90,  90, zr[1]],
				["togpath1-qathseg", [-1000,0],  90, -90, zr[1]],
			]),
			zr[0]
		)),
	],
]);
