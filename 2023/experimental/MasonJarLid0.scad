// MasonJarLid0.1
// 
// Just a simple, thin (or thick, if you want) lid.  No built-in ring.

outer_diameter = "68mm";
outer_thickness = "2mm";
outer_rim_height = "0.5mm";
outer_rim_thickness = "0.5mm";
inner_plateau_diameter = "56mm";
inner_plateau_height   = "4mm";

center_hole_spec = "straight-32mm";
center_hole_r_offset = "0.2mm";

$fn = 96;

module __masonjarlid0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

outer_diameter_mm = togunits1_to_mm(outer_diameter);
outer_thickness_mm = togunits1_to_mm(outer_thickness);
outer_rim_height_mm = togunits1_to_mm(outer_rim_height);
outer_rim_thickness_mm = togunits1_to_mm(outer_rim_thickness);
inner_plateau_diameter_mm = togunits1_to_mm(inner_plateau_diameter);
inner_plateau_height_mm = togunits1_to_mm(inner_plateau_height);
center_hole_r_offset_mm = togunits1_to_mm(center_hole_r_offset);

togmod1_domodule(["difference",
	let(bbev = max(0.1, min(outer_thickness_mm+outer_rim_height_mm-1, 1))) // Bottom bevel
	tphl1_make_z_cylinder(zds=[
		[0, outer_diameter_mm-bbev*2],
		[bbev, outer_diameter_mm],
		[outer_thickness_mm + outer_rim_height_mm, outer_diameter_mm],
		[outer_thickness_mm + outer_rim_height_mm, outer_diameter_mm - outer_rim_thickness_mm],
		[outer_thickness_mm                      , outer_diameter_mm - outer_rim_thickness_mm*3],
		[outer_thickness_mm                      , inner_plateau_diameter_mm               ],
		[outer_thickness_mm + inner_plateau_height_mm, inner_plateau_diameter_mm - inner_plateau_height_mm*2],
   ]),
	
	togthreads2_make_threads(
		togthreads2_simple_zparams([[-1, 1], [outer_thickness_mm + inner_plateau_height_mm+1, 1]], taper_length=1, extend=1),
		center_hole_spec, r_offset=center_hole_r_offset_mm
	),
]);
