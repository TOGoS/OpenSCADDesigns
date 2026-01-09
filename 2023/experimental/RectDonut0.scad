// RectDonut0.1
// 
// TODO: Option for a floor
// TODO: Chunk holes?
// 
// Specifying size as a single string
// because OpenSCAD 2024 doesn't seem to allow
// arrays of strings.

wall_thickness = "1/4inch";
size = "4+1/2inch 4+1/2inch 1+1/2inch";
atom_hole_style = "THL-1005";
$fn = 24;

module __rectdonut0__end_params() { }

// May add later:

// floor_thickness = "0";
// chunk_hole_style = "THL-1002";

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGStringLib1.scad>

$togunits1_default_unit = "mm";

size_vec = togstr1_tokenize(size, " ");

wall_thickness_mm  = togunits1_to_mm(wall_thickness);
// floor_thickness_mm = togunits1_to_mm(floor_thickness);
size_mm            = togunits1_vec_to_mms(size_vec);
size_chunks        = togunits1_decode_vec(size_vec, unit="chunk", xf="round");
size_atoms         = togunits1_decode_vec(size_vec, unit="atom", xf="round");
depth_mm = size_mm[2];

atom = togunits1_decode("1atom");

bev = 0.4; // TODO: Make sure it's less than wall thickness

atom_hole = tog_holelib2_hole(atom_hole_style, inset=1, overhead_bore_height=10);

togmod1_domodule(
	["difference",
		tphl1_make_polyhedron_from_layer_function(
			[
				[-depth_mm/2    , 0                  -bev],
				[-depth_mm/2+bev, 0                      ],
				[+depth_mm/2-bev, 0                      ],
				[+depth_mm/2    , 0                  -bev],
				[+depth_mm/2    , 0-wall_thickness_mm+bev],
				[+depth_mm/2-bev, 0-wall_thickness_mm    ],
				[-depth_mm/2+bev, 0-wall_thickness_mm    ],
				[-depth_mm/2    , 0-wall_thickness_mm+bev],
				[-depth_mm/2    , 0                  -bev],
			],
			function(zo)
				togpath1_rath_to_polypoints(
					togpath1_make_rectangle_rath(
						[size_mm[0], size_mm[1]],
						corner_ops=[["round", wall_thickness_mm+1], ["offset", zo[1]]]
					)
				),
			layer_points_transform = "key0-to-z",
			cap_top = false,
			cap_bottom = false
		),
		
		// TODO: Subtract chunk, atom holes
		for( ym=[-1,1] )
		for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
		for( zm=[-size_atoms[2]/2+0.5 : 1 : size_atoms[2]/2-0.4] )
		let( pos=[xm*atom, ym*(size_mm[1]/2-wall_thickness_mm), zm*atom] )
		if( pos[0] >= -size_mm[0]/2+wall_thickness_mm*1.5 && pos[0] <= size_mm[0]/2-wall_thickness_mm*1.5 )
		["translate", pos, ["rotate", [90*ym,0,0], atom_hole]],
		
		for( xm=[-1,1] )
		for( ym=[-size_atoms[1]/2+0.5 : 1 : size_atoms[1]/2-0.4] )
		for( zm=[-size_atoms[2]/2+0.5 : 1 : size_atoms[2]/2-0.4] )
		let( pos=[xm*(size_mm[0]/2-wall_thickness_mm), ym*atom, zm*atom] )
		if( pos[1] >= -size_mm[1]/2+wall_thickness_mm*1.5 && pos[1] <= size_mm[1]/2-wall_thickness_mm*1.5 )
		["translate", pos, ["rotate", [0,-90*xm,0], atom_hole]],
	]
);
