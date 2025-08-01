// DesiccantHolderCap0.2
//
// Cap for DesiccantHolder0

total_height  = "3/4inch";
thread_spec   = "2-4+1/2-UNC";
thread_length = "1/2inch";
diameter = "2+1/8inch";
neck_hole_diameter = "1+1/2inch";
cutaway = false;
$fn = 48;
$tgx11_offset = -0.1;

module desiccantholder0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGrat1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

inch = 25.4;
u = 254/160;

height_mm          = togunits1_to_mm(total_height);
diameter_mm        = togunits1_to_mm(diameter);
neck_diameter_mm   = togunits1_to_mm(neck_hole_diameter);
thread_z0 = height_mm - togunits1_to_mm(thread_length);

the_body = ["difference",
	["union",
		tphl1_make_z_cylinder(zds=[
			[0        , diameter_mm - 2*u + $tgx11_offset*2],
			[1*u      , diameter_mm - 2*u + $tgx11_offset*2],
			[2*u      , diameter_mm       + $tgx11_offset*2],
			[height_mm, diameter_mm       + $tgx11_offset*2],
		]),
	],
	
	togthreads2_make_threads(
  	   togthreads2_simple_zparams([[thread_z0, 0], [height_mm, 1]], 3, 1),
		thread_spec,
		r_offset = 0.2
	),
	
	["difference",
		tphl1_make_z_cylinder(zrange=[-1, thread_z0+1], d=neck_diameter_mm),
		
		tograt1_grating_to_togmod(
		   [neck_diameter_mm+1, neck_diameter_mm+1],
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
