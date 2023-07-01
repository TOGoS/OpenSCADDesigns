use <../lib/TOGridPileLib-v3.scad>

// Using default unit table (may give a warning):
togridpile3_cube(
	[[1, "chunk"], [2, "chunk"], [3, "chunk"]]
);

alternate_unit_table = [
	["chunk", [2, "atom"]],
	each togridpile3_get_default_unit_table()
];

// Using explicit unit table
translate([76.2, 0, 0]) togridpile3_cube(
	[[1, "chunk"], [2, "chunk"], [3, "chunk"]],
	$togridpile3_unit_table = alternate_unit_table
);
