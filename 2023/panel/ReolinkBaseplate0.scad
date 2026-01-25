// ReolinkBaseplate0.1
// 
// Panel for mounting Reolink bullet cameras

$fn = 96;
$tgx11_offset = -0.15;

module __reolinkbaseplate0__end_params() { }

panel_size = ["3inch", "6inch", "3/4inch"];
groove_size = ["1+1/8inch", "3/8inch"];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

$togridlib3_unit_table = [
	["tgp-m-outer-corner-radius", [3, "u"]],
	each tgx11_get_default_unit_table()
];

atom = togunits1_to_mm("atom");

panel_size_ca = togunits1_vec_to_cas(panel_size);
panel_size_mm = togunits1_vec_to_mms(panel_size);
panel_size_atoms = togunits1_decode_vec(panel_size, unit="atom");
groove_size_mm = togunits1_vec_to_mms(groove_size);

togmod1_domodule(

	let( panel_hull = ["translate", [0,0,-panel_size_mm[2]/2], tgx11_block(panel_size_ca, top_segmentation="none", bottom_v6hc_style="none", bottom_foot_bevel=0.4, bottom_segmentation="atom")] )
	//let( center_hole = tphl1_make_z_cylinder(d=32, zrange=[-panel_size_mm[2], panel_size_mm[2]]) )
	let( center_hole =
		let( zb = -panel_size_mm[2]/2 )
		let( zm =  0                  )
		let( zt =  panel_size_mm[2]/2 )
		tphl1_make_z_cylinder(zds=[
			[zm - 32, 32+64],
			[zm     , 32   ],
			[zt - 2 , 32   ],
			[zt + 2 , 32+ 8]
		])
	)
	let( groove2d = togmod1_make_rounded_rect([groove_size_mm[0], groove_size_mm[1]*2], r=min(groove_size_mm[0]/2, groove_size_mm[1])*128/128) )
	let( cam_mounting_hole_dist_mm = 24/cos(30) )
	let( cam_mounting_hole = ["render", ["union",
		["rotate", [180,0,0], tog_holelib2_hole("THL-1005", inset=panel_size_mm[2]/2, depth=panel_size_mm[2]*2)],
	]] )
	let( panel_mounting_hole = ["render", tog_holelib2_hole("THL-1005", inset=panel_size_mm[2]/2, depth=panel_size_mm[2]*2)] )

	["difference",
		panel_hull,
		
		center_hole,
		["translate", [0,0,-panel_size_mm[2]/2], ["union",
			togmod1_linear_extrude_x([-panel_size_mm[0], panel_size_mm[0]], groove2d),
			togmod1_linear_extrude_y([-panel_size_mm[1], panel_size_mm[1]], groove2d),
		]],
		// Cutout to remove useless atom foot fragments around cam mounting holes:
		togmod1_linear_extrude_z([-panel_size_mm[2]/2-1, -panel_size_mm[2]/2 + 6.35], togmod1_make_rounded_rect([4*atom, 4*atom], r=1.6)),
		
		for( a=[15:30:360-1] ) ["rotate", [0,0,a], ["translate", [cam_mounting_hole_dist_mm,0,-panel_size_mm[2]/2], cam_mounting_hole]],
		
		for( ya=[-panel_size_atoms[1]/2 + 0.5 : 1 : panel_size_atoms[1]/2] )
		for( xa=[-panel_size_atoms[0]/2 + 0.5 : 1 : panel_size_atoms[0]/2] )
		if( (sqrt(xa*xa+ya*ya)-0.5)*atom > cam_mounting_hole_dist_mm ) ["translate", [xa*atom, ya*atom, panel_size_mm[2]/2], panel_mounting_hole],
	]
);
