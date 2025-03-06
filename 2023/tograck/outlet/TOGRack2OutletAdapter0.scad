// TOGRack2OutletAdapter0.1
// 
// Adapter for attaching standard outlets WSTYPE-4140-4.5 racks.
// 
// Outlet mounting holes are 3+1/4" apart.
// WSTYPE-4140-4.5 mounting holes are 4" apart.
// Therefore the distance between those two rows
// is (4" - 3+1/4")/2 = 3/4"/2 = 3/8".
// 
// 2+7/8" was a reasonable cavity size (used by p1404).
// (3+1/4 - 2+7/8)/2 = (1+2/8 - 7/8)/8 = (10-7)/8/2 = 3/16".
// So half the distance again.  Should work.

width_atoms = 3;
panel_thickness = 1.5875; // 0.0001
draft           = 6.3500; // 0.0001
hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
outer_offset = -0.1;

module __asdasd__end_params() { }

$fn = 24;

use <../../lib/TOGHoleLib2.scad>
use <../../lib/TOGMod1.scad>
use <../../lib/TOGMod1Constructors.scad>
use <../../lib/TOGPath1.scad>
use <../../lib/TOGPolyhedronLib1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

sx = atoms_to_mm(width_atoms);
y0 = u_to_mm(-4);
y1 = u_to_mm(6 + 4);
corner_ops = [["bevel", u_to_mm(2)], ["round", u_to_mm(2)], ["offset", -u_to_mm(1)+outer_offset]];
panel_rath = ["togpath1-rath",
	["togpath1-rathnode", [-sx/2,y0], each corner_ops],
	["togpath1-rathnode", [ sx/2,y0], each corner_ops],
	["togpath1-rathnode", [ sx/2,y1], each corner_ops],
	["togpath1-rathnode", [-sx/2,y1], each corner_ops],
];

//panel_hole = tphl1_make_z_cylinder(d=25.4*5/32, zrange=[-1, panel_thickness+1]);
panel_hole = tog_holelib2_hole(hole_style, depth=panel_thickness+1);
mort_hole  = tphl1_make_z_cylinder(zrange=[-draft-1, panel_thickness+1], d=5);

togmod1_domodule(["difference",
	tphl1_extrude_polypoints([-draft, panel_thickness], togpath1_rath_to_polypoints(panel_rath)),
	
	["translate", [0,u_to_mm(-1),-draft], togmod1_make_cuboid([atoms_to_mm(width_atoms)*2, 12.7, draft*2])],

	for( xm=[-width_atoms/2+0.5 : 1 : width_atoms/2-0.5] )
	["translate", [atoms_to_mm(xm), 0, panel_thickness], panel_hole],
	
	["translate", [0, u_to_mm(6), 0], mort_hole],
]);
