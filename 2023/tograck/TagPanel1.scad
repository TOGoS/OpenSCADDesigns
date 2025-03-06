// TagPanel1.0
// 
// A flat TOGRack2 / WSTYPE-4140 panel that can also be used
// as like a tag for a keychain or something.

size_atoms = [6,3];
panel_thickness = 1.5875; // 0.0001
hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
outer_offset = -0.1;

$fn = 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

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
	tphl1_extrude_polypoints([0, panel_thickness], togpath1_rath_to_polypoints(panel_rath)),
	
	for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
	["translate", [atoms_to_mm(xm), atoms_to_mm(ym), panel_thickness], panel_hole]
]);
