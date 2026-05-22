// ButtonBlock0.1
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

length = "4chunk";
width  = "1chunk";
depth  = "3/4inch";
front_thickness = "3/16inch";
wall_thickness = "1/8inch";

$tgx11_offset = -0.1;
$fn = 32;

use <../lib/TOGArrayLib1.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

size = [length, width, depth];
size_mm     = togunits1_vec_to_mms(size);
size_chunks = togunits1_decode_vec(size, unit="chunk", xf="round");
size_atoms  = togunits1_decode_vec(size, unit="atom" , xf="round");
chunk_mm    = togunits1_to_mm("chunk");
atom_mm     = togunits1_to_mm("atom");
front_thickness_mm = togunits1_to_mm(front_thickness);
wall_thickness_mm  = togunits1_to_mm(wall_thickness);

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

// TODO: Make sure these will actually hold the buttons
// and have space for the nut!
// Post diameter   = 31/ 64" = 12.3mm
// Flange diameter = 71/128" = 14.1mm
// Nut diameter    = 41/ 64" = 16.3mm
// Make panel thickness = 9/32" = 7.1mm
// Bottom of flange to top of button = 1/4" = 6.3mm
// Bottom of flange to ends of terminals = 23mm
button_cutout = tphl1_make_z_cylinder(zds=[[-2, 15], [6.5, 15], [6.5, 13], [11, 13], [11, 17], [6.5+23, 17], [6.5+23+2, 17-4]]);
button_cavity_subtraction = tphl1_make_z_cylinder(zds=[[-1, 21+10], [4, 21], [11+1/128, 21]]);

screw_hole = tphl1_make_z_cylinder(d=5, zrange=[-size_mm[1], size_mm[1]]);
wire_slot  = togmod1_linear_extrude_y([-size_mm[1], size_mm[1]], togpath1_rath_to_polygon(["togpath1-rath",
	each tal1_duplicate_reversed([
		["togpath1-rathnode", [3.175, -3.175], ["round", 3.175*($fn-1)/$fn]],
		["togpath1-rathnode", [3.175, size_mm[2]/2 - 4], ["round", 6.35]],
		["togpath1-rathnode", [3.175 + 8, size_mm[2]/2 + 4]],
	], rxf=function(rn) [rn[0], [-rn[1][0], rn[1][1]], for(i=[2:1:len(rn)-1]) rn[i]])
]));

corner_cavity_subtraction = togmod1_linear_extrude_z([-size_mm[2], size_mm[2]],
	togmod1_make_rounded_rect([25.4,25.4], r=6.35)
);
corner_hole = ["render", ["translate", [0,0,-size_mm[2]/2], ["rotate", [180,0,0], tog_holelib2_hole("THL-1005", depth=size_mm[2]+2)]]];

togmod1_domodule(
	let( ybev = 1.6 )
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
			let( ft = front_thickness_mm )
			let( xzbev = max(wt*1.5, 3.175) )
			tphl1_make_polyhedron_from_layer_function(
				[
					[-size_mm[2]/2 + ft   + $tgx11_offset    , 0 - wt ],
					[ size_mm[2]/2 + 10   + $tgx11_offset    , 0 - wt ],
				],
				function(zo) togpath1_rath_to_polypoints(make_hull_rath(bev=xzbev, offset=zo[1])),
				layer_points_transform = "key0-to-z"
			),
			
			for( xm=[-size_chunks[0]/2 + 1 : 1 : size_chunks[0]/2 - 1] )
		   ["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate", [-90,0,0], button_cavity_subtraction]],
			
			for( x=[-size_mm[0]/2, size_mm[0]/2] )
			for( y=[-size_mm[1]/2, size_mm[1]/2] )
			["translate", [x,y,0], corner_cavity_subtraction],
		],

		for( xm=[-size_chunks[0]/2 + 1 : 1 : size_chunks[0]/2 - 1] )
		["translate", [xm*chunk_mm, -size_mm[1]/2, 0], ["rotate", [-90,0,0], button_cutout]],
		
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2 - 0.5] ) ["union",
			["translate", [xm*chunk_mm, 0, size_mm[2]/2-front_thickness_mm], screw_hole],
			["translate", [xm*chunk_mm, 0, 0], wire_slot],
		],

		for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
		for( ym=[-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
		["translate", [xm*atom_mm,ym*atom_mm,0], corner_hole],
	]
);
