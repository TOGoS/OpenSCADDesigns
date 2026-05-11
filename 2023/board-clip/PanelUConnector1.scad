// PanelUConnector1.4
// 
// U-shaped connector for attaching
// one gridbeam panel (that fits inside the "U")
// perpendicular to another (that bolts under it)
// 
// v1.1:
// - Add bottom atom holes
// - Add optional bottom membrane
// v1.2:
// - Add beveled wing slot counterbores
// v1.3:
// - Bevel X ends of center slot
// - Rename `total_height` to just `height`
// v1.4:
// - Bevel slot on both sides!

base_thickness = "1/2inch";
wing_thickness = "1/2inch";
width = "1chunk";
height = "2+1/2inch";
length = "1chunk";
base_slot_diameter = "5/16inch";
base_slot_length = "0mm";
base_slot_frequency = 2;

wing_slot_diameter = "5/16inch";
wing_slot_counterbore_diameter = "7/8inch";
wing_slot_counterbore_depth = "1/8inch";
wing_slot_frequency = 2;

bottom_atom_hole_style = "diamond-4.5mm";

bottom_membrane_thickness = "0.3mm";

$fn = 24;

module __paneluconnector__end_params() { }

// Not parameters:
// wing_slot_length = "0mm"; // Implied by height, yaddah yaddah

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

size = [length, width, height];

atom_mm               = togunits1_to_mm("atom");
chunk_mm              = togunits1_to_mm("chunk");

size_mm               = togunits1_decode_vec(size, unit="mm");
size_chunks           = togunits1_decode_vec(size, unit="chunk", xf="round");
size_atoms            = togunits1_decode_vec(size, unit="atom", xf="round");

base_thickness_mm     = togunits1_to_mm(base_thickness);
base_slot_diameter_mm = togunits1_to_mm(base_slot_diameter);
base_slot_length_mm   = togunits1_to_mm(base_slot_length);
wing_thickness_mm     = togunits1_to_mm(wing_thickness);
wing_slot_diameter_mm = togunits1_to_mm(wing_slot_diameter);
wing_slot_counterbore_diameter_mm = togunits1_to_mm(wing_slot_counterbore_diameter);
wing_slot_counterbore_depth_mm    = togunits1_to_mm(wing_slot_counterbore_depth);

bottom_membrane_thickness_mm = togunits1_to_mm(bottom_membrane_thickness);

togmod1_domodule(
	let( block_bevel = 3.175 )
	let( base_slot = tphl1_make_rounded_cuboid(
		[base_slot_length_mm+base_slot_diameter_mm, base_slot_diameter_mm, base_thickness_mm*3],
		r = let(r=base_slot_diameter_mm*127/256) [r,r,0]
	))
	let( wing_slot_z0 = base_thickness_mm + wing_slot_diameter_mm * 3/2 )
	let( wing_slot_z1 = size_mm[2]   - wing_slot_diameter_mm * 3/2 )
	let( wing_slot_straight_part = ["rotate", [90,0,0], ["translate", [0,(wing_slot_z0+wing_slot_z1)/2,0], tphl1_make_rounded_cuboid(
		[wing_slot_diameter_mm, wing_slot_z1-wing_slot_z0+wing_slot_diameter_mm, size_mm[1]*2 + 2],
		r = let(r=wing_slot_diameter_mm*127/256) [r,r,0]
	)]])
	let( cb_rad = wing_slot_counterbore_diameter_mm/2 )
	let( cb_bev = wing_slot_counterbore_depth_mm )
	// If top of counterbore would be into the bevel, then just extend it out the top
	let( cb_top = cb_rad + wing_slot_z1 > size_mm[2] - block_bevel ? size_mm[2]+cb_rad*2 : wing_slot_z1 + cb_rad )
	let( wing_counterbore = (cb_rad <= 0 || cb_bev <= 0) ? ["union"] : tphl1_make_polyhedron_from_layer_function(
		[
			[-cb_bev  , 0       ],
			[ cb_bev  , cb_bev*2],
		],
		function(zo) togpath1_rath_to_polypoints(["togpath1-rath",
			["togpath1-rathnode", [ cb_rad, wing_slot_z0-cb_rad], ["round", cb_rad*($fn-1)/$fn], ["offset", zo[1]]],
			["togpath1-rathnode", [ cb_rad, cb_top             ], ["round", cb_rad*($fn-1)/$fn], ["offset", zo[1]]],
			["togpath1-rathnode", [-cb_rad, cb_top             ], ["round", cb_rad*($fn-1)/$fn], ["offset", zo[1]]],
			["togpath1-rathnode", [-cb_rad, wing_slot_z0-cb_rad], ["round", cb_rad*($fn-1)/$fn], ["offset", zo[1]]],
		], $fn=max($fn,min($fn*2,144))),
		layer_points_transform="key0-to-z"
	))
	let( wing_slot = ["union",
		wing_slot_straight_part,
	   ["translate", [0,-size_mm[1]/2,0], ["rotate-xyz", [90,0,  0], wing_counterbore]],
	   ["translate", [0, size_mm[1]/2,0], ["rotate-xyz", [90,0,180], wing_counterbore]],
	])
	let( bottom_atom_hole = ["rotate", [180,0,0], tog_holelib2_hole(bottom_atom_hole_style, depth=wing_slot_z0)] )
	["difference",
		["translate", [0,0,size_mm[2]/2],
			tphl1_make_rounded_cuboid(
				[size_mm[0], size_mm[1], size_mm[2]],
				r=[block_bevel*3/2,block_bevel*3/2,block_bevel], corner_shape="cone2"
			)],
		
		["difference",
			["union",
				let( slot_width = size_mm[1]-wing_thickness_mm*2 )
				let( slot_bev = 1.6 )
				// Hmm: This doesn't quite bevel the top as nicely as I'd like, but I suppose good enough for starters.
				togmod1_linear_extrude_z(
					[base_thickness_mm, size_mm[2]+11],
					togpath1_rath_to_polygon(["togpath1-rath",
						["togpath1-rathnode", [ size_mm[0]/2 + slot_bev,  slot_width/2 + slot_bev*2]],
						["togpath1-rathnode", [ size_mm[0]/2 - slot_bev,  slot_width/2             ]],
						["togpath1-rathnode", [-size_mm[0]/2 + slot_bev,  slot_width/2             ]],
						["togpath1-rathnode", [-size_mm[0]/2 - slot_bev,  slot_width/2 + slot_bev*2]],
						["togpath1-rathnode", [-size_mm[0]/2 - slot_bev, -slot_width/2 - slot_bev*2]],
						["togpath1-rathnode", [-size_mm[0]/2 + slot_bev, -slot_width/2             ]],
						["togpath1-rathnode", [ size_mm[0]/2 - slot_bev, -slot_width/2             ]],
						["togpath1-rathnode", [ size_mm[0]/2 + slot_bev, -slot_width/2 - slot_bev*2]],
					])
				),
								
				for( xm=[-size_chunks[0]/2 + 0.5 : 1/base_slot_frequency : size_chunks[0]/2-0.5] )
				["translate", [xm*chunk_mm,0,0], base_slot],
				
				for( xm=[-size_chunks[0]/2 + 0.5 : 1/wing_slot_frequency : size_chunks[0]/2-0.5] )
				["translate", [xm*chunk_mm,0,0], wing_slot],
				
				for( xm=[-size_atoms[0]/2 + 0.5 : 1 : size_atoms[0]/2 - 0.5] )
				for( ym=[-size_atoms[1]/2 + 0.5 : 1 : size_atoms[1]/2 - 0.5] )
				["translate", [xm*atom_mm, ym*atom_mm, 0], bottom_atom_hole],
			],
			
			if( bottom_membrane_thickness_mm > 0 ) togmod1_make_cuboid([size_mm[0]+10, size_mm[1]+10, bottom_membrane_thickness_mm*2]),
		]
	]
);
