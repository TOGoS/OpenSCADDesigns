// TGPLidTopper0.1
// 
// TOGridPile top for terrarium lid.
// Specifically for p1797
// (http://picture-files.nuke24.net/uri-res/raw/urn:bitprint:GJQ6W6P2MMP7R2EHB5LKBKRW44WESZDW.WRY2ZSMRMQBXZYCHY2Q3PSDIRCEL5VTCDACXM5I/p1797.png)
// though it could be parameterized later

$fn = $preview ? 16 : 48;
$tgx11_offset = -0.1;

magnet_hole_diameter = 6.2; // 0.1
magnet_hole_depth    = 2.4; // 0.1

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>

function u_to_mm(u)    = u * 254 / 160;
function inch_to_mm(i) = i * 254 / 10;

chunk = 38.1;
atom  = 12.7;

togmod1_domodule(
let(inner_round = 2)
let(component_hole_2d = togmod1_make_circle(d = 32))
let(extra_hole_2d = togmod1_make_circle(d = 5))
let(magnet_hole_2d = togmod1_make_circle(d = magnet_hole_diameter))
let(big_square = togpath1_make_rounded_beveled_rect([inch_to_mm(3), inch_to_mm(3)], u_to_mm(2), inner_round, offset=0 - u_to_mm(1) - $tgx11_offset))
let(small_square = togpath1_make_rounded_beveled_rect([inch_to_mm(1.5), inch_to_mm(1.5)], u_to_mm(2), inner_round, offset=0 - u_to_mm(1) - $tgx11_offset))
let(component_hole_positions = [for(cp=[[-3,1],[3,1]] ) cp*chunk])
let(cps = [for(cy=[-1.5 : 1 : 1.5]) for(cx=[-3.5 : 1 : 3.5]) [cx,cy]]) // All chunk positions, in chunks
let(small_square_positions   = [for(cp=cps) if(cp[1] < 0 || (cp[0] > -2 && cp[0] < 2)) cp*chunk])
let(magnet_hole_positions    = [for(cp=cps) for(ap=[[1,-1],[1,1],[-1,1],[-1,-1]]) [cp[0]*3+ap[0], cp[1]*3+ap[1]]*atom])
let(extra_hole_positions     = [for(cp=cps) for(ap=[[1,0],[0,1],[-1,0],[0,-1]]) [cp[0]*3+ap[0], cp[1]*3+ap[1]]*atom])
["difference",
	togmod1_linear_extrude_z([0, u_to_mm(3)], ["difference",
	   togpath1_make_rounded_beveled_rect([inch_to_mm(12), inch_to_mm(6)], u_to_mm(2), u_to_mm(2), offset=$tgx11_offset),
		
		for( pos=component_hole_positions ) ["translate", pos, component_hole_2d],
		for( pos=extra_hole_positions ) ["translate", pos, extra_hole_2d],
	]),
	
	togmod1_linear_extrude_z([u_to_mm(2), u_to_mm(4)], ["union",
		for( pos=component_hole_positions ) ["translate", pos, big_square],
		for( pos=small_square_positions   ) ["translate", pos, small_square],											  
	]),

	togmod1_linear_extrude_z([u_to_mm(2) - magnet_hole_depth, u_to_mm(2)+1], ["union",
		for( pos=magnet_hole_positions ) ["translate", pos, magnet_hole_2d],
	]),
]);
