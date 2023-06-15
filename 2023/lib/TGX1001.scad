// TGX1001: A simple shape to subtract from TOGridPile lips
// to accommodate horizontal v6 columns

$tgx1001_column_diameter = 9.525; // 3/8"
$tgx1001_bevel_size = 2.71; // (1/16") * (sqrt(2)/2+1)

function tgx1001_v6c_points(
	column_diameter = $tgx1001_column_diameter,
	bevel_size      = $tgx1001_bevel_size,
	offset
) = assert(offset != undef) [
	[-column_diameter/2 + 0*bevel_size - 1    *offset,  column_diameter/2 - 0*bevel_size + 1    *offset],
	[+column_diameter/2 - 0*bevel_size + 1    *offset,  column_diameter/2 - 0*bevel_size + 1    *offset],
	[+column_diameter/2 - 0*bevel_size + 1    *offset, -column_diameter/2 + 1*bevel_size - 0.414*offset],
	[+column_diameter/2 - 1*bevel_size + 0.414*offset, -column_diameter/2 + 0*bevel_size - 1    *offset],
	[-column_diameter/2 + 1*bevel_size - 0.414*offset, -column_diameter/2 + 0*bevel_size - 1    *offset],
	[-column_diameter/2 + 0*bevel_size - 1    *offset, -column_diameter/2 + 1*bevel_size - 0.414*offset],
];

module tgx1001_v6c_polygon(offset=0) polygon(tgx1001_v6c_points(offset=offset));

module tgx1001_v6xc_subtractor(length=$tgx1001_column_diameter, offset) {
	rotate([90, 0, 90]) linear_extrude(length, center=true) tgx1001_v6c_polygon(offset=offset);
}
module tgx1001_v6yc_subtractor(length=$tgx1001_column_diameter, offset) {
	rotate([90, 0,  0]) linear_extrude(length, center=true) tgx1001_v6c_polygon(offset=offset);
}

use <./TOGUnitTable-v1.scad>

tgx1001_default_unit_table = [
	["um",    [    1,               "um"]],
	["mm",    [ 1000,               "um"]],
	["inch",  [25400,               "um"]],
	["u",     [    1/16,          "inch"]],
	["atom",  [    8,                "u"]],
	["chunk", [    3,             "atom"]],
];

// 'version 6 horizontal column' subtractor
module tgx1001_v6hc_block_subtractor(block_size_ca, unit_table=tgx1001_default_unit_table, offset) {
	assert(offset != undef);
	atom_pitch = tog_unittable__divide_ca(unit_table, [1, "atom"], [1, "mm"]);
	block_size_atoms = [
		tog_unittable__divide_ca(unit_table, block_size_ca[0], [1, "atom"]),
		tog_unittable__divide_ca(unit_table, block_size_ca[1], [1, "atom"])
	];
	block_size = [
		tog_unittable__divide_ca(unit_table, block_size_ca[0], [1, "mm"]),
		tog_unittable__divide_ca(unit_table, block_size_ca[1], [1, "mm"])
	];
	
	for( xm=[-block_size_atoms[0]/2 + 0.5 : 1 : block_size_atoms[0]/2] ) {
		translate([xm*atom_pitch, 0, atom_pitch/2]) tgx1001_v6yc_subtractor(length=block_size[1], offset=offset-1/1024);
	}

	for( ym=[-block_size_atoms[1]/2 + 0.5 : 1 : block_size_atoms[1]/2] ) {
		translate([0, ym*atom_pitch, atom_pitch/2]) tgx1001_v6xc_subtractor(length=block_size[0], offset=offset+1/1024);
	}
}

module tgx1001_demo() {
	tgx1001_v6hc_block_subtractor([[2, "chunk"], [1, "chunk"]], offset=0);
}
