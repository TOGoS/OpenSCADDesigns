// HollowRail0.3
// 
// v0.2
// - Skip generating cavity when appropriate
// - Make diamond holes a little smaller, 4mm instead of 4.5mm
// v0.3:
// - back_y, front_y now configurable, so you can make narrower (or thicker) rails
// - Multiple rounded cutouts instead of one big sharp-cornered one

length = "15atom";
height = "1inch";
// Offset to apply to outer surfaces, usually a small negative value to provide 'wiggle room'
$tgx11_offset = -0.1;
back_y = "-1/4inch";
front_y = "1/4inch";
top_thickness = "1/4inch";
bottom_thickness = "1/4inch";
back_thickness = "3/32inch";
end_thickness = "1u";
$fn = 24;

module hollowrail0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

length_atoms = togunits1_decode(length, [1, "atom"]);
length_mm = togunits1_to_mm(length);
height_mm = togunits1_to_mm(height);
back_thickness_mm  = togunits1_to_mm(back_thickness);
top_thickness_mm  = togunits1_to_mm(top_thickness);
bottom_thickness_mm  = togunits1_to_mm(bottom_thickness);
end_thickness_mm  = togunits1_to_mm(end_thickness);
atom_mm = togunits1_to_mm([1, "atom"]);
back_y_mm  = togunits1_to_mm(back_y);
front_y_mm = togunits1_to_mm(front_y);

length_chunks = round(length_atoms/3);

hole = togmod1_linear_extrude_z([-height_mm, height_mm], togmod1_make_circle(d=4, $fn=4));

togmod1_domodule(["difference",
	togmod1_linear_extrude_y([back_y_mm-$tgx11_offset, front_y_mm+$tgx11_offset], togmod1_make_rounded_rect([length_mm+$tgx11_offset*2, height_mm+$tgx11_offset*2], r=2)),
	
	// 'hollow' bits
	if( back_thickness_mm < (front_y_mm-back_y_mm) && height_mm - top_thickness_mm - bottom_thickness_mm > 0 )
	for( xm=[-length_atoms/2 + 1.5 : 3 : length_atoms/2+1.5] )
	let( cx0 = max(-length_mm/2 + end_thickness_mm, (xm-1.5)*atom_mm + end_thickness_mm/2) )
	let( cx1 = min( length_mm/2 - end_thickness_mm, (xm+1.5)*atom_mm - end_thickness_mm/2) )
	if( cx1 > cx0 )
	let( cy0 = back_y_mm - $tgx11_offset + back_thickness_mm, cy1 = max(cy0+10, front_y_mm + $tgx11_offset + 1) )
	echo( cy0=cy0, cy1=cy1 )
	let( cz0 = -height_mm/2 + bottom_thickness_mm, cz1 = height_mm/2 - top_thickness_mm )
	let( corner_r = min(5, cx1-cx0, cz1-cz0)*127/256 )
	let( korner_r = min(corner_r, 1.5) )
	["rotate", [-90,0,0], tphl1_make_polyhedron_from_layer_function(
		[
			[cy0         ,-korner_r],
			[cy0+korner_r, 0       ],
			[cy1         , 0       ],
		],
		function(yo)
		   togpath1_rath_to_polypoints(["togpath1-rath",
				// Note that winding order looks backwards when extruding along Y
				["togpath1-rathnode", [cx1,cz0], ["round", corner_r], ["offset", yo[1]]],
				["togpath1-rathnode", [cx1,cz1], ["round", corner_r], ["offset", yo[1]]],
				["togpath1-rathnode", [cx0,cz1], ["round", corner_r], ["offset", yo[1]]],
				["togpath1-rathnode", [cx0,cz0], ["round", corner_r], ["offset", yo[1]]],
			]),
		layer_points_transform = "key0-to-z"
	)],
	/*
	// Old cavity generation as used by p2175
	togmod1_linear_extrude_x([-length_mm/2+end_thickness_mm, length_mm/2-end_thickness_mm], togmod1_make_polygon(
		let(y0 = back_y_mm - $tgx11_offset + back_thickness_mm, y1 = front_y_mm + $tgx11_offset + 1)
		let(z0 = -height_mm/2 + bottom_thickness_mm, z1 = height_mm/2 - top_thickness_mm)
		[
			[y0  , z0+1],
			[y0+1, z0  ],
			[y1  , z0  ],
			[y1  , z1  ],
			[y0+1, z1  ],
			[y0  , z1-1],
		] // Maybe this should be rounded, too, but WHATEVER
	)),
	*/
	
	for( xm=[-length_atoms/2+0.5 : 1 : length_atoms/2-0.4] ) ["translate", [xm*atom_mm, 0, 0], hole],
]);
