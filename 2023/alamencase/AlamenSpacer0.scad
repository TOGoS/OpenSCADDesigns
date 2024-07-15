// AlamenSpacer0.1
// 
// 1/2" TOGBeam or TOGRail, depending on thickness.

length_atoms   = 3;
thickness      = 1; // 0.01
thickness_unit = "mm"; // ["mm", "u", "atom"]

preview_fn = 24;
render_fn  = 32;

module __alamenspacer__end_params() { }

inch = 25.4;
atom = inch/2;
u    = inch/8;

thickness_atoms = togridlib3_decode([thickness, thickness_unit], unit=[1, "atom"]);
thickness_mm    = togridlib3_decode([thickness, thickness_unit]);

$fn = $preview ? preview_fn : render_fn;

use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGVecLib0.scad>

5mm_circle   = togmod1_make_circle(d=5);
5mm_cylinder = tphl1_make_z_cylinder(d=5, zrange=[-atom, +atom]);

function alamenspacer0_make_spacer(size) =
	let( yhole = ["rotate", [90,0,0], 5mm_cylinder] )
	["difference",
		togmod1_linear_extrude_z([0, size[2]], ["difference",
			togmod1_make_rounded_rect([size[0], size[1]], r=1.6),
			
			for( xa=[-length_atoms/2+0.5 : 1 : length_atoms/2-0.5] )
				["translate", [xa*atom, 0, 0], 5mm_circle],
		]),
		
		for( za=[0.5 : 1 : thickness_atoms-0.45] )
			for( xa=[-length_atoms/2+0.5 : 1 : length_atoms/2-0.5] )
				["translate", [xa*atom, 0, za*atom], yhole],
	];

togmod1_domodule(alamenspacer0_make_spacer([length_atoms*atom, atom, thickness_mm]));
