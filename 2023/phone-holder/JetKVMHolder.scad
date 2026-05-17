// JetKVMHolder0.2
// 
// v0.1:
// - Full of hacks!
// v0.2:
// - Parameterize back_thickness and front_lip_z
// - Optional front slot (when front_slot_width > 0)
// - Fix the 'mouth' at the top
// 
// TODO: Optional top lip

back_thickness = "1/4inch";
front_slot_width = "0inch";
front_lip_z = "1/4inch";

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

inner_width_mm = 45;
inner_depth_mm = 24;

front_slot_width_mm = togunits1_to_mm(front_slot_width);
back_thickness_mm   = togunits1_to_mm(back_thickness);

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
	// Y {back|front} {outer|inner}
	let( ybo = size_mm[1]/2 )
	let( ybi = ybo - back_thickness_mm )
	let( yfo = -size_mm[1]/2 )
	let( yfi = ybi - inner_depth_mm )
	let( front_thickness_mm = yfi-yfo )
	// Z positions
	let( zlip = togunits1_to_mm(front_lip_z) )
	["difference",
		the_hull,
		
		let( xi0 = -inner_width_mm/2 )
		let( xi1 =  inner_width_mm/2 )
		let( ximax = size_mm[0]/2 -  6.35 )
		let( xitop = size_mm[0]/2 - 12.7  )
		tphl1_make_polyhedron_from_layer_function(
			[
				[-size_chunks[2]/2*chunk_mm - 50, [xi1, 0]],
				for(a=[0 : 10 : 90]) [zlip + 6.35*(sin(a)-1), [
					min(ximax, a == 90 ?  50 : xi1 + 6.35*(1-cos(a))),
					a == 90 ? -50 : 0-6.35*(1-cos(a))
				]],
				[ size_chunks[2]/2*chunk_mm -  9 - (ximax - xitop), [ximax     , -50]],
				[ size_chunks[2]/2*chunk_mm -  9                  , [xitop     , -50]],
				[ size_chunks[2]/2*chunk_mm -  2                  , [xitop     , -50]],
				[ size_chunks[2]/2*chunk_mm -  2 + 10             , [xitop + 10, -50]],
			],
			function(zp) [
				[ zp[1][0], yfi + zp[1][1]],
				[ zp[1][0], ybi           ],
				[-zp[1][0], ybi           ],
				[-zp[1][0], yfi + zp[1][1]],
			],
			layer_points_transform = "key0-to-z"
		),
		
		for( xz=screw_hole_xz_positions )
		["translate", [xz[0], min(ybi,size_mm[1]/2-7), xz[1]], xz[1] == 6.35 ? scraw_hole : screw_hole],
		
		if( front_slot_width_mm > 0 )
		["translate", [0, (yfo + yfi)/2, 0],
			togmod1_linear_extrude_z([-size_mm[2], size_mm[2]],
				["difference",
					togmod1_make_rect([front_slot_width_mm + front_thickness_mm/2, front_thickness_mm + 2]),
					for(xm=[-1,1]) ["translate", [xm*(front_slot_width_mm + front_thickness_mm)/2, 0],
						togmod1_make_circle(d=front_thickness_mm)]
				]
			)
		],
	]
);
