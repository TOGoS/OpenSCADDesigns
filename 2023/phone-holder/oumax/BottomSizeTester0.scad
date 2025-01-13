// OumaxBottomSizeTester0.1

use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>

outer_margin = 0.1;
inner_margin = 0.5;
$fn = 48;

module oumaxholder0__end_params() { }

inch = 25.4;

base_size_tester = togmod1_linear_extrude_z([0, 3.175], ["difference",
	togmod1_make_rounded_rect([5*inch - outer_margin*2, 5*inch - outer_margin*2], r=3.175),
	
	togmod1_make_rounded_rect([4.75*inch + inner_margin*2, 4.75*inch + inner_margin*2], r=12.7),
	for( ym=[-1,1] ) for( xm=[-1,1] ) ["translate", [xm * (2.5-3/16)*inch, ym * (2.5-3/16)*inch], togmod1_make_circle(d=4)],
]);

togmod1_domodule(base_size_tester);
