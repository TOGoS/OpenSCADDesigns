// QuarterInchPlug0.1
//
// - [X] Measure one of the nozzle plugs
//   - OD of post: 6.4mm at bottom end, 6.24mm band in middle, 6.4mm under cap
//   - Post length: 21.3mm
//   - Cap: 13.8mm OD, 3.1mm thick

part_type = "SinglePlug"; // ["SinglePlug","DoublePlug"]
post_diameter = "1/4inch";
post_mid_r_offset = "-0.1mm";
post_r_offset = "-0.1mm";
total_length = "1inch";

$fn = 72;

module __qarterinchplug0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPolyhedronLib1.scad>

post_diameter_mm = togunits1_to_mm(post_diameter);
post_mid_r_offset_mm = togunits1_to_mm(post_mid_r_offset);
post_r_offset_mm = togunits1_to_mm(post_r_offset);
total_length_mm  = togunits1_to_mm(total_length);

post =
	let( d0=post_diameter_mm + post_r_offset_mm*2, d1=d0 + post_mid_r_offset_mm*2, bev = abs(post_mid_r_offset_mm) )
	tphl1_make_z_cylinder(zds=[
		[ 1                  , d0+6    ],
		[ 1+3                , d0      ],
		[15-bev              , d0      ],
		[15                  , d1      ], // TODO: Base height on, uh, total_length_mm, though maybe matching the original is good idk
		[16                  , d1      ],
		[16+bev              , d0      ],
		[total_length_mm-1.5 , d0      ],
		[total_length_mm-0.75, d0-0.4  ],
		[total_length_mm     , d0-2    ],
	]);

function make_single_cap(d=12.7, h=3.1, bev=0.7) =
	tphl1_make_z_cylinder(zds=[
		[   0 , d-bev*2],
		[  bev, d      ],
		[h-bev, d      ],
		[h- 0 , d-bev*2],
	]);

// With flange to match that of the TubePort1 Cap
function make_double_cap(d=(25.4 * (1+3/32)), h=3.1, tbev=0.3) =
	let( bbev = h-tbev-1 )
	tphl1_make_z_cylinder(zds=[
		[0       , d-bbev*2],
		[h-tbev-1, d       ],
		[h-tbev  , d       ],
		[h       , d-tbev*2],
	]);

part =
	part_type == "SinglePlug" ? ["union", make_single_cap(), post] :
	part_type == "DoublePlug" ? ["union", make_double_cap(), ["translate", [-6.35,0,0], post], ["translate", [6.35,0,0], post]] :
	assert(false, str("Unrecognized part_type: '", part_type, "'"));

togmod1_domodule(part);
