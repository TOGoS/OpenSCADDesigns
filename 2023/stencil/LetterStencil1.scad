// LetterStencil1.2
// 
// Simple stencils, based on a font.
// User indicates hull size.
// 
// v1.1:
// - Option for pocket in top left corner
// v1.2:
// - Adjust corner radius for very small panels

text = "WSITEM-";
font_name = "Prototype";
font_size = "2.25inch";
height = "3inch";
width = "12.5inch";
thickness = "1/8inch";
central_bar_width = "0mm";
central_bar_position = "full"; // ["full","top","bottom"]
dot_position = ""; // ["", "top-left"]
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGUnits1.scad>
use <../lib/Prototype.ttf>


font_size_mm = togunits1_to_mm(font_size);
width_mm     = togunits1_to_mm(width    );
height_mm    = togunits1_to_mm(height   );
thickness_mm = togunits1_to_mm(thickness);
central_bar_width_mm = togunits1_to_mm(central_bar_width);

central_bar_2d =
	central_bar_width_mm <= 0 ? ["union"] :
	["translate", [0, central_bar_position == "full" ? 0 : central_bar_position == "top" ? height_mm*1/3 : -height_mm*1/3],
		togmod1_make_rect([central_bar_width_mm, height_mm+2])
	];

togmod1_domodule(["difference",
	let( max_corner_radius = min(width_mm, height_mm)*($fn-1)/($fn*2) )
	togmod1_linear_extrude_z([0, thickness_mm], ["difference",
		togmod1_make_rounded_rect([width_mm, height_mm], r=min(1.6, max_corner_radius) ),
		
		["difference",
			togmod1_text(text, size=font_size_mm, font=font_name, halign="center", valign="center"),
			central_bar_2d,
		]
	]),
	
	if( dot_position == "top-left" ) ["translate", [-width_mm/2, height_mm/2],
		togmod1_linear_extrude_z([thickness_mm/2, thickness_mm+1],
			togmod1_make_rounded_rect([6.35,6.35], r=1))]
]);
