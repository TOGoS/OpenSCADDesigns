// HollowRail0.2
// 
// v0.2
// - Skip generating cavity when appropriate
// - Make diamond holes a little smaller, 4mm instead of 4.5mm
// 
// TODO: Round some bits more
// TODO: Bulkheads every 3 atoms or so in the cavity

length = "15atom";
height = "1inch";
$tgx11_offset = -0.1;
top_thickness = "1/4inch";
bottom_thickness = "1/4inch";
back_thickness = "3/32inch";
end_thickness = "1u";
$fn = 24;

module hollowrail0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

length_atoms = togunits1_decode(length, [1, "atom"]);
length_mm = togunits1_to_mm(length);
height_mm = togunits1_to_mm(height);
width_mm  = togunits1_to_mm([1,"atom"]);
back_thickness_mm  = togunits1_to_mm(back_thickness);
top_thickness_mm  = togunits1_to_mm(top_thickness);
bottom_thickness_mm  = togunits1_to_mm(bottom_thickness);
end_thickness_mm  = togunits1_to_mm(end_thickness);
atom_mm = togunits1_to_mm([1, "atom"]);

hole = togmod1_linear_extrude_z([-height_mm, height_mm], togmod1_make_circle(d=4, $fn=4));

togmod1_domodule(["difference",
	tphl1_make_rounded_cuboid([
		length_mm + $tgx11_offset*2,
		width_mm  + $tgx11_offset*2,
		height_mm + $tgx11_offset*2,
	], r=[2,0,2]),
	
	if( back_thickness_mm < width_mm && height_mm - top_thickness_mm - bottom_thickness_mm > 0 )
	togmod1_linear_extrude_x([-length_mm/2+end_thickness_mm, length_mm/2-end_thickness_mm], togmod1_make_polygon(
		let(y0 = -width_mm/2 + back_thickness_mm, y1 = +width_mm/2 + 1)
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
	
	for( xm=[-length_atoms/2+0.5 : 1 : length_atoms/2-0.4] ) ["translate", [xm*atom_mm, 0, 0], hole],
]);
