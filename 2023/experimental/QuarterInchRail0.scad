// QuarterInchRail0.1
// 
// Can I print a 1/4" rail that fits #6 screws without getting mucked up?
// Maybe if I print the threads?  Sideways?  Z-scaled a bit?

atom = 254/20;
thickness = 254/40;
height = atom;
$fn = 24;

module __quarterinchrail0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGThreads2.scad>
use <../lib/Prototype.ttf>

text_size = 4;
text_font = "Prototype";
text_thickening = 0.10; // 0.1

y0 = -   height/2;
y1 =     height/2;
z0 = -thickness/2;
z1 =  thickness/2;

hoes = [for(i=[0:1:3]) [(i-1.5)*atom, 1+(i+1)/100]];

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([z0, z1], togmod1_make_rounded_rect([4*atom,height], r=[3,3,0])),
   
	for( hoe=hoes ) ["translate", [hoe[0],0,0], ["rotate", [90,0,0], ["scale", [1, hoe[1], 1],
		togthreads2_make_threads(
			togthreads2_simple_zparams([[y0,1],[y1,1]], taper_length=3),
			"#6-32-UNC",
			r_offset = 0.2
		)
	]]],
	
	togmod1_linear_extrude_z( [z1-0.6, z1+0.6], ["union",
		for( hoe=hoes ) ["translate", [hoe[0], 0], ["rotate",[0,0,90],
			["offset-ds", text_thickening, togmod1_text(str(hoe[1]), text_size, text_font, halign="center", valign="center")]
		]]
   ]),
]);
