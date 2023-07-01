// TOGridPileLib-v3
//
// HOKAY WHAT ARE THE COMMON
// things that I want the library to do?
// 
// - [X] Be `include`-able, to make inlining easy
// - [X] Allow unit table to be overridden easily, but default by default
// - [ ] Support common configurations by name (e.g. "V9", or some "WSTYPE-...")
//   without having to pass 50 different parameters in
// - [ ] Make a simple foot-only block that I can subtract stuff from
//   params: foot style
// - [ ] Make a block with a lip
// - [ ] Make a block foot, and I'll intersect it with some other things
// - [X] Translate a block_size_ca to mm

use <../lib/TOGUnitTable-v1.scad>

function togridpile3_map(arr, fn) = [ for(item=arr) fn(item) ];

togridpile3_default_unit_table = [
	["um",    [    1,               "um"]],
	["mm",    [ 1000,               "um"]],
	["inch",  [25400,               "um"]],
	["u",     [    1.5875,          "mm"]],
	["atom",  [    8,                "u"]],
	["chunk", [    3,             "atom"]],
	["tgp-standard-bevel"   , [2,    "u"]], // Usuually 1/8"
	["m-outer-corner-radius", [4,    "u"]],
	["f-outer-corner-radius", [3,    "u"]],
];

function togridpile3_get_default_unit_table() = togridpile3_default_unit_table;
function togridpile3_get_unit_table() = is_undef($togridpile3_unit_table) ? togridpile3_default_unit_table : $togridpile3_unit_table;

function togridpile3_decode_size(size) =
	let( unit_table = togridpile3_get_unit_table() )
	togridpile3_map(size, function(dim) is_num(dim) ? dim : tog_unittable__divide_ca(unit_table, dim, [1, "mm"]));

module togridpile3_cube(size, offset=0) {
	cube(togridpile3_decode_size(size), center=true);
}
