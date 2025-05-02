// Midblock2.1
// 
// New midblocks, for different purposes!
// 
// v2.1:
// - Add `right_side_offset` parameter
// - Add `straight-4.5mm` option for `hole_style`
// - Base at z=0 instead of center

height = "2inch";
size = ["3atom","1atom"];
concave_corner_radius = "0mm";
hole_style = "straight-4.5mm"; // ["#6-32-UNC", "straight-4.5mm", "straight-5mm"]
right_side_offset = "0mm";
$fn = 32;

module __midblock2__end_params() { }

use <../lib/TOGUnits1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGPath1.scad>

right_side_offset_mm = togunits1_to_mm(right_side_offset);
size_mm = [for(d=size) togunits1_to_mm(d)];
height_mm = togunits1_to_mm(height);
concave_corner_radius_mm = togunits1_to_mm(concave_corner_radius);
atom = 12.7;
$togthreads2_polyhedron_algorithm = "v3";

hole = ["render",togthreads2_make_threads(
	togthreads2_simple_zparams([[0,1], [height_mm,1]], 1),
	hole_style,
	r_offset = 0.2
)];

block_hull_x0 = -size_mm[0]/2;
block_hull_x1 =  size_mm[0]/2 + right_side_offset_mm;
block_hull_y0 = -size_mm[1]/2;
block_hull_y1 =  size_mm[1]/2;

block_hull =
	togmod1_linear_extrude_z([0, height_mm], ["difference",
		togpath1_rath_to_polygon(let(cops=[["round",5]]) ["togpath1-rath",
			["togpath1-rathnode", [block_hull_x1, block_hull_y0], each cops],
			["togpath1-rathnode", [block_hull_x1, block_hull_y1], each cops],
			["togpath1-rathnode", [block_hull_x0, block_hull_y1], each cops],
			["togpath1-rathnode", [block_hull_x0, block_hull_y0], each cops],
		]),
		
		["translate", [size_mm[0]/2, size_mm[1]/2],
			togmod1_make_circle(r=concave_corner_radius_mm)]
	]);

size_atoms = [for(d=size) round(togunits1_decode(d, "1atom"))];

block = ["difference",
	block_hull,
	
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.4] )
	let( x=xm*atom, y=ym*atom )
	if( x > block_hull_x0+4 && x < block_hull_x1-4 )
	["translate", [x, y], hole]
];

togmod1_domodule(block);
