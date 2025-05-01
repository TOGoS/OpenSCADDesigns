// Midblock2.0
// 
// New midblocks, for different purposes!

height = "2inch";
size = ["3atom","1atom"];
concave_corner_radius = "0mm";
hole_style = "straight-5mm"; // ["#6-32-UNC", "straight-5mm"] 
$fn = 32;

module __midblock2__end_params() { }

use <../lib/TOGUnits1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

size_mm = [for(d=size) togunits1_to_mm(d)];
height_mm = togunits1_to_mm(height);
concave_corner_radius_mm = togunits1_to_mm(concave_corner_radius);
atom = 12.7;
$togthreads2_polyhedron_algorithm = "v3";

hole = ["render",togthreads2_make_threads(
	togthreads2_simple_zparams([[-height_mm/2,1], [height_mm/2,1]], 1),
	hole_style,
	r_offset = 0.2
)];

concave_corner_cutout =
	concave_corner_radius_mm == 0 ? ["union"] :
	["translate", [size_mm[0]/2, size_mm[1]/2], tphl1_make_z_cylinder(zrange=[-height_mm, height_mm], d=concave_corner_radius_mm*2)];

block_hull = ["difference",
	tphl1_make_rounded_cuboid([size_mm[0], size_mm[1], height_mm], r=[5,5,0]),
	concave_corner_cutout,
];

size_atoms = [for(d=size) round(togunits1_decode(d, "1atom"))];

block = ["difference",
	block_hull,
	
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.4] )
	["translate", [xm*atom, ym*atom], hole]
];

togmod1_domodule(block);
