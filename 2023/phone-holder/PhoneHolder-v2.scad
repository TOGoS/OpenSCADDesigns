// PhoneHolder-v2.0
// 
// Minimal outer box, designed to hold 

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

module __asd123sudifn_end_params() { }

inch = 25.4;
size = [4.5*inch, 1.5*inch, 6*inch];
cavity_size = [4*inch, 1.25*inch, 6*inch];
panel_thickness = (size[1] - cavity_size[1])/2;
side_thickness  = (size[0] - cavity_size[0])/2;
bottom_thickness = 0.25*inch;
corner_rad = 1.6;
front_slot_width = 0.5*inch;

$fn = $preview ? 8 : 24;

bottom_hole_size = [3.75*inch, 1*inch];

render() togmod1_domodule(["difference",
	["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid(size, corner_rad)],
	
	["translate", [0,0,size[2]/2+bottom_thickness], togmod1_make_cuboid(cavity_size)],
	//["translate", [0,panel_thickness,size[2]], togmod1_make_cuboid(size)],
	["translate", [0,panel_thickness+size[1],size[2]], togmod1_linear_extrude_x([-size[0], size[0]], togmod1_make_rounded_rect([size[1]*3, size[2]], r=6.35))],
	["translate", [0,size[1]/2,bottom_thickness], togmod1_make_cuboid([front_slot_width, size[1], size[2]*2])],
	togmod1_linear_extrude_z([-1, bottom_thickness+1], togmod1_make_rounded_rect(bottom_hole_size, r=0.125*inch)),

	for( xm=[-1 : 1 : 1] ) for( ym=[0.5 : 1 : 4] ) ["translate", [xm*1.5*inch, -size[1]/2 + panel_thickness, ym*1.5*inch],
		["rotate", [-90,0,0], tog_holelib2_hole("THL-1002", overhead_bore_height=size[1])]
	]
]);
