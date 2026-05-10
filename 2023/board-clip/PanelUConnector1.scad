// PanelUConnector1.0
// 
// U-shaped connector for attaching
// one gridbeam panel (that fits inside the "U")
// perpendicular to another (that bolts under it)

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
$fn = 24;

module __paneluconnector__end_params() { }

// Not parameters:
// wing_slot_length = "0mm"; // Implied by total_height, yaddah yaddah

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

chunk_mm              = togunits1_to_mm("chunk");
width_mm              = togunits1_to_mm(width);
length_mm             = togunits1_to_mm(length);
length_chunks         = togunits1_decode(length, unit="chunk");
total_height_mm       = togunits1_to_mm(total_height);
base_thickness_mm     = togunits1_to_mm(base_thickness);
base_slot_diameter_mm = togunits1_to_mm(base_slot_diameter);
base_slot_length_mm   = togunits1_to_mm(base_slot_length);
wing_thickness_mm     = togunits1_to_mm(wing_thickness);
wing_slot_diameter_mm = togunits1_to_mm(wing_slot_diameter);

togmod1_domodule(
	let( base_slot = tphl1_make_rounded_cuboid(
		[base_slot_length_mm+base_slot_diameter_mm, base_slot_diameter_mm, base_thickness_mm*3],
		r = let(r=base_slot_diameter_mm*127/256) [r,r,0]
	))
	let( wing_slot_z0 = base_thickness_mm + wing_slot_diameter_mm * 3/2 )
	let( wing_slot_z1 = total_height_mm   - wing_slot_diameter_mm * 3/2 )
	let( wing_slot = ["rotate", [90,0,0], ["translate", [0,(wing_slot_z0+wing_slot_z1)/2,0], tphl1_make_rounded_cuboid(
		[wing_slot_diameter_mm, wing_slot_z1-wing_slot_z0+wing_slot_diameter_mm, width_mm*2 + 2],
		r = let(r=wing_slot_diameter_mm*127/256) [r,r,0]
	)]])
	// TODO: Beveled counterbores for wing slots, 1/8" deep or so
	["difference",
		["translate", [0,0,total_height_mm/2],
			tphl1_make_rounded_cuboid(
				[length_mm, width_mm, total_height_mm],
				r=[5,5,3.175], corner_shape="cone2"
			)],
		
		// Cut out center.
		// Hmm: it'd be nice to round the edges somewhat.
		["translate", [0,0,total_height_mm],
			togmod1_make_cuboid(
				[length_mm+2, width_mm-wing_thickness_mm*2, (total_height_mm-base_thickness_mm)*2])],
		
		for( xm=[-length_chunks/2 + 0.5 : 1/base_slot_frequency : length_chunks/2-0.5] )
		["translate", [xm*chunk_mm,0,0], base_slot],
		
		for( xm=[-length_chunks/2 + 0.5 : 1/wing_slot_frequency : length_chunks/2-0.5] )
		["translate", [xm*chunk_mm,0,0], wing_slot],
		
		// TODO: 4.5m diamond holes in bottom for #6s on atom centers
	]
);
