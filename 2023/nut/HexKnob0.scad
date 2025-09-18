// HexKnob0.1
// 
// Knob to fit around a hex nut (or maybe a stack of them)

knob_ff_diameter = "1inch";
knob_side_count = 6; // [3:1:20]
nut_ff_diameter = "7/16inch";
nut_side_count = 6; // [3:1:20]
hole_diameter = "9/32inch";
nut_margin = "0.1mm";
thickness = "1/2inch";

$fn = 24;

module __hexknob0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

knob_ff_diameter_mm = togunits1_to_mm(knob_ff_diameter);
nut_ff_diameter_mm  = togunits1_to_mm( nut_ff_diameter);
hole_diameter_mm    = togunits1_to_mm(hole_diameter   );
thickness_mm        = togunits1_to_mm(thickness       );
nut_margin_mm       = togunits1_to_mm(nut_margin      );

outer_rath = togpath1_make_polygon_rath(
	knob_ff_diameter_mm/2 / cos(360/knob_side_count/2),
	[["round", knob_ff_diameter_mm*sin(360/knob_side_count/2/3), 8]],
	$fn=knob_side_count
);
nut_rath = togpath1_make_polygon_rath(
	(nut_ff_diameter_mm/2 + nut_margin_mm) / cos(360/nut_side_count/2),
	$fn=nut_side_count
);

obev = 2;
ibev = 1;
nut_z0 = min(4, thickness_mm/2);

togmod1_domodule(["difference",
	tphl1_make_polyhedron_from_layer_function([
		[           0     , -obev],
		[           0+obev,  0   ],
		[thickness_mm-obev,  0   ],
		[thickness_mm     , -obev],
	], function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(togpath1_offset_rath(outer_rath, zo[1])),
		zo[0]
	)),
	
	tphl1_make_z_cylinder(zrange=[-1, thickness_mm+1], d=hole_diameter_mm),
	tphl1_make_polyhedron_from_layer_function([
		[nut_z0           ,  0    ],
		[thickness_mm-ibev,  0    ],
		[thickness_mm+ibev, ibev*2],
	], function(zo) togvec0_offset_points(
		togpath1_rath_to_polypoints(togpath1_offset_rath(nut_rath, zo[1])),
		zo[0]
	)),
]);
