// NetPotPanel0.1
// 
// Panel to sit inside TerrariumSegment0
// and hold a couple of 4" netpots.

// Size of panel in 1/2"; this should be the size of a terrarium segment minus two in each dimension
panel_size_atoms = [22,10];
// Extra subtraction around the outer edges to make room for bumps and wiggles
panel_margin = 0.5;
panel_thickness = 3.175;

use <../lib/TOGridLib3.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>

module netpotpanel0__end_params() { }

$togridlib3_unit_table = togridlib3_get_default_unit_table();
$fn = 32;

// Outer dimensions should be dimension of terrarium segment - 2 * (1/2 inch + 0.4 * inch).
// The 0.4 is from the walls of the terrarium segments actually incurring
// into the interior by that much, since the concave bits start at 7/16" in from the
// outside and are 2mm thick (not taking into account an additional -0.1mm offset,
// which is really just there to appease the CGAL engine.

function netpotpanel0_outer_to_panel_dim(x) =
	let( terrarium_wall_thickness = togridlib3_decode([7/8, "atom"]) + 2 )
	let( extra_margin = 0.1 )
	x - 2 * (terrarium_wall_thickness + extra_margin);

function netpotpanel0_make_panel(size_ca, panel_margin=0, thickness=3.175) =
	let( inch = 25.4 )
	let( actual_size = [for(d=togridlib3_decode_vector(size_ca)) d - panel_margin * 2] )
	let( cell_size = 6*inch )
	let( grid_size_cells = [for(d=actual_size) round(d/cell_size)] )
	echo( grid_size_cells=grid_size_cells )
	let( netpot_hole = togmod1_make_circle(d=4*inch, $fn=min(128, $fn*2)) )
	togmod1_linear_extrude_z([0, 3.175], ["difference",
		togmod1_make_rounded_rect(actual_size, r=6),
		
		for( xm=[-grid_size_cells[0]/2+0.5 : 1 : grid_size_cells[0]/2-0.4] )
		for( ym=[-grid_size_cells[1]/2+0.5 : 1 : grid_size_cells[1]/2-0.4] )
		["translate", [xm,ym]*cell_size, netpot_hole]
	]);

togmod1_domodule(
	let( panel_size_ca = [for(a=panel_size_atoms) [a, "atom"]] )
	netpotpanel0_make_panel(panel_size_ca, panel_margin=panel_margin, thickness=panel_thickness)
);
