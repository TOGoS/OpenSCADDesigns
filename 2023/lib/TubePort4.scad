// TubePort[Lib]4.1
// 
// Functions for making 'standard' ports for tubing
// 
// v4.1:
// - Replace qtube_diameter and donut_bevel_mm with outer_diameter

use <../lib/TOGThreads2.scad>
use <../lib/TOGPolyhedronLib1.scad>

/**
 * Make the threaded/beveled part of a 'qport',
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
			thread_r_offset
		),
		
		tphl1_make_z_cylinder(zds=[
			[-depth - outer_diameter/2, 0             ],
			[-depth                   , outer_diameter],
			[1                        , outer_diameter],
		]),
	]
];
