// LEDChannelClip
// 
// To hold the extruded aluminium 'LED strip channels'
// against a gridbeam or other surface.
// 
// Product page (no longer available as of 2024): https://www.amazon.com/dp/B0773LDWHC
// 'uxcell LED Strip Channel - 1M/3.28FT LED Aluminum Channel with
// Milky Cover for LED Flexible Light Strip Mounting- 10 Packs(
// CN502,1mx14.9mmx8.6mm)'

mode = "single"; // ["single","double"]

hole1_type = "THL-1002";
hole2_type = "THL-1001";

channel_x_adjust = -3.175;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? 16 : 64;

channel_width  = 16;
channel_height =  9;

hull_width = 19.05;
single_channel_pos_x = hull_width+channel_width/2+channel_x_adjust;
hull_length = mode == "double" ? 50.8 : ceil((single_channel_pos_x + channel_width/2+1)/12.7)*12.7;

hull_size = [hull_length, hull_width, 12.7];

echo(hull_size=hull_size);

the_hull = tphl1_make_rounded_cuboid(hull_size, r=[6.3,6.3,1.6], corner_shape="ovoid1");

function rect_points(size, z) =
let( x0=-size[0]/2, x1=size[0]/2, y0=-size[1]/2, y1=size[1]/2 )
[
	[x0, y0, z],
	[x1, y0, z],
	[x1, y1, z],
	[x0, y1, z],
];

function lcc__flange_zds(z, d, flange_radius, end=1) =
let(_flangefn = max(2, round($fn/4)))
_flangefn > 0 ? [
	for( am=[0 : 1 : _flangefn] ) let( a=(end == -1 ? -90 : 0) + 90*am/_flangefn) [
		z + (sin(a) - end) * flange_radius,
		d + (1 - cos(a)) * flange_radius * 2,
	]
] : [z, d];

//the_cutout = togmod1_make_cuboid([channel_width, hull_size[1]*2, channel_height*2]);
the_cutout = ["rotate", [90,0,0], tphl1_make_polyhedron_from_layer_function([
	each lcc__flange_zds(-hull_width/2-0.5, 0, 3.175, -1),
	each lcc__flange_zds( hull_width/2+0.5, 0, 3.175,  1),
], function(funk)
	rect_points([channel_width + funk[1], channel_height*2+funk[1]], funk[0])
)];

hole1 = tog_holelib2_hole(hole1_type, depth=hull_size[2]+1);
hole2 = tog_holelib2_hole(hole2_type, depth=hull_size[2]+1);

hole_offset_x = (hull_size[0]-hull_size[1])/2;

single_thing = ["difference",
	["translate", [0, 0, hull_size[2]/2], the_hull],
	["translate", [-hull_size[0]/2+single_channel_pos_x, 0, hull_size[2]], the_cutout],
	["translate", [-hole_offset_x, 0, 0], ["rotate", [180,0,0], hole1]],
];

double_thing = ["difference",
	["translate", [0, 0, hull_size[2]/2], the_hull],
	["translate", [0, 0, hull_size[2]], the_cutout],
	["translate", [-hole_offset_x, 0, 0], ["rotate", [180,0,0], hole1]],
	["translate", [ hole_offset_x, 0, 0], ["rotate", [180,0,0], hole2]],
];

togmod1_domodule(
	mode == "single" ? single_thing :
	mode == "double" ? double_thing :
	assert(false, str("Unrecognized mode: '", mode, "'"))
);
