// MatchfitSlotShover0.1
// 
// A device that can be shoved along a Matchfit dovetail slot
// to make sure that it is large enough and/or knock out or
// squish down small bits that might be in the way.

outer_offset = "0mm";
total_length = "3inch";
taper_length = "1inch";
taper_inset = "2mm";
top_protrusion = "1/4inch";

module matchfitslotshover0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

total_length_mm = togunits1_to_mm(total_length);
taper_length_mm = togunits1_to_mm(taper_length);
taper_inset_mm  = togunits1_to_mm(taper_inset);
outer_offset_mm = togunits1_to_mm(outer_offset);
top_protrusion_32nds = togunits1_decode(top_protrusion, [1/32, "inch"]);

hole_spacing_mm = 12.7;


// [position (In 1/32"), offset vector]
basic_shape_data = [
	[[- 5,  top_protrusion_32nds], [-1  , 0  ]],
	[[- 5,  0                   ], [-1  , 1/4]],
	[[- 8, -12                  ], [-1.3,-1  ]], // close enough; don't feel like doing the trig right now
	[[  8, -12                  ], [ 1.3,-1  ]],
	[[  5,  0                   ], [ 1  , 1/4]],
	[[  5,  top_protrusion_32nds], [ 1  , 0  ]],
];

function offset_sd_point( sdat, offset ) =
	[sdat[0][0] + offset*sdat[1][0], sdat[0][1] + offset*sdat[1][1]];

z_offsets = [
	[                                0, outer_offset_mm                 ],
	[total_length_mm - taper_length_mm, outer_offset_mm                 ],
	[total_length_mm                  , outer_offset_mm - taper_inset_mm],
];

hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1005", inset=5, depth=100)]];

togmod1_domodule(["difference",
	tphl1_make_polyhedron_from_layer_function(z_offsets, function(zo)
		togvec0_offset_points(
			togpath1_rath_to_polypoints(["togpath1-rath",
				for( p=basic_shape_data ) ["togpath1-rathnode", offset_sd_point(p, zo[1]), ["round", 1, 8]]
			]),
			zo[0]
		)
	),
	
	for( zm=[0.5 : 1 : total_length_mm/hole_spacing_mm] )
	["translate", [0, -12, zm*hole_spacing_mm], hole],
]);
