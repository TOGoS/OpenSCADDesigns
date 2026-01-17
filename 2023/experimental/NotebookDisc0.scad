// NotebookDisc0.3
// 
// Can I print half-discs for discbound notebooks
// that are later glued together into full discs?
// 
// v0.2:
// - Add `cap_x_scale` option
// v0.3:
// - Add notch on right side, controlled by `cap_notch_x_scale` and `cap_notch_z_scale`

cap_diameter = "5mm";
cap_x_scale = 1.00; // 0.01
cap_notch_x_scale = 1.00; // 0.01
cap_notch_z_scale = 1.00; // 0.01
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
	let( cap_center_x = disc_diameter_mm/2 - cap_diameter_mm/2 * cap_x_scale )
	let( cap_inner_edge_x = disc_diameter_mm/2 - cap_diameter_mm * cap_x_scale )
	tphl1_make_polyhedron_from_layer_function(
		let( quarterfn = max(1,ceil($fn/4)) )
		[
			[0                  , center_hole_diameter_mm/2],
			for(i=[0:1:quarterfn]) let(a=i*90/quarterfn) [0 + sin(a) * cap_diameter_mm / 2, disc_diameter_mm/2 + (cos(a) - 1) * cap_diameter_mm/2 * cap_x_scale],
			[stem_thickness_mm/2, cap_center_x ],
			[stem_thickness_mm/2, center_hole_diameter_mm/2],
			[0                  , center_hole_diameter_mm/2],
		],
		function(zr) togpath1_rath_to_polypoints(togpath1_make_circle_rath(r=zr[1])),
		layer_points_transform = function(key, points) let(lz = key[0]) [for(p=points)
			let( in_notch_zone = p[1] == 0 && p[0] > 0 && (p[0] > cap_center_x || lz > stem_thickness_mm/2) )
			// let( in_notch_zone = p[0] > center_hole_diameter_mm*129/256 && p[1] == 0 )
			in_notch_zone ? [cap_center_x + (p[0]-cap_center_x) * cap_notch_x_scale, p[1], lz*cap_notch_z_scale] :
			[p[0], p[1], lz]
		],
		cap_bottom = false,
		cap_top = false
	)
);
