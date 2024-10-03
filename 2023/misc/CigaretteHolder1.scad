// CigaretteHolder1.0
// 
// These Lucky Leaf ones are about 3+5/16" long and 5/16" in diameter

module __cigaretteholder1__end_params() { }

inch = 25.4;

cig_hole_dameter = 3/8*inch;
cig_hole_depth = (3+6/16)*inch;
height = (3+1/2)*inch;

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

cig_hole = ["union",
	togmod1_linear_extrude_z([-cig_hole_depth, 1], togmod1_make_circle(d=cig_hole_dameter)),
	togmod1_linear_extrude_z([-cig_hole_depth-10, 0], togmod1_make_circle(d=3)),
];

finger_notch = togmod1_linear_extrude_y([-1*inch, +1*inch], togmod1_make_rounded_rect([0.5*inch, 1*inch], r=0.25*inch));

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, height], togmod1_make_rounded_rect([1*inch, 0.5*inch], r=6.3)),
	["translate", [-0.25*inch, 0, height], cig_hole],
	["translate", [ 0.25*inch, 0, height], cig_hole],
	["translate", [         0, 0, height], finger_notch],
]);
