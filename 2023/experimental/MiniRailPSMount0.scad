// MiiRailPSMount0.1
// 
// 'Generic' mount for power strips that mount on screw heads.
// Put two of these along a MiniRail and then jam the power strip on, I guess.

$fn = 32;
block_size = ["1+1/2inch", "1+1/2inch", "3/4inch"];
mr_offset = 0.2;
$tgx11_offset = -0.1;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGVecLib0.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TGx11.1Lib.scad>

block_size_mm = togunits1_vec_to_mms(block_size);
$togridlib3_unit_table = tgx11_get_default_unit_table();

function mirror_rathnodes(nodes) =
	[for(i=[len(nodes)-1 : -1 : 0])
		let(n=nodes[i])
		[n[0], [-n[1][0], n[1][1]], for(o=[2:1:len(n)-1]) n[o]]
	];

function make_mr_basic_rath(mr_offset, offset) =
	let( inch = 25.4 )
	let( u = inch/16 )
	let( rd1 = [
	   ["togpath1-rathnode", [          + 3*u, -4*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [          + 5*u, -6*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [mr_offset + 6*u, -6*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [mr_offset + 7*u, -5*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [mr_offset + 8*u, -4*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [mr_offset + 5*u, -1*u], ["round", u], ["offset", offset]],
		["togpath1-rathnode", [mr_offset + 7*u,  1*u],               ["offset", offset]],
	])
	["togpath1-rath", each rd1, each mirror_rathnodes(rd1)];

hole = tphl1_make_z_cylinder(zrange=[-100,100], d=4, $fn=4);
rothole = ["rotate", [0,0,45], hole];
// hole = ["rotate", [0,0,45], tphl1_make_z_cylinder(zds=[[-1,8], [1,8], [3,4], [100,4]], $fn=4)];
// hole = ["rotate", [0,0,45], tphl1_make_z_cylinder(zds=[[0.3, 4], [100,4]], $fn=4)];

togmod1_domodule(
	let( inch = 25.4 )
	let( u = inch/16 )
	["difference",
		["translate", [0,0,-block_size_mm[2]/2], tgx11_block(togunits1_vec_to_cas(block_size), lip_height=-1, bottom_segmentation="chunk", top_segmentation="chunk", bottom_foot_bevel=0.4)],
		//togmod1_make_cuboid(block_size_mm),
		
		/*["translate", [0,0,1.5*inch/2], togmod1_linear_extrude_x([-2*inch, 2*inch],
			togmod1_make_polygon(togpath1_rath_to_polypoints(mr_basic_rath))
		)],*/
		["translate", [0,0,block_size_mm[2]/2], ["rotate", [90,0,0], tphl1_make_polyhedron_from_layer_function([
		   [-block_size_mm[0]/2 - 0.1, 1, 1],
			[-block_size_mm[0]/2 + 3.9, 0, 0],
			[ block_size_mm[0]/2 - 3.9, 0, 0],
		   [ block_size_mm[0]/2 + 0.1, 1, 1],
		], function(zo) togvec0_offset_points(
			togpath1_rath_to_polypoints(make_mr_basic_rath(mr_offset=mr_offset+zo[1], offset=zo[2])),
			zo[0]
	   ))]],

		//for(xm=[-2 : 1 : 2])	for(ym=[-2 : 1 : 2])
		for(xm=[0 : 1 : 0]) for(ym=[-2 : 1 : 2])
		//let(xm=0, ym=0)
		//if( (xm+ym+100) % 2 == 0 )
		["translate", [xm*6.35,ym*6.35,-block_size_mm[2]/2], rothole],
	]
);
