// TGx12.0[.6]Lib
// 
// Generate a simplified atomn foot shape
// 
// v12.0.6:
// - Separated from TGx12.0.scad
// 
// TODO: Once alternate segmentations are defined,
// add a function for non-atomic feet that unions in chunks or whatever.

use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

function tgx12__regular_polypoints(apothem, position=[0,0], rotation=0) =
	let( circumradius = apothem / cos(180/$fn) )
	let( rot = rotation + 180/$fn )
	[
		for( i=[0 : 1 : $fn-1] )
		togvec0_add_vec([circumradius * cos(rot + i*360/$fn), circumradius * sin(rot + i*360/$fn)], position),
	];

// A simple circular foot.
// Horizontal foot column face offset (foot bottom is always at exactly 0) may be specified
// as $tgx12_fc_r_offset, independently of the regular TOGridPile bevel face offset ($tgx11_offset).
// Uses $fn for side count.
function tgx12_make_atom_foot(height, shape="column+padbevel", foot_bevel=0) =
	assert(shape == "column" || shape == "column+padbevel")
	let( atom = togunits1_to_mm("atom") )
	let( bev = togunits1_to_mm("tgp-standard-bevel") )
	// padded_r = maximum radius of bevel to put the edge comfortably outside the atom;
	// minimum to guarantee overlap would be sqrt(2)*atom/2
	let( padded_r = atom )
	let( fc_r_offset = !is_undef($tgx12_fc_r_offset) ? $tgx12_fc_r_offset : $tgx11_offset )
	let( fc_rad = sqrt(2)*atom/4 + fc_r_offset )
	let( bev_z0    = bev - atom/2 - $tgx11_offset*sqrt(2) ) // Z of imaginary 'bottom point' of bevel under center of foot
	let( fcbev_z   = bev_z0 + fc_rad) // Z at center + radius at which they intersect; easy peasy!
	let( padedge_z = bev_z0 + padded_r ) // Z position where radius of beveled section reaches padded_r
	// Ideal z position of foot column/bevel intersection
	let( r0 = atom/2 )
	assert( shape == "column" || fcbev_z > foot_bevel, str("Z at which column and bevel meet should be > foot bevel height; got ", fcbev_z, " and ", foot_bevel) )
	tphl1_make_polyhedron_from_layer_function(
		[
			[    0    , fc_rad - foot_bevel],
			if( foot_bevel > 0 ) [foot_bevel, fc_rad],
			each shape == "column" ? [
				[height   , fc_rad        ],
			] : [
				[fcbev_z  , fc_rad        ],
				[padedge_z, padded_r      ],
				[max(padedge_z+1, + height), padded_r],
			],
		],
		function(zo) tgx12__regular_polypoints(zo[1], position=[0,0,zo[0]], rotation=45)
	);

/**
 * Convenience function to make an array of atom feet, basically.
 */
function tgx12_make_atomic_block_bottom(
	size, // List of three number, number + unit name string, or [number, unit_name]
	shape = "column+padbevel",
	foot_bevel = 0
) =
let( size_atoms = togunits1_decode_vec([size[0],size[1]], unit="atom", xf="round") )
let( height_mm = togunits1_decode(size[2], unit="mm") )
let( atom_mm = togunits1_to_mm("atom") )
let( foot = ["render", tgx12_make_atom_foot(height_mm, shape=shape, foot_bevel=foot_bevel)] )
["union",
	for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.5] )
	for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.5] )
	["translate", [xm*atom_mm, ym*atom_mm, 0], foot],
];
