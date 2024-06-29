// Hemisphere1.2
// 
// Hemisphere for setting a camera on or something
//
// Changes:
// v1.1:
// - For infill efficiency, only have some holes
// v1.2:
// - No v6hcs

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

randish_values = [871,238,957,613,450,912,637,845,673,289,012,934,876,128,345,199,348,591,723,40];

function randish1(a) =
	let( a_int = floor(a) )
	let( a_mod = a_int % len(randish_values) )
	let( a_fixed = a_mod < 0 ? len(randish_values) + a_mod : a_mod )
	randish_values[a_fixed] + a - a_mod;

function randish2(a,b) = randish1(randish1(a)*b+b);

thing1 = ["difference",
	hemi,
	
	["translate", [0,0,20], tog_holelib2_hole("THL-1006", depth=d/2, overhead_bore_height=d/2, inset=1)],
	
	for( xm=[round(-d/12.7)+0.5 : 1 : ceil(d/12.7)] )
	for( ym=[round(-d/12.7)+0.5 : 1 : ceil(d/12.7)] )
	let( x=xm*12.7 ) let( y=ym*12.7 )
	let( xy_dist = sqrt(x*x+y*y) )
	if( abs(randish2(xm,ym)) % 4 < 1 )
	if( xy_dist < d/2-4 && xy_dist > 12.7 )
	["translate", [x,y,12.7], small_hole],
];

use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

thing2 = ["intersection",
	thing1,
	tgx11_block_bottom(
		[[d, "mm"], [d, "mm"], [d/2, "mm"]], $tgx11_gender="m",
		v6hc_style = "none",
		segmentation = "chunk"
	),
];

togmod1_domodule(thing2);
