// CylHolder3.2
// 
// Iteration on an idea; 3 is an estimate.
// 
// Cylinder with threaded cap and cylindrical cavities
// for something-or-other inside.
// 
// v3.1:
// - Optional midriff, which appears when the threads
//   from the top and bottom do not reach in the middle
// v3.2:
// - Add cyl_outer_thread_radius_offset option
// 
// TODO, maybe: a separate (from the troff) counterbore for each hole,
// in case they held items need a little extra room.

// Your description here
description = "";

cyl_height = "3inch";
// cyl_diameter = "1.5inch";
cyl_outer_threads = "1+1/2-6-UNC";
// If less than half the cylinder height, midriff will be exposed
cyl_outer_thread_length = "3inch";
cyl_outer_thread_radius_offset = "-0.00mm";
cyl_midriff_diameter = "1+1/2inch";
cyl_midriff_side_count = 8;

hole_count = 3;
hole_pattern_r = "3/8inch";
hole_diameter = "1/2inch";

hole_troff_width = "9/16inch";
hole_troff_depth = "1/2inch";

preview_fn = 32;
render_fn = 144;

$fn = $preview ? preview_fn : render_fn;

module __cylholder3__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>

cyl_height_mm       = togunits1_to_mm(cyl_height       );
// cyl_diameter_mm     = togunits1_to_mm(cyl_diameter     );
hole_pattern_r_mm   = togunits1_to_mm(hole_pattern_r   );
hole_diameter_mm    = togunits1_to_mm(hole_diameter    );
hole_troff_width_mm = togunits1_to_mm(hole_troff_width );
hole_troff_depth_mm = togunits1_to_mm(hole_troff_depth );
cyl_outer_thread_length_mm = togunits1_to_mm(cyl_outer_thread_length);
cyl_outer_thread_radius_offset_mm = togunits1_to_mm(cyl_outer_thread_radius_offset);
cyl_midriff_diameter_mm    = togunits1_to_mm(cyl_midriff_diameter   );

function normalize_vec2d(v2d) =
	let( len = sqrt(v2d[0]*v2d[0] + v2d[1]*v2d[1]) )
	len == 0 ? v2d : [v2d[0]/len, v2d[1]/len];

togmod1_domodule(
	let( hole_posrots = [for(i=[0:1:hole_count-1]) let(ang=i*360/hole_count) [[cos(ang)*hole_pattern_r_mm, sin(ang)*hole_pattern_r_mm], [0,0,0]]] )
	let( hole = tphl1_make_z_cylinder(zrange=[-cyl_height_mm, cyl_height_mm], d=hole_diameter_mm) )
	let( midriff_exposed = cyl_outer_thread_length_mm < cyl_height_mm/2 )
	let( midriff = !midriff_exposed ? ["union"] :
		// Bottom and top of midriff's outer face
		let( mdbz0 = -cyl_height_mm/2 + cyl_outer_thread_length_mm )
		let( mdtz0 =  cyl_height_mm/2 - cyl_outer_thread_length_mm )
		// Extension, uhh, halfway along the threads?
		let( md_extension_dz  = cyl_outer_thread_length_mm/2 )
		let( md_extension_dr  = md_extension_dz*2 ) // Eh, something like that
		// HMM, maybe midriff should get a slight r_offset, also.
		// Threads2 uses $tgx11_offset for this
		let( md_r0 = cyl_midriff_diameter_mm/2 )
		let( md_r1 = max(1, md_r0 - md_extension_dr) )
		let( md_extension_dz2 = (md_r0-md_r1)/2 ) // Actual dz, taking actual dr into account
		let( mdbz1 = mdbz0 - md_extension_dz2 )
		let( mdtz1 = mdtz0 + md_extension_dz2 )
		tphl1_make_polyhedron_from_layer_function(
			[
				[mdbz1, md_r1],
				[mdbz0, md_r0],
				[mdtz0, md_r0],
				[mdtz1, md_r1],
			],
			function(zr) let(r=zr[1]) togpath1_rath_to_polypoints(
				// TODO: Base corner radius on cyl_midriff_diameter_mm and side count?
				togpath1_make_polygon_rath(
					r          = r / cos(360/cyl_midriff_side_count/2),
					corner_ops = [["round", min(r/2, 3.2)]],
					$fn        = cyl_midriff_side_count
				)
			),
			layer_points_transform="key0-to-z"
		)
	)
	let( hole_troffs_2d = ["union",
		for( p = hole_posrots )
		let( direction = normalize_vec2d(p[0]) )
		["hull", togmod1_make_circle(d=hole_troff_width_mm), ["translate", direction*1000, togmod1_make_circle(d=hole_troff_width_mm)]]
	])
	let( cyl_body = !midriff_exposed ? togthreads2_make_threads(
		togthreads2_simple_zparams([
			[-cyl_height_mm/2, -1],
			[ cyl_height_mm/2, -1],
		], taper_length=1, inset=3),
		cyl_outer_threads,
		r_offset = cyl_outer_thread_radius_offset_mm
	) : ["union",
		togthreads2_make_threads(
			togthreads2_simple_zparams([
				[-cyl_height_mm/2                             , -1],
				[-cyl_height_mm/2 + cyl_outer_thread_length_mm,  0],
			], taper_length=1, inset=3),
			cyl_outer_threads,
			r_offset = cyl_outer_thread_radius_offset_mm
		),
		midriff,
		togthreads2_make_threads(
			togthreads2_simple_zparams([
				[ cyl_height_mm/2 - cyl_outer_thread_length_mm,  0],
				[ cyl_height_mm/2                             , -1],
			], taper_length=1, inset=3),
			cyl_outer_threads,
			r_offset = cyl_outer_thread_radius_offset_mm
		)
	] )
	["difference",
		// Note: I went with 'threads all the way up' for now, because that's 'simple',
		// but it might be nice to cut off threads in the middle section, or to jut out beyond them.
		cyl_body,
		
		for( p=hole_posrots ) ["translate", p[0], ["rotate", p[1], hole]],
		togmod1_linear_extrude_z([cyl_height_mm/2 - hole_troff_depth_mm, cyl_height_mm], hole_troffs_2d),
	]
);
