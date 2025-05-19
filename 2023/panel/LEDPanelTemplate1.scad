// LEDPanelTemplate1.0
// 
// Template for marking hole and 'keepout zone' on 12"x6" LED panels a la WSITEM-101331

inch = 25.4;
thickness = inch / 16;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

togmod1_domodule(togmod1_linear_extrude_z([0, thickness],
	let( hole = togmod1_make_circle(d=5/16*inch) )
	["difference",
		togmod1_make_rounded_rect([12*inch, 6*inch], r=inch*3/4),
		
		let(x0=-6*inch + 3/4*inch, x1=-6*inch + 1.5*inch, x2=6*inch-1.5*inch, x3=6*inch-3/4*inch)
		let(y0=-3*inch + 3/4*inch, y1=-3*inch + 1.5*inch, y2=3*inch-1.5*inch, y3=3*inch-3/4*inch)
		let(cops=[["round", inch/4.1]])
		let(vops=[["round", inch/2.1]])
		togpath1_rath_to_polygon(["togpath1-rath",
			["togpath1-rathnode", [x2,y0], each cops],
			["togpath1-rathnode", [x2,y1], each vops],
			["togpath1-rathnode", [x3,y1], each cops],
			["togpath1-rathnode", [x3,y2], each cops],
			["togpath1-rathnode", [x2,y2], each vops],
			["togpath1-rathnode", [x2,y3], each cops],
			["togpath1-rathnode", [x1,y3], each cops],
			["togpath1-rathnode", [x1,y2], each vops],
			["togpath1-rathnode", [x0,y2], each cops],
			["togpath1-rathnode", [x0,y1], each cops],
			["togpath1-rathnode", [x1,y1], each vops],
			["togpath1-rathnode", [x1,y0], each cops],
	   ]),
		
		for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*(6-3/4)*inch, ym*(3-3/4)*inch], hole],
	]
));
