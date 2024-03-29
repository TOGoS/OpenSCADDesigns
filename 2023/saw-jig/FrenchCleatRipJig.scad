// FrenchCleatRipJig-v1.2
// 
// Goal is to allow:
// 1. Fence to be set at the proper distance from the angled blade
// 2. Holding the already-cut pointy end of a cleat at a constant distance from the fence
// 3. Stretch goal: Cutting the first angled cut and then the second without having to
//    adjust the fence!  i.e. the jig will take up the exact amount of thickness needed.
// 
// For (2), assuming symmetrical cuts, we can simply say that the point will be at the fence,
// and then the jig simply fills the space above it.  Some downward pressure would be required,
// which maybe is not ideal.
// 
// v1.0 only accomplishes (2).
//
// v1.1:
// - Add 'panel' mode, to make a simple panel that can be bolted
//   to the wedge to hold boards in place.
// v1.2:
// - More and countersunk holes in panel

length_ca = [6, "inch"];
mode = "wedge"; // ["wedge", "panel","THL-1001"]
render_fn = 48;

module __fcrj_end_params() { }

use <../lib/TOGridLib3.scad>

$fn = $preview ? 12 : render_fn;
$togridlib3_unit_table = [
	["atom", [6, "u"], "atom"],
	each togridlib3_get_unit_table()
];

length       = togridlib3_decode(length_ca);
length_atoms = round(togridlib3_decode(length_ca, unit=[1, "atom"]));
u = togridlib3_decode([1, "u"]);
atom = togridlib3_decode([1, "atom"]);
b = 1; // Bevel size
panel_thickness = 3.175;

wedge_points_u = [
	[  3, 12, -1,  0],
	[- 3, 12,  0,  0],
	[-15,  0,  2,  2],
	[-15,  0,  2,  1],
	[-15,  0,  3,  0],
	[  3,  0, -1,  0],
	[  3,  0,  0,  1],
	[  3, 12,  0, -1],
];

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGHoleLib2.scad>

thl_1001 = tog_holelib2_hole("THL-1001", depth=panel_thickness+1);

tmod =
	mode == "wedge" ? ["difference",
		tphl1_make_polyhedron_from_layer_function([-length/2, length/2], function(x) [
			for( p=wedge_points_u ) [x, p[0]*u+p[2]*b, p[1]*u+p[3]*b]
		]),
		for( xm=[-length_atoms/2 + 0.5 : 1 : length/2] )
			["translate", [xm*atom, 0, 0], togmod1_make_cylinder(d=5, zrange=[-1*u,13*u])]
	] :
	mode == "panel" ? ["difference",
		["linear-extrude-zs", [0, panel_thickness],
			togmod1_make_rounded_rect([length, 3*atom], 3.175)],
		
		for( xm=[-length_atoms/2 + 0.5 : 1 : length/2] ) for( ym=[-1 : 1 : 1] )
			["translate", [xm*atom, ym*atom, panel_thickness], ["render", thl_1001]]
	] :
	mode == "THL-1001" ? thl_1001 :
	assert(false);

togmod1_domodule(tmod);
