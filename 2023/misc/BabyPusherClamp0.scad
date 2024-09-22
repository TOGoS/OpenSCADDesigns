// BabyPusherClamp0.2
// 
// Clamp for Marilla's tricycle thing
// for WSPROJECT-201202.
// 
// Post diameter is 19.3mm to 19.4mm (it's got a groove in one side, so not perfectly circular).

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/Flangify0.scad>

module __babypusherclamp0__end_params() { }

inch = 25.4;
$fn = $preview ? 32 : 64;

ty   = 1.5  * inch;
tz   = 1.5  * inch;
bhd2 = 7/8  * inch;
bhd1 = 5/16 * inch;
gap_width = 1/8 * inch;

half_body_thickness = (ty - gap_width)/2;
half_bahdy = tphl1_make_rounded_cuboid([3*inch, half_body_thickness, tz], r=[2,2,0]);
bahdy = ["union",
	["translate", [0, -gap_width/2 - half_body_thickness/2, 0], half_bahdy],
	["translate", [0,  gap_width/2 + half_body_thickness/2, 0], half_bahdy],
];

post_hole = flangify0_extrude_z(flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zdopses",
	["zdops", [-tz/2 - 0.1, 40]],
	["zdops", [-tz/2 - 0.1, 20], ["round", 5]],
	["zdops", [ tz/2 + 0.1, 20], ["round", 5]],
	["zdops", [ tz/2 + 0.1, 40]],
])));

bolt_hole = flangify0_extrude_z(flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zdopses",
	["zdops", [-ty/2 - 0.10, bhd2 + 20]],
	["zdops", [-ty/2 - 0.10, bhd2], ["round", 3]],
	["zdops", [-ty/2 + 6.35, bhd2]],
	["zdops", [-ty/2 + 6.35, bhd1], ["round", 2]],
	["zdops", [ ty/2 - 6.35, bhd1], ["round", 2]],
	["zdops", [ ty/2 - 6.35, bhd2]],
	["zdops", [ ty/2 + 0.10, bhd2], ["round", 3]],
	["zdops", [ ty/2 + 0.10, bhd2 + 20]],
])));

thing = ["difference",
	bahdy,
	post_hole,
	for( x=[-3/4*inch, 3/4*inch] ) ["translate", [x,0,0], ["rotate", [90,0,0], bolt_hole]],
];

togmod1_domodule(thing);
