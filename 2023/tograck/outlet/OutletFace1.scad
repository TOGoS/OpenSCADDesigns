// OutletFace1.0
// 
// Outlet dimensions from:
// https://www.doorware.com/specials/images/DEL-SWP4771.gif
// https://sc02.alicdn.com/kf/HTB11kntehjaK1RjSZFAq6zdLFXap/225750389/HTB11kntehjaK1RjSZFAq6zdLFXap.jpg

size_atoms = [4,9];
panel_thickness = 1.5875; // 0.0001
hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
outer_offset = -0.1;
inner_offset = -0.1;

$fn = 24;

use <../../lib/TOGHoleLib2.scad>
use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>
use <../../lib/TOGPath1.scad>
use <../../lib/TOGPolyhedronLib1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

outlet_cut_2d = ["intersection",
	togmod1_make_rect([100, u_to_mm(18)-inner_offset*2]),
	togmod1_make_circle(d=u_to_mm(22)-inner_offset*2, $fn=$fn*2),
];

sx = atoms_to_mm(size_atoms[0]);
sy = atoms_to_mm(size_atoms[1]);
corner_ops = [["bevel", u_to_mm(2)], ["round", u_to_mm(2)], ["offset", -u_to_mm(1)+outer_offset]];
panel_rath = ["togpath1-rath",
	["togpath1-rathnode", [-sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2, sy/2], each corner_ops],
	["togpath1-rathnode", [-sx/2, sy/2], each corner_ops],
];

//panel_hole = tphl1_make_z_cylinder(d=25.4*5/32, zrange=[-1, panel_thickness+1]);
panel_hole = tog_holelib2_hole(hole_style);

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, panel_thickness], ["difference",
		togpath1_rath_to_polygon(panel_rath),
	   
		for(ym=[-1,+1]) ["translate", [0, ym*u_to_mm(12)], outlet_cut_2d],
	]),
	
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.5] )
	for( ym=size_atoms[1] == 1 ? [0] : [-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
	["translate", [atoms_to_mm(xm), atoms_to_mm(ym), panel_thickness], panel_hole],
	
	["translate", [0,0,panel_thickness], panel_hole],
]);
