// Hemisphere1.0
// 
// Hemisphere for setting a camera on or something

$tgx11_offset = -0.1;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

module __hemisphere1__end_params() { }

inch = 25.4;

sphere_fn = $preview ? 32 : 64;

$fn = 24;

d = 6*inch;

hemi = ["intersection",
	tphl1_make_rounded_cuboid([d, d, d], r=d/2-0.1, $fn=sphere_fn),
	["translate", [0,0,d], togmod1_make_cuboid([d*2, d*2, d*2])],
];

small_hole = tog_holelib2_hole("THL-1005", depth=d, overhead_bore_height=d, inset=0);

thing1 = ["difference",
	hemi,
	
	["translate", [0,0,20], tog_holelib2_hole("THL-1006", depth=d/2, overhead_bore_height=d/2, inset=1)],
	
	for( xm=[round(-d/12.7)+0.5 : 1 : ceil(d/12.7)] )
	for( ym=[round(-d/12.7)+0.5 : 1 : ceil(d/12.7)] )
	let( x=xm*12.7 ) let( y=ym*12.7 )
	let( xy_dist = sqrt(x*x+y*y) )
	if( xy_dist < d/2-4 && xy_dist > 12.7 )
	["translate", [x,y,12.7], small_hole],
];

use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

thing2 = ["intersection",
	thing1,
	tgx11_block_bottom(
		[[d, "mm"], [d, "mm"], [d/2, "mm"]], $tgx11_gender="m",
		segmentation = "chunk"
	),
];

togmod1_domodule(thing2);
