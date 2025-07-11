// SmallPanelClip0.1
// 
// Clip for holding small panels, like TOGRack2 panels, together

//panel_thickness = "4u";
//panel_gap = "2u";
width = "4u";

module smallpanelclip0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>

function reverse_list(list, mapping=function(item) item) = [for(i=[len(list)-1 : -1 : 0]) mapping(list[i])];

function mirror_points_r_to_l(points) = reverse_list(points, function(p) [-p[0],  p[1]]);
function mirror_points_t_to_b(points) = reverse_list(points, function(p) [ p[0], -p[1]]);

function extrapolate_tr(points) =
	let( top = [each points, each mirror_points_r_to_l(points)] )
	[each top, each mirror_points_t_to_b(top)];

u = 254/160;

width_mm = togunits1_to_mm(width);

togmod1_domodule(togmod1_linear_extrude_z([0,width_mm],togmod1_make_polygon(extrapolate_tr([
	[1*u - 0.1, 2*u+0.2],
	[3*u - 0.1, 2*u-0.1],
	[4*u - 0.1, 2*u+0.2],
	[4*u - 0.1, 4*u-0.1],
]))));
