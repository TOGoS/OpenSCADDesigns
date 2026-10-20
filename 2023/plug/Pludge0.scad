// Pludge0.1
// 
// Idea: 'universal' generator for adapters between various
// housing shapes (TOGrack panel, 1+1/4" plug, ...)
// and component cutouts (3-way switches, buttons, etc).
// 
// But for v0.1...

housing_shape = "1+1/4-7-UNC"; // ;flange-thickness=1mm;thread-length=1inch";
housed_shape = "771W-X2/01";
$fn = 144;

module __pludge0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

total_height_mm = 25.4;

housing =
	let( head_height_mm = 3.175 )
	let( head_diameter_mm = 38.1 )
	let( neck_height_mm = 0 )
	let( neck_diameter_mm = 30 )
	["union",
		tphl1_make_z_cylinder(zrange=[0,head_height_mm], d=head_diameter_mm),
		["difference",
			["union",
				if( neck_height_mm > 0 && neck_diameter_mm > 0 )
				tphl1_make_z_cylinder(zrange=[head_height_mm,head_height_mm+neck_height_mm], d=neck_diameter_mm),
				
				togthreads2_make_threads(
					togthreads2_simple_zparams([[head_height_mm+neck_height_mm-1/128, 0], [total_height_mm, -1]], 1.6, 3.175, inset=2),
					"1+1/4-7-UNC",
					r_offset = -0.2,
					thread_origin_z = head_height_mm
				),
			],
			// The 771W-X2/01 cutout's corners would cut into the threads,
			// so we may as well just cut out the sides:
			togmod1_linear_extrude_z([head_height_mm, total_height_mm+1], togmod1_make_rect([100, 12.25+1/128])),
		]
	];

cutout =
	let( panel_thickness_mm = 1 )
	["union",
		togmod1_linear_extrude_z([panel_thickness_mm, total_height_mm+1], togmod1_make_rounded_rect([28, 12.25], r=2)),
		togmod1_linear_extrude_z([-1, panel_thickness_mm+1], ["union",
			togmod1_make_rect([19.5, 12.25]),
			togmod1_make_rect([24.5,  7.5 ]),
		]),
	];

togmod1_domodule(["difference",
	housing,
	
	cutout
]);
