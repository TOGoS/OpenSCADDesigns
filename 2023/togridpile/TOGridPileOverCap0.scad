// TOGridPileOverCap0.1
// 
// A cap that just fits over the block.
// Will collide with neighboring blocks' caps.
// Intended to be printed in PETG and for non-tesselating uses.

size_atoms = [4, 2];
$fn = 64;

use <../lib/TOGPath1.scad>
use <../lib/TOGMod1.scad>
use <../lib/SimpleCap0.scad>

function mkcaprath(size, offset) = togpath1_make_rectangle_rath(size, corner_ops=[["bevel", 3.175], ["round", 1.6], ["offset", offset]]);

cap =
let( size = size_atoms * 12.7 )
let( inner_rath = mkcaprath(size, 0) )
simplecap0_make_cap(inner_rath);

togmod1_domodule(cap);
