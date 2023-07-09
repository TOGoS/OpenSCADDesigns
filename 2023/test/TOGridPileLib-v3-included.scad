include <../lib/TOGridLib3.scad>

alternate_unit_table = [
	["chunk", [2, "atom"]],
	each togridlib3_get_default_unit_table()
];

// Using default unit table (may give a warning):
togridlib3_cube(
	[[1, "chunk"], [2, "chunk"], [3, "chunk"]]
);

// Using explicit unit table
translate([-76.2, 0, 0]) togridlib3_cube(
	[[1, "chunk"], [2, "chunk"], [3, "chunk"]],
	$togridpile3_unit_table = alternate_unit_table
);
