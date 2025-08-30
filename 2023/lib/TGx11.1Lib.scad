// TGx11.1Lib - v11.1.20
// 
// Attempt at re-implementation of TGx9 shapes
// using TOGMod1 S-shapes and cleaner APIs with better defaults.
// 
// TODO: v6gc should be:
// - For the male case: narrower; find out what the equivalent outer bevel
//   of 'v6.0' style is and use that
// 
// Changes:
// v11.1.7
// - Fix tgx11__get_gender() to return $tgx11_gender if defined
// v11.1.8:
// - tgx11_block uses tgx11__get_gender() and tgx11__invert_gender() functions
//   instead of hardcoding 'm' and 'f'.
// - Refactor block body placement to be a little more explicit
//   and maybe more 'correct', also (stopping at exectly the point
//   where the bevels meet)
// v11.1.9:
// - Update reference to togpath1_qath_to_polypoints
// v11.1.10
// - Fix unifoot generation for short blocks
// v11.1.11:
// - tgx11_atomic_block_bottom takes atom size into account for v6hcs,
//   which might screw up some designs that were (ab)using it to make
//   chunk-segmented bottoms!
// v11.1.12:
// - Add support for foot segmentation="chatom"
// v11.1.13:
// - Add tgx11_block_bottom, which supports 'block', 'atom', or 'chatom' foot styles
// v11.1.14:
// - Fix to use chunk_xms/yms instead of atom_xms/yms for chatomic feet
// v11.1.15:
// - Support segmentation = "chunk"
// - Support v6hc_style = "none"
// v11.1.16:
// - Refactor a couple of expressions to use temporary variables
//   (this can help with debugging, sometimes)
// - Remove an echo
// v11.1.17:
// - tgx11_block_bottom will assume gender="m", same as tgx11_block does
// v11.1.18:
// - [bottom_]foot_bevel option to put a small bevel at the bottom of foot columns.
//   This may be useful to help blocks slide into baseplates or
//   to compensate for overly squished-down (and out) first layers of FDM prints.
// - Fix that segmentation = "none" was not handled properly by tgx11_block_bottom
// v11.1.19:
// - Don't try to bevel corners when rounding radius would make it impossible;
//   this allows for round atom bottoms by setting rounding radius to a large value
// v11.1.20:
// - Why am I not allowed to increment the middle number lmao.  Anyway,
// - tgx11_block accepts top_v6hc_style, defaulting to "v6.1", as before
// - tgx11_block accepts top_shape, defaulting to bottom_shape, as before
// - tgx11_block interprets negative lip height as a block that's male on the top;
//   previously negative lip heights just truncated the block,
//   which is not especially useful.
// - Fix 'Unrecognized v6hc_style' error message, which previously and
//   erroneously indicated 'bottom_shape' as the problem

module __tgx11lib_end_params() { }

use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGridLib3.scad>

//// 

function tgx11_ath_to_polygon(thing, offset=0) =
	togmod1_make_polygon(
		thing[0] == "togpath1-qath" ? togpath1_qath_to_polypoints(thing, offset=offset) :
		thing[0] == "togpath1-zath" ? togpath1_zath_to_polypoints(thing, offset=offset) :
		assert(false, str("Unrecognized object: ", thing))
	);

function tgx11__gnerate_beveled_rect_data(bevels=[true,true,true,true]) =
let(z41 = sqrt(2)-1) [
	each bevels[0] ? [
		[[ 1, 1], [ 0,-1], [   1,  z41]],
		[[ 1, 1], [-1, 0], [ z41,    1]],
	] : [
		[[ 1, 1], [ 0, 0], [   1,    1]],
	],
	each bevels[1] ? [
		[[-1, 1], [ 1, 0], [-z41,    1]],
		[[-1, 1], [ 0,-1], [-  1,  z41]],
	] : [
		[[-1, 1], [ 0, 0], [-  1,    1]],
	],
	each bevels[2] ? [
		[[-1,-1], [ 0, 1], [-  1, -z41]],
		[[-1,-1], [ 1, 0], [-z41, -  1]],
	] : [
		[[-1,-1], [ 0, 0], [-  1, -  1]],
	],
	each bevels[3] ? [
		[[ 1,-1], [-1, 0], [ z41, -  1]],
		[[ 1,-1], [ 0, 1], [   1, -z41]],
	] : [
		[[ 1,-1], [ 0, 0], [   1, -  1]],
	]
];

// TODO: Just use togpath1_points_to_zath!
function tgx11_beveled_rect_zath(size, bevel_size, bevels=[true,true,true,true]) =
assert(is_list(size))
assert(is_num(size[0]))
assert(is_num(size[1]))
assert(is_num(bevel_size))
let( data = tgx11__gnerate_beveled_rect_data(bevels) )
[
	"togpath1-zath",
	
	for( d=data ) [
		[
			d[0][0]*size[0]/2 + d[1][0] * bevel_size,
			d[0][1]*size[1]/2 + d[1][1] * bevel_size
		],
		d[2]
	]
];

//// TOGridPile-specific stuff

//// Low-level operations requiring explicit offset and gender
//// (but still reading from $togridlib3_unit_table)

// Height of the straight part at the bottom of blocks,
// or thickness of 'column-only' plates/lips:
function tgx11__bare_column_height() =
	togridlib3_decode([1, "tgp-standard-bevel"]) - 
	togridlib3_decode([1, "tgp-column-inset"]);

/**
 * Returns radius for corners for the given gender
 * at the given offset from the 'ideal' chunk hull
 */
function tgx11__corner_radius(offset, gender) =
	assert(is_num(offset))
	assert(is_string(gender))
	max(
		togridlib3_decode([1, gender == "m" ? "tgp-min-m-corner-radius" : "tgp-min-f-corner-radius"]),
		togridlib3_decode([1, gender == "m" ? "tgp-m-outer-corner-radius" : "tgp-f-outer-corner-radius"]) + offset
	);

function tgx11_chunk_xs_zath(size, gender, bevels=undef) =
	// Cleverly skip beveling corners by default if rounding radius sufficiently large:
	let( rounding_radius = tgx11__corner_radius(offset=0,gender=gender) )
	let( bevel_size = togridlib3_decode([1, "tgp-standard-bevel"]) )
	let( default_bevel = rounding_radius < bevel_size * 1.707 )
	let( _bevels1 = is_undef(bevels) ? [undef,undef,undef,undef] : bevels )
	let( _bevels2 = [for(b=_bevels1) is_undef(b) ? default_bevel : b] )
	tgx11_beveled_rect_zath(size, bevel_size=togridlib3_decode([1,"tgp-standard-bevel"]), bevels=_bevels2);

function tgx11_chunk_xs_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
	tgx11_chunk_xs_zath(size, gender=gender),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender)
);

function tgx11_chunk_xs_half_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
	tgx11_chunk_xs_zath(size, gender=gender, bevels=[false,undef,undef,false]),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender),
	closed=false
);

/**
 * 'chunk cross-section points'
 *
 * Returns points for a rounded, beveled rectangle
 * of the standard bevel size and radius, given
 * the specified offset.
 */
function tgx11_chunk_xs_points(size, gender="m", offset=0) =
	assert( is_list(size) && is_num(size[0]) && is_num(size[1]) )
	let( qath = tgx11_chunk_xs_qath(size, gender=gender, offset=offset) )
	togpath1_qath_to_polypoints(qath);

// v6 atom foot cross-section
function tgx11_v6c_polygon(atom_size, gender="m", offset=0) = // tgx11_ath_to_polygon(tgx11_atom_foot_qath(atom_size, gender=gender, offset=offset));
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	togmod1_make_polygon(tgx11_chunk_xs_points(atom_size, gender=gender, offset=offset-column_inset));

// v6 atom foot, but right side is flat instead of beveled and rounded
function tgx11_v6c_flatright_polygon(atom_size, gender="m", offset=0) =
	let( column_inset = togridlib3_decode([1,"tgp-column-inset"]) )
	let( offset = offset-column_inset )
	togmod1_make_polygon([
		[atom_size[0]/2+offset,  atom_size[1]/2+offset],
		each togpath1_qath_to_polypoints(tgx11_chunk_xs_half_qath(atom_size, gender=gender, offset=offset)),
		[atom_size[0]/2+offset, -atom_size[1]/2-offset],
	]);

//// Higher-level TOGridPile shapes; offset, gender passed implicitly
// Maybe I should differentiate by making these tgx12, tgx13 ha ha lmao

// Declare defaults:
// Actually lol don't because if these are specified here,
// they override those passed directly to modules, which defetats the purpose.
// If we want defaults, need to make a function like tgx11__get_offset() = is_undef($tgx11_offset) ? ....
//$tgx11_offset = 0;
//$tgx11_gender = "m";

/**
 * Generate a polyhedron with TOGridPile rounded beveled rectangle cross-sections
 * for each [z, offset] in layer_keys.
 */
function tgx11__chunk_footlike(layer_keys, size) =
	assert( is_list(size) && is_num(size[0]) && is_num(size[1]) )
	tphl1_make_polyhedron_from_layer_function(layer_keys, function(zo)
		let( points = tgx11_chunk_xs_points(size, gender=$tgx11_gender, offset=zo[1]) )
		[for (p=points) [p[0], p[1], zo[0]]]
	);

/*
 * A beveled (no column) chunk bottom that extends beyond the chunk (to be intersected).
 */
function tgx11_chunk_foot(size) =
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	let( height = max(size[2], 8*u+3/32) )
	tgx11__chunk_footlike([
		[0*u - offset    , -2*u + offset*z41],
		[4*u - offset*z41,  2*u + offset],
		[height          ,  2*u + offset]
	], size=size);

/*
 * A footed chunk bottom that extends beyond the chunk (to be intersected).
 */
function tgx11_chunk_unifoot(size, foot_bevel=0) =
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	let( height = max(size[2], 8*u+3/32) )
	tgx11__chunk_footlike([
		[0*u - offset    , -1*u + offset - foot_bevel],
		if( foot_bevel > 0 ) [0*u - offset + foot_bevel, -1*u + offset],
		[1*u - offset*z41, -1*u + offset],
		[4*u - offset*z41,  2*u + offset],
		[height          ,  2*u + offset]
	], size=size);

function tgx11_chunk_column(size, foot_bevel=0) =
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	let( height = max(size[2], 8*u+3/32) )
	tgx11__chunk_footlike([
		[0*u - offset    , -1*u + offset - foot_bevel],
		if( foot_bevel > 0 ) [0*u - offset + foot_bevel, -1*u + offset],
		[height          , -1*u + offset]
	], size=size);


/**
 * 'atomic' foot shape + enough solid stuff above to fully fill the rest of the block and goa bit beyond.
 * Intended to be intersected with a block hull that is no larger than block_size
 */
function tgx11_atomic_block_bottom(
	block_size_ca,
	bottom_shape = "footed",
	segmentation = "atom",
	v6hc_style = "v6.1",
	foot_bevel = 0
) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(block_size_chunks = togridlib3_decode_vector(block_size_ca, [1, "chunk"]))
let(v6hc =
	v6hc_style == "none" ? ["union"] :
	v6hc_style == "v6.1" ? ["rotate", [0,0,90], tgx11_v6c_flatright_polygon(
		togridlib3_decode_vector([[1, "atom"], [1,"atom"]]),
		gender=$tgx11_gender, offset=$tgx11_offset
	)] :
	assert(false, str("Unrecognized v6hc_style '", v6hc_style, "' (expected 'none' or 'v6.1')"))
)
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let(chunk_xms = [-block_size_chunks[0]/2+0.5:1:block_size_chunks[0]/2])
let(chunk_yms = [-block_size_chunks[1]/2+0.5:1:block_size_chunks[1]/2])
let(u = togridlib3_decode([1,"u"]))
let(bevel_size = togridlib3_decode([1,"tgp-standard-bevel"]))
let(atom = togridlib3_decode([1,"atom"]))
let(chunk = togridlib3_decode([1,"chunk"]))
let(atom_foot =
	bottom_shape == "footed" ? (
		// If 'chatomic', then the chunk will provide the bevel;
		// simplify things by letting atoms be straight:
		segmentation == "chatom" ? tgx11_chunk_column([atom,atom,block_size[2]+3/32], foot_bevel=foot_bevel) :
		tgx11_chunk_unifoot([atom,atom,block_size[2]+3/32], foot_bevel=foot_bevel)
	):
	bottom_shape == "beveled" ? tgx11_chunk_foot([atom,atom,block_size[2]+3/32]) :
	assert(false, str("Unrecognized bottom_shape '", bottom_shape, "' (expected 'footed' or 'beveled')"))
)
let(chunk_beveled_foot = tgx11_chunk_foot([chunk,chunk,block_size[2]+2.5/32]))
let(chunk_foot =
	bottom_shape == "footed" ? tgx11_chunk_unifoot([chunk,chunk,block_size[2]+3/32], foot_bevel=foot_bevel) :
	bottom_shape == "beveled" ? chunk_beveled_foot :
	assert(false, str("Unrecognized bottom_shape '", bottom_shape, "' (expected 'footed' or 'beveled')"))
)
let(v6hc_y = togmod1_linear_extrude_y([-block_size[1]/2+6, block_size[1]/2-6], v6hc))
let(v6hc_x = togmod1_linear_extrude_x([-block_size[0]/2+6, block_size[0]/2-6], v6hc))
let(body_z0 = bevel_size-$tgx11_offset*sqrt(2)) // Seems to work, though I didn't actually do the math <_<
let(body_z1 = block_size[2]+1+1/32)
// tgx11_chunk_unifoot(block_size),
["union",
	// Atom feet
	if( segmentation == "atom" || segmentation == "chatom" )
		for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_foot],
	
	// Y-axis v6hcs
	for(xm=atom_xms) ["translate", [xm*atom,0,atom/2], v6hc_y],
	// X-axis v6hcs
	for(ym=atom_yms) ["translate", [0,ym*atom,atom/2], v6hc_x],
	// Chunk body
	["translate", [0,0,(body_z0+body_z1)/2], togmod1_make_cuboid([
		block_size[0]-atom, block_size[1]-atom,
		body_z1-body_z0])],
	
	if( segmentation == "chatom" ) for(xm=chunk_xms) for(ym=chunk_yms) ["translate", [xm*chunk, ym*chunk, 0], chunk_beveled_foot],

	if( segmentation == "chunk" ) for(xm=chunk_xms) for(ym=chunk_yms) ["translate", [xm*chunk, ym*chunk, 0], chunk_foot],
];

function tgx11__get_gender() = is_undef($tgx11_gender) ? "m" : $tgx11_gender;
function tgx11__invert_gender(g) = g == "m" ? "f" : "m";

/**
 * Generate the bottom of a block.
 * The space above the bottom will be solid, extending somewhat beyond block_size_ca,
 * so that the bottom can be intersected with top and sides.
 */
function tgx11_block_bottom(
	block_size_ca,
	bottom_shape = "footed",
	segmentation = "atom",
	v6hc_style = "v6.1",
	foot_bevel = 0
) =
	segmentation == "none" ? let(block_size=togridlib3_decode_vector(block_size_ca)) ["translate", [0,0,block_size[2]], togmod1_make_cuboid(block_size*2)] :
	let($tgx11_gender = tgx11__get_gender())
	segmentation == "block" ? (
		bottom_shape == "footed" ? tgx11_chunk_unifoot(togridlib3_decode_vector(block_size_ca), foot_bevel=foot_bevel) :
		tgx11_chunk_foot(togridlib3_decode_vector(block_size_ca))
	) :
	tgx11_atomic_block_bottom(block_size_ca, bottom_shape=bottom_shape, segmentation=segmentation, v6hc_style=v6hc_style, foot_bevel=foot_bevel);

/**
 * A whole, complete block, including bottom top ('lip').
 * The gender (for offset purposes) of the bottom will be $tgx11_gender,
 * and the gender of the top will be the inverse.
 */
function tgx11_block(
	block_size_ca,
	bottom_shape="footed",
	lip_height = 2.54,
	atom_bottom_subtractions=[],
	bottom_segmentation = "atom",
	bottom_v6hc_style = "v6.1", // For bottoms, you might want the narrower one, which is, uhhh
	top_v6hc_style = "v6.1", // For tops, you might want the wider one, which is, uhh
	top_shape = undef,
	bottom_foot_bevel = 0,
	top_segmentation = "atom"
) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let($tgx11_gender = tgx11__get_gender())
let(atom = togridlib3_decode([1,"atom"]))
let(positive_lip_height = lip_height > 0 ? lip_height : 0)
let(top_shape_eff = is_undef(top_shape) ? bottom_shape : top_shape)
// TODO: Taper top and bottom all cool?
["difference",
	["intersection",
		tphl1_extrude_polypoints([-1,block_size[2]+positive_lip_height], tgx11_chunk_xs_points(
			size = block_size,
			offset = $tgx11_offset
		)),
		tgx11_block_bottom(
			[
				block_size_ca[0],
				block_size_ca[1],
				[togridlib3_decode(block_size_ca[2], [1, "mm"]) + lip_height, "mm"]
			],
			segmentation = bottom_segmentation,
			bottom_shape = bottom_shape,
			v6hc_style = bottom_v6hc_style,
			foot_bevel = bottom_foot_bevel
		),
		if( lip_height < 0 ) ["translate", [0,0,block_size[2]], ["rotate", [0,180,0], tgx11_block_bottom(
			block_size_ca,
			bottom_shape = top_shape_eff,
			segmentation = top_segmentation,
			v6hc_style = top_v6hc_style
		)]],
	],
	
	if( len(atom_bottom_subtractions) > 0 )
	let( atom_bottom_subtraction = ["union", each atom_bottom_subtractions] )
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_bottom_subtraction],
	
	if( lip_height > 0 ) ["translate", [0,0,block_size[2]], tgx11_block_bottom(
		block_size_ca,
		bottom_shape = top_shape_eff,
		segmentation = top_segmentation,
		v6hc_style = top_v6hc_style,
		$tgx11_offset = -$tgx11_offset,
		$tgx11_gender = tgx11__invert_gender($tgx11_gender)
	)],
];

function tgx11_get_default_unit_table() = [
	// The defaults in TOGridLib3 were chosen for v8-style things;
	// for our v6-inspired designs with beveled corners,
	// and also 'tgp-' -prefix them while we're at it.
	["tgp-m-outer-corner-radius", [2, "u"]],
	["tgp-f-outer-corner-radius", [1, "u"]],
	["tgp-column-inset", [1, "u"]],
	["tgp-min-m-corner-radius", [1, "u"]],
	["tgp-min-f-corner-radius", [0, "u"]],
	["tgp-standard-bevel", [2, "u"]],
	each togridlib3_get_default_unit_table()
];
