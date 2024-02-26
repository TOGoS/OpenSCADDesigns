// LidHolder-v0.1
// 
// TOGridPile-ish holder for wide mouth mason jar lids,
// assuming that the lids have had stuff added to them
// so they don't just stack on each other anymore.
// 
// - TODO: Bolt holes in sides and back
// - TODO: Offset the lid slots to one side,
//   put small holes for holding random whatevers
//   (twist ties?  pencils?  screws?) along the edge
// - TODO: Maybe finger slots in the top/bottom of the front
// 
// Idea: Cut holes in the drywall and stick TOGridPile holders in there rofl

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>

block_size_chunks = [3,3,3];
chunk_pitch = 38.1;

module __lh202301__end_paramns() { }

$togridlib3_unit_table = tgx11_get_default_unit_table();
$tgx11_offset = -0.1;

block_size_ca = [for(d=block_size_chunks) [d, "chunk"]];
block_size = togridlib3_decode_vector(block_size_ca);

inch = 25.4;
lidslot_width  = 3.4*inch;
lidslot_height = 1/8*inch;
lidslot_neck_width = 2.8*inch;
lidslot_pitch = 3/8*inch;

oval_fn = $preview ? 16 : 72;
tgp_fn  = $preview ? 16 : 72;

function lh_oval_rath(size, offset) =
let( rx=size[0]/2 )
let( ry=size[1]/2 )
let( rr=min(rx,ry) )
["togpath1-rath",
	["togpath1-rathnode", [-rx,-ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [ rx,-ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [ rx, ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [-rx, ry], ["round", rr], ["offset", offset]],
];

function lh_oval_points(size, offset) = togpath1_rath_to_points(lh_oval_rath(size,offset), $fn=oval_fn);

function lh_shape_wall(x, y0, y1, bs) =
let( bsp = y1 > y0 ? bs : -bs )
[
	[x-bs, y0    ],
	[x   , y0+bsp],
	[x   , y1-bsp],
	[x+bs, y1    ]
];

function make_slotstack(slot_count, slot_oval_size) =
let( slotoff=0 )
let( neckoff=(lidslot_neck_width-lidslot_width)/2 )
tphl1_make_polyhedron_from_layer_function([
	for( l=[-slot_count/2+0.5 : 1 : slot_count/2] )	each [
		[(l-0.5)*lidslot_pitch                 , neckoff],
		each lh_shape_wall(
			l*lidslot_pitch - lidslot_height,
			neckoff, slotoff, 1
		),
		each lh_shape_wall(
			l*lidslot_pitch + lidslot_height,
			slotoff, neckoff, 1
		),
		[(l+0.5)*lidslot_pitch                 , neckoff]
	]
], function(lp) [
	for( p=lh_oval_points(slot_oval_size, lp[1]) ) [p[0], p[1], lp[0]]
]);

min_walthik = 3/16*inch;

slot_count = floor((block_size[2] - min_walthik*2) / lidslot_pitch);

walthik = (block_size[0] - lidslot_width)/2;

slot_oval_size = [lidslot_width, block_size[2]*2 - walthik*2];

r_slotstack = ["render", make_slotstack(slot_count, slot_oval_size)];

// Based on tgx11_block
function lh_block(block_size_ca, bottom_shape="footed", lip_height=2.54, atom_bottom_subtractions=[]) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_chunks = togridlib3_decode_vector(block_size_ca, unit=[1, "chunk"]))
let(chunk_xms = [-block_size_chunks[0]/2+0.5 : 1 : block_size_chunks[0]/2])
let(chunk_yms = [-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2])
let($tgx11_gender = tgx11__get_gender())
let(chunk_foot = tgx11_chunk_unifoot([chunk_pitch,chunk_pitch,block_size[2]+lip_height*2]))
let(atom = togridlib3_decode([1,"atom"]))
let(bevel_size = togridlib3_decode([1,"tgp-standard-bevel"]))
// TODO: Taper top and bottom all cool?
["difference",
	["intersection",
		// X/Y and +Z hull
		tphl1_extrude_polypoints([-1,block_size[2]+lip_height], tgx11_chunk_xs_points(
			size = block_size,
			offset = $tgx11_offset
		)),
		["union",
			// Feet
			for(xm=chunk_xms) for(ym=chunk_yms) ["translate", [xm, ym, 0]*chunk_pitch, chunk_foot],
			// Chunk body so that corners between feet aren't so deep
			["translate", [0,0,atom/2+bevel_size], togmod1_make_cuboid([block_size[0]-atom, block_size[1]-atom, atom])]
		],
	],
	
	if( len(atom_bottom_subtractions) > 0 )
	let( atom_bottom_subtraction = ["union", each atom_bottom_subtractions] )
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_bottom_subtraction],
	
	if( lip_height > 0 ) ["translate", [0,0,block_size[2]],
		tgx11_chunk_unifoot([block_size[0],block_size[1],chunk_pitch],
			$tgx11_offset=-$tgx11_offset, $tgx11_gender=tgx11__invert_gender($tgx11_gender))],
];

extra_space_width = block_size[0] - min_walthik*3 - lidslot_width;
echo(extra_space_width=extra_space_width);

togmod1_domodule(["difference",
	lh_block(block_size_ca, $tgx11_gender = "m", $fn=tgp_fn),
	//["translate", [0,0,block_size[2]/2], togmod1_make_cuboid(block_size)],

	// Lid slot stack
	["translate", [
		-block_size[0]/2 + min_walthik+lidslot_width/2,
		0, block_size[2]
	], ["rotate", [90,0,0], r_slotstack]],

	// Extra space
	["translate", [
		block_size[0]/2 - min_walthik - extra_space_width/2,
		0, block_size[2]
	], togmod1_make_cuboid([
		// TODO: Something more useful than a big empty rectangle;
		// this is just a placeholder
		extra_space_width, block_size[1]-min_walthik*2, (block_size[2]-min_walthik*2)*2]
	)]
]);

//togmod1_domodule(slotstack);
