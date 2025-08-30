// TagPanel1.4
// 
// A blank TOGRack or TOGRack2 panel.
// Can generate small, thin panels usable as 'tags', e.g. for keychains.
//
// v1.1:
// - Rack along X asis
// - 1-atom high panels work and can be used as spacers
// v1.2:
// - Move most panel-generation logic into TOGRackPanel1 library
// v1.3:
// - Replace panel_thickness with panel_thickness_u
// - Add back_fat_u and outer_offset_u (which defaults to -1 for TOGRack2-compatibility)
// v1.4:
// - Add support for center_hole_slot_width, which if >= 0, will add a wider
//   version of the regular hole in the center of the front and back edges

size_atoms = [3,6];
panel_thickness_u = 1; // 0.05
hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
center_hole_style = "none";
center_hole_slot_width = 0;
outer_offset_u = -1;
outer_offset = -0.1;
back_fat_u = 0; // 0.05

$fn = 24;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGRackPanel1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

panel_thickness_mm = u_to_mm(panel_thickness_u);

nominal_size = [
	atoms_to_mm(size_atoms[0]),
	atoms_to_mm(size_atoms[1]),
	panel_thickness_mm,
];

slot = center_hole_slot_width < 0 ? ["union"] :
	tog_holelib2_slot(center_hole_style, [-1, panel_thickness_mm, panel_thickness_mm + 10], [[-center_hole_slot_width/2, 0], [center_hole_slot_width/2, 0]]);

togmod1_domodule(["difference",
	tograckpanel1_panel(
		nominal_size,
		outer_offset = u_to_mm(outer_offset_u)+outer_offset,
		mounting_hole_style = hole_style,
		back_fat = u_to_mm(back_fat_u)
	),
	
	if( center_hole_slot_width > 0 ) for( ym=[-size_atoms[1]/2 + 0.5, size_atoms[1]/2 - 0.5] ) ["translate", [0, atoms_to_mm(ym), 0], slot]
]);
