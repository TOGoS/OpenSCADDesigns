// DesiccantHolder0.1
// 
// Hmm, maybe the threads should be on the outside of the container
// 
// TODO: Try putting threads on outside of cap
// TODO: Cap

thread_spec = "2-4+1/2-UNC";
$fn = 48;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

inch = 25.4;

floor_thickness_mm = inch/8;
height_mm = inch*2.25;
diameter_mm = inch*(2+1/8);
wall_thickness_mm = inch/16;
neck_diameter_mm = inch*(2-1/8);

the_body = ["difference",
	togmod1_linear_extrude_z([0, height_mm], togmod1_make_circle(d=(2+1/8)*inch)),
	
	tphl1_make_z_cylinder(zds=[
		[floor_thickness_mm, diameter_mm - wall_thickness_mm*2],
		[height_mm - inch, diameter_mm - wall_thickness_mm*2],
		[height_mm + inch, diameter_mm - wall_thickness_mm*2 - inch],
   ]),
	
	togthreads2_make_threads(
	   togthreads2_simple_zparams([[height_mm - inch, 0], [height_mm, 1]], 3, 1),
		thread_spec,
		r_offset = 0.2
	)
];

togmod1_domodule(["intersection",
	the_body,
   ["translate", [0,50,0], togmod1_make_cuboid([100,100,100])],
]);
