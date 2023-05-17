// So I have this magnet case that's like 72mm square on the top,
// but more like 70mm square on the bottom, with uhh, let's say 10mm rounded corners
// (somewhere between 1/4" and 1/2")

preview_fn = 12;
render_fn = 48;

// include <../lib/TOGridPileLib-v1.scad>;
use <TOGridPileBlock.scad>

module __end_params() { }

inch = 25.4;

$fn = $preview ? preview_fn : render_fn;

difference() {
	togridpile_multiblock_cup([2, 2], 6.35, 2.54);
	translate([0,0,3/16*inch]) {
		linear_extrude(100) togridpile__rounded_square([71,71], 9);
	}
}
