// LetterStencil1.0
// 
// Simple stencils, based on a font.
// User indicates hull size.
// 
// TODO: Have a pocket to mark the top left corner or something
// so it's more obvious which way is right-side-up when the font has
// e.g. "0"s that are just slightly asymmetrical.

text = "WSITEM-";
font_name = "Prototype";
font_size = "2.25inch";
height = "3inch";
width = "12.5inch";
thickness = "1/8inch";
central_bar_width = "0mm";
central_bar_position = "full"; // ["full","top","bottom"]
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

togmod1_domodule(
	togmod1_linear_extrude_z([0, thickness_mm], ["difference",
		togmod1_make_rounded_rect([width_mm, height_mm], r=1.6),
		["difference",
			togmod1_text(text, size=font_size_mm, font=font_name, halign="center", valign="center"),
			central_bar_2d,
		]
	])
);
