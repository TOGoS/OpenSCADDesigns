// FlatheadRouterTemplateAdapter1.0
// 
// 

bushing_hole_diameter = 12.5;
bolt_head_diameter = "1/2inch";
bolt_head_height = "3/16inch";
bolt_diameter  = "1/4inch";

$fn = 72;

module __amlksdjkansd__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

bushing_hole_diameter_mm = togunits1_to_mm(bushing_hole_diameter);
bolt_head_diameter_mm    = togunits1_to_mm(bolt_head_diameter);
bolt_head_height_mm      = togunits1_to_mm(bolt_head_height);
bolt_diameter_mm         = togunits1_to_mm(bolt_diameter);

u = togunits1_to_mm("1u");

togmod1_domodule(
	["difference",
		tphl1_make_z_cylinder(zds=[
			[  0, bushing_hole_diameter_mm    ],
			[  u, bushing_hole_diameter_mm    ],
			[2*u, bushing_hole_diameter_mm+2*u]
		]),

		tphl1_make_z_cylinder(zds=[
			[2*u-bolt_head_height_mm-10, bolt_diameter_mm     ],
			[2*u-bolt_head_height_mm   , bolt_diameter_mm     ],
			[2*u                       , bolt_head_diameter_mm],
			[2*u+10                    , bolt_head_diameter_mm],
		]),
	]
);
