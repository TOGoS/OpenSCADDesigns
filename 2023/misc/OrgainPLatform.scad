// OrgainPlatform-v1.1
// 
// Platform to hold a teeter-totter for Renee's Orgain
// v1.1:
// - What if kinda TOGridPile baseplate?

lip_height = 0; // 0.0001
$tgx11_offset = -0.2;

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronlib1.scad>
use <../lib/TOGHoleLib2.scad>

module __asda_end_params() { }

magnet_hole_diameter = 6.2; // 0.1
magnet_hole_depth    = 2.4; // 0.1

fan_hole_spacing = 105;
fan_hole_diameter = 5; // *shrug*
// 5m will be fine for a #6 (0.138 = 3.51mm) and
// probably #8 (0.164" = 4.17mm) 3.96875

inch = 25.4;
u = inch/16;

hull_size = [
	5*inch, 5*inch, 0.25*inch
];
hullpluslip_size = [
	hull_size[0], hull_size[1], hull_size[2] + lip_height
];
$fn = $preview ? 24 : 72;

cshole = tog_holelib2_hole("THL-1005", depth=hullpluslip_size[2]*2, overhead_bore_height=lip_height*2);
magnet_hole = tphl1_make_z_cylinder(d=magnet_hole_diameter, zrange=[-magnet_hole_depth, magnet_hole_depth]);

function make_tgp_cutout(chunk_pitch, atom_pitch=12.7, include_cshole=false, include_magnet_holes=false) = ["union",
	["translate", [0,0,chunk_pitch/2],
		tphl1_make_rounded_cuboid(
			[chunk_pitch - 2*u + $tgx11_offset*2, chunk_pitch - 2*u + $tgx11_offset*2, chunk_pitch],
			[u, u, 0]
		)
	],
	if( include_cshole ) cshole,
	if( include_magnet_holes ) ["union", for(xm=[-1,1]) for(ym=[-1,1]) ["translate", [xm*atom_pitch, ym*atom_pitch, 0], magnet_hole]]
];

central_tgp_cutout = make_tgp_cutout(38.1, include_cshole=true , include_magnet_holes=true);
edge_tgp_cutout    = make_tgp_cutout(38.1, include_cshole=false, include_magnet_holes=true);
corner_tgp_cutout  = make_tgp_cutout(38.1, include_cshole=false);

togmod1_domodule(["difference",
	["translate", [0,0,hullpluslip_size[2]/2], tphl1_make_rounded_cuboid(hullpluslip_size, [9.525, 9.525, u], corner_shape="ovoid1")],
	for( xm=[-1,1] ) for( ym=[-1,1] ) ["translate", [xm*fan_hole_spacing/2, ym*fan_hole_spacing/2, hull_size[2]], cshole],
	//for( ym=[-1,0,1] ) ["translate", [0,ym*19.05,0], ["rotate", [180,0,0], cshole]],
	if( lip_height > 0 ) ["translate", [0,0,hull_size[2]], ["union",
		for( xm=[-1.5:1:1.5] ) for( ym=[-1.5:1:1.5] ) ["translate", [xm*38.1, ym*38.1, 0],
			abs(xm)+abs(ym) > 2 ? corner_tgp_cutout :
			abs(xm)+abs(ym) > 1 ? edge_tgp_cutout :
			central_tgp_cutout
		]
	]]
]);
