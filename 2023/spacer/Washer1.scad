// Washer1.0
//
// A very simple washer.

thickness      =  1.00; // 0.01
outer_diameter = 19.05; // 0.01
inner_diameter =  8.00; // 0.01
$fn = 96;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

togmod1_domodule(togmod1_linear_extrude_z([-thickness/2,thickness/2], ["difference",
	togmod1_make_circle(d=outer_diameter),
	togmod1_make_circle(d=inner_diameter),
]));
