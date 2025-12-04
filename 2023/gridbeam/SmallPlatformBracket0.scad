// SmallPlatformBracket0.1
// 
// Did you want to attach something to a gridbeam
// using one bolt without it wiggling all over?

$tgx11_offset = -0.1;
$fn = 32;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
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

togmod1_domodule(
	let( inch = 25.4, chunk=38.1 )
   let( x1 = 3/4*inch, x2 = 1.5*inch )
	let( y0 = -3/4*inch, y1 = 3/4*inch, y2 = 2.25*inch )
   let( lcops = [["round", 6.35 ]] )
   let( scops = [["round", 3.175]] )
	let( vbev = 2 )
	let( hole = ["render", tphl1_make_z_cylinder(zrange=[-100,100], d=9)] )
	let( cb_hole = ["render", tphl1_make_z_cylinder(zds=[[-100,9],[0,9],[0,21],[100,21]])] )
	let( oo = $tgx11_offset )
	["difference",
		tphl1_make_polyhedron_from_layer_function([
			[-3/4*inch        - oo, oo-vbev],
			[-3/4*inch + vbev - oo, oo     ],
			[ 3/4*inch - vbev + oo, oo     ],
			[ 3/4*inch        + oo, oo-vbev],
	   ], function(zo) togvec0_offset_points(
		   togpath1_rath_to_polypoints(["togpath1-rath", each with_mirrored_rathnodes([
			   ["togpath1-rathnode", [x2,y0], each lcops, ["offset", zo[1]]],
			   ["togpath1-rathnode", [x2,y2], each scops, ["offset", zo[1]]],
			   ["togpath1-rathnode", [x1,y2], each scops, ["offset", zo[1]]],
			   ["togpath1-rathnode", [x1,y1], each scops, ["offset", zo[1]]],
			])]),
		   zo[0]
	   )),
		
		for( xm=[-0.5, 0, 0.5] ) for( ym=[0] )
   	["translate", [xm,ym]*chunk, hole],
		
		for( xm=[0] ) for( ym=[0,1] )
   	["translate", [xm,ym,0]*chunk, ["rotate", [0,90,0], hole]],
		
		for( xm=[0] ) for( ym=[0.25] )
   	["translate", [xm,ym,0]*chunk, ["rotate", [90,0,0], cb_hole]],

	]
);
