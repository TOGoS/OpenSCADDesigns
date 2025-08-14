// DesiccantHolder1.1
//
// Stackable desiccant holder, using same
// threads as DesiccantHolder[Cap]0
// 
// v1.1:
// - Based on DesiccantHolderCap0.4

total_height  = "2inch";
thread_spec   = "2-4+1/2-UNC";
thread_length = "1/2inch";
beam_thickness = "0.6mm";
diameter = "2+1/8inch";
neck_hole_diameter = "1+1/2inch";
central_cavity_diameter = "2inch";
cutaway = false;
inner_thread_radius_offset =  0.2;
outer_thread_radius_offset = -0.2;
floor_style = "empty"; // ["empty","solid","grating"]
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

total_height_mm    = togunits1_to_mm(total_height);
thread_length_mm   = togunits1_to_mm(thread_length);
diameter_mm        = togunits1_to_mm(diameter);
neck_diameter_mm   = togunits1_to_mm(neck_hole_diameter);
central_cavity_diameter_mm = togunits1_to_mm(central_cavity_diameter);
outer_thread_z0 = 0;
outer_thread_z1 = thread_length_mm;
beam_thickness_mm  = togunits1_to_mm(beam_thickness);

thread_type23 = togthreads2__get_thread_type23(thread_spec);
thread_min_radius = thread_type23[3];
outer_thread_zext = diameter_mm/2 - thread_min_radius;

outer_thread_z1_adjusted = outer_thread_z1 + outer_thread_zext;
inner_thread_z0 = total_height_mm - thread_length_mm;
inner_thread_z1 = total_height_mm;

thread_inner_diameter_mm = 40; // uhh

the_floor =
	floor_style == "empty" ? ["union"] :
	floor_style == "grating" ? tograt1_grating_to_togmod(
	   [neck_diameter_mm+1, neck_diameter_mm+1],
			let(bt = beam_thickness_mm) tograt1_make_multi_grating([
		   	tograt1_make_grating([1  ,bt], pitch=4, angle= 30, z=0.4),
		   	tograt1_make_grating([1  ,bt], pitch=4, angle= 90, z=1.0),
		   	tograt1_make_grating([1  ,bt], pitch=4, angle=150, z=1.4),
		   	tograt1_make_grating([0.8,bt], pitch=2, angle=  0, z=1.8),
			])
		) :
	floor_style == "solid" ? togmod1_make_cuboid([100,100,5]) :
	assert(false, str("Unrecognized floor_style: '", floor_style, "'"));

the_body = ["difference",
	["union",
		togthreads2_make_threads(
	  	   togthreads2_simple_zparams([[outer_thread_z0, 0], [outer_thread_z1_adjusted, 1]], 3, 1),
			thread_spec,
			r_offset = outer_thread_radius_offset
		),

		tphl1_make_z_cylinder(zds=[
			[outer_thread_z1         , (thread_min_radius + outer_thread_radius_offset)*2 - 0.1],
			[outer_thread_z1_adjusted, diameter_mm + $tgx11_offset*2],
			[total_height_mm         , diameter_mm + $tgx11_offset*2],
		]),
	],

	["difference",
		["union",	
			togthreads2_make_threads(
  			   togthreads2_simple_zparams([[inner_thread_z0, 0], [total_height_mm, 1]], 3, 1),
				thread_spec,
				r_offset = inner_thread_radius_offset
			),
			
			//tphl1_make_z_cylinder(zrange=[-1, inner_thread_z0+1], d=neck_diameter_mm),
			
			let(ddiff = central_cavity_diameter_mm-neck_diameter_mm)
			// Good enough for prototype?
			tphl1_make_z_cylinder(zds=[
			   [-1                 , neck_diameter_mm],
				[outer_thread_z1   , neck_diameter_mm],
				[outer_thread_z1 + ddiff/2, central_cavity_diameter_mm],
				[inner_thread_z0 - 5 - ddiff/2, central_cavity_diameter_mm],
				[inner_thread_z0 - 5, neck_diameter_mm],
				[total_height_mm + 1, neck_diameter_mm],
			]),
		],
		
		the_floor
	],
];

togmod1_domodule(["intersection",
	the_body,
   if(cutaway) ["translate", [0,100,0], togmod1_make_cuboid([200,200,200])],
]);
