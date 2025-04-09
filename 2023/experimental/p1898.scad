// p1898
// 
// M2.5ish hole size tester to help me determine
// how big to make holes for M2.5 screws to thead into
// (without actually modeling the threads).

text_size = 5;
text_thickening = 0;
text_font = "Prototype";
label = "p1898";

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/Prototype.ttf>

// togmod1_domodule(togmod1_linear_extrude_z([0,2], ["difference", togmod1_make_circle(d=5.77, $fn=6), togmod1_make_circle(d=2.6, $fn=24)]));

paramses = [for(i=[0 : 1 : 7]) [(i-3.5)*5.5, 2.5 + i/10]];
thickness = 3.175;

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, thickness], ["difference",
		togmod1_make_rounded_rect([12.7 * 4, 12.7], r=3.185),
		
	   for(ps=paramses) ["translate", [ps[0], -2.5, 0], togmod1_make_circle(d=ps[1])]
	]),
	
	togmod1_linear_extrude_z([thickness-1, thickness+1], ["union",
		for(ps=[paramses[0],paramses[len(paramses)-1]])
		["translate", [ps[0], 2.5, thickness], ["offset-ds", text_thickening, togmod1_text(str(ps[1]), text_size, text_font, halign="center", valign="center")]],
		
		["translate", [0, 2.5, thickness], ["offset-ds", text_thickening, togmod1_text(label, text_size, text_font, halign="center", valign="center")]],
	]),
]);
