// NotebookDisc0.1
// 
// Can I print half-discs for discbound notebooks
// that are later glued together into full discs?

cap_diameter = "5mm";
stem_thickness = "1mm";
disc_diameter = "3/4inch";
center_hole_diameter = "7mm";

$fn = 48;

module __asdaskjdnakjsnd__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

cap_diameter_mm         = togunits1_to_mm(cap_diameter         );
stem_thickness_mm       = togunits1_to_mm(stem_thickness       );
disc_diameter_mm        = togunits1_to_mm(disc_diameter        );
center_hole_diameter_mm = togunits1_to_mm(center_hole_diameter );

togmod1_domodule(
	tphl1_make_polyhedron_from_layer_function(
		let( quarterfn = max(1,ceil($fn/4)) )
		[
			[0                  , center_hole_diameter_mm/2],
			for(i=[0:1:quarterfn]) let(a=i*90/quarterfn) [0 + sin(a) * cap_diameter_mm / 2, disc_diameter_mm/2 + (cos(a) - 1) * cap_diameter_mm/2],
			[stem_thickness_mm/2, disc_diameter_mm/2 - cap_diameter_mm/2],
			[stem_thickness_mm/2, center_hole_diameter_mm/2],
			[0                  , center_hole_diameter_mm/2],
		],
		function(zr) togpath1_rath_to_polypoints(togpath1_make_circle_rath(r=zr[1])),
		layer_points_transform = "key0-to-z",
		cap_bottom = false,
		cap_top = false
	)
);
