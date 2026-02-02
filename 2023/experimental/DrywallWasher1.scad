// DrywallWasher1.2
// 
// Combined DrywallWasher0[.1] + port
// 
// v1.1:
// - Based on DrywallWasher0.1
// v1.2
// - Add holes for spanner wrench

description = "combined drywall washer/port with 1\" inner threads, corner cutout version";
outer_threads = "1+1/4-7-UNC";
outer_thread_radius_offset = "-0.2mm";
inner_threads = "1-8-UNC";
inner_thread_radius_offset = "0.3mm";
tunnel_front_diameter = "1+1/2inch";
tunnel_diameter = "7/8inch";

spanner_hole_count = 0;
spanner_hole_diameter = "4mm";
spanner_hole_pattern_diameter = "1+3/8inch";

/* [Detail] */

$fn = 144;

/* [Debugging] */

cutout = "none"; // ["none","corner"]

module __drywallwasher0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

outer_thread_radius_offset_mm    = togunits1_to_mm(outer_thread_radius_offset   );
inner_thread_radius_offset_mm    = togunits1_to_mm(inner_thread_radius_offset   );
spanner_hole_diameter_mm         = togunits1_to_mm(spanner_hole_diameter        );
spanner_hole_pattern_diameter_mm = togunits1_to_mm(spanner_hole_pattern_diameter);

togmod1_domodule(
	let( inch = 25.4 )
	let( washer_height_mm = togunits1_to_mm("7/16inch") )
	let( total_height_mm  = togunits1_to_mm("1inch") )
	let( inner_diameter_mm = togunits1_to_mm("1inch") )
	let( washer_outer_diameter_mm = togunits1_to_mm("1+1/2inch") )
	let( front_height_mm = (1/8)*inch )
	let( tunnel_front_slope = 1 )
	let( front_outer_slope = 1 )
	let( tunnel_front_diameter_mm  = togunits1_to_mm(tunnel_front_diameter) )
	let( tunnel_diameter_mm = togunits1_to_mm(tunnel_diameter) )
	let( front_outer_diameter_mm  = washer_outer_diameter_mm + front_height_mm*2/front_outer_slope )
	let( tunnel_front_bevel_height_mm = (tunnel_front_diameter_mm-tunnel_diameter_mm)/2/tunnel_front_slope )
	let( spanner_hole =
		spanner_hole_diameter_mm <= 0 ? ["union"] :
		let( bev = min(1, spanner_hole_diameter_mm/4) )
		tphl1_make_z_cylinder(zds=[
			[                                                    - 1  , spanner_hole_diameter_mm + bev*2 + 2], // Give it a slight bevel
			[                                              + bev      , spanner_hole_diameter_mm            ],
			[washer_height_mm                                    + 0.1, spanner_hole_diameter_mm            ],
			[washer_height_mm + spanner_hole_diameter_mm/2       + 0.1,                                    0],
		])
	)
	let( thing = ["difference",
		["render", ["union",
			tphl1_make_z_cylinder(zds=[
				[washer_height_mm, washer_outer_diameter_mm - 2],
				[ front_height_mm, washer_outer_diameter_mm],
				[           0 , front_outer_diameter_mm],
			], cap_bottom=true, cap_top=true),
			
			togthreads2_make_threads(
				togthreads2_simple_zparams([[max(0,washer_height_mm-10),0], [total_height_mm,-1]], taper_length=1, extend=1, inset=1.5),
				outer_threads,
				r_offset = outer_thread_radius_offset_mm
			)
		]],
		
		["union",
			togthreads2_make_threads(
				togthreads2_simple_zparams([[0,0], [total_height_mm,-1]], taper_length=1, extend=1, inset=1.5),
			   inner_threads,
				r_offset = inner_thread_radius_offset_mm
			),
			tphl1_make_z_cylinder(zds=[
				for( p=togpath1_rath_to_polypoints(["togpath1-rath",
					["togpath1-rathnode", [tunnel_front_diameter_mm/2 + 1,  -1                         ]],
					["togpath1-rathnode", [      tunnel_diameter_mm/2    , tunnel_front_bevel_height_mm], ["round", tunnel_front_bevel_height_mm*2]],
					["togpath1-rathnode", [      tunnel_diameter_mm/2    , total_height_mm + 1]],
				])) [p[1], p[0]*2]
			])
		],
		
		if( spanner_hole != ["union"] )
		for( i=[0:1:spanner_hole_count-1] )
		["rotate", [0,0,360*i/spanner_hole_count], ["translate", [spanner_hole_pattern_diameter_mm/2,0,0], spanner_hole]],
	])
	let( sliceout =
		cutout == "none" ? ["union"] :
		cutout == "corner" ? ["translate", [50,50,0], togmod1_make_cuboid([100,100,400])] :
		assert(false, str("Unrecognized cutout mode: '", cutout, "'"))
	)
	["difference", thing, sliceout]
);
