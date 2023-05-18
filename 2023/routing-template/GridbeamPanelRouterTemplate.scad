// GridbeamPanelRouterTemplate-v2.6
// (Formerly RouterGuideGridPanel)
//
// -- Change history --
// 
// v2.0:
// - Add between-grid of countersunk #6 holes
// - Add beveled guide slots to help the bushing find the holes
// v2.1:
// - Allow selection of different bowtie cutout shapes
// v2.2:
// - Fix the notch position to avoid z-fighting with top of panel
// - Additional pockets with rad diagonal pattern cut out to reduce filament use
// v2.3:
// - Rename, move from ProjectNotes2 to OpenSCADDesigns
// v2.4:
// - Replace infinitely customizable alternate holes hopefully better holelib ones,
//   and have 4x as many of them
// - Recommend not using margin but doing that part in Slic1ng.
// v2.5:
// - Rounded instead of beveled corners
// v2.6:
// - Allow bowties only along certain edges
// - $fn tweaks

// Length of bowties (mm); 3/4" = 19.05mm
bowtie_length    = 19.05;
// Thickness of panel (mm); 1/8" = 3.175mm
thickness = 3.175;

// Grid size (mm); 1.5" = 38.1
grid_unit_size = 38.1;
// Outer dimensions of panel, in grid units
panel_size_gc = [4, 4];

// Distance (mm) to offset outer edges inwards for wiggle room or to account for fat extrusion.  It may be better to leave this 0 and use your slicer's X/Y compensation parameter, instead.
margin    = 0.00;  // 0.01

// Size of holes; 12.2 printed with my regular Slic3r settings on my Kobra Max was found to fit 7/16" router bushings
hole_diameter = 12;
// How many units to skip at corners
bowtie_position_offset = 1.0; // 0.5
bowtie_edges = [true, true, false, false];

bowtie_cutout_shape = "semi-maximal"; // ["angular","quarter-bit-cutout","semi-maximal"]

// Style of in-between holes; THL-1001 is for #6 flatheads, THL-1002 is for 1/4" flatheads
hole2_type_name = "THL-1001"; // ["none", "THL-1001", "THL-1002"]

// 6.35mm = 1/4", 4.7625mm = 3/16"; 3.125mm = 1/8"
corner_radius = 4.7625;

pocket_wall_thickness = 3.175;
// Thickness of floor under silly pockets; set to >= thickness to disable the silly pockets
pocket_floor_thickness = 1;

pocket_interior_wall_thickness = 1.5;
pocket_interior_wall_spacing = 5;
pocket_interior_angle = 60;

preview_fn = 12;
render_fn = 48;

$fn = $preview ? preview_fn : render_fn;

module __end_parameter_list() { }

hole2_surface_diameter = 12; // Eh

include <../lib/BowtieLib-v0.scad>
include <../lib/TOGHoleLib-v1.scad>

// Panel

inch = 25.4;
panel_size = [panel_size_gc[0] * grid_unit_size, panel_size_gc[1] * grid_unit_size];

translate([0,0,0]) {
	difference() {
		linear_extrude(thickness) difference() {
			rounded_square([panel_size[0]-margin*2, panel_size[1]-margin*2], corner_radius);
			for( pos=bowtie_positions(panel_size, [bowtie_length, bowtie_length], bowtie_position_offset*bowtie_length, edges=bowtie_edges ) ) {
				translate([pos[0],pos[1]]) rotate([0,0,pos[2]]) bowtie_of_style(bowtie_cutout_shape, bowtie_length, margin);
			}
			if( bowtie_position_offset == 0.5 ) {
				// Chop off corners
				for( r=[0:90:270] ) rotate([0,0,r]) {
					translate([bowtie_length*2, bowtie_length*2]) square([bowtie_length, bowtie_length], center=true);
				}
			}
			if( hole_diameter > 0 ) for( pos=grid_cell_center_positions(panel_size, [grid_unit_size, grid_unit_size]) ) {
				translate( pos ) circle(d=hole_diameter, $fn=max($fn,48));
			}
		}
		small_hole_positions = fencepost_positions_ofe_2d(panel_size, [grid_unit_size/2, grid_unit_size/2], grid_unit_size/2);
		if( hole2_type_name != "none" ) translate([0,0,thickness]) {
			for( pos=small_hole_positions ) {
				translate(pos) {
					tog_holelib_hole(hole2_type_name, thickness*2);
				}
			}
		}
		for( y=fencepost_positions_ofe(panel_size[1], grid_unit_size, grid_unit_size/2) ) {
			translate([0,y,thickness]) rotate([0,0,90]) rotate([90,0,0]) linear_extrude(grid_unit_size*(panel_size_gc[0]-1), center=true) {
				polygon([
					[+hole_diameter/2 + thickness/2,  thickness/2],
					[+hole_diameter/2 + thickness/2,  0          ],
					[+hole_diameter/2 + 0          , -thickness/2],
					[-hole_diameter/2 - 0          , -thickness/2],
					[-hole_diameter/2 - thickness/2,  0          ],
					[-hole_diameter/2 - thickness/2,  thickness/2],
				]);
			}
			for(xm=[-1,1]) translate([xm*grid_unit_size*(panel_size_gc[0]-1)/2, y, thickness]) {
				cylinder(h=thickness, d1=hole_diameter, d2=hole_diameter+thickness*2, center=true);
			}
		}
		// Additional pockets just to use less material
		if( pocket_floor_thickness < thickness ) translate([0,0,thickness]) linear_extrude((thickness-pocket_floor_thickness)*2, center=true) difference() {
			for( y=fencepost_positions_ofe(panel_size[1], grid_unit_size, grid_unit_size) ) {
				translate([0, y, 0]) {
					beveled_square([
						panel_size[0] - bowtie_length - pocket_wall_thickness*2,
						grid_unit_size - hole_diameter - thickness - pocket_wall_thickness*2
					], corner_radius);
					
				}
			}
			for( pos=small_hole_positions ) {
				translate(pos) circle(d=hole2_surface_diameter+pocket_wall_thickness*2);
			}
			rotate([0,0,pocket_interior_angle]) {
				for( i=[-panel_size[0]-panel_size[1] : pocket_interior_wall_spacing : panel_size[0]+panel_size[1]] ) {
					translate([0, i]) square([panel_size[0]+panel_size[1], pocket_interior_wall_thickness], center=true);
				}
			}
		}
		// Notch to mark left end of top edge
		translate([-panel_size[0]/2 + 5/16*inch, panel_size[1]/2, thickness/2]) cube([1/8*inch, 1/8*inch, thickness*2], center=true);
	}
}
