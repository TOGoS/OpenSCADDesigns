// OrgainTeeterTotter-v1.0

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGHoleLib2.scad>

part_name = "teeter"; // ["teeter","totter","assembly"]

module __asdads_end_params() { }

inch = 25.4;
orgain_size = [5.25*inch, 2.5*inch, 2.5*inch];
cradle_hull_size = [5.5*inch, 2.75*inch, 1*inch];
floor_thickness = 0.5*inch;

$fn = $preview ? 24 : 48;

screw_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(5, zrange=[-cradle_hull_size[1], cradle_hull_size[1]])];

cradle_pivot_position = [0,0,floor_thickness/2];
cradle = ["difference",
	["translate", [0,0,cradle_hull_size[2]/2], tphl1_make_rounded_cuboid(cradle_hull_size, r=[6,6,0])],
	["translate", [0,0,orgain_size[2]/2+floor_thickness], tphl1_make_rounded_cuboid(orgain_size, r=[3,3,0])],
	["translate", cradle_pivot_position, screw_hole],
];

totter_size = [1.5*inch, 3.5*inch, 2*inch];
totter_round = 15;

totter_rath = ["togpath1-rath",
	["togmod1-rathnode", [-totter_size[0]/2, 0]],
	["togmod1-rathnode", [ totter_size[0]/2, 0]],
	["togmod1-rathnode", [ totter_size[0]/2, totter_size[2]], ["round", totter_round]],
	["togmod1-rathnode", [-totter_size[0]/2, totter_size[2]], ["round", totter_round]],
];
mounting_hole = tog_holelib2_hole("THL-1001");
totter_floor_thickness = 6.35;
totter_pivot_position = [0,0,totter_size[2]-0.5*inch];
totter = ["difference",
	["rotate", [90,0,0], tphl1_extrude_polypoints([-totter_size[1]/2, totter_size[1]/2], togpath1_rath_to_points(totter_rath))],
	["translate", [0,0,totter_size[2]], togmod1_make_cuboid([totter_size[0]*2, cradle_hull_size[1]+2, (totter_size[2]-totter_floor_thickness)*2])],
	["translate", totter_pivot_position, screw_hole],
	for( ym=[-1,0,1] ) ["translate", [0,ym*0.75*inch,totter_floor_thickness], mounting_hole],
];

assembly = ["union", totter, ["translate", totter_pivot_position-cradle_pivot_position, cradle]];

togmod1_domodule(
	part_name == "teeter" ? cradle :
	part_name == "totter" ? totter :
	part_name == "assembly" ? assembly :
	assert(false, str("Bad part name: '", part_name, "'"))
);
