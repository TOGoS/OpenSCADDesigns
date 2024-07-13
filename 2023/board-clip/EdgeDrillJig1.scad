// EdgeDrillJig1.1
// 
// To help guide your drill bit straight into the edge of something narrow.
// 
// Changes:
// v1.1:
// - Alternate hole patterns "B" and "C"

atom_pitch = 12.7;
length_atoms = 6;
drill_hole_diameter = 3;
mounting_hole_diameter = 4.5;

hole_pattern = "A"; // ["A", "B", "C"]

use <../lib/TOGMod1.scad>
use <../lib/TOGPolyhedronLib1.scad>

function edj1_make_block(
	size,
	hole_spacing,
	drill_hole_diameter,
	mounting_hole_diameter,
	hole_pattern
) =
	let( y_hole = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-size[1], size[1]], d=mounting_hole_diameter, $fn=24)] )
	let( z_hole = tphl1_make_z_cylinder(zrange=[-size[2], size[2]], d=drill_hole_diameter, $fn=24) )
	let( dust_chute = ["rotate", [90,0,0], tphl1_make_z_cylinder(zrange=[-size[1], size[1]], d=drill_hole_diameter*2.5, $fn=6)] )
	let( rail_hull = tphl1_make_rounded_cuboid(size, r=[2, 2, 0], corner_shape="ovoid1", $fn=24) )
	let( drill_hole_xms =
		hole_pattern == "A" ? [-round(size[0]/hole_spacing)/2 + 1.5 : 1 : size[0]/hole_spacing/2 - 1.4] :
		hole_pattern == "B" ? [-round(size[0]/hole_spacing)/2 + 0.5 : 1 : size[0]/hole_spacing/2 - 0.4] :
		hole_pattern == "C" ? [-round(size[0]/hole_spacing)/2 + 1   : 1 : size[0]/hole_spacing/2 - 0.9] :
		assert(false, str("Unrecognized hole pattern name: '", hole_pattern, "'"))
	)
	let( mounting_hole_xms =
		hole_pattern == "A" ? [-round(size[0]/hole_spacing)/2 + 0.5     , size[0]/hole_spacing/2 - 0.5] :
		hole_pattern == "B" ? [-round(size[0]/hole_spacing)/2 + 1   : 1 : size[0]/hole_spacing/2 - 0.9] :
		hole_pattern == "C" ? [-round(size[0]/hole_spacing)/2 + 0.5 : 1 : size[0]/hole_spacing/2 - 0.4] :
		assert(false, str("Unrecognized hole pattern name: '", hole_pattern, "'"))
	)
	["difference",
		rail_hull,
		for( xm = drill_hole_xms    ) ["translate", [xm*hole_spacing, 0, 0], z_hole],
		for( xm = drill_hole_xms    ) ["translate", [xm*hole_spacing, 0, -size[1]/2], dust_chute],
		for( xm = mounting_hole_xms ) for( xr=[0,90] ) ["translate", [xm*hole_spacing, 0, 0], ["rotate", [xr,0,0], y_hole]],
	];

togmod1_domodule(edj1_make_block(
	size=[length_atoms*atom_pitch, atom_pitch, atom_pitch],
	hole_spacing=atom_pitch,
	drill_hole_diameter = drill_hole_diameter,
	mounting_hole_diameter = mounting_hole_diameter,
	hole_pattern = hole_pattern
));
