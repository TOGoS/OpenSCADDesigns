// LidHolder-v0.3
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
// 
// v0.1:
// - Basic idea
// v0.2:
// - Imperfectize rath-based ovals to avoid CGAL errors
// v0.3:
// - Tunnels, mounting holes, fingerslides, refactoring...

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>

block_size_chunks = [3,3,3];
chunk_pitch = 38.1;

lip_height = 2.54;

mode = "normal"; // ["normal","end-cb-hole","flanged-tunnel","fingerslot-subtraction"]

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
tunnel_fn = $preview ? 16 : 24;

function lh_oval_rath(size, offset) =
let( rx=size[0]/2 )
let( ry=size[1]/2 )
let( rr=min(rx,ry)-1 ) // That minus one helps prevent CGAL errors
["togpath1-rath",
	["togpath1-rathnode", [-rx,-ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [ rx,-ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [ rx, ry], ["round", rr], ["offset", offset]],
	["togpath1-rathnode", [-rx, ry], ["round", rr], ["offset", offset]],
];

function lh_oval_points(size, offset=0) = togpath1_rath_to_points(lh_oval_rath(size,offset), $fn=max($fn, oval_fn));

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
	// [(-slot_count/2)*lidslot_pitch                 , neckoff],
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
	],
	[(slot_count/2)*lidslot_pitch                 , neckoff],
], function(lp) [
	for( p=lh_oval_points(slot_oval_size, lp[1]) ) [p[0], p[1], lp[0]]
]);

min_walthik = 3/16*inch;

slot_count = floor((block_size[2] - min_walthik*3) / lidslot_pitch);

// Thicker in the backbottom so we can put more crap down there
slot_floor_z = 19.05;
slot_oval_size = [lidslot_width, block_size[2]*2 - slot_floor_z*2];

slotstack_height = slot_count*lidslot_pitch;

// Fer seein where the edges are
extended_slotstack_hull = tphl1_extrude_polypoints([-block_size[1]/2-1, block_size[1]/2+1], lh_oval_points(slot_oval_size, $fn=64));

// Based on tgx11_block
function lh_block(block_size_ca, bottom_shape="footed", lip_height=lip_height, atom_bottom_subtractions=[]) =
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

function lh__flange_zds(z, d, flange_radius, end=1) =
//let(_flangefn = flange_radius == 0 ? 0 : max(1,round(min(flange_radius,$fn/4)))) // At most one segment per mm
let(_flangefn = 16)
_flangefn > 0 ? [
	for( am=[0 : 1 : _flangefn] ) let( a=(end == -1 ? -90 : 0) + 90*am/_flangefn) [
		z + (sin(a) - end) * flange_radius,
		d + (1 - cos(a)) * flange_radius * 2,
	]
] : [z, d];

function lh__tunnel(d, zrange, flange_radius=3, end_offset=10) =
tphl1_make_z_cylinder(zds=[
	[zrange[0]-end_offset, d+flange_radius*2],
	each lh__flange_zds(zrange[0], d, flange_radius, end=-1),
	each lh__flange_zds(zrange[1], d, flange_radius, end=+1),
	[zrange[1]+end_offset, d+flange_radius*2],
]);

extra_floor_z = 25.4; // Avoid tunnels
extra_space_width = block_size[0] - min_walthik*3 - lidslot_width;
echo(extra_space_width=extra_space_width);

lidstack_transform = function(s) ["translate", [
	-block_size[0]/2 + min_walthik+lidslot_width/2,
	0, block_size[2]
], ["rotate", [90,0,0], s]];

tb_thik = (block_size[1] - slotstack_height)/2;
end_cb_hole   = tog_holelib2_hole("THL-1006", depth=tb_thik*2, inset=min(tb_thik-2, 3.175), flange_radius=2, overhead_bore_height=10, $fn=tunnel_fn);

bottom_counterbore_z = 12.7;

bottom_cb_hole = tog_holelib2_hole("THL-1006", depth=bottom_counterbore_z+1, inset=0, overhead_bore_height=block_size[2]/2 - bottom_counterbore_z, $fn=tunnel_fn);

slotstack = make_slotstack(slot_count, slot_oval_size);

function make_fingerslot_rath(width, depth=undef, y0=0) =
let(_depth = is_undef(depth) ? width*2 : depth)
assert(_depth > width) // Otherwise will need to adjust rop more
let(zN = 0 + y0 - width)
let(z0 = 0 + y0)
let(zP = 0 + depth)
let(rop = ["round", width/2.5])
["togpath1-rath",
	["togpath1-rathnode", [-width*1.5, z0]],
	["togpath1-rathnode", [-width*1.5, zN]],
	["togpath1-rathnode", [ width*1.5, zN]],
	["togpath1-rathnode", [ width*1.5, z0]],
	["togpath1-rathnode", [ width*0.5, z0], rop],
	["togpath1-rathnode", [ width*0.5, zP], rop],
	["togpath1-rathnode", [-width*0.5, zP], rop],
	["togpath1-rathnode", [-width*0.5, z0], rop],
];

fingerslot_rath = make_fingerslot_rath(25.4, 38.1, y0=-lip_height);
fingerslot_subtraction = ["translate", [0,0,block_size[2]], ["rotate", [-90,0,0],
	tphl1_extrude_polypoints([-block_size[1], block_size[1]], togpath1_rath_to_points(fingerslot_rath, $fn=24))
]];

if( $preview && mode == "normal" ) togmod1_domodule(["x-debug", lidstack_transform(extended_slotstack_hull)]);

main =
mode == "flanged-tunnel" ? lh__tunnel(5/16*inch, [-25.4, 25.4], flange_radius=2, $fn=tunnel_fn) :
mode == "end-cb-hole" ? end_cb_hole :
mode == "fingerslot-subtraction" ? fingerslot_subtraction :
mode == "normal" ? ["difference",
	lh_block(block_size_ca, $tgx11_gender = "m", $fn=tgp_fn),
	//["translate", [0,0,block_size[2]/2], togmod1_make_cuboid(block_size)],

	// Lid slot stack
	lidstack_transform(["render", slotstack]),

	// End holes
	for( ym=[-1,1] )
	for( zm=[1.5 : 1 : block_size_chunks[2]-1] )
		["translate", [0, ym*(block_size[1]/2-tb_thik-0.01), zm*chunk_pitch], ["rotate", [ym*90,0,0], end_cb_hole]],
	
	// Bottom hole
	for( ym=[-block_size_chunks[1]/2+0.5 : 1 : block_size_chunks[1]/2] )
		["translate", [0, ym*chunk_pitch, bottom_counterbore_z], bottom_cb_hole],

	// Extra space
	["translate", [
		block_size[0]/2 - min_walthik - extra_space_width/2,
		0, block_size[2]
	], togmod1_make_cuboid([
		// TODO: Something more useful than a big empty rectangle;
		// this is just a placeholder
		extra_space_width, block_size[1]-min_walthik*2, (block_size[2]-extra_floor_z)*2]
	)],
	
	fingerslot_subtraction,
					
	// Y-holes
	for( tunnel=[
		[[-block_size[0]/2 + chunk_pitch/2, 0, chunk_pitch/2], 5/16*inch],
		[[ block_size[0]/2 - chunk_pitch/2, 0, chunk_pitch/2], 5/16*inch],
	]) let(pos=tunnel[0], d=tunnel[1])
	["translate", pos, ["rotate", [90,0,0],
		lh__tunnel(d, [-block_size[1]/2, block_size[1]/2], $fn=tunnel_fn)]]
] :
assert(false, str("Bad mode: '", mode, "'"));

togmod1_domodule(main);

//togmod1_domodule(slotstack);
