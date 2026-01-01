// TwoPartPortLid1.1
// 
// Slots parallel to the edge of the circle
// so you can stack two and rotate them to get the
// width you want.

outer_diameter    = "1+3/32inch";
thickness         = "1/16inch";
slot_width        = "1/4inch";
slot_distance     = "1/4inch";
$fn = 48;

use <../lib/TOGUnits1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

thickness_mm = togunits1_to_mm(thickness);
outer_diameter_mm  = togunits1_to_mm(outer_diameter);
slot_width_mm      = togunits1_to_mm(slot_width);
slot_distance_mm   = togunits1_to_mm(slot_distance);

togmod1_domodule(
	let( r0 = slot_distance_mm - slot_width_mm/2 )
	let( r1 = slot_distance_mm + slot_width_mm/2 )
	let( r3 = outer_diameter_mm/2 )
	let( r4 = r3 + 100 )
	let( x0 = -slot_width_mm*129/256 )
	let( cr =  slot_width_mm*127/256 )
	togmod1_linear_extrude_z([-thickness_mm/2, thickness_mm/2], ["difference",
		togmod1_make_circle(d=outer_diameter_mm),
		
		togpath1_rath_to_polygon(["togpath1-rath",
			["togpath1-rathnode", [ r0, x0], ["round", cr]],
			["togpath1-rathnode", [ r1, x0], ["round", cr]],
			["togpath1-rathnode", [ r1, r1], ["round", r1]],
			["togpath1-rathnode", [-r1, r1], ["round", r1]],
			["togpath1-rathnode", [-r1, x0], ["round", cr]],
			["togpath1-rathnode", [-r0, x0], ["round", cr]],
			["togpath1-rathnode", [-r0, r0], ["round", r0]],
			["togpath1-rathnode", [ r0, r0], ["round", r0]],
		]),
		// Ugh, I should learn to make nice curves.
		["translate", [0,(r1+r3)/2], togmod1_make_rect([slot_width_mm, (r3-r1)*2])],
	])
);
