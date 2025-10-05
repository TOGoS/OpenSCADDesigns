// FCUnipanel0.1
// 
// French cleat + panel as a single part,
// because messing with screws can be annoying.

height = "6chunk";
width = "1chunk";
panel_thickness = "1/8inch";
fc_height = "1+1/2inch";
fc_thickness = "3/4inch";

$tgx11_offset = -0.1;
$fn = 24;

module fcunipanel0__end_params() { }

use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

panel_thickness_mm = togunits1_to_mm(panel_thickness);
fc_thickness_mm = togunits1_to_mm(fc_thickness);
fc_height_mm = togunits1_to_mm(fc_height);
height_mm = togunits1_to_mm(height);
width_mm = togunits1_to_mm(width);

togmod1_domodule(tphl1_make_polyhedron_from_layer_function([
	[0       , 0],
	[width_mm, 0],
],
let( x0 = -panel_thickness_mm )
let( x1 = 0 )
let( x2 = fc_thickness_mm )
let( fcyd0 = 0 )
let( fcyd1 = fc_height_mm )
let( fcydn = fc_height_mm - fc_thickness_mm/2 )
let( fcydf = fc_height_mm + fc_thickness_mm/2 )
let( icops = [["round", -$tgx11_offset], ["offset", $tgx11_offset]] )
let( ocops = [["round", 3.2 + $tgx11_offset], ["offset", $tgx11_offset]] )
let( pcops = [["round", 1.6 + $tgx11_offset], ["offset", $tgx11_offset]] )
function(zo) togvec0_offset_points(
	togpath1_rath_to_polypoints(["togpath1-rath",
		["togpath1-rathnode", [x0, -height_mm/2 + fcyd0], each ocops],
		["togpath1-rathnode", [x2, -height_mm/2 + fcyd0], each ocops],
		["togpath1-rathnode", [x2, -height_mm/2 + fcydf], each pcops],
		["togpath1-rathnode", [x1, -height_mm/2 + fcydn], each icops],
		["togpath1-rathnode", [x1,  height_mm/2 - fcydn], each icops],
		["togpath1-rathnode", [x2,  height_mm/2 - fcydf], each pcops],
		["togpath1-rathnode", [x2,  height_mm/2 - fcyd0], each ocops],
		["togpath1-rathnode", [x0,  height_mm/2 - fcyd0], each ocops],
	]),
	zo[0]
)));
