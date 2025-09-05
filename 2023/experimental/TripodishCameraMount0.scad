// TripodishCameraMount0.1
//
// Can I make a thingy that can hold the camera holder
// that goes on top of my tripod?
// IDK if it's, like, standard or anything.

$fn = 32;
bottom_hole_style = "straight-9mm";

module __tripodishcameramount0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

slot_profile_data = [
	[42.7/2, -8.95      ],
	[42.7/2, -8.95 + 2.5],
	[36.2/2,  0         ],
];

function reverse_list(list) =
	[for(i=[len(list)-1 : -1 : 0]) list[i]];

function mirror_points(points) = [
	for(p=points) p,
	for(p=reverse_list(points)) [-p[0], p[1]]
];


function profile_data_to_polypoints(dat, x_offset) =
	mirror_points([for(p=dat) [p[0]+x_offset, p[1]]]);

slot_inner_x = slot_profile_data[len(slot_profile_data)-1][0];
slot_bottom_z = slot_profile_data[0][1];
block_bottom_z = -19.05;

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([block_bottom_z, 0], togmod1_make_rounded_rect([76.2, 76.2], r=12.7)),
	
	["intersection",
		togmod1_linear_extrude_y([-100,100], ["union",
			togmod1_make_polygon(profile_data_to_polypoints(slot_profile_data, 0.4)),
			togmod1_make_rect([(slot_inner_x+1)*2, -(slot_bottom_z+1)*2])
		]),
		togmod1_linear_extrude_x([-100,100], ["union",
			togmod1_make_polygon([
				[-100, slot_bottom_z],
				each slot_profile_data,
				[slot_inner_x, 100],
				[-100, 100],
			]),
	   ]),
	],
	
	["translate", [0,0,slot_bottom_z], tog_holelib2_hole("THL-1006")],
	["translate", [0,-25.4,block_bottom_z], ["rotate",[180,0,0],tog_holelib2_hole(bottom_hole_style)]],
]);
