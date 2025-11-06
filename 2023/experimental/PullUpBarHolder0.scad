// PullUpBarHolder0.1
// 
// A U-shape inside with a threaded outside,
// so you can hold your pull-up bars in place real good.
// 
// Alternatively, this could just have inner threads,
// a little larger than the 'U' diameter,
// and a cap on the pull-up bar could twist into those!
//
// The conduit I gave to Renee is about 30mm in diameter,
// so there's not quite enough room for 1+1/4 threads on the cap.
//
// Should have a flange of some sort to connect to a gridbeam panel,
// which possibly also has that U cutout, so that this isn't carrying all the weight.
// 
// Use "2-4+1/2-UNC" if you want compatibility with desiccant holders lmao

module __pullupbarholder0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGThreads2.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

thickness_mm = 19.05;
chunk = 38.1;
inch = 25.4;
$fn = $preview ? 24 : 48;

mounting_hole = tog_holelib2_hole("THL-1006", depth=thickness_mm + 1);

togmod1_domodule(["difference",
	let(bev = 2)
	tphl1_make_polyhedron_from_layer_function([
		[0               ,-bev],
		[bev             , 0  ],
		[thickness_mm-bev, 0  ],
		[thickness_mm    ,-bev],
	], function(zo) 
		togvec0_offset_points(
			togpath1_rath_to_polypoints(
				let( xx = inch*2.25, ur=inch*1.25/2+1 )
				let( ocops = [["round", 12.7], ["offset", zo[1]]] )
				let( dcops = [["round", 6.35], ["offset", zo[1]]] )
				let( icops = [["round", inch*1.25/2], ["offset", zo[1]]] )
				["togpath1-rath",
			   	["togpath1-rathnode", [ xx, -xx], each ocops],
			   	["togpath1-rathnode", [ xx,  xx], each ocops],
			   	["togpath1-rathnode", [ ur,  xx], each dcops],
			   	["togpath1-rathnode", [ ur, -ur], each icops],
			   	["togpath1-rathnode", [-ur, -ur], each icops],
			   	["togpath1-rathnode", [-ur,  xx], each dcops],
			   	["togpath1-rathnode", [-xx,  xx], each ocops],
			   	["togpath1-rathnode", [-xx, -xx], each ocops],
				]
			),
			zo[0]
		)
	),

	togthreads2_make_threads(
		togthreads2_simple_zparams([[0,1], [thickness_mm,1]], 3, extend=1),
		"2-4+1/2-UNC",
		r_offset = 0.2
	),

	for( xm=[-1,0,1] ) for( ym=[-1,0,1] )
	["translate", [xm*chunk,ym*chunk,thickness_mm], mounting_hole]
]);
