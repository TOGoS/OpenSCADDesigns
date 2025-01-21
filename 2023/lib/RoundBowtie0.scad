// RoundBowtie0.6
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
// v0.4:
// - Split library from demo
// v0.6:
// - Allow arbitrary lobe_count

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

function roundbowtie0_make_bowtie_rath(diamond_r, lobe_count=2, offset) =
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
		for( xm=[-lobe_count+1 :  2 :  lobe_count-1] ) each [[xm-1, 0], [xm, -1]],
		for( xm=[ lobe_count-1 : -2 : -lobe_count+1] ) each [[xm+1, 0], [xm, +1]],
	])	["togpath1-rathnode", v * diamond_r, each corner_ops]
];

function roundbowtie0_make_bowtie_2d(diamond_r, lobe_count=2, offset=0, center_hole_d=0) =
   let( hole = togmod1_make_circle(d=center_hole_d) )
	["difference",
		togmod1_make_polygon(togpath1_rath_to_polypoints(
			roundbowtie0_make_bowtie_rath(diamond_r, lobe_count=lobe_count, offset=offset)
		)),
		
		for( xm=[-1,1] ) ["translate", [xm*diamond_r,0,0], hole],
	];
