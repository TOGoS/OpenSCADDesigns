// PepsiPanelNetSpacer1.0
// 
// Spacer to take up about the same width as the netting on the Pepsi panels,
// at the very edge of the panel where the netting does not cover.

thickness = 1.6;
width = 23.0; // A little under an inch
slot_width = 8.5; // A little over 5/16"
$fn = 32;

module __pepsipanelnetspacer1__end_params() { }

inch = 25.4;
length = 5*inch;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

togmod1_domodule(
	let( hull_cx = (width-1.5*inch)/2 )
	let( slot_cx = 3/4*inch )
	let( edge_x  = 3/4*inch - (1.5*inch-width) )
	let( slot_length = 1.5*inch )
	let( slot = togmod1_make_rounded_rect([slot_length + slot_width, slot_width], r=slot_width/2*0.99) )
	let( boat = ["rotate", [0,0,45], togmod1_make_rect([slot_width,slot_width])] )
	togmod1_linear_extrude_z(
		[0, thickness],
		["difference",
			["translate", [hull_cx, 0, 0], togmod1_make_rounded_rect([width, 5*inch], r=5)],
			
			for( y=[-length/2+3/4*inch, -length/2+(2+3/4)*inch, length/2-3/4*inch] ) ["union",
				["translate", [slot_cx, y], slot],
			   ["translate", [edge_x, y], boat],
			]
			// togmod1_make_circle(d=slot_width),
		]
	)
);
