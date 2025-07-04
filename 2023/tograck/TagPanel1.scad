// TagPanel1.2
// 
// A flat TOGRack2 / WSTYPE-4140 panel that can also be used
// as like a tag for a keychain or something.
//
// v1.1:
// - Rack along X asis
// - 1-atom high panels work and can be used as spacers
// v1.2:
// - Move most panel-generation logic into TOGRackPanel1 library

size_atoms = [3,6];
panel_thickness = 1.5875; // 0.0001
hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
outer_offset = -0.1;

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGRackPanel1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

nominal_size = [
	atoms_to_mm(size_atoms[0]),
	atoms_to_mm(size_atoms[1]),
	panel_thickness
];

togmod1_domodule(tograckpanel1_panel(
	nominal_size,
	outer_offset = -u_to_mm(1)+outer_offset,
	mounting_hole_style = hole_style
));
