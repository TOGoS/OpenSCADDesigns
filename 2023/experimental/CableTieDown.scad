use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = 24;

torus = ["difference",
	togmod1_make_cuboid([6.35, 50, 50]),
	//togmod1_make_cuboid([50, 25.4, 19.05-6.35]),
	// TODO: Make the unner surface rounded
	tphl1_make_polyhedron_from_layer_function([
		for( a=[-180:15:0] ) [3.5*cos(a), 4+3.5*sin(a)]
	], function(xo) [
		for(rpp = togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [-16, -6], ["round", 4], ["offset", xo[1]]],
			["togpath1-rathnode", [ 16, -6], ["round", 4], ["offset", xo[1]]],
			["togpath1-rathnode", [ 16,  6], ["round", 4], ["offset", xo[1]]],
			["togpath1-rathnode", [-16,  6], ["round", 4], ["offset", xo[1]]],
		]))
		[xo[0], rpp[0], rpp[1]]
	])
	//tphl1_make_rounded_cuboid([50, 25.4, 19.05-6.35], [0,4,4]),
];

togmod1_domodule(["difference",
	["translate", [0,0,9.525], tphl1_make_rounded_cuboid([38.1,38.1,19.05], 4.7625)],
	["translate", [0,0,9.525], tog_holelib2_hole("THL-1006", inset=3.175, overhead_bore_height=38.1)],
	["translate", [0,0,19.05], tphl1_make_rounded_cuboid([50,19.05,7.5], [0,3,3])],
	for(xm=[-1,1]) ["translate", [-25.4/3*xm,0,9.525], torus]
]);
