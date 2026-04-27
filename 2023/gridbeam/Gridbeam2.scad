// Gridbeam2.0
//
// Slightly less simple grid beams.

chunk_pitch   = "12.7mm";
length        = "8chunk";
hole_diameter = "4.5mm";
hole_frequency = 1;
xy_corner_bevel = "1/8inch";
xy_corner_round = "1mm";
z_corner_bevel = "1/8inch";
width_x = "1chunk";
width_y = "1chunk";

$tgx11_offset = -0.1;
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGridLib3.scad>

$togridlib3_unit_table = [
	["chunk", togunits1_to_ca(chunk_pitch)],
	each togridlib3_get_default_unit_table()
];

length_mm = togunits1_to_mm(length);
chunk_pitch_mm = togunits1_to_mm("chunk");
length_chunks = togunits1_decode(length, unit="chunk");
hole_diameter_mm = togunits1_to_mm(hole_diameter);
xy_corner_bevel_mm = togunits1_to_mm(xy_corner_bevel);
xy_corner_round_mm = togunits1_to_mm(xy_corner_round);
z_corner_bevel_mm = togunits1_to_mm(z_corner_bevel);
width_x_mm = togunits1_to_mm(width_x);
width_y_mm = togunits1_to_mm(width_y);
width_max_mm = max(width_x_mm, width_y_mm);

echo(str("Length: ",length,"; ",length_mm, "mm; ", togunits1_decode(length,unit="inch"),"in"));

hole = tphl1_make_z_cylinder(hole_diameter_mm, [-width_max_mm/2-1, width_max_mm/2+1]);

hole_pair = ["union",
	["rotate", [90,0,0], hole],
	["rotate", [0,90,0], hole],
];

togmod1_domodule(["difference",
	tphl1_make_polyhedron_from_layer_function(
	[
			[-length_mm/2                  -$tgx11_offset, -z_corner_bevel_mm+$tgx11_offset],
			[-length_mm/2+z_corner_bevel_mm-$tgx11_offset,                  0+$tgx11_offset],
			[ length_mm/2-z_corner_bevel_mm+$tgx11_offset,                  0+$tgx11_offset],
			[ length_mm/2                  +$tgx11_offset, -z_corner_bevel_mm+$tgx11_offset],
		], function(zo) let(rn=max(xy_corner_round_mm,-zo[1]+1)) togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [ width_x_mm/2, -width_y_mm/2], ["bevel", xy_corner_bevel_mm], ["round", rn], ["offset", zo[1]]],
			["togpath1-rathnode", [ width_x_mm/2,  width_y_mm/2], ["bevel", xy_corner_bevel_mm], ["round", rn], ["offset", zo[1]]],
			["togpath1-rathnode", [-width_x_mm/2,  width_y_mm/2], ["bevel", xy_corner_bevel_mm], ["round", rn], ["offset", zo[1]]],
			["togpath1-rathnode", [-width_x_mm/2, -width_y_mm/2], ["bevel", xy_corner_bevel_mm], ["round", rn], ["offset", zo[1]]],
		]),
		layer_points_transform = "key0-to-z"
	),
	
	for( zm=[-length_chunks/2+0.5 : 1/hole_frequency : length_chunks/2-0.4] ) ["translate", [0,0,zm*chunk_pitch_mm], hole_pair],
]);
