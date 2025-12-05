// SmallPlatformBracket1.2
// 
// Did you want to attach something to a gridbeam
// using one bolt without it wiggling all over?
// 
// v1.1:
// - Forked from SmallPlatformBracket0.1
// - Maybe this one is front-only
// v1.2:
// - Back holes every 1/2 chunk

height = "2chunk";

inner_thread_radius_offset = 0.2;
$tgx11_offset = -0.1;
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGVecLib0.scad>

function mirror_rathnodes(nodes) =
	[for(i=[len(nodes)-1 : -1 : 0])
		let(n=nodes[i])
		[n[0], [-n[1][0], n[1][1]], for(o=[2:1:len(n)-1]) n[o]]
	];

function with_mirrored_rathnodes(nodes) =
	[each nodes, for(i=[len(nodes)-1 : -1 : 0])
		let(n=nodes[i])
		[n[0], [-n[1][0], n[1][1]], for(o=[2:1:len(n)-1]) n[o]]
	];

function xf_points(xf, points) = [for(p=points) xf(p)];

togmod1_domodule(
	let( inch = 25.4, chunk=38.1 )
	let( x1 = 3/4*inch, x2 = 1.5*inch )
	let( x0 = -x1 )
	let( y0 = -3/4*inch, y1 = 3/4*inch, y2 = 2.25*inch )
	let( height_chunks = togunits1_decode(height, unit="chunk", xf="round") )
	let( height_mm = togunits1_decode(height, unit="mm") )
	let( z0 = -height_mm/2, z1=height_mm/2 )
	let( lcops = [["round", 6.35 ]] )
	let( scops = [["round", 3.175]] )
	let( vbev = 2 )
	let( y_hole = ["render",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[6.35,1],[y1,1]], taper_length=1, inset=1, extend=1),
			"1/2-13-UNC",
			r_offset = inner_thread_radius_offset
		)
	])
	let( x_hole = ["render",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[x0,1],[x1,1]], taper_length=1, inset=1, extend=1),
			"1/2-13-UNC",
			r_offset = inner_thread_radius_offset
		)
	])
	let( threaded_dunk_hole = ["render",
		togthreads2_make_threads(
			togthreads2_simple_zparams([[z0,1],[z1,1]], taper_length=1, inset=1, extend=1),
			"1/2-13-UNC",
			r_offset = inner_thread_radius_offset
		)
	])
	let( oo = $tgx11_offset )
	let( main_block = tphl1_make_polyhedron_from_layer_function([
			[ z0        - oo, oo-vbev],
			[ z0 + vbev - oo, oo     ],
			[ z1 - vbev + oo, oo     ],
			[ z1        + oo, oo-vbev],
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(["togpath1-rath", each with_mirrored_rathnodes([
				["togpath1-rathnode", [x1,y0], each lcops, ["offset", zo[1]]],
				["togpath1-rathnode", [x1,y1], each scops, ["offset", zo[1]]],
			])]),
			zo[0]
		))
	)
	let( triangle_block = tphl1_make_polyhedron_from_layer_function([
			[ x0        - oo, oo-vbev],
			[ x0 + vbev - oo, oo     ],
			[ x1 - vbev + oo, oo     ],
			[ x1        + oo, oo-vbev],
		], function(zo) xf_points(
			function(xy) [zo[0], xy[0], xy[1]],
			togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [y1,z0], each scops, ["offset", zo[1]]],
				["togpath1-rathnode", [y1,z1], each scops, ["offset", zo[1]]],
				["togpath1-rathnode", [y0,z1], each scops, ["offset", zo[1]]],
			])
		))
	)
	["difference",
		["intersection",
			// main_block,
			triangle_block,
		],
		
		["translate", [0, -6.35, -6.35], tphl1_make_rounded_cuboid([inch, chunk, height_mm], r=vbev, corner_shape="cone2")],
		
		for( xm=[0] ) for( ym=[0] )
		["translate", [xm,ym]*chunk, threaded_dunk_hole],
		
		for( xm=[0] ) for( ym=[0,1] ) for( zm=[-height_chunks/2 + 0.5 : 1 : height_chunks/2-0.5] )
		["translate", [xm,ym,zm]*chunk, ["rotate", [0,90,0], x_hole]],
		
		for( xm=[0] ) for( ym=[0] ) for( zm=[-height_chunks/2 + 0.5 : 0.5 : height_chunks/2-0.5] )
		["translate", [xm,ym,zm]*chunk, ["rotate", [-90,0,0], y_hole]],
	]
);
