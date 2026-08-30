// HollowCornerBracket0.1
// 
// A simple gridbeam corner bracket.
// 
// See also: SmallPlatformBracket1, which is similar but has threaded holes.

width = "1chunk";
height = "1chunk";
depth = "1chunk";
wall_thickness = "1/4inch";
counterbore_depth = "1/16inch";

// Offset of outer hull and inner walls, in mm
$tgx11_offset = 0.0;
$fn = 24;

module __hollowcornerbracket0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>
use <../lib/TOGHoleLib2.scad>

function xf_points(xf, points) = [for(p=points) xf(p)];

togmod1_domodule(
	let( chunk_mm  = togunits1_to_mm("chunk") )
	let( width_mm  = togunits1_to_mm(width ) )
	let( width_chunks = togunits1_decode(width, unit="chunk") )
	let( height_mm = togunits1_to_mm(height) )
	let( height_chunks = togunits1_decode(height, unit="chunk") )
	let( depth_mm  = togunits1_to_mm(depth ) )
	let( depth_chunks = togunits1_decode(depth, unit="chunk") )
	let( wall_thickness_mm  = togunits1_to_mm(wall_thickness) )
	let( counterbore_depth_mm = togunits1_to_mm(counterbore_depth) )
	let( x0 = -width_mm/2, x1 = width_mm/2 )
	let( y0 = -depth_mm/2, y1 = depth_mm/2 )
	let( z0 = -height_mm/2, z1 = height_mm/2 )
	let( oo = $tgx11_offset )
	
	let( vbev = 1 )
	let( scops = [["round", 3.175]] )

	let( the_hull = tphl1_make_polyhedron_from_layer_function(
		[
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
	let( hole = tog_holelib2_hole("THL-1006", depth=wall_thickness_mm*2, counterbore_inset=counterbore_depth_mm, overhead_bore_height=oo+1, $fn=min(360,$fn*3)) )
	let( chunk_cutout =
		let( y_hole = ["translate", [0, 0, height_mm/2-wall_thickness_mm],
			["rotate-xyz", [180,0,0], hole]] )
		let( z_hole = ["translate", [0,  depth_mm/2-wall_thickness_mm, 0],
			["rotate-xyz", [ 90,0,0], hole]] )
		["union",
			["translate", [0,-wall_thickness_mm,-wall_thickness_mm],
				togmod1_make_cuboid([chunk_mm - wall_thickness_mm*2 - oo*2, depth_mm-oo*2, height_mm-oo*2])],
			
			for( zm=[-height_chunks/2+0.5 : 1 : height_chunks/2-0.5] )
			["translate", [0,0,zm*chunk_mm], y_hole],
			
			for( ym=[-depth_chunks/2+0.5 : 1 : depth_chunks/2-0.5] )
			["translate", [0,ym*chunk_mm,0], z_hole],			
		]
	)
	["difference",
		the_hull,
		
		for( xm=[-width_chunks/2 + 0.5 : 1 : width_chunks/2-0.5] )
		["translate", [xm*chunk_mm, 0, 0], chunk_cutout],
	]
);
