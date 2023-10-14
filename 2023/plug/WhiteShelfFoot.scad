// WhiteShelfFoot-v1.1
// 
// Replacement feet for the white shelves Sara
// dragged home from Rich Bitch Land
// 
// v1.1:
// - Define 'stem margin' with default 0.2

main_height   =  9.8;
main_diameter = 18.4;
stem_diameter =  8.0;
total_height  = 18.8;

stem_margin = 0.1;

top_bevel_size = 0.5;
mouth_bevel_size = 0.5;
bottom_bevel_size = 0.5;

stem_height = total_height - main_height;

$fn = $preview ? 16 : 96;

rotate_extrude() polygon([
	[                                 0  ,  stem_height    ],
	[-stem_diameter/2 - stem_margin + 1.3,  stem_height    ],
	[-stem_diameter/2 - stem_margin + 0.2,  stem_height - 4],
	[-stem_diameter/2 - stem_margin      , mouth_bevel_size],
	[-stem_diameter/2 - stem_margin - mouth_bevel_size,   0],

	[-main_diameter/2 + bottom_bevel_size,                0],
	[-main_diameter/2                    ,bottom_bevel_size],
	[-main_diameter/2                    ,  main_height - top_bevel_size],
	[-main_diameter/2 + top_bevel_size   ,  main_height     ],

	[-stem_diameter/2 + stem_margin      ,  main_height     ],
	[-stem_diameter/2 + stem_margin      , total_height  - 4],
	[-stem_diameter/2 + stem_margin  + 1.5, total_height    ],
	[                                  0  , total_height    ],
]);
