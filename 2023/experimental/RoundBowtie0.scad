// RoundBowtie0.3
// 
// A curvier 'bowtie' piece.
// 
// diamond_r is the distance from the center of the bowtie
// to the center of one of the 'circles'.
// 
// v0.2:
// - Factor out roundbowtie0_make_bowtie_2d
// v0.3:
// - Add base_size option; if nonzero,
//   will union the bowtie with a rectangular base

thickness = 6.35;
diamond_r = 6.35;
offset = -0.1; // 0.01
center_hole_d = 4.5;
base_size = [25.4, 12.7, 0]; // 0.01
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>



function roundbowtie0_make_bowtie_rath__take1(diamond_r, offset) =
let(off2 = offset/sqrt(2))
// As of TOGPath1.100, both round-then-offset and offset-then-round
// approaches are problematic.  Offset-then-round would work
// if all offsets applied before rounding, which would be 'correct',
// but not what it currently does.  So apply offsets manually:
let(corner_ops = [["round", diamond_r/sqrt(2) + offset]])
["togpath1-rath",
	for(v = [
		[ 0     , 0-off2],
		[ 1     ,-1-off2],
		[ 2+off2, 0     ],
		[ 1     , 1+off2],
		[ 0     , 0+off2],
		[-1     , 1+off2],
		[-2-off2, 0     ],
		[-1     ,-1-off2],
	])	["togpath1-rathnode", v * diamond_r, each corner_ops]
];

function roundbowtie0_make_bowtie_rath(diamond_r, offset) =
// Take 2:
// 0.7 is intentionally chosen as it is slightly less than sqrt(2),
// which avoids funkiness at 'seams' between roundings when offset is negative.
// togpath1_rath_to_polypoints could theoretically handle this better,
// but as of v1.100 it doesn't, hence workarounds like this:
//let(actual_rounding_r = diamond_r*0.7)
// 
// Take 3:
// A more 'scalable' adjustment: adding offset/diamond_r seems to do the job:
let(actual_rounding_r = diamond_r*0.707 + min(0,offset/diamond_r))
let(corner_ops = [["round", actual_rounding_r], ["offset", offset]])
["togpath1-rath",
	for(v = [
		[ 0, 0],
		[ 1,-1],
		[ 2, 0],
		[ 1, 1],
		[ 0, 0],
		[-1, 1],
		[-2, 0],
		[-1,-1],
	])	["togpath1-rathnode", v * diamond_r, each corner_ops]
];

function roundbowtie0_make_bowtie_2d(diamond_r, offset=0, center_hole_d=0) =
   let( hole = togmod1_make_circle(d=center_hole_d) )
	["difference",
		togmod1_make_polygon(togpath1_rath_to_polypoints(
			roundbowtie0_make_bowtie_rath(diamond_r, offset)
		)),
		
		for( xm=[-1,1] ) ["translate", [xm*diamond_r,0,0], hole],
	];

togmod1_domodule(
   let( hole = togmod1_linear_extrude_z([-1, thickness+1], togmod1_make_circle(d=center_hole_d)) )
	["difference",
		["union",
			togmod1_linear_extrude_z([0, thickness], roundbowtie0_make_bowtie_2d(diamond_r, offset=offset)),
			if(base_size[2] > 0) ["difference",
				togmod1_linear_extrude_z([0, base_size[2]], togmod1_make_rounded_rect([base_size[0], base_size[1]], r=3.175)),
				togmod1_linear_extrude_z([base_size[2]/2, base_size[2]+1], ["union",
					togmod1_make_rect([min(6.35, base_size[0]/2), base_size[1]*2]),
					togmod1_make_rect([base_size[0]*2, min(6.35, base_size[1]/2)]),
				])
			],
		],
		for( xm=[-1,1] ) ["translate", [xm*diamond_r,0,0], hole],
	]
);
