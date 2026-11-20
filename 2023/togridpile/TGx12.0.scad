// TGx12.0.9 - can we uhm sqrt(2)/4 stuff
// 
// v12.0.1:
// - Rough first 
// - Calculations are a little sloppy!
//   'circumfact' influences radius of foot column, but also the bevels above it;
//   probably tgx12_make_rp_atom_foot_column_rath needs to be inlined
//   and calculation of insets (or radiuses) moved to another function which also
//   calculates Z positions of the column and the bevels.
// - $tgx11_offset only influences outer horizontal hull
// - $tgx12_fc_offset does not influence Z position
// - This may be cleaner in a way than trying to have offsets that work
//   in 3 dimensions?  Definitely easier to reason about, anyway.
// - That said, I think the goal was to to have $tgx11_offset have the usual meaning,
//   except horizontal offset of the foot column faces would use $tgx12_fc_offset instead.
// v12.0.2:
// - Allow the `polarity` to be inverted and provide an option for
//   `bottom_foot_connector_width` so that the first layer of your print
//   can be something a bit more solid and less likely to tear off the bed.
// - Top feet ('toots') don't get a bevel
// - Note that polarity handling is *BROKEN* haha top always mirrors bottom oops
// v12.0.4:
// - Replace `polarity` with separate gender options for top and bottom
// - Fix top/bottom positions so that `m` connectors are at block boundaries,
//   and `f` connectors protrude by `lip_height`
// - Option for `top_secondary_segmentation`
// - Fix Z position of block bottom
// v12.0.5:
// - Simplify foot generation
//   - Always assume we're talking about apothem rather than circumradius
//   - Fix calculation of bevel/foot intersection
// v12.0.6:
// - Use TGx12.0Lib
// v12.0.7:
// - Replace segmentation and gender settings with 'style' that can be applied to top or bottom
// - `tgx11-f-block` and `tgx11-f-chunk` are options for top style!
// - `foot_connector_thickness` option - make it small and maybe you could break off the connectors after printing
// v12.0.8:
// - Cavity options
// v12.0.9:
// - Wonderfully elegant fingerslide generation using TPLists and TPGens and stuff
// 
// TODO: Don't try to ensure 45-degree bevels around atom feet.
// Do guarantee num_overlap of nubbin before it meets the bevel!

block_size = "6atom 3atom 1/4inch";
// Segmentation of bottom of block above the nubbins
bottom_style = "flat"; // ["flat", "tgx12-f-atom", "tgx12-f-atom+connectors", "tgx12-m-atom", "tgx12-m-atom+connectors", "tgx12-m-atom/chunk", "tgx12-m-atom/flat"]
// Segmentation of top of block under the nubbins
top_style = "flat"; // ["flat", "tgx11-f-block", "tgx11-f-chunk", "tgx12-f-atom", "tgx12-m-atom", "tgx12-m-atom/chunk", "tgx12-m-atom/flat"]
// Nominal length of nubbins
lip_height = "1u";

foot_connector_width = "0mm";
foot_connector_thickness = "99mm";

/* [Cavity] */

cavity_type = "none"; // ["none", "clarp2505-square", "clarp2505-square+fs"]
// Nominal thickness of cavity wall; i.e. inset from ideal block boundary
cavity_wall_thickness = "1u";
// Don't let the actual wall thickness be less than this
cavity_wall_min_actual_thickness = "2.1mm";

/* [Detail] */

// General face offset
$tgx11_offset = -0.15; // 0.01
// Offset of foot colum side faces; id undefined, defaults to $tgx11_offset
$tgx12_fc_r_offset = 0; // 0.01
// Number of sides of foot; multiples of 8 are probably best, but in-between multiples of 4 may be interesting, too
foot_side_count = 8; // [4 : 4 : 128]
// Fn for things other than the foot columns
$fn = 32;

module __tgx12_0_end_params() { }

use <../lib/TGx11.1Lib.scad>
use <../lib/TGx12.0Lib.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGStringLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_size_strs = togstr1_tokenize(block_size, " ");
block_size_mm = togunits1_decode_vec(block_size_strs, unit="mm");
// Size in atoms, rounded to nearest integer
block_size_atoms_r = togunits1_decode_vec(block_size_strs, unit="atom", xf="round");
block_size_chunks_r = togunits1_decode_vec(block_size_strs, unit="chunk", xf="round");
lip_height_mm = togunits1_to_mm(lip_height);
foot_connector_width_mm = togunits1_to_mm(foot_connector_width);
foot_connector_thickness_mm = togunits1_to_mm(foot_connector_thickness);
cavity_wall_thickness_mm = togunits1_to_mm(cavity_wall_thickness);
cavity_wall_min_actual_thickness_mm = togunits1_to_mm(cavity_wall_min_actual_thickness);

// Nominal overlap when m nubbins insert between f nubbins.
nub_overlap_mm = togunits1_to_mm("1u");

/**
 * Generate a circumradius between that which would be needed
 * if r = circumradius (smaller polygon, circfact=0)
 *    r = apothem      ( larger polygon, circfact=1)
 *
 * Fun to think about for circle-approximation, but not actually used.
 */
/*
function tgx12__circfact_polyrad(r, circfact=0.5) =
	let(
		circumradius_a = r,
		circumradius_b = r / cos(180/$fn)
	)
	circumradius_a * (1-circfact) + circumradius_b * circfact;
*/


// Some types:
// 
// RBLF<D> = [right_x:T, back_y:D, left_x:D, front_y:D]
// Combiner<I,O> = (left:I, right:I) -> O
// TList<I> = [t:I, ...]
// TPList<I,O> = [[t:I, data:O], ...]
// TFunc<I,O> = t:I -> O
// TPGen<I,O> = [[t:I, ...], TFunc<I,O>]
// Interpolator<T> = (left:T, right:T, rat:Number 0..1) -> T
// Tagged = [type_name = nameof(T):TypeName, value:T]
// TypeName = "TPList<RBLF<Number>>" | "TPGen<Number,RBLF<Number>>" | ...

tgx12__is_number = function(t) is_num(t);

function tgx12__is_tlist(is_t, maybe_tlist, index=0) =
	assert( is_function(is_t), "tgx12__is_tlist: is_t should be a function!" )
	is_list(maybe_tlist) && index >= len(maybe_tlist) || is_t(maybe_tlist[index]) && tgx12__is_tlist(is_t, maybe_tlist, index+1);

function tgx12__is_tpgen(is_t, maybe_tpgen) =
	tgx12__is_tlist(is_t, maybe_tpgen[0]) && is_function(maybe_tpgen[1]);

// The merge part of merge sort.
// [1, 4, 6, 7], [3, 4, 9, 10] -> [1, 3, 4, 4, 6, 7, 9, 10]
function tgx12__merge_tlist( left_ts, right_ts, left_index=0, right_index=0 ) =
	// Either list ran out?  It's the rest of the other list (which could also be at its end!)
	left_index  >= len(left_ts)  ? [for(i=[right_index : 1 : len(right_ts)-1]) right_ts[i]] :
	right_index >= len(right_ts) ? [for(i=[ left_index : 1 : len( left_ts)-1])  left_ts[i]] :
	left_ts[left_index] < right_ts[right_index] ? [
		left_ts[left_index],
		each tgx12__merge_tlist(left_ts, right_ts, left_index+1, right_index)
	] : [
		right_ts[right_index],
		each tgx12__merge_tlist(left_ts, right_ts, left_index, right_index+1)
	];
function tgx12__uniq_tlist( ts, index=0, prev=undef ) =
	index >= len(ts) ? [] :
	!is_undef(prev) && ts[index] == prev ? tgx12__uniq_tlist(ts, index+1, prev) :
	[ts[index], each tgx12__uniq_tlist(ts, index+1, ts[index])];

function tgx12__tpgen_to_tplist( tpgen ) =
	assert( tgx12__is_tpgen(tgx12__is_number, tpgen) )
	[for(t=tpgen[0]) [t, tpgen[1](t)]];

// tgx12__combine_tfunc : (right_func : (x:I) -> O, left_func : (y:I) -> O, combiner: (left:O, right:O) -> O ) -> (x:I) -> O
function tgx12__combine_tfunc( left_func, right_func, combiner ) =
	function(t) combiner( left_func(t), right_func(t) );

far = 65536; // Big number

// tgx12__min_rblf : (left_func:TFunc<T, RBLF>, right_func:TFunc<T, RBLF>) -> TFunc<T, RBLF>
tgx12__min_rblf = function( left, right ) [
	min(left[0], right[0]),
	min(left[1], right[1]),
	max(left[2], right[2]),
	max(left[3], right[3]),
];
// tgx12__max_rblf : (left_func:TFunc<T, RBLF>, right_func:TFunc<T, RBLF>) -> TFunc<T, RBLF>
tgx12__max_rblf = function( left, right ) [
	max(left[0], right[0]),
	max(left[1], right[1]),
	min(left[2], right[2]),
	min(left[3], right[3]),
];

function tgx12__fingerslide_tpgen( zrange, front_y ) =
	let( rad = zrange[1] - zrange[0] )
	let( pivot_y = front_y + rad )
	let( segcount = ceil($fn/4+0.5) )
	[
		[
			for( am = [0 : 1 : segcount] )
			let( angle = am*90/segcount - 90 )
			zrange[1] + rad * sin(angle)
		],
		function(z) [
			// Right, back, left: Don't care
			far, far, -far,
			// And for front Y:
			z >= zrange[1] ? front_y :
			z <= zrange[0] ? pivot_y :
			let( angle = asin((z - zrange[1])/rad) )
			pivot_y - rad * cos(angle)
		]
	];

function tgx12__make_lookup_function( interpolator ) =
	// TODO: Binary subdivision instead of linear scan?
	// TODO: Could always use interpolator, even at exact matches,
	// and maybe using (undef, first) and (last, undef) to indicate inputs beyond first/last position,
	// with which it could do something special if desired!
	let( lookup_func = function( t, list, index=0 )
		assert(len(list) > 0, "Lookup requires at least one item, but empty list was given!")
		// At or beyond last position?   Give 'em the last value.
		index >= len(list)-1 ? list[len(list)-1][1] :
		// At or before current position?  Give 'em the current value.
		t <= list[index][0] ? list[index][1] :
		t < list[index+1][0] ?
			// Time to interpolate!
			assert( index >= 0 )
			assert( index+1 < len(list) )
			let( t0 = list[index+0][0], t1 = list[index+1][0] )
			let( v0 = list[index+0][1], v1 = list[index+1][1] )
			let( rat = (t-t0)/(t1-t0) )
		   interpolator(v0, v1, rat) :
		// Try next span
		lookup_func(t, list, index+1)
	)
   lookup_func;

tgx12__lerp_vectors = function(left, right, rat)
	assert(len(left) == len(right), "left/right vectors must be same length to interpolate")
	[
		for( i=[0 : 1 : len(left)-1] )
		left[i] + (right[i] - left[i])*rat
	];

function tgx12__tplist_to_tpgen(tplist, value_interpolator) =
	let( my_lookup = tgx12__make_lookup_function(value_interpolator) )
	[
		[for(tp=tplist) tp[0]],
		function(t) my_lookup(t, tplist)
	];

function tgx12__merge_tpgen(left_tpgen, right_tpgen, value_combiner) =
	let( merged_ts = tgx12__uniq_tlist(tgx12__merge_tlist(left_tpgen[0], right_tpgen[0])) )
	[merged_ts, tgx12__combine_tfunc(left_tpgen[1], right_tpgen[1], value_combiner)];

function tgx12__merge_tplist(left_tplist, right_tplist, value_interpolator, value_combiner) =
	let(   left_tpgen = tgx12__tplist_to_tpgen( left_tplist, value_interpolator) )
	let(  right_tpgen = tgx12__tplist_to_tpgen(right_tplist, value_interpolator) )
	let( merged_tpgen = tgx12__merge_tpgen(left_tpgen, right_tpgen, value_combiner) )
	tgx12__tpgen_to_tplist(merged_tpgen);

function tgx12_basic_cavity_rect_points(rblf, bev=2) = echo(rblf=rblf) [
	// Could adjust bev as needed here
   [rblf[0]    , rblf[1]-bev],
   [rblf[0]-bev, rblf[1]    ],
   [rblf[2]+bev, rblf[1]    ],
   [rblf[2]    , rblf[1]-bev],
   [rblf[2]    , rblf[3]+bev],
   [rblf[2]+bev, rblf[3]    ],
   [rblf[0]-bev, rblf[3]    ],
   [rblf[0]    , rblf[3]+bev],
];

tgx12__rblf_to_beveled_rect_polypoints_function = function(bev)
	function(rblf) tgx12_basic_cavity_rect_points(rblf, bev=bev);

/**
 * rblf_zlist : TList<Number,RBLF<Number>> = list of [z, [+x, +y, -x, -y positions of inner faces]
 */
function tgx12__rblf_tplist_to_polyhedron(rblf_zlist, rblf_to_polypoints) =
	assert( is_function(rblf_to_polypoints) )
	echo( rblf_zlist = rblf_zlist )
	tphl1_make_polyhedron_from_layer_function(
		rblf_zlist,
		function(zrblf) rblf_to_polypoints(zrblf[1]),
		layer_points_transform = "key0-to-z"
	);
function tgx12__rblf_tpgen_to_polyhedron(rblf_tpgen, rblf_to_polypoints) =
	assert( is_function(rblf_to_polypoints) )
	tgx12__rblf_tplist_to_polyhedron(tgx12__tpgen_to_tplist(rblf_tpgen), rblf_to_polypoints);

function tgx12__basic_cavity_rblf_tplist(block_size) =
	let( bx1 = block_size[0]/2 )
	let( by1 = block_size[1]/2 )
	let( bx0 = -bx1, by0 = -by1 )
	let( u = 254/160 )
	let( bz1 = block_size[2]   )
	let( cx1 = min(bx1 - cavity_wall_thickness_mm, bx1 + $tgx11_offset - cavity_wall_min_actual_thickness_mm) )
	let( cy1 = min(by1 - cavity_wall_thickness_mm, by1 + $tgx11_offset - cavity_wall_min_actual_thickness_mm) )
	// TODO: I suppose min_actual_thickness should be applied to everything, not just cx1 and cy1
	let( cx0 = -cx1, cy0 = -cy1 )
	[
		[      4*u, [cx1-1*u, cy1-1*u, cx0+1*u, cy0+1*u]],
		[      5*u, [cx1    , cy1    , cx0    , cy0    ]],
		[bz1 - 7*u, [cx1    , cy1    , cx0    , cy0    ]],
		[bz1 - 3*u, [bx1-2*u, by1-2*u, bx0+2*u, by0+2*u]],
		[bz1 - 2*u, [bx1-3*u, by1-3*u, bx0+3*u, by0+3*u]],
		[bz1 + 2*u, [bx1-3*u, by1-3*u, bx0+3*u, by0+3*u]],
	];

togmod1_domodule(
	let( atom = togunits1_to_mm("atom") )
	let( chunk = togunits1_to_mm("chunk") )
	let( pad = atom )
	let( u    = togunits1_to_mm("u"   ) )
	/*togmod1_linear_extrude_z([0, 12.7],
		togpath1_rath_to_polygon(tgx12_make_rp_atom_foot_column_rath())
	)*/
	let( boot = ["render",tgx12_make_atom_foot(height=block_size_mm[2]+atom+1/128, shape="column+padbevel", foot_bevel=0.4, $fn=foot_side_count)] )
	let( bev = togunits1_to_mm("tgp-standard-bevel") )
	let( m_foot_positions = [
		for( ym=[-block_size_atoms_r[1]/2+0.5 : 1 : block_size_atoms_r[1]/2-0.5] )
		for( xm=[-block_size_atoms_r[0]/2+0.5 : 1 : block_size_atoms_r[0]/2-0.5] )
		[xm*atom, ym*atom]
	])
	let( f_foot_positions = [
		for( ym=[-block_size_atoms_r[1]/2 : 1 : block_size_atoms_r[1]/2] )
		for( xm=[-block_size_atoms_r[0]/2 : 1 : block_size_atoms_r[0]/2] )
		[xm*atom, ym*atom]
	])
	let( bottom_to_top = function(top_z, thing) ["translate", [0,0,top_z], ["rotate", [180,0,0], thing]] )
	let( make_atom_feet = function(gender, shape, foot_bevel=0, foot_side_count=3)
		let( toot = ["render",tgx12_make_atom_foot(
			height = block_size_mm[2]+atom+1/128,
			shape = shape,
			foot_bevel = foot_bevel,
			$fn = foot_side_count)
		] )
		let( foot_positions = gender == "m" ? m_foot_positions : f_foot_positions )
		["union",
			for( pos = foot_positions )
			["translate", [pos[0], pos[1], gender == "m" ? 0 : -nub_overlap_mm], toot],
		]
	)
	let( secondary_chunk_foot = let(oH=$tgx11_offset*(sqrt(2)-1), oF=$tgx11_offset) tphl1_make_polyhedron_from_layer_function(
		[
			[        nub_overlap_mm - oF , 0 - bev + nub_overlap_mm + oH],
			[             bev + pad - oH , 0 + pad + 5/128          + oF],
			[block_size_mm[2] + bev + pad, 0 + pad + 5/128          + oF],
		],
		function(zo) togpath1_rath_to_polypoints(
			togpath1_make_rectangle_rath([chunk, chunk], corner_ops=[["bevel", bev], ["round", 3], ["offset", zo[1]]])
		),
		layer_points_transform = "key0-to-z"
	))
	let( make_foot_connectors = function(gender) ["union",
		each foot_connector_width_mm <= 0 ? [] :
			let(fc_z0 = (gender == "m" ? 0 : -nub_overlap_mm)+1/128, fc_z1 = fc_z0 + foot_connector_thickness_mm)
			let(y_bar = togmod1_linear_extrude_z([fc_z0, fc_z1], togmod1_make_rect([foot_connector_width_mm, block_size_mm[1] - (gender == "m" ? atom : 0)])))
			let(x_bar = togmod1_linear_extrude_z([fc_z0, fc_z1], togmod1_make_rect([block_size_mm[0] - (gender == "m" ? atom : 0), foot_connector_width_mm])))
			let(xms = gender == "m" ? [-block_size_atoms_r[0]/2+0.5 : 1 : +block_size_atoms_r[0]/2-0.5] : [-block_size_atoms_r[0]/2 : 1 : +block_size_atoms_r[0]/2] )
			let(yms = gender == "m" ? [-block_size_atoms_r[1]/2+0.5 : 1 : +block_size_atoms_r[1]/2-0.5] : [-block_size_atoms_r[1]/2 : 1 : +block_size_atoms_r[1]/2] )
			[
				for( xm = xms ) ["translate", [xm*atom, 0, 0], y_bar],
				for( ym = yms ) ["translate", [0, ym*atom, 0], x_bar],
			]
		]
	)
	let( make_block_foot = function(style, foot_bevel=0, foot_side_count=3)
		style == "flat" ? togmod1_linear_extrude_z([0 /* or maybe $tgx11_offset? */, block_size_mm[2]+1], togmod1_make_rect(block_size_mm*2)) :
		style == "tgx11-f-block" ? ["difference",
			togmod1_linear_extrude_z([-lip_height_mm, block_size_mm[2]+1], togmod1_make_rect(block_size_mm*2)),
			["rotate", [180,0,0], tgx11_block_bottom(
				[[block_size_mm[0], "mm"], [block_size_mm[1], "mm"], [38.1, "mm"]],
				bottom_shape = "footed",
				segmentation = "block",
				$tgx11_offset = -$tgx11_offset,
				$tgx11_gender = "f"
			)]
		] :
		style == "tgx11-f-chunk" ? ["difference",
			togmod1_linear_extrude_z([-lip_height_mm, block_size_mm[2]+1], togmod1_make_rect(block_size_mm*2)),
			["rotate", [180,0,0], tgx11_block_bottom(
				[[block_size_mm[0], "mm"], [block_size_mm[1], "mm"], [38.1, "mm"]],
				bottom_shape = "footed",
				segmentation = "chunk",
				v6hc_style = "none",
				$tgx11_offset = -$tgx11_offset,
				$tgx11_gender = "f"
			)]
		] :
		style == "tgx12-f-atom" ? make_atom_feet("f", "column+padbevel", foot_bevel=foot_bevel, foot_side_count=foot_side_count) :
		style == "tgx12-f-atom+connectors" ? ["union",
			make_atom_feet("f", "column+padbevel", foot_bevel=foot_bevel, foot_side_count=foot_side_count),
			make_foot_connectors("f"),
		] :
		style == "tgx12-m-atom" ? make_atom_feet("m", "column+padbevel", foot_bevel=foot_bevel, foot_side_count=foot_side_count) :
		style == "tgx12-m-atom+connectors" ? ["union",
			make_atom_feet("m", "column+padbevel", foot_bevel=foot_bevel, foot_side_count=foot_side_count),
			make_foot_connectors("m"),
		] :
		style == "tgx12-m-atom/flat" ? ["union",
			make_atom_feet("m", "column", foot_bevel=foot_bevel, foot_side_count=foot_side_count),
			togmod1_linear_extrude_z([nub_overlap_mm, block_size_mm[2]+1], togmod1_make_rect(block_size_mm*2))
		] :
		style == "tgx12-m-atom/chunk" ? ["union",
			make_atom_feet("m", "column", foot_bevel=foot_bevel, foot_side_count=foot_side_count),
			for( ym = [-block_size_chunks_r[1]/2+0.5 : 1 : block_size_chunks_r[1]/2-0.5] )
			for( xm = [-block_size_chunks_r[0]/2+0.5 : 1 : block_size_chunks_r[0]/2-0.5] )
			["translate", [xm*chunk, ym*chunk, 0], secondary_chunk_foot],
		] :
		assert(false, str("Unrecognized style: '", foot_style, "'"))
	)
	let( rblf_to_polypoints_function = tgx12__rblf_to_beveled_rect_polypoints_function(2) )
	let( max_rblf = [
		 block_size_mm[0]/2+$tgx11_offset-cavity_wall_min_actual_thickness_mm,
		 block_size_mm[1]/2+$tgx11_offset-cavity_wall_min_actual_thickness_mm,
		-block_size_mm[0]/2-$tgx11_offset+cavity_wall_min_actual_thickness_mm,
		-block_size_mm[1]/2-$tgx11_offset+cavity_wall_min_actual_thickness_mm,
	])
	// Hmm: could pull min wall thickness stuff out of basic cavity,
	// since we must always apply it anyway.
	// TODO: Centralize cavity generation; take a list of features to apply and just keep
	// wrapping the tpgen until we run out.
	let( basic_cavity_tplist = tgx12__basic_cavity_rblf_tplist(block_size_mm) )
	let( basic_cavity_tpgen = tgx12__tplist_to_tpgen(basic_cavity_tplist, tgx12__lerp_vectors) )
	let( cavity =
		cavity_type == "none" ? ["union"] :
		cavity_type ==	"clarp2505-square" ? tgx12__rblf_tplist_to_polyhedron(basic_cavity_tplist, rblf_to_polypoints_function) :
		cavity_type ==	"clarp2505-square+fs" ? tgx12__rblf_tpgen_to_polyhedron(
			tgx12__merge_tpgen(
				basic_cavity_tpgen,
				tgx12__fingerslide_tpgen([6.35, 19.05], max_rblf[3]), // TODO: Configurable fingerslide radius
				tgx12__min_rblf
			),
			rblf_to_polypoints_function
		) :
		assert(false, str("Unsupported [for now] cavity type: '", cavity_type, "'"))
	)
	["intersection",
		// Bottom
		make_block_foot(bottom_style, foot_bevel=0.4, foot_side_count=foot_side_count),
		// Top
		["difference",
			bottom_to_top(block_size_mm[2], make_block_foot(top_style, foot_bevel=0.2, foot_side_count=foot_side_count)),
			
			cavity
		],
		// X/Y hull
		togmod1_linear_extrude_z(
			[-20, block_size_mm[2]+20],
			togpath1_rath_to_polygon(togpath1_make_rectangle_rath(
				[block_size_mm[0], block_size_mm[1]],
				corner_ops = [["bevel", bev], ["round", 3], ["offset", $tgx11_offset]]
			))
		),
	]
);
