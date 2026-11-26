use <../lib/Flangify0.scad>
use <../lib/TOGMod1.scad>

assert(
	flangify0_extend(10,20,["zdopses",
		["zdops", [-10,10]],
		["zdops", [-10,5 ], ["round", 3]],
		["zdops", [ 10,5 ], ["bevel", 3]],
		["zdops", [ 10,10]],
	]) == ["zdopses",
		["zdops", [-20,10]],
		["zdops", [-10,10]],
		["zdops", [-10,5 ], ["round", 3]],
		["zdops", [ 10,5 ], ["bevel", 3]],
		["zdops", [ 10,10]],
		["zdops", [ 30,10]],
	]
);

assert(
	flangify0_extend(10,20,["zropses",
		["zrops", [-10,10]],
		["zrops", [-10,5 ], ["round", 3]],
		["zrops", [ 10,5 ], ["bevel", 3]],
		["zrops", [ 10,10]],
	]) == ["zropses",
		["zrops", [-20,10]],
		["zrops", [-10,10]],
		["zrops", [-10,5 ], ["round", 3]],
		["zrops", [ 10,5 ], ["bevel", 3]],
		["zrops", [ 10,10]],
		["zrops", [ 30,10]],
	]
);

// togmod1_domodule(zrs_to_cylinder([[0,5],[10,5]]));
togmod1_domodule(flangify0_extrude_z(flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zdopses",
	["zdops", [-10,20]],
	["zdops", [- 5,20]],
	["zdops", [- 5,10], ["round", 3]],
	["zdops", [  5,10], ["bevel", 3]],
	["zdops", [  5,20]],
	["zdops", [ 10,20]],
]))), $fn = 24);

translate([40,0,0])
togmod1_domodule(flangify0_extrude_z(flangify0_spec_to_zrs(flangify0_extend(10, 10, ["zropses",
	["zrops", [-10,20]],
	["zrops", [- 5,20]],
	["zrops", [- 5,10], ["round", 3]],
	["zrops", [  5,10], ["bevel", 3]],
	["zrops", [  5,20]],
	["zrops", [ 10,20]],
]))), $fn = 24);
