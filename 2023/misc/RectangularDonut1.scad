// RectangularDonut1.1
// 
// Gridbeam size tester / center marker
// 
// v1.1:
// - Allow threaded hole styles

outer_offset = -0.1;
inner_offset = -0.1;
$fn = 64;

// Also try 3/4-10-UNC
hole_style = "straight-3/4inch";

module rectangulardonut1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>

inch = 25.4;
atom = 12.7;
outer_r = 3/16*inch;
$togthreads2_polyhedron_algorithm = "v3";

outer_size = [4*atom, 4*atom, 4*atom];

hole = ["render", togthreads2_make_threads(
	togthreads2_simple_zparams([[-outer_size[2]/2,1], [outer_size[2]/2,1]], taper_length=2),
	hole_style,
	r_offset = 0.2
)];

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([outer_size[0]+outer_offset*2, outer_size[1]+outer_offset*2, outer_size[2]+outer_offset*2], r=[outer_r, outer_r, 0]),
	
	tphl1_make_rounded_cuboid([3*atom-inner_offset*2, 3*atom-inner_offset*2, 5*atom], r=[0.5,0.5,0]),
	for( a=[0,90] ) ["rotate-xyz", [90,0,a], hole],
]);
