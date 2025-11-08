// GasketizingWasher0.2
//
// Fill it with goop, clamp it down, make a gasket?
// 
// v0.2:
// - Allow for zero-thickness inner wall, outer wall, and/or gasket
//   (which turn it more and more into a simple flat washer)

inner_diameter = "32mm";
inner_wall_thickness = "1mm";
outer_diameter = "50.8mm";
washer_thickness = "3mm";
gasket_thickness = "2mm";
outer_wall_thickness = "2mm";
$fn = 72;

module __gasketizingwasher0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

inner_diameter_mm       = togunits1_decode(inner_diameter);
inner_wall_thickness_mm = togunits1_decode(inner_wall_thickness);
outer_diameter_mm       = togunits1_decode(outer_diameter);
washer_thickness_mm     = togunits1_decode(washer_thickness);
gasket_thickness_mm     = togunits1_decode(gasket_thickness);
outer_wall_thickness_mm = togunits1_decode(outer_wall_thickness);

togmod1_domodule(
	let( z0 = 0, z1 = gasket_thickness_mm, z2 = gasket_thickness_mm + washer_thickness_mm )
	let( the_hull = tphl1_make_z_cylinder(zds=[
		[z2, inner_diameter_mm                            ],
		each (inner_wall_thickness_mm > 0 && z1 > z0) ? [
			[z0 + inner_wall_thickness_mm/2, inner_diameter_mm],
			[z0, inner_diameter_mm + inner_wall_thickness_mm  ],
			[z0, inner_diameter_mm + inner_wall_thickness_mm*2],
			[z1, inner_diameter_mm + inner_wall_thickness_mm*2],
		] : [
			[z1, inner_diameter_mm                            ],
		],
		each (outer_wall_thickness_mm > 0 && z1 > z0) ? [
			[z1, outer_diameter_mm - gasket_thickness_mm*2    ],
			[z0, outer_diameter_mm                            ],
		] : [
			[z1, outer_diameter_mm                            ],
		],
		[z2, outer_diameter_mm                            ],
		[z2, inner_diameter_mm                            ],
	], cap_top=false, cap_bottom=false))
	["difference",
		the_hull,
		
		["difference",
			["union",
				for( a=[0:45:360-1] ) ["rotate", [0,0,a], togmod1_linear_extrude_x([-outer_diameter_mm, outer_diameter_mm], togmod1_make_polygon([[-z1*2,-z1-0.1],[z1*2,-z1-0.1],[0,z1-0.1]]))],
			],
			tphl1_make_z_cylinder(zrange=[-z1-2, z2+1], d = inner_diameter_mm+inner_wall_thickness_mm*2+1),
		]
	]
);
