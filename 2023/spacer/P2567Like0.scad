// P2567Like0.1
// 
// Spacer with multiple slotted holes.

size_chunks = [3,1];
hole_size_mm = [9, 4.5];
thickness = "1/8inch";
$fn = 32;

module __p2567like__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGUnits1.scad>

chunk_mm    = togunits1_to_mm("chunk");
atom_mm     = togunits1_to_mm("atom");

size_mm     = size_chunks * chunk_mm;
size_atoms  = size_chunks * togunits1_decode("1chunk", unit="atom");
thickness_mm = togunits1_to_mm(thickness);

hole = togmod1_make_rounded_rect(hole_size_mm, r=min(hole_size_mm[0], hole_size_mm[1])/2);

togmod1_domodule(
	togmod1_linear_extrude_z([0, thickness_mm],
		["difference",
			togpath1_rath_to_polygon(togpath1_make_rectangle_rath(size_mm, [["bevel", 3.175], ["round", 3.175]])),
			
			for( ym=[-size_atoms[1]/2 + 0.5 : 1 : size_atoms[1]/2] )
			for( xm=[-size_atoms[0]/2 + 0.5 : 1 : size_atoms[0]/2] )
			["translate", [xm,ym]*atom_mm, ["rotate", [0,0,90*floor(xm+ym)], hole]]
		]
	)
);
