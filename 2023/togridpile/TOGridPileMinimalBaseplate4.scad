// TOGridPileMinimalBaseplate4.2
// 
// With experimental 'tall' lips that cups
// rest on instead of resting on the floor.
// 
// v4.1:
// - Option for bowtie cutouts
// v4.2:
// - Option for ridges around bowtie cutouts

size_chunks = [4,4];

lip_height = "1.5u";
column_extra_depth = "1u";
column_extra_depth_dxdy = 0; // [0:0.01:1]
floor_thickness = "1u";

/* [Floor holes] */
bottom_hole_style = "THL-1001";

/* [Bowtie connector cutouts] */
bowtie_cutout_style = "none"; // ["none","round"]
bowtie_ridge_height = "max";
bowtie_ridge_width = "1u";

/* [Detail] */
outer_offset  = -0.10; // 0.025
bowtie_offset = -0.10; // 0.025
$tgx11_offset = -0.15; // 0.025
$fn = 24;

module togridpileminimalbaseplate4__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/RoundBowtie0.scad>

chunk = togunits1_to_mm([1,"chunk"]);
atom  = togunits1_to_mm([1,"atom"]);
u     = togunits1_to_mm([1,"u"]);

size_mm = size_chunks * chunk;

lip_height_mm         = togunits1_to_mm(lip_height);
column_extra_depth_mm = togunits1_to_mm(column_extra_depth);
floor_thickness_mm    = togunits1_to_mm(floor_thickness);
virtual_floor_thickness_mm = floor_thickness_mm+column_extra_depth_mm;

total_height_mm = floor_thickness_mm + column_extra_depth_mm + lip_height_mm;

bowtie_ridge_height_mm = min(
	virtual_floor_thickness_mm,
	bowtie_ridge_height == "max" ? 999 : togunits1_to_mm(bowtie_ridge_height)
);
bowtie_ridge_width_mm = togunits1_to_mm(bowtie_ridge_width);

echo(str("Total height: ", total_height_mm, "mm"));
echo(str("Virtual floor thickness: ", virtual_floor_thickness_mm, "mm"));

bowtie_rath = roundbowtie0_make_bowtie_rath(6.35, offset=-bowtie_offset);
//bowtie_cutout_2d = ["render", roundbowtie0_make_bowtie_2d(6.35, offset=-bowtie_offset)];
round_bowtie_cutout = tphl1_make_polyhedron_from_layer_function([
	[-1, 0],
	[virtual_floor_thickness_mm, 0],
	[total_height_mm + 1, total_height_mm + 1 - virtual_floor_thickness_mm],
], function(zo) togvec0_offset_points(
	togpath1_rath_to_polypoints(togpath1_offset_rath(bowtie_rath, zo[1] - bowtie_offset)),
	zo[0]
));

bowtie_addback =
	bowtie_ridge_height_mm <= floor_thickness_mm || bowtie_ridge_width_mm <= 0 || bowtie_cutout_style == "none" ? ["union"] :
	bowtie_cutout_style == "round" ? togmod1_linear_extrude_z([0, bowtie_ridge_height_mm],
		roundbowtie0_make_bowtie_2d(6.35, offset=bowtie_ridge_width_mm-bowtie_offset)
	) :
	assert(false, str("Invalid bowtie_cutout_style: '", bowtie_cutout_style, "'"));
bowtie_cutout =
	bowtie_cutout_style == "none" ? ["union"] :
	bowtie_cutout_style == "round" ? round_bowtie_cutout :
	assert(false, str("Invalid bowtie_cutout_style: '", bowtie_cutout_style, "'"));

outer_hull = togmod1_linear_extrude_z([0, total_height_mm], ["difference",
	togpath1_rath_to_polygon(
		togpath1_make_rectangle_rath(size_mm, [["round", 2*u]])
	),
/*	
	for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2-0.5] )
	for( ym=[-size_chunks[1]/2, size_chunks[1]/2] )
	["translate", [xm,ym]*chunk, ["rotate", [0,0,90], bowtie_cutout_2d]],
*/
]);


chunk_main_subtraction =
let(z0 = floor_thickness_mm)
let(z1 = floor_thickness_mm + column_extra_depth_mm)
let(z2 = floor_thickness_mm + column_extra_depth_mm + 1*u)
let(z3 = floor_thickness_mm + column_extra_depth_mm + 3*u)
let(o3 = 2*u)
tphl1_make_polyhedron_from_layer_function([
	[z0, -1*u - $tgx11_offset - column_extra_depth_mm*column_extra_depth_dxdy],
	[z1, -1*u - $tgx11_offset],
	[z2, -1*u - $tgx11_offset],
	[z3, o3 - $tgx11_offset],
], function(zo) togvec0_offset_points(
	let(offset = zo[1] )
	let(roundr = max(2*u, -offset))
	togpath1_rath_to_polypoints(
		togpath1_make_rectangle_rath([chunk,chunk], [["round", roundr], ["offset", offset]])
	), zo[0]
));

// screw_hole = ["render", tphl1_make_z_cylinder(zrange=[-floor_thickness_mm-1, +floor_thickness_mm+1], d=5)];

screw_hole = ["render", tog_holelib2_hole(bottom_hole_style)];

chunk_subtraction = ["union",
	chunk_main_subtraction,
	
	for( ym=[-1,0,1] ) for( xm=[-1,0,1] )
	["translate", [xm*atom,ym*atom,floor_thickness_mm], screw_hole]
];

bowtie_posrots = [
	for( xm=[-size_chunks[0]/2 + 0.5 : 1 : size_chunks[0]/2-0.5] )
	for( ym=[-size_chunks[1]/2, size_chunks[1]/2] )
	[[xm,ym]*chunk, [0,0,90]],

	for( ym=[-size_chunks[1]/2 + 0.5 : 1 : size_chunks[1]/2-0.5] )
	for( xm=[-size_chunks[0]/2, size_chunks[0]/2] )
	[[xm,ym]*chunk, [0,0,0]],
];

togmod1_domodule(["difference",
	outer_hull,
	
	["difference",
		["union",
			for( ym=[-size_chunks[1]/2+0.5 : 1 : size_chunks[1]/2] )
			for( xm=[-size_chunks[0]/2+0.5 : 1 : size_chunks[0]/2] )
			["translate", [xm,ym]*chunk, chunk_subtraction],
		],
		
		for( posrot=bowtie_posrots )
		["translate", posrot[0], ["rotate", posrot[1], bowtie_addback]],
	],

	for( posrot=bowtie_posrots )
	["translate", posrot[0], ["rotate", posrot[1], bowtie_cutout]],
]);

