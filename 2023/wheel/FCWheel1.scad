// FCWheel1.1
// 
// Maybe it can roll along the top of a French cleat?
// 
// v1.1:
// - Copy/pasta from FCWhee0.2

wheel_width      = "3/4inch";
// Outer diameter of wheel in the groove
wheel_diameter   = "2+1/4inch";
// Slope of flange outward from groove
wheel_flanginess = 1;
// Width of flat bottom of outer groove
groove_width     = "2mm";
bearing_diameter = "22mm";
bearing_width    = "7mm";
bearing_lip      = "1mm";

$fn = 128;

module __fcwheel1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

  wheel_diameter_mm = togunits1_to_mm(  wheel_diameter);
  wheel_width_mm    = togunits1_to_mm(  wheel_width   );
 groove_width_mm    = togunits1_to_mm( groove_width   );
bearing_diameter_mm = togunits1_to_mm(bearing_diameter);
bearing_width_mm    = togunits1_to_mm(bearing_width   );
bearing_lip_mm      = togunits1_to_mm(bearing_lip     );

u = 254/160;
wbot_z = -wheel_width_mm/2;
wtop_z =  wheel_width_mm/2;
wgro_r = wheel_diameter_mm/2;
wrim_r = wheel_diameter_mm/2 + wheel_flanginess * (wtop_z-groove_width_mm/2);

btop_z =  bearing_width_mm/2;
bmid_r = bearing_diameter_mm/2;
bbot_z = -bearing_width_mm/2;
bflr_r =  bearing_diameter_mm/2 - bearing_lip_mm;
bsub_z =  bbot_z - 2; // Bottom of floor
bmou_r = bearing_diameter_mm/2 + (wtop_z - btop_z);
bbut_r = bflr_r + (bsub_z - wbot_z);

function make_the_wheel() =
echo(str("Bearing floor hole diameter: ", bflr_r*2))
echo(str("Bearing butt diameter: ", bbut_r*2, ", depth: ", (bsub_z - wbot_z)))
echo(str("Plug min height: ", bbot_z - wbot_z, ", max diameter at bearing: ", bflr_r*2))
tphl1_make_z_cylinder(
	zrs=togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [           wbot_z  , bbut_r]],
		
		["togpath1-rathnode", [           wbot_z  , wrim_r], ["round", u]],
		["togpath1-rathnode", [ -groove_width_mm/2, wgro_r], ["round", groove_width_mm/2]],
		["togpath1-rathnode", [  groove_width_mm/2, wgro_r], ["round", groove_width_mm/2]],
		["togpath1-rathnode", [           wtop_z  , wrim_r], ["round", u]],
		// TODO: The bearing-holding bits
		["togpath1-rathnode", [           wtop_z  , bmou_r]],
		["togpath1-rathnode", [           btop_z  , bmid_r]],
		["togpath1-rathnode", [           bbot_z  , bmid_r]],
		["togpath1-rathnode", [           bbot_z  , bflr_r]],
		["togpath1-rathnode", [           bsub_z  , bflr_r]],
		
		["togpath1-rathnode", [           wbot_z  , bbut_r]],
	], $fn=min(32,$fn)),
	cap_top = false,
	cap_bottom = false
);

togmod1_domodule(make_the_wheel());
