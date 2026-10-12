// FCWheelSpacer1.0
// 
// Spacer to go around your FCWheel1

total_height  = "1/4inch";
neck_diameter = "11mm";
neck_height   = "1mm";
bore_diameter = "7mm";
foot_diameter = "3/4inch";

$fn = 32;

module __fcwheel1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

total_height_mm  = togunits1_to_mm(total_height );
neck_diameter_mm = togunits1_to_mm(neck_diameter);
neck_height_mm   = togunits1_to_mm(neck_height  );
bore_diameter_mm = togunits1_to_mm(bore_diameter);
foot_diameter_mm = togunits1_to_mm(foot_diameter);

bot_z = -total_height_mm/2;
top_z =  total_height_mm/2;
nk_z0 = top_z - neck_height_mm;

function make_the_spacer() =
tphl1_make_z_cylinder(
	zrs = togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [            bot_z  , bore_diameter_mm/2]],
		
		["togpath1-rathnode", [            bot_z  , foot_diameter_mm/2], ["round", 1]], // TODO: Min with length of adjacent lines
		if( neck_height_mm > 0 )
		["togpath1-rathnode", [            nk_z0  , neck_diameter_mm/2], ["round", neck_height_mm]],
		["togpath1-rathnode", [            top_z  , neck_diameter_mm/2]],
		["togpath1-rathnode", [            top_z  , bore_diameter_mm/2]],
		
		["togpath1-rathnode", [            bot_z  , bore_diameter_mm/2]],
	], $fn=min(32,$fn)),
	cap_top = false,
	cap_bottom = false
);

togmod1_domodule(make_the_spacer());
