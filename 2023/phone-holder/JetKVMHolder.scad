// JetKVMHolder0.5
// 
// v0.1:
// - Full of hacks!
// v0.2:
// - Parameterize back_thickness and front_lip_z
// - Optional front slot (when front_slot_width > 0)
// - Fix the 'mouth' at the top
// v0.3
// - Optional lip at top
// v0.4:
// - Simplify cavity generation
// v0.5:
// - Clean up screw hole definitions _somewhat_
// - More screw holes behind lip

back_thickness = "1/4inch";
front_slot_width = "0inch";
front_lip_z = "1/4inch";
top_lip_protrusion = "0inch";

$tgx11_offset = -0.5;
$fn = 32;

use <../lib/TGx11.1Lib.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGridLib3.scad>

$togridlib3_unit_table = tgx11_get_default_unit_table();

inner_width_mm = 45;
inner_depth_mm = 24;

front_slot_width_mm   = togunits1_to_mm(front_slot_width);
back_thickness_mm     = togunits1_to_mm(back_thickness);
top_lip_protrusion_mm = togunits1_to_mm(top_lip_protrusion);

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

function mirror_rathnodes(nodes) = [
	for( n=nodes ) n,
	
	for( i=[len(nodes)-1 : -1 : 0] )
	let( n=nodes[i] )
	[n[0], [-n[1][0], n[1][1]], for(j=[2 : 1 : len(n)-1]) n[j]],
];

togmod1_domodule(
	// Y {back|front} {outer|inner}
	let( ybo = size_mm[1]/2 )
	let( ybi = ybo - back_thickness_mm )
	let( yfo = -size_mm[1]/2 )
	let( yfi = ybi - inner_depth_mm )
	let( front_thickness_mm = yfi-yfo )
	// Z positions
	let( zlip = togunits1_to_mm(front_lip_z) )
	let( edge_screw_hole = ["translate", [0,        0              ,0], ["rotate", [90,0,0], tog_holelib2_hole("THL-1005", depth=50, overhead_bore_height=size_mm[1])]] )
	let( back_screw_hole = ["translate", [0,min(ybi,size_mm[1]/2-7),0], ["rotate", [90,0,0], tog_holelib2_hole("THL-1005", depth=50, overhead_bore_height=6.35      )]] )
	let( screw_hole_xz_positions = [
		// These are hard-coded assuming block size is 2x1x2
		for( xm=[-2.5 : 1 :  2.5] )
		for( zm=[ 2.5 : 1 :  2.5] )
		[xm*atom_mm, zm*atom_mm],
		
		for( xm=[-1.5 : 1 :  1.5] )
		for( zm=[ 0.5 : 1 :  1.5] )
		[xm*atom_mm, zm*atom_mm],
		
		// Behind lip
		for( xm=[-1.5 : 1 :  1.5] )
		for( zm=[-2.5 : 1 : -0.5] )
		[xm*atom_mm, zm*atom_mm],
		
		for( xm=[-2.5,  2.5] )
		for( zm=[-2.5 : 1 : -0.5] )
		[xm*atom_mm, zm*atom_mm],		
	])
	let( the_hull = ["union",
		["render", make_togridpilish_block([2,1,2])]
	])
	let( the_cavity =
		let( xi1   = inner_width_mm/2 )
		let( ximax = size_mm[0]/2 -  6.35 )
		let( xitop = size_mm[0]/2 - 12.7  )
		["intersection",
			let( tlipp = top_lip_protrusion_mm )
			let( ypi = ybi - tlipp )
			togmod1_linear_extrude_x([-size_mm[0], size_mm[0]], togpath1_rath_to_polygon(["togpath1-rath",
				["togpath1-rathnode", [ybi     , -size_mm[2]/2-10]],
				each tlipp > 0 ? [
					["togpath1-rathnode", [ybi, size_mm[2]/2-3-tlipp]],
					["togpath1-rathnode", [ypi, size_mm[2]/2-3      ]],
				] : [],
				["togpath1-rathnode", [ypi     ,  size_mm[2]/2+10]],
				["togpath1-rathnode", [yfo - 10,  size_mm[2]/2+10]],
				["togpath1-rathnode", [yfo - 10,  zlip           ]],
				["togpath1-rathnode", [yfi     ,  zlip           ], ["round", 6.35]],
				["togpath1-rathnode", [yfi     , -size_mm[2]/2-10]],
			])),
			
			togmod1_linear_extrude_y([-size_mm[1], size_mm[1]], togpath1_rath_to_polygon(["togpath1-rath",
				each mirror_rathnodes([
					["togpath1-rathnode", [xi1  , -size_mm[2]/2-20]],
					["togpath1-rathnode", [xi1  ,  zlip - 3.175   ]],
					["togpath1-rathnode", [ximax,  zlip - 3.175 + (ximax - xi1)]],
					["togpath1-rathnode", [ximax,  zlip - 3.175 + (ximax - xi1)]],
					["togpath1-rathnode", [ximax     ,  size_mm[2]/2 - 9 - (ximax - xitop)  ]],
					["togpath1-rathnode", [xitop     ,  size_mm[2]/2 - 9                    ]],
					["togpath1-rathnode", [xitop     ,  size_mm[2]/2 - 2       ]],
					["togpath1-rathnode", [xitop + 20,  size_mm[2]/2 - 2 + 20  ]],
				])
			]))
		]
	)
	["difference",
		the_hull,
		
		the_cavity,
		
		for( xz=screw_hole_xz_positions )
		["translate", [xz[0], 0, xz[1]],
			// If behind the lip, use 'scraw hole', with less overhead bore height
			(abs(xz[0]) < inner_width_mm/2+6) ? back_screw_hole : edge_screw_hole],
		
		if( front_slot_width_mm > 0 )
		["translate", [0, (yfo + yfi)/2, 0],
			togmod1_linear_extrude_z([-size_mm[2], size_mm[2]],
				["difference",
					togmod1_make_rect([front_slot_width_mm + front_thickness_mm, front_thickness_mm + 2]),
					for(xm=[-1,1]) ["translate", [xm*(front_slot_width_mm + front_thickness_mm)/2, 0],
						togmod1_make_circle(d=front_thickness_mm)]
				]
			)
		],
	]
);
