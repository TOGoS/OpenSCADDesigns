// VacuumPort1.0
// 
// A port for so-called 2.5" (really 2.35") vacuum hoses
// to be attached using the standard 1/2" grid of holes

panel_thickness = 3.175;
mounting_hole_diameter = 4.5;

// Diameter of tapper at narrow end
taper_d0 = 59;
// Diameter of taper at wide end
taper_d1 = 58;
// Distance along hose of d0-d1 measurements
taper_length = 30;

port_height = 38.1;

module __asdin_vp1_end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

inch = 25.4;
port_fn = $preview ? 48 : 96;

panel_hull = ["linear-extrude-zs", [0, panel_thickness],
	togmod1_make_rounded_rect([3*inch, 3*inch], r=6.35, $fn=24)
];

port_hull = ["linear-extrude-zs", [1, port_height],
	togmod1_make_circle(d=2.5*inch, $fn=port_fn),
];

mounting_hole_2d = togmod1_make_circle(d=mounting_hole_diameter, $fn=24);

function approx_eq(a, b) = let(rat = a/b) (rat > 0.99 && rat < 1.01);

togmod1_domodule(["difference",
	["union", panel_hull, port_hull],
	tphl1_make_polyhedron_from_layer_function(
		// Calculate Z positions and diameters of *actual*
		// taper, which is extrapolated from taper_d0/d1/length
		let( taper_start_z = 5 )
		let( taper_top_z = port_height + 1 )
		let( taper_top_d = taper_d0 + ((taper_top_z - taper_start_z) / taper_length) * (taper_d1 - taper_d0) )
		assert( approx_eq((taper_d1-taper_d0)/taper_length, (taper_top_d-taper_d0)/(taper_top_z-taper_start_z)) )
		[
			[           -1, taper_d0],
			[taper_start_z, taper_d0],
			[  taper_top_z, taper_top_d],
		], function(zd) togvec0_offset_points(togmod1_circle_points(d=zd[1]), zd[0], $fn=port_fn)
	),
	["linear-extrude-zs", [-1, panel_thickness+1], ["union",
		for( xm=[-2.5, -1.5, 1.5, 2.5] ) for( ym=[-2.5, 2.5] ) ["translate", [xm*12.7, ym*12.7], mounting_hole_2d],
		for( xm=[-2.5, 2.5] ) for( ym=[-1.5, 1.5] ) ["translate", [xm*12.7, ym*12.7], mounting_hole_2d],
	]],
]);
