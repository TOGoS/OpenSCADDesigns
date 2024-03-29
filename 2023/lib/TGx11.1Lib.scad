// TGx11.1Lib - v11.1.10
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
//
// TODO: 'chunk' bottom style
// (currently can hack it by making chunk=atom, but that's kinda ugly)
//
// TODO: Fix weirdness with v6hc (x-debug it to see) when chunk=atom
// 
// TODO: 'atomic' bottom style

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

function tgx11_chunk_xs_zath(size, bevels=[true,true,true,true]) =
	tgx11_beveled_rect_zath(size, bevel_size=togridlib3_decode([1,"tgp-standard-bevel"]), bevels=bevels);

function tgx11_chunk_xs_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
	tgx11_chunk_xs_zath(size),
	offset = offset,
	radius = tgx11__corner_radius(offset=offset, gender=gender)
);

function tgx11_chunk_xs_half_qath(size, offset=0, gender="m") = togpath1_zath_to_qath(
	tgx11_chunk_xs_zath(size, bevels=[false,true,true,false]),
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
	togpath1_qath_to_polypoints(tgx11_chunk_xs_qath(size, gender=gender, offset=offset));

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
		[for (p=tgx11_chunk_xs_points(size, gender=$tgx11_gender, offset=zo[1])) [p[0], p[1], zo[0]]]
	);

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

function tgx11_chunk_unifoot(size) =
	echo("tgx11_chunk_unifoot", size=size)
	let( u = togridlib3_decode([1,"u"]) )
	let( offset=$tgx11_offset )
	let( z41 = sqrt(2) - 1 )
	let( height = max(size[2], 8*u+3/32) )
	tgx11__chunk_footlike([
		[0*u - offset    , -1*u + offset],
		[1*u - offset*z41, -1*u + offset],
		[4*u - offset*z41,  2*u + offset],
		[height          ,  2*u + offset]
	], size=size);

/**
 * 'atomic' foot shape + enough solid stuff above to fully fill the rest of the block and goa bit beyond.
 * Intended to be intersected with a block hull that is no larger than block_size
 */
function tgx11_atomic_block_bottom(block_size_ca, bottom_shape="footed") =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(v6hc = ["rotate", [0,0,90], tgx11_v6c_flatright_polygon([12.7,12.7], gender=$tgx11_gender, offset=$tgx11_offset)])
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let(u = togridlib3_decode([1,"u"]))
let(bevel_size = togridlib3_decode([1,"tgp-standard-bevel"]))
let(atom = togridlib3_decode([1,"atom"]))
let(atom_foot =
	bottom_shape == "footed" ? tgx11_chunk_unifoot([atom,atom,block_size[2]+3/32]) :
	bottom_shape == "beveled" ? tgx11_chunk_foot([atom,atom,block_size[2]+3/32]) :
	assert(false, str("Unrecognized bottom_shape '", bottom_shape, "' (expected 'footed' or 'beveled')"))
)
let(v6hc_y = togmod1_linear_extrude_y([-block_size[1]/2+6, block_size[1]/2-6], v6hc))
let(v6hc_x = togmod1_linear_extrude_x([-block_size[0]/2+6, block_size[0]/2-6], v6hc))
let(body_z0 = bevel_size-$tgx11_offset*sqrt(2)) // Seems to work, though I didn't actually do the math <_<
let(body_z1 = block_size[2]+1+1/32)
// tgx11_chunk_unifoot(block_size),
["union",
	// Atom feet
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_foot],
	// Y-axis v6hcs
	for(xm=atom_xms) ["translate", [xm*atom,0,atom/2], v6hc_y],
	// X-axis v6hcs
	for(ym=atom_yms) ["translate", [0,ym*atom,atom/2], v6hc_x],
	// Chunk body
	["translate", [0,0,(body_z0+body_z1)/2], togmod1_make_cuboid([
		block_size[0]-atom, block_size[1]-atom,
		body_z1-body_z0])]
];

function tgx11__get_gender() = is_undef($tgx11_gender) ? "m" : $tgx11_gender;
function tgx11__invert_gender(g) = g == "m" ? "f" : "m";

function tgx11_block(block_size_ca, bottom_shape="footed", lip_height=2.54, atom_bottom_subtractions=[]) =
let(block_size = togridlib3_decode_vector(block_size_ca))
let(block_size_atoms = togridlib3_decode_vector(block_size_ca, [1, "atom"]))
let(atom_xms = [-block_size_atoms[0]/2+0.5:1:block_size_atoms[0]/2])
let(atom_yms = [-block_size_atoms[1]/2+0.5:1:block_size_atoms[1]/2])
let($tgx11_gender = tgx11__get_gender())
let(atom = togridlib3_decode([1,"atom"]))
// TODO: Taper top and bottom all cool?
["difference",
	["intersection",
		tphl1_extrude_polypoints([-1,block_size[2]+lip_height], tgx11_chunk_xs_points(
			size = block_size,
			offset = $tgx11_offset
		)),
		tgx11_atomic_block_bottom([
			block_size_ca[0],
			block_size_ca[1],
			[togridlib3_decode(block_size_ca[2], [1, "mm"]) + lip_height, "mm"]
		], bottom_shape=bottom_shape),
	],
	
	if( len(atom_bottom_subtractions) > 0 )
	let( atom_bottom_subtraction = ["union", each atom_bottom_subtractions] )
	for(xm=atom_xms) for(ym=atom_yms) ["translate", [xm*atom, ym*atom, 0], atom_bottom_subtraction],
	
	if( lip_height > 0 ) ["translate", [0,0,block_size[2]], tgx11_atomic_block_bottom(
		block_size_ca, bottom_shape=bottom_shape,
		$tgx11_offset=-$tgx11_offset, $tgx11_gender=tgx11__invert_gender($tgx11_gender))],
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
