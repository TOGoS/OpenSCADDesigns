// PanelUConnector1.1
// 
// U-shaped connector for attaching
// one gridbeam panel (that fits inside the "U")
// perpendicular to another (that bolts under it)
// 
// v1.1:
// - Add bottom atom holes
// - Add optional bottom membrane

base_thickness = "1/2inch";
wing_thickness = "1/2inch";
width = "1chunk";
total_height = "2inch";
length = "1chunk";
base_slot_diameter = "5/16inch";
base_slot_length = "0mm";
base_slot_frequency = 2;
wing_slot_diameter = "5/16inch";
wing_slot_frequency = 2;

bottom_atom_hole_style = "diamond-4.5mm";

bottom_membrane_thickness = "0.3mm";

$fn = 24;

module __paneluconnector__end_params() { }

// Not parameters:
// wing_slot_length = "0mm"; // Implied by total_height, yaddah yaddah

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

size = [length, width, total_height];

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

bottom_membrane_thickness_mm = togunits1_to_mm(bottom_membrane_thickness);

togmod1_domodule(
	let( base_slot = tphl1_make_rounded_cuboid(
		[base_slot_length_mm+base_slot_diameter_mm, base_slot_diameter_mm, base_thickness_mm*3],
		r = let(r=base_slot_diameter_mm*127/256) [r,r,0]
	))
	let( wing_slot_z0 = base_thickness_mm + wing_slot_diameter_mm * 3/2 )
	let( wing_slot_z1 = size_mm[2]   - wing_slot_diameter_mm * 3/2 )
	let( wing_slot = ["rotate", [90,0,0], ["translate", [0,(wing_slot_z0+wing_slot_z1)/2,0], tphl1_make_rounded_cuboid(
		[wing_slot_diameter_mm, wing_slot_z1-wing_slot_z0+wing_slot_diameter_mm, size_mm[1]*2 + 2],
		r = let(r=wing_slot_diameter_mm*127/256) [r,r,0]
	)]])
	let( bottom_atom_hole = ["rotate", [180,0,0], tog_holelib2_hole(bottom_atom_hole_style, depth=wing_slot_z0)] )
	// TODO: Beveled counterbores for wing slots, 1/8" deep or so
	["difference",
		["translate", [0,0,size_mm[2]/2],
			tphl1_make_rounded_cuboid(
				[size_mm[0], size_mm[1], size_mm[2]],
				r=[5,5,3.175], corner_shape="cone2"
			)],
		
		["difference",
			["union",
				// Cut out center.
				// Hmm: it'd be nice to round the edges somewhat.
				["translate", [0,0,size_mm[2]],
					togmod1_make_cuboid(
						[size_mm[0]+2, size_mm[1]-wing_thickness_mm*2, (size_mm[2]-base_thickness_mm)*2])],
				
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
