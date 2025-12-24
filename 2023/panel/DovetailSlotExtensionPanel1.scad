// DovetailSlotExtensionPanel1.2
// 
// Do your dovetail slot nuts stick
// out the top of the slots?
// Need to add some extra depth?
// This type of panel is for you.
// 
// v1.1:
// - Fix that radius was being interpreted as diameter,
//   making all the holes half the size they should be.
// v1.2:
// - Fix that radius was being interpreted as diameter,
//   making the central slots half the size they should be.

panel_width = "3inch";
panel_length = "9inch";
panel_thickness = "3/4inch";

preview_fn = 24;
render_fn = 72;

module __dovetailslotextensionpanel1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/Flangify0.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? preview_fn : render_fn;

panel_width_mm      = togunits1_to_mm( panel_width     );
panel_length_mm     = togunits1_to_mm( panel_length    );
panel_length_chunks = togunits1_decode(panel_length, unit="chunk", xf="round");
panel_width_chunks = togunits1_decode(panel_width, unit="chunk", xf="round");
panel_thickness_mm  = togunits1_to_mm( panel_thickness );

// Where to start/end slots relative to edge of chunk
slot_x0 = 15;

// Ensure points are in ascending order by X position.
// Otherwise return a single-point list of the average.
function fix_slot_points(points) =
	assert(len(points) == 2, "I only can fix 2-point lists")
	points[0][0] >= points[1][0] ? [[(points[0][0]+points[1][0])/2, points[0][1]]] : points;

togmod1_domodule(
	let( chunk = togunits1_to_mm("chunk") )
	let( panel_hull = tphl1_make_rounded_cuboid([panel_length_mm, panel_width_mm, panel_thickness_mm], r=[19.05, 19.05, 2], corner_shape="ovoid2") )
	let( slot_width = 25.4*3/8 + 1 )
	let( cb_width = 25.4*7/8 )
	let( e = 1/256 ) // A small number
	let( straight_hole_zdopses = ["zdopses",
		["zdops", [-panel_thickness_mm/2-e, slot_width + 10]],
		["zdops", [-panel_thickness_mm/2-e, slot_width     ], ["round", 2]],
		["zdops", [ panel_thickness_mm/2+e, slot_width     ], ["round", 2]],
		["zdops", [ panel_thickness_mm/2+e, slot_width + 10]],
	])
	let( cb_hole_zdopses = ["zdopses",
		["zdops", [-panel_thickness_mm/2-e, slot_width + 10]],
		["zdops", [-panel_thickness_mm/2-e, slot_width     ], ["round", 2  ]],
		["zdops", [                  0    , slot_width     ], ["round", 2  ]],
		["zdops", [                  0    ,   cb_width     ], ["round", 0.5]],
		["zdops", [ panel_thickness_mm/2+e,   cb_width     ], ["round", 2  ]],
		["zdops", [ panel_thickness_mm/2+e,   cb_width + 10]],
	])
	let( phole = 
		let( slot_points = fix_slot_points([[-chunk/2 + slot_x0, 0], [chunk/2 - slot_x0, 0]]) )
		let( e = 1/256 )
		flangify0_extrude_z(
			shape = ["togpath1-polyline", each slot_points],
			zrs = flangify0_spec_to_zrs(flangify0_extend(10, 10, straight_hole_zdopses))
		)
	)
	
	["difference",
		panel_hull,
		
		// Slots
		let( slot_pitch = panel_length_chunks%3 == 0 ? 3 : panel_length_chunks%2 == 0 ? 2 : 3 )
		for( xm0=[-panel_length_chunks/2 : slot_pitch : panel_length_chunks/2 - 0.1] )
		let( to_end = panel_length_chunks/2-0.5 - xm0 )
		// let( xm1 = to_end == 2 ? xm0+2 : min(panel_length_chunks/2-0.5, xm0+1) ) // Make the last slot longer
		let( xm1 = min(panel_length_chunks/2, xm0+slot_pitch) )
		let( slot_points = fix_slot_points([[xm0*chunk + slot_x0, 0], [xm1*chunk - slot_x0, 0]]) )
		flangify0_extrude_z(
			shape = ["togpath1-polyline", each slot_points],
			zrs = flangify0_spec_to_zrs(flangify0_extend(10, 10, straight_hole_zdopses))
		),
		
		// Pooping butts
		for( xm=[-panel_length_chunks/2+0.5 : 1 : panel_length_chunks/2-0.4] )
		for( ym=[-panel_width_chunks/2+0.5 : 1 : panel_width_chunks/2-0.4] )
		if( ym != 0 )
		["translate", [xm,ym,0]*chunk, phole],
	]
);
