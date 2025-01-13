// OumaxSideSizeTester0.1

use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>

outer_margin = 0.1;
inner_margin = 0.5;
$fn = 48;

module oumaxholder0__end_params() { }

inch = 25.4;

side_size_tester = togmod1_linear_extrude_z([0, 3.175], ["difference",
	togmod1_make_rounded_rect([5*inch - outer_margin*2, (1+3/4)*inch - outer_margin*2], r=3.175),
	
	togmod1_make_rounded_rect([4.75*inch + inner_margin*2, 1.5*inch + inner_margin*2], r=0),
]);

togmod1_domodule(side_size_tester);
