// GrippyPanel1.0
// 
// Panel for use with e.g. EdgeDrillJig1.

atom_pitch = 12.7;
size_atoms = [6, 3];
thickness0 = 3.175;
thickness1 = 4.7625;

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

hull_2d = togmod1_make_rounded_rect(atom_pitch*[size_atoms[0], size_atoms[1]], r=3.175, $fn=24);
hole = togmod1_make_circle(d=4.5, $fn=24);

size = size_atoms * atom_pitch;

togmod1_domodule(["intersection",
	["linear-extrude-zs", [0, max(thickness0, thickness1)],
		["difference",
			hull_2d,
			
			for( xm=[-size_atoms[0]/2+0.5 : 1 : size_atoms[0]/2-0.4] )
			for( ym=[size_atoms[1]/2-0.5] )
			["translate", [xm*atom_pitch, ym*atom_pitch], hole],
		],
	],
	
	["rotate", [0,-90,0], ["linear-extrude-zs", [-size[0], size[0]], togmod1_make_polygon([
		[-1, -size[1]],
		[thickness1, -size[1]],
		[thickness1, -size[1]/2 + atom_pitch],
		[thickness0,  size[1]/2 - atom_pitch],
		[thickness0,  size[1]],
		[-1,  size[1]],
	])]],
]);
