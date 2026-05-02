// CarriageBoltGridbeamClip0.2
// 
// Wraps around a gridbeam and provides a hole
// in the middle for a carriage bolt
// (or whatever; hole style is configurable).
// 
// Based on RBClip0.2.

inner_width = "1chunk";
length = "1chunk";
thickness = "3/16inch";
arm_length = "3/8inch";
hole_style = "square-0.26inch";
hole_frequency = 2;
// Outset of hull.  Does not affect hole.
$tgx11_offset = -0.1;

$fn = 32;

module __carriageboltgridbeamclip0__end_params() { }

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGUnits1.scad>

inner_width_mm = togunits1_to_mm(inner_width);
length_mm      = togunits1_to_mm(length    );
length_chunks  = togunits1_decode(length, unit="chunk", xf="round");
thickness_mm   = togunits1_to_mm(thickness );
arm_length_mm  = togunits1_to_mm(arm_length );
chunk          = togunits1_to_mm("chunk");

togmod1_domodule(
	let( wi = inner_width_mm )
	let( t = thickness_mm )
	let( a = arm_length_mm )
	let( wo = inner_width_mm + t*2 )
	let( bev = min(2, thickness_mm/4) + $tgx11_offset*0.7 ) // or something like that
	let( r = t*($fn/2-1)/$fn ) // Try to avoid errors between rounded corners
	let( hole = tog_holelib2_hole(hole_style, depth=thickness_mm + 1) )
	["difference",
		["rotate-xyz", [90,0,90], tphl1_make_polyhedron_from_layer_function(
			[
				[-length_mm/2     - $tgx11_offset, -bev + $tgx11_offset],
				[-length_mm/2+bev - $tgx11_offset,  0   + $tgx11_offset],
				[ length_mm/2-bev - $tgx11_offset,  0   + $tgx11_offset],
				[ length_mm/2     - $tgx11_offset, -bev + $tgx11_offset],
			],
			function(zo) togpath1_rath_to_polypoints(["togpath1-rath",
				["togpath1-rathnode", [ wo/2    , -t], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ wo/2    ,  a], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ wi/2    ,  a], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [ wi/2    ,  0],               ["offset", zo[1]]],
				["togpath1-rathnode", [-wi/2    ,  0],               ["offset", zo[1]]],
				["togpath1-rathnode", [-wi/2    ,  a], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [-wo/2    ,  a], ["round", r], ["offset", zo[1]]],
				["togpath1-rathnode", [-wo/2    , -t], ["round", r], ["offset", zo[1]]],
			]),
			layer_points_transform = "key0-to-z"
		)],
		
		for( xm=[-length_chunks/2 + 0.5 : 1/hole_frequency : length_chunks/2 - 0.5] )
		["translate", [xm*chunk, 0, -t], ["rotate", [180,0,0], hole]],
	]
);
