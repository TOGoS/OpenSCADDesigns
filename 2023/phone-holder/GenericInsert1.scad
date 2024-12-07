// GenericHolder1.0
// 
// A simple, generic insert for blocky things
// that are to fit inside other blocky things.
// 
// BrickHolder1 can do most of what this does, and more.
// Use that if you want TOGridPile-shaped blocks or something.

description = "";
size_atoms = [5, 5, 1];
atom_pitch = 12.7; // 0.001
cavity_size = [0, 0]; // 0.1
bottom_hole_size = [0,0]; // 0.2
floor_thickness = 3.2; // 0.1
front_slot_width = 0; // 0.1
outer_offset = -0.1;
$fn = 64;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGArrayLib1.scad>
use <../lib/TOGVecLib0.scad>

size = [for(s=size_atoms) s * atom_pitch + outer_offset*2];

function brickholder2insert_volume( vec ) = tal1_reduce(1, vec, function(a,b) a*b);

togmod1_domodule(
let(height = size[2])
let(z_mid = 0)
let(crad = min(12, max((size[0]-cavity_size[0])/2, (size[1]-cavity_size[1])/2)))
let(hull = tphl1_make_rounded_cuboid(size, r=[crad,crad,0]))
let(cavity = brickholder2insert_volume(cavity_size) == 0 ? ["union"] :
	["translate", [0,0,height/2], tphl1_make_rounded_cuboid([cavity_size[0], cavity_size[1], (height-floor_thickness)*2], r=[1,1,0])])
let(bottom_hole =  brickholder2insert_volume(bottom_hole_size) == 0 ? ["union"] :
   tphl1_make_rounded_cuboid([bottom_hole_size[0], bottom_hole_size[1], height*2], r=[1,1,0]))
let(front_slot = front_slot_width == 0 ? ["union"] :
	["translate", [0,-(size[1]+bottom_hole_size[1])/4,0], tphl1_make_rounded_cuboid([front_slot_width, (size[1]-bottom_hole_size[1]), height*2], r=0)])
["difference",
	hull,
	cavity,
	bottom_hole,
	front_slot,
]);
