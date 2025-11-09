// WSTYPE4007Rimmogram0.2
//
// Can I model one of these well enough to
// print something that fits around the rim?
// 
// v0.2:
// - Add mounting holes along edges
// - Size customizable

algorithm = "Rath"; // ["Rath","Intersection"]

max_rath_round = 1000000;
outer_size = ["13.5inch","8.5inch","3/8inch"];
mounting_hole_style = "THL-1005";
inner_flange_thickness = "2mm";

$fn = 48;
$togunits1_default_unit = "mm";

module wstype4007rimmogram__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

inch = 25.4;
atom = 12.7;

inner_flange_thickness_mm = togunits1_decode(inner_flange_thickness);
outer_size_atoms = togunits1_decode_vec(outer_size, unit="atom");
outer_size_mm    = togunits1_decode_vec(outer_size, unit="mm");



basic_shape_by_rath = togpath1_rath_to_polygon(["togpath1-rath",
	["togpath1-rathnode", [ (13+1/16)/2*inch  ,   0               ], ["round", min(max_rath_round,170*inch), 20]],
	["togpath1-rathnode", [ (6+1/2  )  *inch  ,  (3+15/16 )  *inch], ["round", min(max_rath_round,5/8*inch), 20]],
	["togpath1-rathnode", [ 0                 ,  (8+1/8   )/2*inch], ["round", min(max_rath_round,130*inch), 20]],
	["togpath1-rathnode", [-(6+1/2  )  *inch  ,  (3+15/16 )  *inch], ["round", min(max_rath_round,5/8*inch), 20]],
	["togpath1-rathnode", [-(13+1/16)/2*inch  ,   0               ], ["round", min(max_rath_round,170*inch), 20]],
	["togpath1-rathnode", [-(6+1/2  )  *inch  , -(3+15/16 )  *inch], ["round", min(max_rath_round,5/8*inch), 20]],
	["togpath1-rathnode", [ 0                 , -(8+1/8   )/2*inch], ["round", min(max_rath_round,130*inch), 20]],
	["togpath1-rathnode", [ (6+1/2  )  *inch  , -(3+15/16 )  *inch], ["round", min(max_rath_round,5/8*inch), 20]],
]);

basic_shape_by_intersection =
let( corner_circ = togmod1_make_circle(r=5/8*inch) )
["intersection",
   ["hull",
		for( xm=[-1,1] ) for( ym=[-1,1] )
		["translate", [xm*(11+3/4)*inch/2,ym*(6+5/8)*inch/2], corner_circ],

		for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*6*inch, 0*ym*inch], corner_circ],
		for( ym=[-1,1] ) for( xm=[-1,1] ) ["translate", [0*xm*inch, ym*(4+7/8)*inch], corner_circ],
	],
	
	for( xm=[-1,1] ) ["translate", [xm * ((13+1/16)*inch/2 - (175+13/16)*inch), 0], togmod1_make_circle(r=(175+13/16)*inch, $fn = 480)],
	for( ym=[-1,1] ) ["translate", [0, ym*((8+1/8)*inch/2 - (138+23/64)*inch)], togmod1_make_circle(r=(138+23/64)*inch , $fn = 480)],
];

basic_shape = algorithm == "Rath" ? basic_shape_by_rath : basic_shape_by_intersection;

outer_shape = togmod1_make_rounded_rect(outer_size_atoms*12.7, r=1/4*inch);
inner_shape = ["union",
	["offset-ds", -3.175, basic_shape],
	
	["intersection",
		["offset-ds", -0.1, basic_shape],
		["union",
			for( xm=[-1,1] ) ["translate", [xm*11.25/2*inch, 0], togmod1_make_rect([3,1000])]
		]
	],
];

mounting_hole = tog_holelib2_hole(mounting_hole_style, depth=100);

function defloor(z, zmin, zunder) = z > zmin ? z : zunder;

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, outer_size_mm[2]], ["difference", outer_shape, inner_shape]),
	
	togmod1_linear_extrude_z([defloor(inner_flange_thickness_mm, 0, -1), outer_size_mm[2]+1], ["offset-ds", 0.5, basic_shape]),
	
	for( ym=[-outer_size_atoms[1]/2+0.5 : 1 : outer_size_atoms[1]/2-0.5] )
	for( xm=[-outer_size_atoms[0]/2+0.5 : 1 : outer_size_atoms[0]/2-0.5] )
	if( abs(ym) > 8 || abs(xm) > 13 )
	["translate", [xm*atom, ym*atom, outer_size_mm[2]], mounting_hole],
]);
