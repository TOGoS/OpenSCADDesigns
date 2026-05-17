// JetKVMHolder0.1
// 
// v0.1:
// - Full of hacks!

$tgx11_offset = -0.5;
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TGx11.1Lib.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGHoleLib2.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

chunk_mm = togunits1_to_mm("chunk");
atom_mm  = togunits1_to_mm("atom");
size_chunks = [2,1,2];
size_mm = size_chunks * chunk_mm;

function make_togridpilish_block(size_chunks) =
	let( foot = function(size)
		tgx11_block_bottom(
			[[size[0],"chunk"],[size[1],"chunk"],[size[2],"chunk"]],
			bottom_shape="beveled",
			segmentation="chunk",
			v6hc_style="none"
		)
	)
	["intersection",
		["translate", [-size_chunks[0]/2*chunk_mm,  0,  0], ["rotate", [  0,  90, 0], foot([size_chunks[2],size_chunks[1],size_chunks[0]])]],
		["translate", [ size_chunks[0]/2*chunk_mm,  0,  0], ["rotate", [  0, -90, 0], foot([size_chunks[2],size_chunks[1],size_chunks[0]])]],
		["translate", [ 0, -size_chunks[1]/2*chunk_mm,  0], ["rotate", [-90,   0, 0], foot([size_chunks[0],size_chunks[2],size_chunks[1]])]],
		["translate", [ 0,  size_chunks[1]/2*chunk_mm,  0], ["rotate", [ 90,   0, 0], foot([size_chunks[0],size_chunks[2],size_chunks[1]])]],
		["translate", [ 0,  0,  size_chunks[2]/2*chunk_mm], ["rotate", [180,   0, 0], foot([size_chunks[0],size_chunks[1],size_chunks[2]])]],
		["translate", [ 0,  0, -size_chunks[2]/2*chunk_mm], ["rotate", [  0,   0, 0], foot([size_chunks[0],size_chunks[1],size_chunks[2]])]],
	];

the_hull = ["union",
	["render", make_togridpilish_block([2,1,2])]
];

togmod1_domodule(
	let( screw_hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1005", depth=50, overhead_bore_height=size_mm[1])] )
	let( scraw_hole = ["rotate", [90,0,0], tog_holelib2_hole("THL-1005", depth=50, overhead_bore_height=12.7)] )
	let( screw_hole_xz_positions = [
		for( xm=[-2.5 : 1 : 2.5] )
		for( zm=[ 2.5 : 1 : 2.5] )
		[xm*atom_mm, zm*atom_mm],
		
		for( xm=[-1.5 : 1 : 1.5] )
		for( zm=[ 0.5 : 1 : 1.5] )
		[xm*atom_mm, zm*atom_mm],
		
		for( xm=[-2.5,  2.5] )
		for( zm=[-2.5 : 1 : -0.5] )
		[xm*atom_mm, zm*atom_mm],		
	])

	["difference",
		the_hull,
		
		tphl1_make_polyhedron_from_layer_function(
			[
				[-size_chunks[2]/2*chunk_mm - 50, [0, 0]],
				for(a=[0 : 10 : 90]) [0 + 6.35*sin(a), [
					a == 90 ?  50 : 6.35*(1-cos(a)),
					a == 90 ? -50 : 0-6.35*(1-cos(a))
				]],
				[ size_chunks[2]/2*chunk_mm - 19.05 , [12.7, -50]],
				[ size_chunks[2]/2*chunk_mm -  6.35 , [ 0  , -50]],
				[ size_chunks[2]/2*chunk_mm + 50   , [0, -50]],
			],
			let( iw = 45 )
			let( id = 24 )
			let( ixmax = size_mm[0]/2 - 6.35 )
			function(zp) [
				[ min(ixmax, iw/2 + zp[1][0]), 12.7 - id + zp[1][1]],
				[ min(ixmax, iw/2 + zp[1][0]), 12.7            ],
				[-min(ixmax, iw/2 + zp[1][0]), 12.7           ],
				[-min(ixmax, iw/2 + zp[1][0]), 12.7 - id + zp[1][1]],
			],
			layer_points_transform = "key0-to-z"
		),
		
		for( xz=screw_hole_xz_positions )
		["translate", [xz[0], size_mm[1]/2-8, xz[1]], xz[1] == 6.35 ? scraw_hole : screw_hole],
	]
);
