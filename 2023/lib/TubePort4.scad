// TubePort[Lib]4.4
// 
// Functions for making 'standard' ports for tubing
// 
// v4.1:
// - Replace qtube_diameter and donut_bevel_mm with outer_diameter
// v4.2:
// - Name the r_offset argument to togthreads2_make_threads
// v4.3:
// - Add tubeport4_make_hbarb
// v4.4:
// - `tubeport4_make_hbarb` accepts `z0` parameter (default = 0)

use <../lib/TOGThreads2.scad>
use <../lib/TOGPolyhedronLib1.scad>

/**
 * Make the threaded/beveled part of a WSTYPE-4149 'qport',
 * i.e. a female compression-fitting port for 1/4" irrigation tubing,
 * in which a male plug threads in to squish a rubber gasket
 * against three surfaces to make a pretty good seal.
 * Add your own 1/4" hole at the bottom for the tube itself.
 */
function tubeport4_make_qport(
	depth  = 12.7,
	thread_style = "3/4-10-UNC",
	thread_r_offset = 0.2,
	outer_diameter = 19.05 // TODO: Derive from thread_style
) =
["union",
	["intersection",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-depth - outer_diameter/2, 0], [0, 1]], taper_length=2, inset=1),
			thread_style,
			r_offset = thread_r_offset
		),
		
		tphl1_make_z_cylinder(zds=[
			[-depth - outer_diameter/2, 0             ],
			[-depth                   , outer_diameter],
			[1                        , outer_diameter],
		]),
	]
];

// Barb for so-called 1/2" tubing with optional threads
// for a squish-down cap
function tubeport4_make_hbarb(
	hbarb_thread_length = 0,
	hbarb_thread_r_offset = -0.1,
	z0 = 0,
) =
	["union",
		if( hbarb_thread_length > 0 ) togthreads2_make_threads(
			togthreads2_simple_zparams([[z0, 0], [hbarb_thread_length, -1]], 3, inset=1),
			"7/8-10-UNC",
			r_offset = hbarb_thread_r_offset
		),
		let(z3 = hbarb_thread_length)
		let(z4 = z3 + 254/16 )
		tphl1_make_z_cylinder(zds=[
			[z3     , 12],
			[z3 + 10, 12],
			[z3 + 11, 9*254/160],
			[z4     , 11],
			[z4     ,  9],
			[z4 - 2 ,  5],
		])
	];
