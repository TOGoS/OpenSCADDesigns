// LuckyLeafPackHolder0.1
// 
// Box measurements: 43mm wide, 88mm tall, 17mm thick
// 
// I want something that a pack will fit into to protect it in transit.

pack_size = [43, 17, 88];
$tgx11_offset = -0.1;
$fn = 48;

module luckyleafpackholder0__end_params() { }

cavity_size = [for(d=pack_size) d+0.5];
min_holder_size = [cavity_size[0]+3, cavity_size[1]+3, cavity_size[2]+6.35];
holder_size_ca = [for(d=min_holder_size) [ceil(d/12.7), "atom"]];

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TGx11.1Lib.scad>

function double_height(aabb) = [aabb[0], aabb[1], aabb[2]*2];

inch = 25.4;
u = inch/16;

echo(holder_size_ca = holder_size_ca);

$togridlib3_unit_table = tgx11_get_default_unit_table();

let(holder_size = togridlib3_decode_vector(holder_size_ca))
let(finger_notch = togmod1_linear_extrude_y([-holder_size[1], holder_size[1]], togmod1_make_rounded_rect([0.75*inch, 1.5*inch], r=3/8*inch)))
togmod1_domodule(["difference",
	tgx11_block(holder_size_ca, lip_height=u, top_segmentation="block"),
	//["translate", [0,0,holder_size[2]/2], togmod1_make_cuboid(holder_size)],
	["translate", [0,0,holder_size[2]], togmod1_make_cuboid(double_height(cavity_size))],
	["translate", [0,0,holder_size[2]], finger_notch],
]);
