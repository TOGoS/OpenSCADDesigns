// LidHolder-v0.10
// 
// TOGridPile-ish holder for wide mouth mason jar lids,
// assuming that the lids have had stuff added to them
// so they don't just stack on each other anymore.
// 
// Idea: Cut holes in the drywall and stick TOGridPile holders in there rofl
// 
// v0.1:
// - Basic idea
// v0.2:
// - Imperfectize rath-based ovals to avoid CGAL errors
// v0.3:
// - Tunnels, mounting holes, fingerslides, refactoring...
// v0.4:
// - Fill extra space with a grid of holes
// v0.5:
// - Reduce default lip height to 1/16" to avoid having to do v6hc subtractions
// - Finger slots centered relative to lid slot stack instead of block
// v0.6:
// - Fix hack-ass seed delta calculation for filling of extra space;
//   it is still a hack, but works better.
// v0.7:
// - Make $tgx11_offset configurable, default to more conservative -0.2.
// - Note that TGx11.1Lib v11.1.7 fixes a bug in tgx11__get_gender().
// v0.8:
// - Adjust position of 'TGP block body' (the bit that fills in gaps between chunks above the bevel)
//   downward by $tgx11_offset
// v0.9:
// - Inset extra space fillers a little bit
// v0.10:
// - Correct lidslot_height to be 1/4" instead of 1/8",
//   and correct usage to halve it, for same end result

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>

block_size_chunks = [3,3,3];
chunk_pitch = 38.1;

lip_height = 1.5875;

mode = "normal"; // ["normal","end-cb-hole","flanged-tunnel","fingerslot-subtraction"]

// Recommended: -0.1 if subtracting additional during slic1ng, -0.2 otherwise.
$tgx11_offset = -0.2;

module __lh202301__end_paramns() { }

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_size_ca = [for(d=block_size_chunks) [d, "chunk"]];
block_size = togridlib3_decode_vector(block_size_ca);

inch = 25.4;
lidslot_width  = 3.4*inch;
lidslot_height = 1/4*inch;
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
			l*lidslot_pitch - lidslot_height/2,
			neckoff, slotoff, 1
		),
		each lh_shape_wall(
			l*lidslot_pitch + lidslot_height/2,
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
			["translate", [0,0,atom/2+bevel_size - $tgx11_offset], togmod1_make_cuboid([block_size[0]-atom, block_size[1]-atom, atom])]
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


//// Extra space user-upper

eh_wall_thickness = 1;

function is_rect_volume(vol) =
	is_list(vol) && len(vol) == 3 && vol[0] == "rectvolume" &&
	tal1_is_vec_of_num(vol[1], 3) &&
	tal1_is_vec_of_num(vol[2], 3);

function extend_volume(volume, wall_thickness) = ["rectvolume", volume[1], [volume[2][0]+wall_thickness, volume[2][1]+wall_thickness, volume[2][2]]];

function remaining_volumes(volume, subtracted) = [
	// Assuming for now that subtracted is in the bottom-left of volume.
	// Space to fill in +Y?
	if( subtracted[2][1] < volume[2][1] ) ["rectvolume", [volume[1][0], subtracted[2][1], volume[1][2]], volume[2]],
	// Space to fill in +X?
	if( subtracted[2][0] < volume[2][0] ) ["rectvolume", [subtracted[2][0], volume[1][1], volume[1][2]], [volume[2][0], subtracted[2][1], volume[2][2]]],
];

// TODO: seed_deltas is a big stupid hack
// to get a particular arrangement of holes;
// fix to do something more proper.
function make_rectspace_filler(fillers, seed_deltas=[0,1]) =
//echo("make_rectspace_filler", filler_count=len(fillers))
let( spacefiller = function(volume, seed=0)
	assert(is_rect_volume(volume), str("Expected a rectvolume, got ", volume))
	let(vmin = volume[1], vmax=volume[2])
	let(size = vmax-vmin)
	size[1] <= 0 || size[0] <= 0 || size[2] <= 0 ? ["union"] :
	let(filler_index = seed % len(fillers))
	//echo("spacefiller:", vmin=vmin, seed=seed, filler_count=len(fillers), filler_index=filler_index)
	let(filler = fillers[filler_index])
	let(content = filler(volume, seed))
	assert(content[0] == "bounded-vs", str("Expected filler function to return a bounded-vs, but got", content))
	let(filled_volume = content[1])
	let(filled_shape = content[2])
	assert(is_rect_volume(filled_volume), str("Expected bounded-vs[1] to be a rectvolume, but got", content[1]))
	let(rvs = remaining_volumes(volume, extend_volume(filled_volume, eh_wall_thickness)))
	// TODO: for the general case, remaining_volumes needs to know about wall thickness!
	// Assume for now that everything just works up the Y
	["bounded-vs", volume, ["union",
		filled_shape,
		for( rv = rvs )
			// Hack!  Don't adjust seed for +x volumes
			spacefiller(rv, seed+seed_deltas[rv[1][0] > volume[1][0] ? 0 : 1])
	]]
) spacefiller;

function make_rect_hole_space_filler(max_holesize) =
function(volume, seed=1)
	assert(is_rect_volume(volume), str("Expected a rectvolume, got ", volume))
	let(vmin = volume[1], vmax=volume[2])
	let(vsize = vmax-vmin)
	let(usedx = min(vmax[0]-vmin[0], max_holesize[0]))
	let(usedy = min(vmax[1]-vmin[1], max_holesize[1]))
	let(usedvolume=["rectvolume", [vmin[0], vmin[1], vmin[2]], [vmin[0]+usedx, vmin[1]+usedy, vmax[2]]]) // TODO: Don't use all of it
	let(usedsize=(usedvolume[2]-usedvolume[1]))
	let(centerxy=(usedvolume[1]+usedvolume[2])/2)
	let(centertop=[centerxy[0], centerxy[1], vmax[2]])
	//echo(volume=volume, usedvolume=usedvolume, usedsize=usedsize)
	["bounded-vs", usedvolume, ["translate", centertop, togmod1_make_cuboid([usedsize[0], usedsize[1], usedsize[2]*2])]];

eh_fillers = [
	make_rect_hole_space_filler( [100, 7.9375] ),
	make_rect_hole_space_filler( [4,4] ),
];

function flatten_filler_to_list(hf) =
	hf[0] == "bounded-vs" ? flatten_filler_to_list(hf[2]) :
	hf[0] == "union" ? [ for(i=[1:1:len(hf)-1]) each flatten_filler_to_list(hf[i]) ] :
	[hf];

function flatten_filler(hf) = ["union", each flatten_filler_to_list(hf)];
/**
 * Generate subtractions to cut down into an otherwise solid surface
 * volume = ["rectvolume", min, max]
 * Holes will be cut from the top, i.e. p1[2].
 */
// TODO: Replace with fill_space_using
generate_extra_holes = function(volume, seed=0)
	let(shape0 = make_rectspace_filler(eh_fillers)(volume,seed))
	flatten_filler(shape0); // Flatten unions, remove bounds metadata


//// Fingerslot generation

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


//// Main

extra_floor_z = 25.4; // Avoid tunnels
extra_space_width = block_size[0] - min_walthik*3 - lidslot_width;
echo(extra_space_width=extra_space_width);

lidstack_center_x = -block_size[0]/2 + min_walthik+lidslot_width/2;

lidstack_transform = function(s) ["translate", [
	lidstack_center_x,
	0, block_size[2]
], ["rotate", [90,0,0], s]];

tb_thik = (block_size[1] - slotstack_height)/2;
end_cb_hole   = tog_holelib2_hole("THL-1006", depth=tb_thik*2, inset=min(tb_thik-2, 3.175), flange_radius=2, overhead_bore_height=10, $fn=tunnel_fn);

bottom_counterbore_z = 12.7;

bottom_cb_hole = tog_holelib2_hole("THL-1006", depth=bottom_counterbore_z+1, inset=0, overhead_bore_height=block_size[2]/2 - bottom_counterbore_z, $fn=tunnel_fn);

slotstack = make_slotstack(slot_count, slot_oval_size);

function make_fingerslot_subtraction(depth, thickness) =
	let( fingerslot_rath = make_fingerslot_rath(25.4, depth) )
	["rotate", [-90,0,0],
		tphl1_extrude_polypoints([-thickness/2, thickness/2], togpath1_rath_to_points(fingerslot_rath))
	];

if( $preview && mode == "normal" ) togmod1_domodule(["x-debug", lidstack_transform(extended_slotstack_hull)]);

/*extra_space_subtractions = togmod1_make_cuboid([
	// TODO: Something more useful than a big empty rectangle;
	// this is just a placeholder
	extra_space_width, block_size[1]-min_walthik*2, (block_size[2]-extra_floor_z)*2]
);*/

extra_space_size = [extra_space_width, block_size[1]-min_walthik*2, block_size[2]-extra_floor_z];
extra_space_volume = ["rectvolume",
	[-extra_space_size[0]/2, -extra_space_size[1]/2, -extra_space_size[2]],
	[ extra_space_size[0]/2,  extra_space_size[1]/2, 0],
];
/** Relative to the top/center of the extra space */
extra_space_subtractions = ["union",
	togmod1_make_cuboid([
		extra_space_size[0]+0.2,
		extra_space_size[1]+0.2,
		12.7
	]),
	generate_extra_holes(extra_space_volume)
];

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
	], extra_space_subtractions],


	["translate", [lidstack_center_x, 0, block_size[2]+lip_height], make_fingerslot_subtraction(38.1+lip_height, block_size[1]*2, $fn=24)],
					
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
