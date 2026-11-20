// TGx12.0.6 - can we uhm sqrt(2)/4 stuff
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

block_size = "6atom 3atom 1/4inch";
bottom_gender = "m"; // ["m","f"]
top_gender    = "f"; // ["m","f"]
bottom_foot_connector_width = "0mm";
// Segmentation of bottom of block above the nubbins
bottom_secondary_segmentation = "none"; // ["none","atom"]
// Segmentation of top of block under the nubbins
top_secondary_segmentation = "none"; // ["none", "chunk", "atom"]
// Nominal length of nubbins
lip_height = "1u";

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

block_size_strs = togstr1_tokenize(block_size, " ");
block_size_mm = togunits1_decode_vec(block_size_strs, unit="mm");
// Size in atoms, rounded to nearest integer
block_size_atoms_r = togunits1_decode_vec(block_size_strs, unit="atom", xf="round");
block_size_chunks_r = togunits1_decode_vec(block_size_strs, unit="chunk", xf="round");
lip_height_mm = togunits1_to_mm(lip_height);
bottom_foot_connector_width_mm = togunits1_to_mm(bottom_foot_connector_width);

$togridlib3_unit_table = tgx11_get_default_unit_table();

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
	let( toot = ["render",tgx12_make_atom_foot(height=block_size_mm[2]+atom+1/128, shape=(top_secondary_segmentation == "atom" ? "column+padbevel" : "column"), foot_bevel=0, $fn=foot_side_count)] )
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
	let( bottom_foot_positions = bottom_gender == "m" ? m_foot_positions : f_foot_positions )
	let( top_foot_positions    = top_gender    == "m" ? m_foot_positions : f_foot_positions )
	let( bottom_foot_z = bottom_gender == "m" ?               0  :               0  - lip_height_mm )
	let( top_foot_z    = top_gender    == "m" ? block_size_mm[2] : block_size_mm[2] + lip_height_mm )
	let( secondary_chunk_foot = let(oH=$tgx11_offset*(sqrt(2)-1), oF=$tgx11_offset) tphl1_make_polyhedron_from_layer_function(
		[
			[  lip_height_mm              - oF, 0 - bev + lip_height_mm + oH],
			[                   bev + pad - oH, 0 + pad + 5/128         + oF],
			[block_size_mm[2] + bev + pad     , 0 + pad + 5/128         + oF],
		],
		function(zo) togpath1_rath_to_polypoints(
			togpath1_make_rectangle_rath([chunk, chunk], corner_ops=[["bevel", bev], ["round", 3], ["offset", zo[1]]])
		),
		layer_points_transform = "key0-to-z"		
	))
	["intersection",
		// Bottom
		["union",
			each
				bottom_secondary_segmentation == "none" ? [
					togmod1_linear_extrude_z(
						[bottom_foot_z + bev - $tgx11_offset, block_size_mm[2]+3/128],
						togmod1_make_rect(
							bottom_foot_connector_width_mm <= 0 ? [block_size_mm[0] - atom/2, block_size_mm[1] - atom/2] :
							                                      [block_size_mm[0] +  1/128, block_size_mm[1] +  1/128] 
						)
					)
				] :
				bottom_secondary_segmentation == "atom" ? [] :
				assert(false, str("Bad bottom_secondary_segmentation '", bottom_secondary_segmentation, "' for gender '", bottom_gender, "'")),

			for( pos = bottom_foot_positions )			
			["translate", [pos[0], pos[1], bottom_foot_z], boot],
			
			each bottom_foot_connector_width_mm <= 0 ? [] :
				bottom_gender == "f" ?
					let(y_bar = togmod1_linear_extrude_z([bottom_foot_z+1/128, block_size_mm[2]+4/128], togmod1_make_rect([bottom_foot_connector_width_mm, block_size_mm[1]])))
					let(x_bar = togmod1_linear_extrude_z([bottom_foot_z+1/128, block_size_mm[2]+4/128], togmod1_make_rect([block_size_mm[0], bottom_foot_connector_width_mm])))
					[
						for( xm = [-block_size_atoms_r[0]/2 : 1 : +block_size_atoms_r[0]/2] ) ["translate", [xm*atom, 0, 0], y_bar],
						for( ym = [-block_size_atoms_r[1]/2 : 1 : +block_size_atoms_r[1]/2] ) ["translate", [0, ym*atom, 0], x_bar],
					] :
				assert(false, "Bottom foot connector not yet implemented for feet-down polarity")
		],
		// Top
		["union",
			each
				top_secondary_segmentation == "none" ? [togmod1_linear_extrude_z([-1, block_size_mm[2]-lip_height_mm], togmod1_make_rect(block_size_mm*2))] :
				top_secondary_segmentation == "chunk" && top_gender == "m" ? [
					for( ym = [-block_size_chunks_r[1]/2+0.5 : 1 : block_size_chunks_r[1]/2-0.5] )
					for( xm = [-block_size_chunks_r[0]/2+0.5 : 1 : block_size_chunks_r[0]/2-0.5] )
					["translate", [xm*chunk, ym*chunk, top_foot_z], ["rotate", [180,0,0], secondary_chunk_foot]],
				] :
				top_secondary_segmentation == "atom" ? [] :
				assert(false, str("Bad top_secondary_segmentation '", top_secondary_segmentation, "' for gender '", top_gender, "'")),
			
			for( pos = top_foot_positions )
			["translate", [pos[0], pos[1], top_foot_z], ["rotate", [180,0,0], toot]],
		],
		// X/Y hull
		togmod1_linear_extrude_z(
			[bottom_foot_z - 1, top_foot_z + 1],
			togpath1_rath_to_polygon(togpath1_make_rectangle_rath(
				[block_size_mm[0], block_size_mm[1]],
				corner_ops = [["bevel", bev], ["round", 3], ["offset", $tgx11_offset]]
			))
		),
	]
);
