// LEDStripBeam1.0
// 
// Gridrail with:
// - One flat edge
// - Holes for both bolts and for T-nuts
// - Grooves for wires and/or string

length_chunks = 5;
flat_edge_inset = 3.175;
hull_offset = -0.05;
bowtie_offset = -0.075;
$fn = 24;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

use <./RoundBowtie0.scad>

$togridlib2_unit_table = tgx11_get_default_unit_table();


// Given a *convex* 2D shape, make a 3D shape that's wider at the base in the +z direction,
// to make cuts that are 'printable'.
// To translate to Y, rotate [90,0,0] and scale [1,-1,1].
function ledstribeam1_wedgie_z(zrange, slope, shape2d) =
["hull",
	togmod1_linear_extrude_z([-0.5, zrange[1]], shape2d),
	togmod1_linear_extrude_z([-1, zrange[0]], shape2d),
	togmod1_linear_extrude_z([-1, zrange[0]], ["translate", [0,(zrange[1]-zrange[0])*slope,0], shape2d]),
];

function ledstripbeam1_make_beam(
	length_ca = [5, "chunk"],
	hull_offset = 0,
	bowtie_cutout_offset = 0,
	groove_depth = 3.175
) =
let(size_ca = [length_ca, [12, "u"], [24, "u"]])
let(size = togridlib3_decode_vector(size_ca))
let(length_chunks = round(togridlib3_decode(size_ca[0], unit=[1, "chunk"])))
let(wedgified_cutouts_2d = [
	togmod1_make_circle(d=16),
	["rotate", [0,0, 45], togmod1_make_rect([4, togridlib3_decode([2, "chunk"])])],
	["rotate", [0,0,-45], togmod1_make_rect([4, togridlib3_decode([2, "chunk"])])],
	togmod1_make_rect([4, togridlib3_decode([2, "chunk"])]),
])
let( interchunk_side_cutout = ["union",
	for(ym=[-1,1]) ["scale", [1,ym,1],
		//["translate", [0,-size[1]/2,0], togmod1_linear_extrude_y([-groove_depth, groove_depth], togmod1_make_circle(d=16))]
		//["translate", [0,size[1]/2,0], ["rotate", [90,0,0], ledstribeam1_wedgie_z([-0.01, flat_edge_inset], 1, togmod1_make_circle(d=16))]]
		["translate", [0,size[1]/2,0], ["rotate", [90,0,0], ["union",
			for( shape2d = wedgified_cutouts_2d ) ledstribeam1_wedgie_z([-0.01, flat_edge_inset], 1, shape2d)
		]]],
	],
])
// TODO: Would be nice to round the top grooves down at the sides
let( interchunk_cutout = ["union",
	togmod1_linear_extrude_y([-size[1],size[1]], togmod1_make_circle(d=4.5)),
	["translate", [0,0,size[2]/2], togmod1_linear_extrude_y([-size[1],size[1]], togmod1_make_rounded_rect([4,3], r=0))],
])
let( chunk_cutout = ["union",
	togmod1_linear_extrude_y([-size[1],size[1]], togmod1_make_circle(d=8)),
	["translate", [0,0,size[2]/2], togmod1_linear_extrude_y([-size[1],size[1]], togmod1_make_rounded_rect([9,6.34], r=2))],
])
let( bowtie_cutout = ["union",
	togmod1_linear_extrude_z([-size[2], size[2]], roundbowtie0_make_bowtie_2d(6.35, offset=-bowtie_offset)),
	["translate", [0,0,size[2]/2], togmod1_make_cuboid([38.1,25.4,6.35])],
])
["difference",
	tphl1_make_rounded_cuboid([size[0]+hull_offset*2, size[1]+hull_offset*2, size[2]+hull_offset*2], r=3),
	
	["translate", [0,0,-size[2]/2], togmod1_make_cuboid([size[0]*2, size[1]*2, flat_edge_inset*2])],
	for( xm=[-length_chunks/2+1 : 1 : length_chunks/2-1] ) ["translate", [togridlib3_decode([xm,"chunk"]), 0, 0], interchunk_side_cutout],
	for( xm=[-length_chunks/2+1 : 1 : length_chunks/2-1] ) ["translate", [togridlib3_decode([xm,"chunk"]), 0, 0], interchunk_cutout],
	for( xm=[-length_chunks/2+0.5 : 1 : length_chunks/2-0.5] ) ["translate", [togridlib3_decode([xm,"chunk"]), 0, 0], chunk_cutout],
	for( x=[-size[0]/2, size[0]/2] ) ["translate", [x,0,0], bowtie_cutout],
];

togmod1_domodule(ledstripbeam1_make_beam(
	length_ca = [length_chunks, "chunk"],
	hull_offset = hull_offset,
	bowtie_cutout_offset = bowtie_offset
));
