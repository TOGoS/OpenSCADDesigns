// BrickHolder1.0
// 
// Holder for arbitrary 'bricks'
// with mounting holes to attach to gridbeam or togbeam or whatever
//
// v1.0:
// - Basic rounded cuboid - no TOGridPile nubs for now
// - For ThinkPad power brick holder

// width, depth, height (in mm) of object to be held
brick_size = [47.1, 30.0, 108.3];

// Space between brick and holder on each side
margin = 1;

// Size of hole in bottom centered under brick for cords or whatever
bottom_hole_size = [19.05, 19.05];

cavity_size = [
	brick_size[0] + margin*2,
	brick_size[1] + margin*2,
	(brick_size[2] + margin), // Z Might be not relevant...
];

top_slot_width = cavity_size[0] - 6;

atom = 12.7;
chunk = 3*atom;
block_size_unit = [atom,atom,atom];

min_wall_thickness = 4;
floor_thickness = 6.35;

min_side_thickness = [min_wall_thickness, min_wall_thickness, floor_thickness];

block_size = [
	for( d=[0,1,2] ) block_size_unit[d] * ceil((cavity_size[d]+min_side_thickness[d]*2)/block_size_unit[d])
];

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

$fn = 24;

block_hull = ["translate", [0,0,block_size[2]/2], tphl1_make_rounded_cuboid(block_size, 3)];
cavity = ["translate", [0,0,floor_thickness+cavity_size[2]], tphl1_make_rounded_cuboid([cavity_size[0], cavity_size[1], cavity_size[2]*2], [1,1,1])];
function widthcurve(t) = t <= 0 ? 0 : t >= 1 ? 1 : 0.5 - 0.5*cos(t*180);
slot = tphl1_make_polyhedron_from_layer_function([
	//[-100             , [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	//[block_size[2]+100, [bottom_hole_size[0], block_size[1]+bottom_hole_size[1]]],
	for( z = [-100, for(z=[-1:5:block_size[2]+1]) z, block_size[2]+100] )
		[z, [bottom_hole_size[0] + widthcurve(z / block_size[2]) * (top_slot_width-bottom_hole_size[0]), block_size[1]+bottom_hole_size[1]]],
], function( zs )
	togmod1_rounded_rect_points(zs[1], r=2, pos=[0,-block_size[1]/2, zs[0]])
);

mounting_hole = ["x-debug", ["rotate", [90,0,0], tog_holelib2_hole("THL-1003", depth=20)]];
mounting_holes = ["union",
	for( xm=[round(-block_size[0]/atom)/2 + 0.5 : 1 : round(block_size[0]/atom)/2] )
	let( x = xm*atom )
	if( x-6 >= -cavity_size[0]/2 && x+6 <= cavity_size[0]/2 )
	for( zm=[1.5 : 1 : round(block_size[2]/atom)] )
	["translate", [xm*atom, cavity_size[1]/2, zm*atom], mounting_hole]
];

use <../lib/TOGMod1.scad>

togmod1_domodule(["difference",
	block_hull, cavity, ["x-debug", slot], mounting_holes
]);
