// Pi4Holder1.4
// 
// TOGridPile holder for a Raspberry Pi 4B or similar
// 
// Versions
// v1.1:
// - Default pi_mounting_hole_size to 2.8mm,
//   which was found to be a good size for threading M2.5s into
//   by a print of p1898.
// - Decrease lip height to 1.5mm
// v1.2
// - Lower top of posts to 2mm above center instead of 2mm above edge
// - Chunkify posts (to reduce concave corners)
// - Cutout to accomodate microSD card
// - More mounting holes along edges
// - Round/bevel corners of upper cavity
// v1.3:
// - Ramp between center and edge floors
// - Fix doubling of 'center' offset (which was zero, so no change in output)
// v1.4:
// - Extend SD card cutout to end of enclosure
//   - Maybe it should be all the way through the bottom, so you could
//     actually grab it out!  Maybe next iteration.

$tgx11_offset = -0.1;
$togridlib3_unit_table = tgx11_get_default_unit_table();
$fn = 32;

pi_mounting_hole_size = 2.8;
board_margin = 0.5;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

size_ca = [[3,"chunk"],[2,"chunk"],[1,"inch"]];
size_atoms = togridlib3_decode_vector(size_ca, unit=[1,"atom"]);
size = togridlib3_decode_vector(size_ca);
atom = togridlib3_decode([1,"atom"]);
inch = togridlib3_decode([1,"inch"]);

center_depth = 20;
edge_depth = 19;
post_height = 2;

full_hole = tphl1_make_z_cylinder(zrange=[-size[2]*2, size[2]], d=4.5); // ["render", tog_holelib2_hole("THL-1010", depth=size[2]*2, inset=1/4*inch)];
edge_hole = ["render", tog_holelib2_hole("THL-1001", overhead_bore_height=50)];
full_hick = togmod1_linear_extrude_z([-1/4*inch, 1/4*inch], ["hull",
	for(ym=[-1,1]) ["translate", [0, ym*(size_atoms[1]/2-0.5)*atom, 0], togmod1_make_circle(d=8)]
]);

togmod1_domodule(
let( board_size = [85,56] )
let( corner_hole_positions = [for(xm=[-1,1]) for(ym=[-1,1]) [xm*(size_atoms[0]/2-0.5)*atom, ym*(size_atoms[1]/2-0.5)*atom]] )
let( hick_positions = [for(xm=[-1,1]) [xm*(size_atoms[0]/2-0.5)*atom, 0]] )
let( center = [0,0] )
let( post_data = [for(xm=[-1,1]) for(ym=[-1,1]) [[center[0]-85/2+3.5+58/2+xm*58/2, center[1]+ym*49/2], [/*xm > 0 ? 0 :*/ xm, ym]]] )
let( post = ["render", tphl1_make_z_cylinder(zrange=[-post_height, post_height], d=inch/4)] )
let( post_hole = ["render", tphl1_make_z_cylinder(zrange=[-50, 50], d=pi_mounting_hole_size)] ) // Hmm how to do this
let( s2 = [size[0]*2, size[1]*2] )
["difference",
	tgx11_block(size_ca, top_segmentation="block", lip_height=1.5),
	
	// Cutout for board
	["difference",
		["union",
		   let( hbs = [board_size[0]/2 + board_margin, board_size[1]/2+board_margin] )
			let( cops = [["round", board_margin*2, 6]] )
			let( bcops = [["round", 3, 6]] )
			let( q = inch/4 )
			let( g = inch/8 )
			tphl1_make_polyhedron_from_layer_function([
				[size[2]-center_depth + 0  , 0  ],
				[size[2]-center_depth + 1.5, 1.5],
				[size[2]+center_depth      , 1.5],
			], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
				["togpath1-rathnode", [center[0]+hbs[0]  , center[1]+hbs[1]], each  cops],
				["togpath1-rathnode", [center[0]-hbs[0]  , center[1]+hbs[1]], each  cops],
				["togpath1-rathnode", [center[0]-hbs[0]  , center[1]+q     ], each bcops],
				["togpath1-rathnode", [-size[0]/2+g      , center[1]+q     ], each bcops],
				["togpath1-rathnode", [-size[0]/2+g-10   , center[1]+q+10  ],           ],
				["togpath1-rathnode", [-size[0]/2+g-10   , center[1]-q-10  ],           ],
				["togpath1-rathnode", [-size[0]/2+g      , center[1]-q     ], each bcops],
				["togpath1-rathnode", [center[0]-hbs[0]  , center[1]-q     ], each bcops],
				["togpath1-rathnode", [center[0]-hbs[0]  , center[1]-hbs[1]], each  cops],
				["togpath1-rathnode", [center[0]+hbs[0]  , center[1]-hbs[1]], each  cops],
			], zo[1])), zo[0])),

			// ["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([87,56,center_depth*2]) ],
			
			let( icops = [["bevel", 6.35], ["round", 3.175, 6]] )
			tphl1_make_polyhedron_from_layer_function([
			   [size[2]-edge_depth  ,-1],
			   [size[2]-edge_depth+1, 0],
			   [size[2]           -1, 0],
			   [size[2]           +2, 3],
			   [size[2]+edge_depth  , 3],
			], function(zo) togvec0_offset_points(togpath1_rath_to_polypoints(togpath1_offset_rath(["togpath1-rath",
			   ["togpath1-rathnode", [ 39, -s2[1]], ],
			   ["togpath1-rathnode", [ 39, -28], each icops],
			   ["togpath1-rathnode", [ s2[0], -28], ],
			   ["togpath1-rathnode", [ s2[0], 28], ],
			   ["togpath1-rathnode", [ 39, 28], each icops],
			   ["togpath1-rathnode", [ 39, s2[1]], ],
			   ["togpath1-rathnode", [-39, s2[1]], ],
			   ["togpath1-rathnode", [-39, 28], each icops],
			   ["togpath1-rathnode", [-s2[0], 28], ],
			   ["togpath1-rathnode", [-s2[0], -28], ],
			   ["togpath1-rathnode", [-39, -28], each icops],
			   ["togpath1-rathnode", [-39, -s2[1]], ],
			], zo[1])), zo[0])),

			//["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([size[0]*2, 56, edge_depth*2]) ],
			//["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([79, size[1]*2, edge_depth*2]) ],
		],
		
		//for( pos=post_positions ) ["translate", [pos[0], pos[1], size[2]-center_depth], post],
		for( pd=post_data ) ["hull",
			for( xm=[0,4] ) for( ym=[0,4] )
			if( (xm == 0 || pd[1][0] != 0) && (ym == 0 || pd[1][1] != 0) ) ["translate", [pd[0][0] + pd[1][0]*xm, pd[0][1] + pd[1][1]*ym, size[2]-center_depth], post],
	   ],
	],
	
	for( pos=corner_hole_positions ) ["translate", [pos[0], pos[1], size[2]], full_hole],
	for( pos=hick_positions ) ["translate", [pos[0], pos[1], size[2]], full_hick],
	
	for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
	for( ym=[-size_atoms[1]/2+1.5 : 1 : size_atoms[1]/2-1.4] )
	if( xm > -size_atoms[0]/2+1 || abs(ym) > 1 )
	["translate", [xm*atom, ym*atom, size[2]-edge_depth], edge_hole],
	
	for( xm=[-size_atoms[0]/2+1.5 : 1 : size_atoms[0]/2-1.4] )
	for( ym=[-size_atoms[1]/2+0.5, size_atoms[1]/2-0.5] )
	["translate", [xm*atom, ym*atom, size[2]-edge_depth], edge_hole],

	for( pd=post_data ) ["translate", [pd[0][0], pd[0][1], size[2]-edge_depth], post_hole],
]);
