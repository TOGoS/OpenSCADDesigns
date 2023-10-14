// WhiteShelfFoot-v1.2
// 
// Replacement feet for the white shelves Sara
// dragged home from Rich Bitch Land
// 
// v1.0:
// - Original design which became p1242, which FIT JUST FINE
//   after removing the broken piece of the old feet
//   that were in the holes that were missing feet
// v1.1:
// - Define 'stem margin' with default 0.2
// v1.2:
// - Default stem_diameter = 7.0, stem_margin = 0.15
// - Forget about making them stackable, by default

main_height   =  9.8;
main_diameter = 18.4;
stem_diameter =  7.0;
total_height  = 18.8;

stem_margin   =  0.15;

top_bevel_size = 0.5;
mouth_bevel_size = 0.5;
bottom_bevel_size = 0.5;

stackable = false;

stem_height = total_height - main_height;

$fn = $preview ? 16 : 96;

rotate_extrude() polygon([
	each stackable ? [
		// Negative stem
		[                                 0  ,  stem_height    ],
		[-stem_diameter/2 - stem_margin + 1.3,  stem_height    ],
		[-stem_diameter/2 - stem_margin + 0.2,  stem_height - 4],
		[-stem_diameter/2 - stem_margin      , mouth_bevel_size],
		[-stem_diameter/2 - stem_margin - mouth_bevel_size,   0],
	] : [
		[0,0]
	],

	// Main body
	[-main_diameter/2 + bottom_bevel_size,                0],
	[-main_diameter/2                    ,bottom_bevel_size],
	[-main_diameter/2                    ,  main_height - top_bevel_size],
	[-main_diameter/2 + top_bevel_size   ,  main_height     ],

	// Positive stem
	[-stem_diameter/2 + stem_margin      ,  main_height     ],
	[-stem_diameter/2 + stem_margin      , total_height  - 4],
	[-stem_diameter/2 + stem_margin  + 1.5, total_height    ],
	[                                  0  , total_height    ],
]);
