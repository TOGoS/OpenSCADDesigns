// CompHolePanel1.3
//
// Panel with regularl grid of counterbored circular holes.
// 
// v1.3:
// - Copied from GX12Breakout1.3
// - Default values give an approximate p2012

/* [Metadata] */

description = "";

/* [Panel Hull] */

size = ["5atom","7atom"];
panel_basic_offset = "-1u";
panel_thickness = "2u";
back_fat = "2u";

/* [Panel Mounting Holes] */

mounting_hole_style = "THL-1001"; // ["THL-1001", "THL-1004", "THL-1008", "straight-4.5mm", "straight-5mm"]
mounting_hole_frequency = 1; // [1,2]

/* [Component Holes] */

comp_neck_diameter = "12.1mm";
comp_neck_length = "3mm";
comp_counterbore_diameter = "21mm";
comp_row_count = 2;
comp_row_spacing = "24u";
comp_col_count = 2;
comp_col_spacing = "20u";

/* [Detail] */
outer_offset = "-0.1mm";
$fn = 24;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGRackPanel1.scad>
use <../lib/TOGUnits1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

bottom_z = -togunits1_to_mm( back_fat      );
top_z    =  togunits1_to_mm(panel_thickness);

nominal_size = [
	togunits1_to_mm(size[0]),
	togunits1_to_mm(size[1]),
	top_z,
];


comp_hole = tphl1_make_z_cylinder(
	zds=
	let(shoulder_z = top_z - togunits1_to_mm(comp_neck_length))
	let(cnd = togunits1_to_mm(comp_neck_diameter))
	let(cbd = togunits1_to_mm(comp_counterbore_diameter))
	[
		[bottom_z*2, cbd],
		[shoulder_z, cbd],
		[shoulder_z, cnd],
		[top_z*2   , cnd],
	]
);

comp_hole_positions =
let(cs = togunits1_to_mm(comp_col_spacing))
let(rs = togunits1_to_mm(comp_row_spacing))
[
	for( xm=[-comp_col_count/2+0.5 : 1 : comp_col_count/2-0.4] )
	for( ym=[-comp_row_count/2+0.5 : 1 : comp_row_count/2-0.4] )
	[xm*cs, ym*rs],
];

togmod1_domodule(tograckpanel1_panel(
	nominal_size,
	outer_offset = togunits1_to_mm(panel_basic_offset)+togunits1_to_mm(outer_offset),
	back_fat = -bottom_z,
	mounting_hole_style = mounting_hole_style,
	mounting_hole_frequency = mounting_hole_frequency,
	3d_mod = function(panel) ["difference",
		panel,
		
	   for(pos=comp_hole_positions) ["translate", pos, comp_hole],
	]
));
