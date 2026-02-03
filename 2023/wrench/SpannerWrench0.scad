// SpannerWrench0.1
// 
// A wrench that you can stick some 

thickness = "1/4inch";
width = "3/4inch";
hole_spacing = "1+3/8inch";
hole_style = "diamond-4.5mm";
handle_length = "3inch";
$fn = 48;

module __aklsjndakjslnd__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

hole_spacing_mm  = togunits1_to_mm(hole_spacing);
thickness_mm     = togunits1_to_mm(thickness);
width_mm         = togunits1_to_mm(width);
handle_length_mm = togunits1_to_mm(handle_length);

inner_width_mm = hole_spacing_mm - width_mm;
outer_width_mm = hole_spacing_mm + width_mm;

icops = [["round", inner_width_mm*127/256]];
// ocops should just be outer_width_mm/2, but I have to figure out how to intersect the curve with the handle.
// Have the wto curves flow together, as it were.
ocops = [["round", (outer_width_mm - width_mm*2)*127/256]];
ccops = [["round", width_mm*127/256]];
rath = ["togpath1-rath",
	for( xf = [
		function(nodes) nodes,
		function(nodes) [
			for(i=[len(nodes)-1 : -1 : 0])
			let(n=nodes[i])
			[n[0], [n[1][0], -n[1][1]], for(o=[2:1:len(n)-1]) n[o]]
		]
	])
	each xf([
		["togpath1-rathnode", [ inner_width_mm/2, -inner_width_mm/2], each icops],
		["togpath1-rathnode", [      -width_mm/2, -inner_width_mm/2], each ccops],
		["togpath1-rathnode", [      -width_mm/2, -outer_width_mm/2], each ccops],
		["togpath1-rathnode", [ outer_width_mm/2, -outer_width_mm/2], each ocops], // TODO: Make a better corner somehow
		["togpath1-rathnode", [ outer_width_mm/2,       -width_mm/2], each ccops],
		["togpath1-rathnode", [ outer_width_mm/2+handle_length_mm,       -width_mm/2], each ccops],
	])
];

togmod1_domodule(
	let( bev = min(width_mm/4, thickness_mm/4) )
	let( hole = ["translate", [0,0,thickness_mm/2], tog_holelib2_hole(hole_style, depth=thickness_mm*2)] )
	["difference",
		tphl1_make_polyhedron_from_layer_function(
			[
				[-thickness_mm/2      , -bev],
				[-thickness_mm/2 + bev,    0],
				[ thickness_mm/2 - bev,    0],
				[ thickness_mm/2      , -bev],
			],
			function(zo) togpath1_rath_to_polypoints(
				togpath1_offset_rath(rath, zo[1])
			),
			layer_points_transform = "key0-to-z"
		),
		
		for( hp = [[0,-hole_spacing_mm/2], [0,hole_spacing_mm/2]] )
		["translate", hp, hole],
	]
);

// togmod1_domodule(togpath1_rath_to_polygon(rath));
