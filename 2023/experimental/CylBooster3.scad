// CylBooster3.1
// 
// Booster seats for cigarettes.
// i.e. the boosters match the holes in a CylHolder3.
// 
// Maybe can double as some sort of wrench
// if you give it a thick enough base.
// 
// v3.1:
// - Make booster_diameter configurable

base_thickness = "1/8inch";
booster_diameter = "9mm";

$fn = 144;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

function cylspacer3_make_spacer(
	// base_diameter = 25.4,
	base_side_to_side = 22.225,
	base_thickness = 1.6,
	booster_count = 3,
	booster_pattern_radius = 6.35,
	booster_height = 12.7,
	booster_diameter = 9
) =
let( base_corner_to_corner = base_side_to_side/cos(30) )
echo( base_corner_to_corner = base_corner_to_corner )
let( booster_posrots = [for(i=[0:1:booster_count-1]) let(ang=i*360/booster_count) [[cos(ang)*booster_pattern_radius, sin(ang)*booster_pattern_radius], [0,0,0]]] )
let( boostbev = min(3, booster_height, booster_diameter*1/4) )
let( booster = tphl1_make_z_cylinder(zds=[
	[base_thickness/2                          , booster_diameter             ],
	[base_thickness + booster_height - boostbev, booster_diameter             ],
	[base_thickness + booster_height           , booster_diameter - boostbev*2],
]))
["union",
	togmod1_linear_extrude_z([0, base_thickness],
		togpath1_rath_to_polygon(
			togpath1_make_polygon_rath(r=base_corner_to_corner/2, corner_ops=[["round", 3]], $fn=6)
		)
	),
	
	for( p=booster_posrots ) ["translate", p[0], ["rotate", p[1], booster]],
];

togmod1_domodule(cylspacer3_make_spacer(
	base_thickness   = togunits1_to_mm(base_thickness),
	booster_diameter = togunits1_to_mm(booster_diameter)
));
