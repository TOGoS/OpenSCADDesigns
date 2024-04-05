use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

$fn = 20;

polyline = [[-15,0],[0,10],[15,0]];

togmod1_domodule(tphl1_make_polyhedron_from_layer_function([
	[0],
	[5],
], function(params)
	let(z = params[0])
	togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_polyline_to_rath(polyline, 2.5, end_shape="square")), z)
	//togpath1_qath_to_polypoints(togpath1_polyline_to_qath(polyline, r=2.5))
));

different_polyline = [
	for( x=[-40 : 1 : 40] ) [x, -20 + 10 * sin(x * 5)]
];

togmod1_domodule(tphl1_make_polyhedron_from_layer_function([
	for( a=[ -90 : 15 : 90 ] )
	[sin(a)*2.5, 0.1 + cos(a)*2.5],
], function(params)
	let(z = params[0], r = params[1])
	togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_polyline_to_rath(different_polyline, r, end_shape="round")), z)
	//togpath1_qath_to_polypoints(togpath1_polyline_to_qath(polyline, r=2.5))
));
