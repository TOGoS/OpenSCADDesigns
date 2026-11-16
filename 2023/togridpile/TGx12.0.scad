// TGx12.0.3 - can we uhm sqrt(2)/4 stuff
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
// v12.0.3:
// - Replace `polarity` with separate gender options for top and bottom

block_size = "6atom 3atom 1/4inch";
top_gender    = "f"; // ["m","f"]
bottom_gender = "m"; // ["m","f"]
bottom_foot_connector_width = "0mm";

// General face offset
$tgx11_offset = -0.15;
// Offset of foot colum side faces; id undefined, defaults to $tgx11_offset
$tgx12_fc_offset = 0;
// Number of sides of foot
$tgx12_fc_fn = 8; // [4 : 4 : 128]
// Should be large when $tgx12_fn is low; may be smaller as shape approaches a circle (effectively shrinking it slightly)
$tgx12_fc_circfact = 1; // [0 : 0.1 : 1]
// Fn for things other than the foot columns
$fn = 32;

module __tgx12_0_end_params() { }

use <../lib/TGx11.1Lib.scad>
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
bottom_foot_connector_width_mm = togunits1_to_mm(bottom_foot_connector_width);

$togridlib3_unit_table = tgx11_get_default_unit_table();

/**
 * Generate a circumradius between that which would be needed
 * if r = circumradius (smaller polygon, circfact=0)
 *    r = apothem      ( larger polygon, circfact=1)
 */
function circfact_polyrad(r, circfact=0.5) =
	let(
		circumradius_a = r,
		circumradius_b = r / cos(180/$fn)
	)
	circumradius_a * (1-circfact) + circumradius_b * circfact;

function tgx12_make_rp_atom_foot_column_rath(fc_rad) =
	let( fs_offset = !is_undef($tgx12_fc_offset) ? $tgx12_fc_offset : $tgx11_offset )
	togpath1_make_polygon_rath(
		r = circfact_polyrad(fs_offset + fc_rad, circfact = $tgx12_fc_circfact),
		rotation = 45 + 180/$tgx12_fc_fn,
		$fn = $tgx12_fc_fn
	);

function tgx12_make_atom_foot(height, shape, foot_bevel=0) =
	assert(shape == "column" || shape == "column+padbevel")
	let( atom = togunits1_to_mm("atom") )
	let( bev = togunits1_to_mm("tgp-standard-bevel") )
	let( pad = atom/2 ) // Horizontal extension
	// Note: This all assumes $tgx12_fc_circfact = 1 lol;
	// I should probably calculate a list of actual insets for the different points
	// (i.e. atom/2 - circumradius, assuming $tgx12_fc_fn > 4)
	// rather than delegate to tgx12_make_rp_atom_foot_column_rath,
	// then calculate actual Z positions from that. 
	// and from that 
	// Ideal foot column radius
	let( fc_rad = sqrt(2)*atom/4 )
	// Ideal foot column inset from block edge
	let( fc_inset = atom/2 - fc_rad )
	// Ideal z position of foot column/bevel intersection
	let( fcbev_z = bev - fc_inset )
	tphl1_make_polyhedron_from_layer_function(
		[
			[    0    , -fc_inset-foot_bevel],
			if( foot_bevel > 0 ) [foot_bevel, -fc_inset        ],
			each shape == "column" ? [
				[height   , -fc_inset        ],
			] : [
				[fcbev_z  , -fc_inset        ],
				[bev + pad,  pad             ],
				[height   ,  pad             ],
			],
		],
		function(zo) togpath1_rath_to_polypoints(
			tgx12_make_rp_atom_foot_column_rath(zo[1] + atom/2)
		),
		layer_points_transform = "key0-to-z"
	);

togmod1_domodule(
	let( atom = togunits1_to_mm("atom") )
	let( u    = togunits1_to_mm("u"   ) )
	/*togmod1_linear_extrude_z([0, 12.7],
		togpath1_rath_to_polygon(tgx12_make_rp_atom_foot_column_rath())
	)*/
	let( boot = ["render",tgx12_make_atom_foot(height=block_size_mm[2]+atom+1/128, shape="column+padbevel", foot_bevel=0.4)] )
	let( toot = ["render",tgx12_make_atom_foot(height=block_size_mm[2]+atom+1/128, shape="column", foot_bevel=0)] )
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
	["intersection",
		// Bottom
		["union",
			togmod1_linear_extrude_z([bev+1, block_size_mm[2]+3/128], togmod1_make_rect([block_size_mm[0]-atom/2, block_size_mm[1]-atom/2])),

			for( pos = bottom_foot_positions )			
			["translate", pos, boot],
			
			each bottom_foot_connector_width_mm <= 0 ? [] :
				bottom_gender == "f" ?
					let(y_bar = togmod1_linear_extrude_z([1/128, block_size_mm[2]+4/128], togmod1_make_rect([bottom_foot_connector_width_mm, block_size_mm[1]])))
					let(x_bar = togmod1_linear_extrude_z([1/128, block_size_mm[2]+4/128], togmod1_make_rect([block_size_mm[0], bottom_foot_connector_width_mm])))
					[
						for( xm = [-block_size_atoms_r[0]/2 : 1 : +block_size_atoms_r[0]/2] ) ["translate", [xm*atom, 0, 0], y_bar],
						for( ym = [-block_size_atoms_r[1]/2 : 1 : +block_size_atoms_r[1]/2] ) ["translate", [0, ym*atom, 0], x_bar],
					] :
				assert(false, "Bottom foot connector not yet implemented for feet-down polarity")
		],
		// Top
		["union",
			togmod1_linear_extrude_z([-1, block_size_mm[2]], togmod1_make_rect(block_size_mm*2)),
			
			for( pos = top_foot_positions )			
			["translate", [pos[0], pos[1], block_size_mm[2] + u], ["rotate", [180,0,0], toot]],
		],
		// X/Y hull
		togmod1_linear_extrude_z(
			[0, block_size_mm[2] + atom + 2/128],
			togpath1_rath_to_polygon(togpath1_make_rectangle_rath(
				[block_size_mm[0], block_size_mm[1]],
				corner_ops = [["bevel", bev], ["round", 3], ["offset", $tgx11_offset]]
			))
		),
	]
);
