// DesiccantHolderLid1.0
//
// Flat lid for DesiccantHolders, to be held on with a ring

thickness = "1/16inch";
diameter  = "1+3/4inch";
grating_diameter  = "1+1/2inch";
cutaway = false;
$fn = 144;
$tgx11_offset = -0.1;

module desiccantholder0__end_params() { }

$togunits1_default_unit = "mm";

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGrat1.scad>
use <../lib/TOGUnits1.scad>

inch = 25.4;
u = 254/160;

thickness_mm         = togunits1_to_mm(thickness);
diameter_mm          = togunits1_to_mm(diameter);
grating_diameter_mm  = togunits1_to_mm(grating_diameter);

the_body = ["difference",
	let(bev = min(1, thickness_mm/4))
	tphl1_make_z_cylinder(zds=[for(zo=[
		[0               ,-bev],
		[bev             , 0  ],
		[thickness_mm-bev, 0  ],
		[thickness_mm    ,-bev],
	]) [zo[0], diameter_mm + ($tgx11_offset + zo[1])*2]]),
	
	if( grating_diameter_mm > 0 ) ["difference",
		tphl1_make_z_cylinder(zrange=[-1, thickness_mm+1], d=grating_diameter_mm),
		
		tograt1_grating_to_togmod(
			[grating_diameter_mm+1, grating_diameter_mm+1],
			tograt1_make_multi_grating([
				tograt1_make_grating([0.8,0.8], pitch=4, angle= 30, z=0.4),
				tograt1_make_grating([0.8,0.4], pitch=4, angle= 90, z=1.0),
				tograt1_make_grating([0.8,0.4], pitch=4, angle=150, z=1.4),
				tograt1_make_grating([0.8,0.4], pitch=2, angle=  0, z=1.8),
			])
		)
	],
];

togmod1_domodule(["intersection",
	the_body,
	if(cutaway) ["translate", [0,100,0], togmod1_make_cuboid([200,200,200])],
]);
