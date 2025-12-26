// DovetailSlotExtensionPanel2.0
// 
// Do your dovetail slot nuts stick
// out the top of the slots?
// Need to add some extra depth?
// This type of panel is for you.

panel_width = "3inch";
panel_length = "9inch";
panel_thickness = "3/4inch";

preview_fn = 24;
render_fn = 72;

module __dovetailslotextensionpanel2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/Flangify0.scad>
use <../lib/TOGPolyhedronLib1.scad>

$fn = $preview ? preview_fn : render_fn;

panel_width_mm      = togunits1_to_mm( panel_width     );
cb_width_mm         = togunits1_to_mm( "7/16inch"      );
panel_length_mm     = togunits1_to_mm( panel_length    );
panel_length_chunks = togunits1_decode(panel_length, unit="chunk", xf="round");
panel_width_chunks  = togunits1_decode(panel_width, unit="chunk", xf="round");
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
	let( hole_width = 7 /* just under 5/16" */ )
	let( e = 1/256 ) // A small number
	
	//let( counterbore_rath = togpath1_make_rectangle_rath([panel_length_mm*2, cb_width_mm], $fn=6) ) // Whatever for now
	let( counterbore_rath = ["togpath1-rath",
		["togpath1-rathnode", [ panel_length_mm       ,  cb_width_mm  ]              ],
		["togpath1-rathnode", [ panel_length_mm/2 + e ,  cb_width_mm  ]              ],
		["togpath1-rathnode", [ panel_length_mm/2 + e ,  cb_width_mm/2], ["round", 5]],
		["togpath1-rathnode", [-panel_length_mm/2 - e ,  cb_width_mm/2], ["round", 5]],
		["togpath1-rathnode", [-panel_length_mm/2 - e ,  cb_width_mm  ]              ],
		["togpath1-rathnode", [-panel_length_mm       ,  cb_width_mm  ]              ],
		["togpath1-rathnode", [-panel_length_mm       , -cb_width_mm  ]              ],
		["togpath1-rathnode", [-panel_length_mm/2 - e , -cb_width_mm  ]              ],
		["togpath1-rathnode", [-panel_length_mm/2 - e , -cb_width_mm/2], ["round", 5]],
		["togpath1-rathnode", [ panel_length_mm/2 + e , -cb_width_mm/2], ["round", 5]],
		["togpath1-rathnode", [ panel_length_mm/2 + e , -cb_width_mm  ]              ],
		["togpath1-rathnode", [ panel_length_mm       , -cb_width_mm  ]              ],
	])
	
	let( straight_hole_zdopses = ["zdopses",
		["zdops", [-panel_thickness_mm/2-e, hole_width + 10]],
		["zdops", [-panel_thickness_mm/2-e, hole_width     ], ["round", 2]],
		["zdops", [ panel_thickness_mm/2+e, hole_width     ], ["round", 2]],
		["zdops", [ panel_thickness_mm/2+e, hole_width + 10]],
	])
	let( cb_depth = 6.35 ) // Let's say
	let( counterbore_zdopses = ["zdopses",
		["zdops", [ panel_thickness_mm/2-cb_depth, 0     ]],
		["zdops", [ panel_thickness_mm/2+e       , 0     ], ["round", 2]],
		["zdops", [ panel_thickness_mm/2+e       , 0 + 10]],
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
		
		// Monitor mount slots
		let( slot_pitch = panel_length_chunks%3 == 0 ? 3 : panel_length_chunks%2 == 0 ? 2 : 3 )
		for( xm=[-1,1] )
		let( slot_points = [[xm*0.25*chunk, 0], [xm*(panel_length_mm/2-1*chunk), 0]] )
		flangify0_extrude_z(
			shape = ["togpath1-polyline", each slot_points],
			zrs = flangify0_spec_to_zrs(flangify0_extend(10, 10, straight_hole_zdopses))
		),

		// Panel mount slots
		let( slot_pitch = panel_length_chunks%3 == 0 ? 3 : panel_length_chunks%2 == 0 ? 2 : 3 )
		for( xm=[-1,1] )
		let( slot_points = [[xm*(panel_length_mm/2-0.6*chunk), 0], [xm*(panel_length_mm/2-0.25*chunk), 0]] )
		flangify0_extrude_z(
			shape = ["togpath1-polyline", each slot_points],
			zrs = flangify0_spec_to_zrs(flangify0_extend(10, 10, straight_hole_zdopses))
		),
		
		// Counterbore / panel mount slot extension
		flangify0_extrude_z(
			shape = counterbore_rath,
			zrs = flangify0_spec_to_zrs(flangify0_extend(0, 10, counterbore_zdopses))
		),

		// Pooping butts
		for( xm=[-panel_length_chunks/2+0.5 : 1 : panel_length_chunks/2-0.4] )
		for( ym=[-panel_width_chunks/2+0.5 : 1 : panel_width_chunks/2-0.4] )
		if( ym != 0 )
		["translate", [xm,ym,0]*chunk, phole],
	]
);
