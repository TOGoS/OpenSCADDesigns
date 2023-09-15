use <../lib/TOGridPileLib-v2.scad>
use <../lib/TOGridLib3.scad>

$fn = 48;

u = 1/16; // togridlib3_decode([1, "u"]);

translate([12*u, 12*u]) togridpile2_atom_column_footprint(
	"v6.1", atom_pitch=24*u,
	column_diameter=22*u,
	min_corner_radius=u
);
