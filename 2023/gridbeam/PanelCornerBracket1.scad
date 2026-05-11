// PanelCornerBracket1.4
// 
// Build 'gridbeam' structures with only panels;
// no actual gridbeam required!
// Use these inside corners.
// May require bolts or nuts with small heads.
// 
// v1.1:
// - Round coners using tphl1_make_rounded_cuboid.
//   This is one way to get that done, but maybe not the best way.
// v1.2:
// - More holes.
// v1.3:
// - Bevel / round corners more nicely.
// v1.4:
// - Higher $fn for large-radius curves.
// 
// TODO: Cutout in inner corner in one direction for weld nut.
// 
// TODO: Hollow interior for filling with epoxy, for strenk?
// 
// TODO: Improve diagonal edge/hole overlap avoidance.

size_x = "3chunk";
size_y = "3chunk";
size_z = "3chunk";
thickness = "3/8inch";
edge_bevel = "1u";
$fn = 32;

module __panelcornerbracket1__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

size          = [size_x, size_y, size_z];
size_chunks   = togunits1_decode_vec(size, unit="chunk", xf="round");
size_mm       = togunits1_vec_to_mms(size);
chunk_mm      = togunits1_to_mm("chunk");
thickness_mm  = togunits1_to_mm(thickness);
edge_bev_mm   = togunits1_to_mm(edge_bevel);
face_round_mm = edge_bev_mm;

togmod1_domodule(
	let( ex1 = size_chunks[0]-0.5, ey1 = size_chunks[1]-0.5, ez1 = size_chunks[2]-0.5 )
	// TODO: Chop off more of corners
	// TODO: Round corners nicely?
	let( z_hole = tphl1_make_z_cylinder(zrange=[-thickness_mm/2-1, thickness_mm/2+1], d=9) )
	let( x_hole = ["rotate", [0,90,0], z_hole] )
	let( y_hole = ["rotate", [90,0,0], z_hole] )
	let( x0 = 0, y0 = 0, z0 = 0 ) // TODO, maybe: allow these to be overridden as x/y/z inset, or as outer_{x,y,z}0
	let( make_face_polygon = function(nom_size, inset)
		let(    enl_nom_size=[for(i=[0,1]) nom_size[i] + 100] ) // 100 is hopefully larger than 2*inset + 2*bev
		let( enl_actual_size=[for(i=[0,1]) enl_nom_size[i] - inset[i]*2 - edge_bev_mm*2] )
		["translate", [enl_nom_size[0]/2, enl_nom_size[1]/2], togmod1_make_rounded_rect(enl_actual_size, r=face_round_mm)]
	)
	let( the_cube = ["hull",
		togmod1_linear_extrude_x([x0,size_mm[0]+10], make_face_polygon([size_mm[1], size_mm[2]], [y0, z0])),
		togmod1_linear_extrude_y([y0,size_mm[1]+10], make_face_polygon([size_mm[0], size_mm[2]], [x0, z0])),
		togmod1_linear_extrude_z([z0,size_mm[2]+10], make_face_polygon([size_mm[0], size_mm[1]], [x0, y0])),
	])
	let( make_xc_polygon = function(size) togpath1_rath_to_polygon(["togpath1-rath",
		["togpath1-rathnode", [-10          , -10          ]],
		["togpath1-rathnode", [ size[0]     , -10          ]],
		["togpath1-rathnode", [ size[0]     ,  chunk_mm*2/3], ["round", chunk_mm/2]],
		["togpath1-rathnode", [ chunk_mm*2/3,  size[1]     ], ["round", chunk_mm/2]],
		["togpath1-rathnode", [-10          ,  size[1]     ]],
	], $fn=max($fn, min($fn*2, 64))) )
	let( the_hull = ["intersection",
		the_cube,
		togmod1_linear_extrude_x([x0,size_mm[0]+1], make_xc_polygon([size_mm[1], size_mm[2]])),
		togmod1_linear_extrude_y([y0,size_mm[1]+1], make_xc_polygon([size_mm[0], size_mm[2]])),
		togmod1_linear_extrude_z([z0,size_mm[2]+1], make_xc_polygon([size_mm[0], size_mm[1]])),
	])
	["difference",
		the_hull,
		
		["translate", [thickness_mm + 100, thickness_mm + 100, thickness_mm + 100], togmod1_make_cuboid([200,200,200])],
		
		for( zm=[0.5 : 0.5 : size_chunks[2]-0.5] )
		for( xm=[0.5 : 0.5 : size_chunks[0]-0.5] )
		if( (xm % 1 == 0.5 && zm % 1 == 0.5) || xm == 0.5 || zm == 0.5 )
		["translate", [xm*chunk_mm, thickness_mm/2, zm*chunk_mm], y_hole],
		
		for( xm=[0.5 : 0.5 : size_chunks[0]-0.5] )
		for( ym=[0.5 : 0.5 : size_chunks[1]-0.5] )
		if( (xm % 1 == 0.5 && ym % 1 == 0.5) || xm == 0.5 || ym == 0.5 )
		["translate", [xm*chunk_mm, ym*chunk_mm, thickness_mm/2], z_hole],
		
		for( ym=[0.5 : 0.5 : size_chunks[1]-0.5] )
		for( zm=[0.5 : 0.5 : size_chunks[2]-0.5] )
		if( (ym % 1 == 0.5 && zm % 1 == 0.5) || ym == 0.5 || zm == 0.5 )
		["translate", [thickness_mm/2, ym*chunk_mm, zm*chunk_mm], x_hole],
	]
);
