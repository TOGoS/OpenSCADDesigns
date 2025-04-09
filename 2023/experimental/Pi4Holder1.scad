// Pi4Holder1.1
// 
// TOGridPile holder for a Raspberry Pi 4B or similar
// 
// Versions
// v1.1:
// - Default pi_mounting_hole_size to 2.8mm,
//   which was found to be a good size for threading M2.5s into
//   by a print of p1898.
// - Decrease lip height to 1.5mm

$tgx11_offset = -0.1;
$togridlib3_unit_table = tgx11_get_default_unit_table();
$fn = 32;

pi_mounting_hole_size = 2.8;

use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGPolyhedronLib1.scad>

size_ca = [[3,"chunk"],[2,"chunk"],[1,"inch"]];
size_atoms = togridlib3_decode_vector(size_ca, unit=[1,"atom"]);
size = togridlib3_decode_vector(size_ca);
atom = togridlib3_decode([1,"atom"]);
inch = togridlib3_decode([1,"inch"]);

center_depth = 20;
edge_depth = 19;
post_height = 2;

full_hole = tphl1_make_z_cylinder(zrange=[-size[2]*2, size[2]], d=4.5); // ["render", tog_holelib2_hole("THL-1010", depth=size[2]*2, inset=1/4*inch)];
edge_hole = ["render", tog_holelib2_hole("THL-1001")];
full_hick = togmod1_linear_extrude_z([-1/4*inch, 1/4*inch], ["hull",
	for(ym=[-1,1]) ["translate", [0, ym*(size_atoms[1]/2-0.5)*atom, 0], togmod1_make_circle(d=8)]
]);

togmod1_domodule(
let( corner_hole_positions = [for(xm=[-1,1]) for(ym=[-1,1]) [xm*(size_atoms[0]/2-0.5)*atom, ym*(size_atoms[1]/2-0.5)*atom]] )
let( hick_positions = [for(xm=[-1,1]) [xm*(size_atoms[0]/2-0.5)*atom, 0]] )
let( center = [0,0] )
let( post_positions = [for(xm=[-1,1]) for(ym=[-1,1]) [center[0]-85/2+3.5+58/2+xm*58/2, center[1]+ym*49/2]] )
let( post = ["render", tphl1_make_z_cylinder(zrange=[-post_height, post_height], d=inch/4)] )
let( post_hole = ["render", tphl1_make_z_cylinder(zrange=[-50, 50], d=pi_mounting_hole_size)] ) // Hmm how to do this
["difference",
	tgx11_block(size_ca, top_segmentation="block", lip_height=1.5),
	
	// Cutout for board
	["difference",
		["union",
			["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([87,56,center_depth*2]) ],
			
			["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([size[0]*2, 56, edge_depth*2]) ],
			["translate", [center[0], center[1], size[2]], togmod1_make_cuboid([79, size[1]*2, edge_depth*2]) ],
		],
		
		for( pos=post_positions ) ["translate", [pos[0], pos[1], size[2]-edge_depth], post],
	],
	
	for( pos=corner_hole_positions ) ["translate", [pos[0], pos[1], size[2]], full_hole],
	for( pos=hick_positions ) ["translate", [pos[0], pos[1], size[2]], full_hick],
	
	for( xm=[-size_atoms[0]/2+0.5, size_atoms[0]/2-0.5] )
	for( ym=[-size_atoms[1]/2+1.5 : 1 : size_atoms[1]/2-1.4] )
	["translate", [xm*atom, ym*atom, size[2]-edge_depth], edge_hole],

	for( pos=post_positions ) ["translate", [pos[0], pos[1], size[2]-edge_depth], post_hole],
]);
