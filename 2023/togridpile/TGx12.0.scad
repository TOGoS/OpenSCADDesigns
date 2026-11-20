// TGx12.0.7 - can we uhm sqrt(2)/4 stuff
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
// 
// TODO: Option for a cavity so we can make TOGridPile cups!
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

$togridlib3_unit_table = tgx11_get_default_unit_table();

block_size_strs = togstr1_tokenize(block_size, " ");
block_size_mm = togunits1_decode_vec(block_size_strs, unit="mm");
// Size in atoms, rounded to nearest integer
block_size_atoms_r = togunits1_decode_vec(block_size_strs, unit="atom", xf="round");
block_size_chunks_r = togunits1_decode_vec(block_size_strs, unit="chunk", xf="round");
lip_height_mm = togunits1_to_mm(lip_height);
foot_connector_width_mm = togunits1_to_mm(foot_connector_width);
foot_connector_thickness_mm = togunits1_to_mm(foot_connector_thickness);

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
	["intersection",
		// Bottom
		make_block_foot(bottom_style, foot_bevel=0.4, foot_side_count=foot_side_count),
		// Top
		bottom_to_top(block_size_mm[2], make_block_foot(top_style, foot_bevel=0.2, foot_side_count=foot_side_count)),
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
