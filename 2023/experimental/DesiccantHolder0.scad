// DesiccantHolder0.3
// 
// Hmm, maybe the threads should be on the outside of the container
// 
// v0.2:
// - Threads on outside of container
// - Dimensions configurable
// v0.3:
// - Default thread length = 1/2inch
// v0.4:
// - Configurable outer_thread_radius_offset

height   = "2+1/4inch";
thread_spec = "2-4+1/2-UNC";
diameter = "2+1/8inch";
wall_thickness = "1/16inch";
neck_hole_diameter = "1+1/2inch";
thread_length = "1/2inch";
cutaway = false;
outer_thread_radius_offset = -0.1;
$fn = 48;
$tgx11_offset = -0.1;

module desiccantholder0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

inch = 25.4;
u = 254/160;

height_mm          = togunits1_to_mm(height);
diameter_mm        = togunits1_to_mm(diameter);
wall_thickness_mm  = togunits1_to_mm(wall_thickness);
neck_diameter_mm   = togunits1_to_mm(neck_hole_diameter);
cavity_diameter_mm = diameter_mm - wall_thickness_mm*2;
neck_taper_z01     = max(0, (cavity_diameter_mm - neck_diameter_mm));
thread_z0 = height_mm - togunits1_to_mm(thread_length);

the_body = ["difference",
	["union",
		tphl1_make_z_cylinder(zds=[
			[0        , diameter_mm - 2*u + $tgx11_offset*2],
			[1*u      , diameter_mm - 2*u + $tgx11_offset*2],
			[2*u      , diameter_mm       + $tgx11_offset*2],
			[thread_z0, diameter_mm       + $tgx11_offset*2],
		]),
		togthreads2_make_threads(
   	   togthreads2_simple_zparams([[thread_z0 - 5, 0], [height_mm, 0]], 3, 1),
			thread_spec,
			end_mode = "blunt",
			r_offset = outer_thread_radius_offset
		),
	],
	
	tphl1_make_z_cylinder(zds=[
		[1  *u, cavity_diameter_mm-3*u],
		[2.5*u, cavity_diameter_mm    ],
		for( i=[0 : min(1/4,4/$fn) : 1] )
		[
			thread_z0 - neck_taper_z01 + i*neck_taper_z01,
			(cavity_diameter_mm + neck_diameter_mm)/2 + cos(180*i)*(cavity_diameter_mm - neck_diameter_mm)/2
		],
		[height_mm + 1             , neck_diameter_mm],
   ]),
];

togmod1_domodule(["intersection",
	the_body,
   if(cutaway) ["translate", [0,100,0], togmod1_make_cuboid([200,200,200])],
]);
