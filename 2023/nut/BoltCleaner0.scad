// BoltCleaner0.1
// 
// Maybe you can use this to scrape the crap out of your bolts' threads?

block_width = "3inch";
block_depth = "1+1/2inch";
block_height = "1/4inch";
thread_style = "7/8-10-UNC";
hole_position = "center-right"; // ["center", "center-right", "right"]
thread_radius_offset = "0.2mm";
hull_fn   = 24;
thread_fn = 144;

module __asdaslkdm__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

block_size = [block_width, block_depth, block_height];
block_size_mm = togunits1_vec_to_mms(block_size);
thread_radius_offset_mm = togunits1_to_mm(thread_radius_offset);

hole_diam_mm = togthreads2_get_hole_diameter(thread_style, r_offset = thread_radius_offset_mm);

togmod1_domodule(
	let( inch = 25.4 )
	let( threads = ["render",
		togthreads2_make_threads(
			// Zero taper length would cause overhangs on the bottom!
			// So let the threads go straight through the bottom:
			togthreads2_simple_zparams([[-block_size_mm[2]/2 - 2, 1], [block_size_mm[2]/2, 1]], extend=1, taper_length=1, inset=1),
			thread_style,
			r_offset = thread_radius_offset_mm,
			$fn = thread_fn
		),
	])
	["difference",
		let( qfn = max(2, hull_fn/2) )
		let( xy_r = min(6, block_size_mm[0]/2, block_size_mm[1]/2) * (qfn-1)/qfn )
		let( z_bev = min(2, block_size_mm[0]/4, block_size_mm[1]/4, block_size_mm[2]/4) )
		tphl1_make_rounded_cuboid(block_size_mm, r=[xy_r, xy_r, z_bev], corner_shape="cone2", $fn=hull_fn),
		
		let( right_x = block_size_mm[0]/2-block_size_mm[1]/2 )
		let( hole_pos_mm =
			hole_position == "center"       ? [0        , 0] :
			hole_position == "center-right" ? [right_x/2, 0] :
			hole_position == "right"        ? [right_x  , 0] :
			assert(false, str("Unrecognized hole_position: \"", hole_position, "\""))
		)
		["translate", hole_pos_mm, ["union",
			threads,
			
			// Cutty bit:
			togmod1_linear_extrude_z([-block_size_mm[2], block_size_mm[2]],
				["intersection",
					togmod1_make_rect([hole_diam_mm*2, 5]),
					togmod1_make_circle(d=hole_diam_mm+1/128, $fn=thread_fn),
				]
			),
		]],
		
		// Wrenchy bit
		["translate", [-block_size_mm[0]/2 + block_size_mm[1]/4, 0, 0],
			["intersection",
				togmod1_linear_extrude_z([-block_size_mm[2], block_size_mm[2]], ["union",
					//["translate", [-100,0], togmod1_make_rect([200, hole_diam_mm])],
					//togmod1_make_circle(d=hole_diam_mm, $fn=thread_fn),
					let( cornx = sqrt(2)*hole_diam_mm/2 )
					togpath1_rath_to_polygon(["togpath1-rath",
						["togpath1-rathnode", [cornx - 100, -100]],
						["togpath1-rathnode", [cornx      , 0], ["round", hole_diam_mm/2]],
						["togpath1-rathnode", [cornx - 100, +100]],
						["togpath1-rathnode", [cornx - 200, -200]],
					], $fn=thread_fn)
				]),
				
				let( wx1 = 7/32*inch + 0.2 )
				togmod1_linear_extrude_x([-100, 100], togmod1_make_polygon([
					[ wx1     , -10],
					[ wx1     ,  0 ],
					[ wx1 + 20,  10],
					[-wx1 - 20,  10],
					[-wx1     ,  0 ],
					[-wx1     , -10],
				])),
			],
		],
	]
);
