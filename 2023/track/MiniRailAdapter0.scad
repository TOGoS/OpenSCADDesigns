// MiniRailAdapter0.2
// 
// Hang it on a MiniRail
// and bolt stuff to it.
// 
// Changes:
// v0.2:
// - Change rail cutout and hole placement.
//   If you liked it the way it was, use 0.1.

size_atoms = [3,12,1];
rail_mating_offset = -0.1;
$fn = 24;

module __minirailadapter0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>

$togridlib3_unit_table = togridlib3_get_default_unit_table();
atom = togridlib3_decode([1,"atom"]);
u = togridlib3_decode([1,"u"]);

size = togridlib3_decode_vector([
	[size_atoms[0], "atom"],
	[size_atoms[1], "atom"],
	[size_atoms[2], "atom"]
]);

kq = (sqrt(2)+1)*rail_mating_offset; // Or something
bev = 1;

open_rail_cutout = togmod1_linear_extrude_x(
	[-size[0], size[0]],
	togmod1_make_polygon([
		[  4*u + bev - kq, -1*u       ],
		[  4*u + bev - kq,  0    + bev],
		[  8*u       - kq,  4*u       ],
		[- 8*u       + kq,  4*u       ],
		[-13*u       + kq, -1*u       ],
	])
);
closed_rail_cutout = togmod1_linear_extrude_x(
	[-size[0], size[0]],
	togmod1_make_polygon([
		[  4*u + bev - kq, -1*u       ],
		[  4*u + bev - kq,  0    + bev],
		[  3*u       - kq, -1*u       ],
		[  8*u       - kq,  4*u       ],
		[- 8*u       + kq,  4*u       ],
		[- 4*u - bev + kq,  0    + bev],
		[- 4*u - bev + kq, -1*u       ],
	])
);

the_hull = ["translate", [0,0,size[2]/2], tphl1_make_rounded_cuboid(size, r=[0,3,3])];

back_hole  = ["translate", [0,0,size[2]-2*u], ["rotate", [180,0,90], tog_holelib2_hole("THL-1005", depth=size[2], overhead_bore_height=size[2], inset=0)]];
front_hole = ["translate", [0,0,size[2]-2*u], ["rotate", [  0,0,90], tog_holelib2_hole("THL-1005", depth=size[2], overhead_bore_height=size[2], inset=0)]];

rails = [
	[ size_atoms[1]/2 -  1.5, "open"  , "back" ],
	[ size_atoms[1]/2 -  4.5, "closed", "back" ],
	[ size_atoms[1]/2 -  7.5, "closed", "front"],
	[ size_atoms[1]/2 - 10.5, "closed", "back" ],
];

function hole_row_type_by_rail(ym, rail) =
	rail[1] == "closed" && (ym == rail[0]+1 || ym == rail[0]-1) ? "none" :
	rail[1] == "open"   && (ym == rail[0]+1) ? "none" :
	ym == rail[0] ? rail[2] :
	undef;

function hole_row_type(ym, rails, index=0) =
	index == len(rails) ? "back" :
	let( force_type = hole_row_type_by_rail(ym, rails[index]) )
	force_type != undef ? force_type :
	hole_row_type(ym, rails, index+1);

function hole_of_type(type) =
	type == "none" ? ["union"] :
	type == "back" ? back_hole : front_hole;

hole_rows = [
	for(ym=[-size_atoms[1]/2 + 0.5 : 1 : size_atoms[1]/2])
		[ym, hole_row_type(ym, rails)]
	];

thing = ["difference",
	the_hull,
	
	for( rail=rails )
		["translate", [0, rail[0]*atom, 0], rail[1] == "open" ? open_rail_cutout : closed_rail_cutout],

	for( row=hole_rows )
	for( xm=[-size_atoms[0]/2 + 0.5 : 1 : size_atoms[0]/2] )
		["translate", [xm*atom, row[0]*atom, 0], hole_of_type(row[1])],
];

togmod1_domodule(["translate", [0,0,size[0]/2], ["rotate", [0,90,0], thing]]);
