// LEDChannelClip1.2
// 
// To hold the extruded aluminium 'LED strip channels'
// against a gridbeam or other surface.
// 
// Product page (no longer available as of 2024): https://www.amazon.com/dp/B0773LDWHC
// 'uxcell LED Strip Channel - 1M/3.28FT LED Aluminum Channel with
// Milky Cover for LED Flexible Light Strip Mounting- 10 Packs(
// CN502,1mx14.9mmx8.6mm)'
// 
// Changes;
// v1.2:
// - Add 'square1' mode

mode = "single"; // ["single","double","square1"]

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

narrow_hull_width = 19.05;
single_channel_pos_x = narrow_hull_width+channel_width/2+channel_x_adjust;
double_hull_length = 50.8;
single_hull_length = ceil((single_channel_pos_x + channel_width/2+1)/12.7)*12.7;

hull_size =
	mode == "double" ? [double_hull_length, narrow_hull_width, 12.7] :
	mode == "single" ? [single_hull_length, narrow_hull_width, 12.7] :
	mode == "square1" ? [38.1, narrow_hull_width, 38.1] :
	assert(false, str("Unrecognized mode: '", mode, "'"));

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
function make_the_cutout(w,h) = ["rotate", [90,0,0], tphl1_make_polyhedron_from_layer_function([
	each lcc__flange_zds(-hull_size[1]/2-0.1, 0, 3.175, -1),
	each lcc__flange_zds( hull_size[1]/2+0.1, 0, 3.175,  1),
], function(funk)
	rect_points([w+funk[1], h+funk[1]], funk[0])
)];

hole1 = tog_holelib2_hole(hole1_type, depth=hull_size[2]+1);
hole2 = tog_holelib2_hole(hole2_type, depth=hull_size[2]+1);

hole_offset_x = (hull_size[0]-hull_size[1])/2;

single_thing = ["difference",
	["translate", [0, 0, hull_size[2]/2], the_hull],
	["translate", [-hull_size[0]/2+single_channel_pos_x, 0, hull_size[2]], make_the_cutout(channel_width, channel_height*2)],
	["translate", [-hole_offset_x, 0, 0], ["rotate", [180,0,0], hole1]],
];

double_thing = ["difference",
	["translate", [0, 0, hull_size[2]/2], the_hull],
	["translate", [0, 0, hull_size[2]], make_the_cutout(channel_width, channel_height*2)],
	["translate", [-hole_offset_x, 0, 0], ["rotate", [180,0,0], hole1]],
	["translate", [ hole_offset_x, 0, 0], ["rotate", [180,0,0], hole2]],
];

function make_square1_thing() = ["translate", [0,0,hull_size[1]/2], ["rotate", [90,0,0], ["difference",
	tphl1_make_rounded_cuboid(hull_size, r=[3.2,3.2,3.2], corner_shape="ovoid1"),
	make_the_cutout(channel_width, 25.4),
	["translate", [-hull_size[0]/2, 0, 0], ["rotate", [0,-90,0], hole1]],
]]];

togmod1_domodule(
	mode == "single" ? single_thing :
	mode == "double" ? double_thing :
	mode == "square1" ? make_square1_thing() :
	assert(false, str("Unrecognized mode: '", mode, "'"))
);
