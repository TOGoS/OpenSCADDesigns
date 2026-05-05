// TubePort[Lib]4.0
// 
// Functions for making 'standard' ports for tubing

use <../lib/TOGThreads2.scad>
use <../lib/TOGPolyhedronLib1.scad>

function tubeport4_make_qport(
	depth  = 12.7,
	thread_style = "3/4-10-UNC",
	thread_r_offset = 0.2
) =
let( qtube_diameter = 6.35 + 0.5 )
let( donut_bevel_mm = 6.35 )
["union",
	["intersection",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-depth - donut_bevel_mm, 0], [0, 1]], taper_length=2, inset=1),
			thread_style,
			thread_r_offset
		),
		
		tphl1_make_z_cylinder(zds=[
			[-depth - donut_bevel_mm - qtube_diameter/2, 0                                ],
			[-depth                                    , qtube_diameter + donut_bevel_mm*2],
			[1                                         , qtube_diameter + donut_bevel_mm*2],
		]),
	]
];
