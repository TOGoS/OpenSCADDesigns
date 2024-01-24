// DuctSegment1.0.0-dev
// 
// For now this just demonstrates
// a way to make tapered pipe segment

module __alksd_end_params() { }

inch = 25.4;

// According to ChatGPT, which could be wrong,
// 6" refers to the inner diameter of the pipe.
// TODO: Actually measure some and see.

mating_surface_diameter = 6*inch;

h_fn = $preview ? 48 : 96;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

// Taper       = [ [z, od], ... ]
// HollowTaper = [ [z, od, id], ... ]

function taper_to_shape( taper ) =
	tphl1_make_polyhedron_from_layer_function( taper,
		function(layer) togmod1_circle_points(layer[1], [0,0,layer[0]])
	);

function hollow_taper_to_shape( taper ) = ["difference",
	taper_to_shape(taper),
	taper_to_shape([
		[taper[0][0]-1, taper[0][2]],
		for( l=taper ) [l[0], l[2]],
		[taper[len(taper)-1][0]+1, taper[len(taper)-1][2]]
	])
];

function pipeseg(zrange, id, od) =
	hollow_taper_to_shape([
		[zrange[0], od, id],
		[zrange[1], od, id],
		[zrange[1]*2, id, id-(od-id)],
		[zrange[1]*3, id, id-(od-id)],
	], $fn=h_fn);

togmod1_domodule(pipeseg([0, 1*inch], 6*inch - 6.35, 6*inch));
