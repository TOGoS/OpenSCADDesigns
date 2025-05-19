// LEDPanelTemplate1.1
// 
// Template for marking hole and 'keepout zone' on 12"x6" LED panels a la WSITEM-101331
// 
// v1.1:
// - Add little diamond-shaped notches along the edges, for slicing purposes,
//   but also in case they are useful for alignment on some grid

size_chunks = [8,4];
chunk = 38.1;

module __ledpaneltemplate1__end_params() { }

inch = 25.4;
thickness = inch / 16;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

size = size_chunks * chunk;

togmod1_domodule(togmod1_linear_extrude_z([0, thickness],
	let( hole = togmod1_make_circle(d=5/16*inch) )
	let( diamond = togmod1_make_circle(d=1/4*inch, $fn=4) )
	["difference",
		togmod1_make_rounded_rect(size, r=chunk/2),
		
		let(x0=-size[0]/2 + chunk/2, x1=-size[0]/2 + chunk, x2=size[0]/2-chunk, x3=size[0]/2-chunk/2)
		let(y0=-size[1]/2 + chunk/2, y1=-size[1]/2 + chunk, y2=size[1]/2-chunk, y3=size[1]/2-chunk/2)
		let(cops=[["round", chunk/6.1]])
		let(vops=[["round", chunk/3.1]])
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
		
		for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*(size[0]/2-chunk/2), ym*(size[1]/2-chunk/2)], hole],
		for( xm=[-1,1] ) for( ym=[-size_chunks[1]/2+1 : 1 : size_chunks[1]/2-1] ) ["translate", [xm*size[0]/2, ym*chunk], diamond],
		for( ym=[-1,1] ) for( xm=[-size_chunks[0]/2+1 : 1 : size_chunks[0]/2-1] ) ["translate", [xm*chunk, ym*size[1]/2], diamond],
	]
));
