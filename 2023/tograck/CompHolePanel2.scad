// CompHolePanel2.1
//
// TOGRack panel with configurable component holes.
// Complex compspecs can't be entered into OpenSCAD's customizer,
// so aliases are hardcoded, e.g. p20
// but you could make presets.
// 
// v2.0
// - Copied from CompHolePanel1.3
// - Include p2012 builtin
// v2.1
// - Add p2019 builtin, mostly for show

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

compspec = "p2012";

/* [Detail] */
outer_offset = "-0.1mm";
$fn = 24;

module compholepanel2__end_params() { }

p2012_compspec = ["array", [2,2], ["20u","24u"],
	["cb-hole", "12.1mm", "3mm", "21mm"]
];
p2019_compspec = ["cb-hole", "12.5mm", "1.6mm", "1inch"];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGRackPanel1.scad>
use <../lib/TOGUnits1.scad>

function u_to_mm(u)     = u * 254/160;
function atoms_to_mm(a) = a * 127/10;

basic_offset_mm = togunits1_to_mm(panel_basic_offset);

bottom_z = -togunits1_to_mm( back_fat      );
top_z    =  togunits1_to_mm(panel_thickness);

nominal_size = [
	togunits1_to_mm(size[0]),
	togunits1_to_mm(size[1]),
	top_z,
];

actual_size = [
   nominal_size[0] + basic_offset_mm*2,
   nominal_size[1] + basic_offset_mm*2,
];

function arrayspec_to_togmod(comp) =
	assert(comp[0] == "array")
	let(spacing = togunits1_decode_vec(comp[2]))
	let(thing = compspec_to_togmod(comp[3]))
	let(col_count = comp[1][0], row_count = comp[1][1])
	let(col_space = spacing[0], row_space = spacing[1])
	["union",
		for(ym=[-row_count/2+0.5 : 1 : row_count/2-0.4])
		for(xm=[-col_count/2+0.5 : 1 : col_count/2-0.4])
		["translate", [xm*col_space, ym*row_space], thing]
	];

function cbholespec_to_togmod(comp) =
	let(neck_diam   = togunits1_to_mm(comp[1]))
	let(neck_length = togunits1_to_mm(comp[2]))
	let(cb_diam     = togunits1_to_mm(comp[3]))
	let(shoulder_z = $top_z - neck_length)
	tphl1_make_z_cylinder(zds=[
		[$bottom_z - 1,   cb_diam],
		[shoulder_z   ,   cb_diam],
		[shoulder_z   , neck_diam],
		[$top_z    + 1, neck_diam],
	]);

function posspec_to_vec(pos) = [
	for(d=pos) 
		d == "nominal-right" ?  nominal_size[0]/2 :
		d == "nominal-left"  ? -nominal_size[0]/2 :
		d == "nominal-back"  ?  nominal_size[1]/2 :
		d == "nominal-front" ? -nominal_size[1]/2 :
		d == "actual-right"  ?   actual_size[0]/2 :
		d == "actual-left"   ? - actual_size[0]/2 :
		d == "actual-back"   ?   actual_size[1]/2 :
		d == "actual-front"  ? - actual_size[1]/2 :
		togunits1_to_mm(d)
];

function translatespec_to_togmod(comp, index=1) =
	index == len(comp)-1 ? compspec_to_togmod(comp[index]) :
	["translate", posspec_to_vec(comp[index]), translatespec_to_togmod(comp, index+1)];

function compspec_to_togmod(comp) =
	comp[0] == "translate" ? translatespec_to_togmod(comp) : // ["translate", posspec_to_vec(comp[1]), compspec_to_togmod(comp[2])] :
	comp[0] == "array" ? arrayspec_to_togmod(comp) :
	comp[0] == "cb-hole" ? cbholespec_to_togmod(comp) :
	comp[0] == "union" ? ["union", for(i=[1:1:len(comp)-1]) compspec_to_togmod(comp[i])] :
	// Handle aliases:
	comp == "p2012" ? compspec_to_togmod(p2012_compspec) :
	comp == "p2019" ? compspec_to_togmod(p2019_compspec) :
	assert(false, str("Unrecognized component: '", comp, "'"));

togmod1_domodule(tograckpanel1_panel(
	nominal_size,
	outer_offset = togunits1_to_mm(panel_basic_offset)+togunits1_to_mm(outer_offset),
	back_fat = -bottom_z,
	mounting_hole_style = mounting_hole_style,
	mounting_hole_frequency = mounting_hole_frequency,
	3d_mod = function(panel) ["difference",
		panel,
		
	   compspec_to_togmod(compspec, $bottom_z = bottom_z, $top_z = top_z),
	]
));
