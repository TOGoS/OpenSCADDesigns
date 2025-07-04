// GX12Breakout1.3
// 
// v1.0:
// - Copied from TagPanel1.2
// v1.3
// - Add back_fat_u and panel_thickness_u options, matching TagPanel1.3

size_atoms = [5,7];
panel_thickness_u = 15; // 0.0001
back_fat_u = 1;
mounting_hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
mounting_hole_frequency = 1; // [1,2]
outer_offset_u = -1;
outer_offset = -0.1;

$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGRackPanel1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

nominal_size = [
	atoms_to_mm(size_atoms[0]),
	atoms_to_mm(size_atoms[1]),
	u_to_mm(panel_thickness_u),
];

gx12_hole = tphl1_make_z_cylinder(zds=[[-4, 21], [0, 21], [0, 12.1], [10, 12.1]]);
gx12_hole_positions = [
	for( xm=[-1,1] ) for( ym=[-1,1] )
	[xm*nominal_size[0]/4, ym*19.05]
];

togmod1_domodule(tograckpanel1_panel(
	nominal_size,
	outer_offset = u_to_mm(outer_offset_u)+outer_offset,
	back_fat = u_to_mm(back_fat_u),
	mounting_hole_style = mounting_hole_style,
	mounting_hole_frequency = mounting_hole_frequency,
	3d_mod = function(panel) ["difference",
		panel,
		
	   for(pos=gx12_hole_positions) ["translate", pos, gx12_hole],
	]
	/* An alternative way to get those counterbored holes:
	2d_mod = function(panel) ["difference",
		panel,
	   for(pos=gx12_hole_positions) ["translate", pos, togmod1_make_circle(d=12.1)],
	],
	back_fat_2d_mod = function(panel) ["difference",
		panel,
	   for(pos=gx12_hole_positions) ["translate", pos, togmod1_make_circle(d=21)],
	]
	*/
));
