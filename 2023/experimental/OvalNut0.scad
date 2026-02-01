// OvalNut0.1
// 
// An oval-shaped nut that might be slipped through a hole
// only to be turned and affixed behind that hole,
// like maybe a 1+1/2" hole in some drywall,
// providing a slightly smaller but threaded hole,
// like a 1+1/4"-7 one.
// 
// OpenSCAD 2021 messes up the threaded hole subtraction.
// Use OpenSCAD 2024 with the manifold engine.

width  = "2.5inch";
height = "1.5inch";
thickness = "1/4inch";
edge_rounding_radius = "3/4inch";

inner_threads = "1+1/4-7-UNC";
// Maybe could/should be derived from inner_threads:
inner_hole_nominal_diameter = "1+1/4inch";
inner_thread_radius_offset = "0.2mm";
tape_groove_width = "14mm";

spike_height = "1/8inch";

$fn = 32;

module __ovalnut0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGPath1.scad>

width_mm  = togunits1_to_mm(width);
height_mm = togunits1_to_mm(height);
thickness_mm                   = togunits1_to_mm(thickness);
edge_rounding_radius_mm        = togunits1_to_mm(edge_rounding_radius);
inner_hole_nominal_diameter_mm = togunits1_to_mm(inner_hole_nominal_diameter);
tape_groove_width_mm           = togunits1_to_mm(tape_groove_width);
spike_height_mm                = togunits1_to_mm(spike_height);
inner_thread_radius_offset_mm  = togunits1_to_mm(inner_thread_radius_offset);

togmod1_domodule(
	let( spike = spike_height_mm <= 0 ? ["union"] : tphl1_make_z_cylinder(zds=[[-0.5, spike_height_mm*2], [spike_height_mm, 0]]) )
	/* Hardcoded dimensions version:
	let( tape_groove = togmod1_linear_extrude_x([-7, 7], ["difference",
		togmod1_make_rect([19.05, 19.05]),
		["intersection",
			togmod1_make_rect([6, 100]),
			togmod1_make_circle(r=4)
		],
	]) )
	*/
	let( edge_thickness = (height_mm-inner_hole_nominal_diameter_mm)/2 )
	let( tape_groove = tape_groove_width_mm <= 0 ? ["union"] : togmod1_linear_extrude_x([-tape_groove_width_mm/2, tape_groove_width_mm/2], ["difference",
		togmod1_make_rect([edge_thickness*4, edge_thickness*4]),
		["intersection",
			togmod1_make_rect([edge_thickness*2, 100]),
			togmod1_make_circle(r=edge_thickness*1.2)
		],
	]) )
	["difference",
		["union",
			let( edgeang = 2*asin(thickness_mm/2 / edge_rounding_radius_mm) )
			let( edgefn = max(12, $fn*edgeang/360) )
			let( outer_rath = togpath1_make_rectangle_rath([width_mm, height_mm], corner_ops=[["round",min(width_mm,height_mm)/2]]) )
			let( pentedge_ang         = (edgefn/2-1)*edgeang/edgefn )
			tphl1_make_polyhedron_from_layer_function(
				[for(i=[-edgefn/2:1:edgefn/2])
					let( ang         = i*edgeang/edgefn )
					let( rounded_off = (cos(         ang) - 1) * edge_rounding_radius_mm )
					let( beveled_off = (cos(pentedge_ang) - 1) * edge_rounding_radius_mm - edge_rounding_radius_mm*sin(edgeang/edgefn) )
					[
						sin(ang) * edge_rounding_radius_mm,
						i == (-edgefn/2) || i == (edgefn/2) ? beveled_off : rounded_off
					]
				],
				function(zo) togpath1_rath_to_polypoints(
					togpath1_offset_rath(outer_rath, zo[1])
				),
				layer_points_transform = "key0-to-z"
			),
			
			for( pos=[[-width_mm/2+spike_height_mm*2,0], [width_mm/2-spike_height_mm*2,0]] )
			["translate", [pos[0],pos[1],thickness_mm/2], spike],
		],
		
		togthreads2_make_threads(
			togthreads2_simple_zparams([[-thickness_mm/2, 1], [thickness_mm/2, 1]], taper_length=0.5, inset=0.5, extend=1),
			inner_threads,
			r_offset = inner_thread_radius_offset_mm
		),
		
		for( ym=[-1,1] )
		["translate", [0,ym*height_mm/2,0], tape_groove]
	]
);
