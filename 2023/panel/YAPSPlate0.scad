// YAPSPlate0.1
// 
// Yet Another Power Strip Panel
// 
// Let's librarify the latticey stuff as implemented
// by WSTYPE201630Plate1 and FHTVPSPlate1.
// 
// v0.1:
// - Demonstrate the new library
// - Not a useful thing, yet.

panel_size = ["3chunk","3chunk"];

$fn = 36;
$tgx11_offset = -0.1;

module __yafsplate1__end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGridLatticeLib0.scad>

panel_size_mm = togunits1_vec_to_mms(panel_size);
panel_thickness_mm = 6.35;
$togridlib3_unit_table = tgx11_get_default_unit_table();

togmod1_domodule(["difference",
	togmod1_linear_extrude_z([0, panel_thickness_mm], togmod1_make_rounded_rect(panel_size_mm, r=6.35)),
	
	togmod1_linear_extrude_z([panel_thickness_mm-1.6, panel_thickness_mm+1],
		togridlatticelib0_make_upper_2d([panel_size_mm[0] - 3.175, panel_size_mm[1] - 3.175], $tgx11_offset=-$tgx11_offset)
	),
	
	togmod1_linear_extrude_z([-1, panel_thickness_mm+2],
		togridlatticelib0_make_lower_2d([panel_size_mm[0] - 6.35, panel_size_mm[1] - 6.35], $tgx11_offset=-$tgx11_offset)
	),
]);
