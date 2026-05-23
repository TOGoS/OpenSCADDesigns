// ButtonBlock0.2
// 
// Gridbeam-compatible block to hold those 1/2" toggle buttons
// with WSTYPE-4136-compatible holes for #6 screws.
// 
// Heat-set T-nuts into the screw holes from the inside
// to make the bottom be the 'front'.
// 
// Otherwise, have the open side be the front,
// and both interior and external wires can be ring terminal-terminated
// and be screwed down with screws that go through the holes
// and into something else (e.g. a gridrail lamp), in which case
// the corner holes can be used to attach a front panel, if you like.
// 
// v0.2:
// - Rename 'front_thickness' to 'bottom_thickness'
// - Options for front and back chunk center, and front chunk boundary features

length = "4chunk";
width  = "1chunk";
depth  = "3/4inch";
bottom_thickness = "3/16inch";
wall_thickness = "1/8inch";
// Chunk center front feature
ccf_feat = "wire-slot"; // ["none","barrel-inlet","button","wire-slot"]
// Chunk center back feature
ccb_feat = "wire-slot"; // ["none","barrel-inlet","button","wire-slot"]
// Chunk boundary front feature
cef_feat = "button"; // ["none","barrel-inlet","button","wire-slot"]

$tgx11_offset = -0.1;
$fn = 32;

module buttonblock0__end_params() { }

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

function make_hull_rath(bev=3.175, offset=0) = ["togpath1-rath",
	each tal1_duplicate_reversed([
		["togpath1-rathnode", [ size_mm[0]/2,  size_mm[1]/2], ["bevel", bev], ["round", bev], ["offset", offset]],
		
		for( xm=[size_chunks[0]/2 - 1 : -1 : -size_chunks[0]/2 + 1] ) each [
			["togpath1-rathnode", [xm*chunk_mm + bev, size_mm[1]/2      ], ["round", bev], ["offset", offset]],
			["togpath1-rathnode", [xm*chunk_mm      , size_mm[1]/2 - bev],                 ["offset", offset]],
			["togpath1-rathnode", [xm*chunk_mm - bev, size_mm[1]/2      ], ["round", bev], ["offset", offset]],
		],
		
		["togpath1-rathnode", [-size_mm[0]/2,  size_mm[1]/2], ["bevel", bev], ["round", bev], ["offset", offset]],
	], rxf=function(rn) [rn[0], [rn[1][0], -rn[1][1]], for(i=[2:1:len(rn)-1]) rn[i]])
];

function zig_sheath(zig) =
	assert(zig[0] == "difference")
	assert(len(zig) == 3)
	zig[1];
function zig_cut(zig) =
	assert(zig[0] == "difference")
	assert(len(zig) == 3)
	zig[2];

size = [length, width, depth];
size_mm     = togunits1_vec_to_mms(size);
size_chunks = togunits1_decode_vec(size, unit="chunk", xf="round");
size_atoms  = togunits1_decode_vec(size, unit="atom" , xf="round");
chunk_mm    = togunits1_to_mm("chunk");
atom_mm     = togunits1_to_mm("atom");
bottom_thickness_mm = togunits1_to_mm(bottom_thickness);
wall_thickness_mm  = togunits1_to_mm(wall_thickness);

// Post diameter   = 31/ 64" = 12.3mm
// Flange diameter = 71/128" = 14.1mm
// Nut diameter    = 41/ 64" = 16.3mm
// Make panel thickness = 9/32" = 7.1mm
// Bottom of flange to top of button = 1/4" = 6.3mm
// Bottom of flange to ends of terminals = 23mm
button_cutout = tphl1_make_z_cylinder(zds=[[-2, 15], [6.5, 15], [6.5, 13], [11, 13], [11, 17], [6.5+23, 17], [6.5+23+2, 17-4]]);
button_cavity_subtraction = tphl1_make_z_cylinder(zds=[[-1, 21+10], [4, 21], [11+1/128, 21]]);
button_zig = ["difference",
	button_cavity_subtraction,
	button_cutout
];

screw_hole = tphl1_make_z_cylinder(d=5, zrange=[-size_mm[1], size_mm[1]]);

wire_slot_zig = ["difference",
	["union"],
	togmod1_linear_extrude_z([-1, size_mm[1]/2+1], togpath1_rath_to_polygon(["togpath1-rath",
		each tal1_duplicate_reversed([
			["togpath1-rathnode", [3.175, -3.175], ["round", 3.175*($fn-1)/$fn]],
			["togpath1-rathnode", [3.175, size_mm[2]/2 - 4], ["round", 6.35]],
			["togpath1-rathnode", [3.175 + 8, size_mm[2]/2 + 4]],
		], rxf=function(rn) [rn[0], [-rn[1][0], rn[1][1]], for(i=[2:1:len(rn)-1]) rn[i]])
	]))
];
barrel_inlet_zig = ["difference",
	// Sheath for this is kind of arbitrary
	//tphl1_make_z_cylinder(d=12.7, zrange=[-2, 8+1/256]),
	togmod1_linear_extrude_z([-2, 8+1/256], togmod1_make_rounded_rect([16,16], r=6)),
	
	tphl1_make_z_cylinder(zds=[[-2,11], [5,11], [5,8], [8,8], [8,14], [10,14], [10+14/2,0]]),
];

corner_cavity_subtraction = togmod1_linear_extrude_z([-size_mm[2], size_mm[2]],
	togmod1_make_rounded_rect([25.4,25.4], r=6.35)
);
corner_hole = ["render", ["translate", [0,0,-size_mm[2]/2], ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", depth=size_mm[2]+2)]]];

function feat_to_zig(feat) =
	feat == "wire-slot" ? wire_slot_zig :
	feat == "barrel-inlet" ? barrel_inlet_zig :
	feat == "button" ? button_zig :
	feat == "none" ? ["difference", ["union"], ["union"]] :
	assert(false, str("Unrecognized feature: '", feat, "'"));

togmod1_domodule(
	let( ybev = 1.6 )
	let( ccf_zig = feat_to_zig(ccf_feat) )
	let( cef_zig = feat_to_zig(cef_feat) )
	let( ccb_zig = feat_to_zig(ccb_feat) )
	let( ccf_she = zig_sheath(ccf_zig), ccf_cut = zig_cut(ccf_zig) )
	let( cef_she = zig_sheath(cef_zig), cef_cut = zig_cut(cef_zig) )
	let( ccb_she = zig_sheath(ccb_zig), ccb_cut = zig_cut(ccb_zig) )
	["difference",
		let( xzbev = 3.175 )
		tphl1_make_polyhedron_from_layer_function(
			[
				[-size_mm[2]/2        - $tgx11_offset    , 0-ybev + $tgx11_offset*0.4],
				[-size_mm[2]/2 + ybev - $tgx11_offset*0.4, 0      + $tgx11_offset    ],
				[ size_mm[2]/2 - ybev + $tgx11_offset*0.4, 0      + $tgx11_offset    ],
				[ size_mm[2]/2        + $tgx11_offset    , 0-ybev + $tgx11_offset*0.4],
			],
			function(zo) togpath1_rath_to_polypoints(make_hull_rath(bev=xzbev, offset=zo[1])),
			layer_points_transform = "key0-to-z"
		),
		
		["difference",
			let( wt = wall_thickness_mm )
			let( ft = bottom_thickness_mm )
			let( xzbev = max(wt*1.5, 3.175) )
			tphl1_make_polyhedron_from_layer_function(
				[
					[-size_mm[2]/2 + ft   + $tgx11_offset    , 0 - wt ],
					[ size_mm[2]/2 + 10   + $tgx11_offset    , 0 - wt ],
				],
				function(zo) togpath1_rath_to_polypoints(make_hull_rath(bev=xzbev, offset=zo[1])),
				layer_points_transform = "key0-to-z"
			),
			
			for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] ) ["union",
				["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate-xyz", [90,0,180], ccf_she]],
				["translate", [xm*chunk_mm,  size_mm[1]/2, 0], ["rotate-xyz", [90,0,  0], ccb_she]],
			],

			for( xm=[-size_chunks[0]/2 + 1 : 1 : size_chunks[0]/2 - 1] )
		   ["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate-xyz", [90,0,180], cef_she]],
			
			for( x=[-size_mm[0]/2, size_mm[0]/2] )
			for( y=[-size_mm[1]/2, size_mm[1]/2] )
			["translate", [x,y,0], corner_cavity_subtraction],
		],

		for( xm=[-size_chunks[0]/2 + 1 : 1 : size_chunks[0]/2 - 1] )
		["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate", [90,0,180], cef_cut]],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] ) ["union",
			["translate", [xm*chunk_mm, 0, size_mm[2]/2-bottom_thickness_mm], screw_hole],
			["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate-xyz", [90,0,180], ccf_cut]],
			["translate", [xm*chunk_mm,  size_mm[1]/2, 0], ["rotate-xyz", [90,0,  0], ccb_cut]],
		],

		for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
		for( ym=[-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
		["translate", [xm*atom_mm,ym*atom_mm,0], corner_hole],
	]
);
