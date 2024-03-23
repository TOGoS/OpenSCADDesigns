// BowtieTest2.0

use <../lib/BowtieLib-v0.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

the_text = "";

bowtie_point_data = get_bowtie_point_data();
function make_bowtie_rath(point_data, vex, vexop) =
let( btu=19.05/6 )
["togpath1-rath",
	for( pd=point_data ) ["togpath1-rathnode", [pd[0]*btu, pd[1]*btu], if(pd[4] == vex) vexop]
];

$fn = 48;

female_bowtie_rath = make_bowtie_rath(bowtie_point_data, "concave", ["round", 3.175]);
female_bowtie_shape = togmod1_make_polygon(togpath1_rath_to_polypoints(female_bowtie_rath));

male_bowtie_rath = make_bowtie_rath(bowtie_point_data, "convex", ["round", 2]);
male_bowtie_shape = togmod1_make_polygon(togpath1_rath_to_polypoints(male_bowtie_rath));

function make_rect(bl, tr) = togmod1_make_polygon(togpath1_rath_to_polypoints(["togpath1-rath", for( p=[
	[bl[0],bl[1]],
	[tr[0],bl[1]],
	[tr[0],tr[1]],
	[bl[0],tr[1]],
]) ["togpath1-rathnode", p, ["bevel", 2*u], ["round", 2*u]]]));

u = 1.5875;

linear_extrude(2*u) difference() {
	togmod1_domodule(["difference",
		["union",
			make_rect([-12*u, -12*u], [12*u, 12*u]),
			["translate", [+12*u,0], male_bowtie_shape],
			["translate", [0,+12*u], ["rotate", [0,0,90], male_bowtie_shape]],
		],
		["translate", [-12*u,0], female_bowtie_shape],
		["translate", [0,-12*u], ["rotate", [0,0,90], female_bowtie_shape]],
	]);
	translate([3*u,0,0]) text(the_text, halign="center", valign="center");
}
