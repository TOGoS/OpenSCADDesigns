use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 24;

function make_case_fan( size ) =
	let( mounting_hole = togmod1_make_circle(r=2.5) )
	["linear-extrude-zs",
		[-size[2]/2, size[2]/2],
		["difference",
			togmod1_make_rounded_rect(size, r=7.5),
			togmod1_make_circle(r = min(size[0],size[1])/2 - 2, $fn=max($fn,48)),
			for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*(size[0]/2 - 7.5), ym*(size[1]/2-7.5), 0], mounting_hole],
		]
	];

togmod1_domodule(make_case_fan([120,120,25]));
