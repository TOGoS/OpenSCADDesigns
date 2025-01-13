// [Oumax]Hanger0.1
// 
// v0.1:
// - Based on testing with BottomSizeTester0.1 and SideSizeTester0.1,
//   4.75" x 1.5" with 0.5mm margins is just barely big enough.
//   So let's use 1.0mm margins for the 'full holder' prototype.

outer_margin = 0.1;
inner_margin = 1.0;
$fn = 48;

module oumaxholder0__end_params() { }

use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>
use <../../lib/TOGHoleLib2.scad>

togmod1_domodule(
let( inch = 25.4 )
let( back_hole = ["rotate", [90,0,0], ["render", tog_holelib2_hole("THL-1001", depth=1*inch, overhead_bore_height=2*inch)]] )
["difference",
	togmod1_linear_extrude_z([-2.5*inch + outer_margin, 2.5*inch - outer_margin], togmod1_make_rounded_rect([5*inch - outer_margin*2, 1.75*inch - outer_margin*2], r=3.175)),
	
	// Main cavity
	["translate", [0,0,2.5*inch], togmod1_linear_extrude_y([-3/4*inch - inner_margin, 3/4*inch + inner_margin], togmod1_make_rounded_rect([4.75*inch + inner_margin*2, 9.75*inch - inner_margin*2], r=12.7))],
	
	// Bottom hole
	togmod1_linear_extrude_z([-5*inch, 0], togmod1_make_rounded_rect([3.75*inch, (1+7/16)*inch], r=3.175)),
	
	// Side holes
	let( w = (1+7/16)*inch, h = 4.5*inch )
	let( r = min(w,h)*0.49 )
	togmod1_linear_extrude_x([-5*inch, 5*inch], togmod1_make_rounded_rect([w, h], r=r)),

	// Mounting holes
	for( xm=[-3.5 : 1 : 3.5] ) for( zm=[-3.5 : 1 : 4.5] )
	["translate", [xm*12.7, 3/4*inch + inner_margin, zm*12.7], back_hole],
]);
