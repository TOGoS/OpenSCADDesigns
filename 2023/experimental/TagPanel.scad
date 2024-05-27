// A flat 'tag' that happens to be compatible with TOGRack v2 or whatever

size_atoms = [6,3];
$tgx11_offset = -0.1;
$fn = 24;
panel_thickness = 1.5875; // 0.0001

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

u = 25.4/16;
atom_pitch = 12.7;

function atoms_to_mm(a) = a*atom_pitch;

sx = atoms_to_mm(size_atoms[0]);
sy = atoms_to_mm(size_atoms[1]);
corner_ops = [["bevel", 3.175], ["round", 3.175], ["offset", -u+$tgx11_offset]];
panel_rath = ["togpath1-rath",
	["togpath1-rathnode", [-sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2,-sy/2], each corner_ops],
	["togpath1-rathnode", [ sx/2, sy/2], each corner_ops],
	["togpath1-rathnode", [-sx/2, sy/2], each corner_ops],
];

//panel_hole = tphl1_make_z_cylinder(d=25.4*5/32, zrange=[-1, panel_thickness+1]);
panel_hole = tog_holelib2_hole("THL-1001");

togmod1_domodule(["difference",
	tphl1_extrude_polypoints([0, panel_thickness], togpath1_rath_to_polypoints(panel_rath)),
	
	for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
	["translate", [xm*atom_pitch, ym*atom_pitch, panel_thickness], panel_hole]
]);
