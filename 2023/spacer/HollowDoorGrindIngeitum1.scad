// HollowDoorGrindIngeitum1.0
// 
// A set of parts that stack together to form a 'spacer'
// as described by https://www.nuke24.net/plog/45.html
// with optional 'bushings' that stick into the door,
// which may help to bolt through hollow-core doors.

size_chunks = [1,2];
thickness = 6.35;
post_diameter = 12.5;
post_height = 31.75;
outer_offset = -0.1;
chunk_hole_diameter = 8.5;
chunk_hole_counterbore_diameter = 22;
chunk_hole_counterbore_depth = 0;
corner_hole_style = "THL-1005"; // ["none","THL-1005","straight-5mm"]
corner_hole_placement = "corners"; // ["corners", "all"]
top_bevel = 3.175;
$fn = 72;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>

togmod1_domodule(
	let( chunk = 38.1, bevel=3.175, round=4, atom=12.7 )
	let( topev = top_bevel )
	let( hull_2d_rath = togpath1_make_rectangle_rath(size_chunks*chunk,
		corner_ops=[["bevel", bevel], ["round", round], ["offset", outer_offset]]) )
	let( hull_2d = togmod1_make_polygon(togpath1_rath_to_polypoints(hull_2d_rath)) )
	// let( hull = togmod1_linear_extrude_z([0, thickness], hull_2d) )
	let( hull=tphl1_make_polyhedron_from_layer_function([
		[            0    ,  0    ],
		[thickness - topev,  0    ],
		if( topev > 0 ) [thickness        , -topev],
	], function(zo)
		togvec0_offset_points(
			togpath1_rath_to_polypoints(togpath1_offset_rath(hull_2d_rath, zo[1])),
			zo[0]
		)
	))
	let( post = post_height <= 0 ? ["union"] : tphl1_make_z_cylinder(zrange=[-1, post_height], d=post_diameter) )
	let( chunk_hole = ["union",
		tphl1_make_z_cylinder(zrange=[-1, thickness + post_height + 1], d=chunk_hole_diameter),
		
		if( chunk_hole_counterbore_depth > 0 && chunk_hole_counterbore_diameter > chunk_hole_diameter )
		tphl1_make_z_cylinder(zrange=[-1, chunk_hole_counterbore_depth], d=chunk_hole_counterbore_diameter),
		
		if( post_height < 0 && post_diameter > 0 )
		tphl1_make_z_cylinder(zrange=[thickness+post_height, thickness+1], d=post_diameter),
	])
	let( atom_hole_placement =
		corner_hole_placement == "all" ? [[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1]] :
		[[1,-1],[1,1],[-1,1],[-1,-1]]
	)
	let( atom_hole =
	   corner_hole_style == "none" ? ["union"] :
		corner_hole_style == "straight-5mm" ? tphl1_make_z_cylinder(zrange=[-1,thickness+1], d=5) : // TODO: Make HoleLib2 understand!
		["translate", [0,0,thickness], ["rotate", [0,0,15], tog_holelib2_hole(corner_hole_style, inset=max(0.1, thickness-4.5))]]
	)
	let( chunk_subtraction = ["union",
		chunk_hole,
	   
	   for( pm=atom_hole_placement )
		["translate", pm*atom, atom_hole],
	])
	["difference",
		["union",
			hull,
			
			for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
			for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
			["translate", [xm*chunk, ym*chunk, thickness], post],
		],
		
		for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2] )
		for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2] )
		["translate", [xm*chunk, ym*chunk, 0], chunk_subtraction],
	]
);
