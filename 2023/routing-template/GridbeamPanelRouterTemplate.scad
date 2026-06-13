// GridbeamPanelRouterTemplate-v2.14
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
// v2.7:
// - Add option for 'bowtie' cutouts along the edges
// v2.8:
// - Allow beveled_grooves_enabled=false
// v2.9:
// - More options for small hole style,
//   including 5mm straight hole with 12mm square counterbore
// - Make hole_diameter adjustable in 0.1mm increments
// v2.10:
// - Refactor hole placement so that either a bushing or small hole
//   is placed at each half grid position, and never both
// v2.11:
// - Option for 'round' bowties
// - Fix chopping-off of corners when bowtie_position_offset = 0.5
// v2.12:
// - Define small_hole_positions so that presets that use pockets work again
// v2.13:
// - Style of small holes in troff (hole3) can now be different
//   than that of small holes on ridges (hole2)
// v2.14
// - outer_corner_radius, outer_edge_offset

// Length of bowties (mm); 3/4" = 19.05mm; for round bowties, this corresponds to diamond_r*3
bowtie_length    = 19.05;
// Thickness of panel (mm); 1/8" = 3.175mm
thickness = 3.175;

// Grid size (mm); 1.5" = 38.1
grid_unit_size = 38.1;
// Outer dimensions of panel, in grid units
panel_size_gc = [4, 4];

// Size of holes; 12.2 printed with my regular Slic3r settings on my Kobra Max was found to fit 7/16" router bushings
hole_diameter = 12; // 0.1

// Cut grooves to help guide the bushing into the holes; may be useful when hole_diameter is barely large enough for the bushing
beveled_grooves_enabled = true;

// How many units to skip at corners
bowtie_position_offset = 1.0; // 0.5
// How many bowtie units between cutouts
bowtie_spacing = 1.0; // 0.5
bowtie_edges = [true, true, false, false];

bowtie_cutout_shape = "semi-maximal"; // ["angular","quarter-bit-cutout","semi-maximal","round"]

// Style of in-between holes; THL-1001 is for #6 flatheads, THL-1002 is for 1/4" flatheads
hole2_type_name = "THL-1001"; // ["none", "THL-1001", "THL-1002", "THL-1010", "countersquare:5mm,12mm"]

// Style of in-between holes at bottom of troff; 'hole2' makes them the same as whatever thee ridge holes are
hole3_type_name = "hole2";

// Radius of corners adjacent to bowtie edges, applied before offset/margin; 6.35mm = 1/4", 4.7625mm = 3/16"; 3.125mm = 1/8"
corner_radius = 4.7625; // 0.001
// Radius of non-bowtie corners, applied before offset/margin; actual radius of outer corners = max(outer_rorner_radius, corner_radius
outer_corner_radius = 0; // 0.001

pocket_wall_thickness = 3.175;
// Thickness of floor under silly pockets; set to >= thickness to disable the silly pockets
pocket_floor_thickness = 1;

pocket_interior_wall_thickness = 1.5;
pocket_interior_wall_spacing = 5;
pocket_interior_angle = 60;

// Offset of non-bowtie edges; actual offset of outer edges = outer_edge_offset - margin
outer_edge_offset = 0; // 0.001
// Distance (mm) to offset outer edges inwards for wiggle room or to account for fat extrusion.  It may be better to leave this 0 and use your slicer's X/Y compensation parameter, instead.
margin    = 0.00;  // 0.01

preview_fn = 12;
render_fn = 48;

$fn = $preview ? preview_fn : render_fn;

module __end_parameter_list() { }

eff_bowtie_edges = [
	for(e=bowtie_edges)
	is_bool(e) ? e :
	e == "false" ? false :
	e == "true" ? true :
	e == 0 ? false :
	e == 1 ? true :
	assert(false, str("Invalid boolean representation: ", e))
];

hole2_surface_diameter = 12; // Eh
hole3_surface_diameter = hole2_surface_diameter; // Eh

use <../lib/BowtieLib-v0.scad>
use <../lib/TOGHoleLib2.scad>
use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/RoundBowtie0.scad>
use <../lib/TOGPath1.scad>

function snoc(list, item) = [for(i=list) i, item];

// Panel

inch = 25.4;
panel_size = [panel_size_gc[0] * grid_unit_size, panel_size_gc[1] * grid_unit_size];

function gprt_hole(type_name, hole2) =
	type_name == "hole2" && !is_undef(hole2) ? hole2 :
	let( counterbore_inset = min(thickness-1, 3.175) )
	["render",
		type_name == "countersquare:5mm,12mm" ? ["union",
			togmod1_linear_extrude_z( [-thickness-1, 1], togmod1_make_circle(d=5) ),
			togmod1_linear_extrude_z( [-counterbore_inset, 2], togmod1_make_rounded_rect([12, 12], r=3.175) )
		] :
		tog_holelib2_hole(type_name, thickness*2, counterbore_inset=counterbore_inset)
	];

hole2 = gprt_hole(hole2_type_name);
hole3 = gprt_hole(hole3_type_name, hole2);

bushing_hole = hole_diameter <= 0 ? ["union"] :
	["render",
		togmod1_linear_extrude_z( [-thickness-1, 1], togmod1_make_circle(d=hole_diameter) )
	];
	

all_holes_abstract =
let( panel_size_chunks = [for(d=panel_size) round(d/grid_unit_size)] )
[
	for( hpm = fencepost_positions_ofe_2d(panel_size_chunks, [1/2, 1/2], 1/2) )
	let( xm_from_left  = hpm[0] - panel_size_chunks[0]/2 )
	let( ym_from_front = hpm[1] - panel_size_chunks[1]/2 )
	let( hole_type =
		(ym_from_front % 1 == 0) ? "hole2" :
		(xm_from_left  % 1 == 0) ? "hole3" :
		"bushing-hole"
	)
	["translate", snoc(hpm * grid_unit_size, thickness), hole_type]
];

holes = ["union",
	for( p = all_holes_abstract )
	each
	assert( p[0] == "translate" )
	let( hole =
		p[2] == "hole2" ? hole2 :
		p[2] == "hole3" ? hole3 :
		p[2] == "bushing-hole" ? bushing_hole :
		assert(false, str("Unrecognized hole role: '", p[2], "'"))
	)
   hole == ["union"] ? [] : [
		["translate", p[1], hole]
	]
];

function hole_positions_of_type(type_name, all_holes_abstract) = [
	for( p = all_holes_abstract )
	each
	assert( p[0] == "translate" )
	assert( p[0] == "translate" )
	p[2] == type_name ? [p[1]] : []
];

hole2_positions = hole_positions_of_type("hole2", all_holes_abstract);
hole3_positions = hole_positions_of_type("hole3", all_holes_abstract);

bowtie_2d_togmod =
	bowtie_cutout_shape == "round" ? ["render", roundbowtie0_make_bowtie_2d(bowtie_length/3, offset=margin, $fn=max(24,$fn))] : ["union"];

module bowtie_of_style_2(style, length, r_offset) {
	if( style == "round" ) {
		togmod1_domodule(bowtie_2d_togmod);
	} else {
		bowtie_of_style(style, length, r_offset);
	}
}


translate([0,0,0]) {
	difference() {
		linear_extrude(thickness) difference() {
			togmod1_domodule(
				let( eff_outer_offset = outer_edge_offset - margin )
				let( eff_inner_offset =                 0 - margin )
				let(
					x0 = -panel_size[0]/2 - (eff_bowtie_edges[3] ? eff_inner_offset : eff_outer_offset),
					x1 =  panel_size[0]/2 + (eff_bowtie_edges[1] ? eff_inner_offset : eff_outer_offset),
					y0 = -panel_size[1]/2 - (eff_bowtie_edges[2] ? eff_inner_offset : eff_outer_offset),
					y1 =  panel_size[1]/2 + (eff_bowtie_edges[0] ? eff_inner_offset : eff_outer_offset)
				)
				let( bowtie_corners = /* SE, NE, NW, SW -- different order than edges specified! */ [
					eff_bowtie_edges[1] || eff_bowtie_edges[2],
					eff_bowtie_edges[0] || eff_bowtie_edges[1],
					eff_bowtie_edges[0] || eff_bowtie_edges[3],
					eff_bowtie_edges[2] || eff_bowtie_edges[3]
				])
				// Since these are applied *after* inset
				let( inner_cops = [["round", max(0,     corner_radius                       + eff_inner_offset)]] )
				let( outer_cops = [["round", max(0, max(corner_radius, outer_corner_radius) + eff_outer_offset)]] )
				let( copses = [for(i=[0:1:3])
					bowtie_corners[i] ? inner_cops : outer_cops
				])
				togpath1_rath_to_polygon(["togpath1-rath",
					["togpath1-rathnode", [x1, y0], each copses[0]],
					["togpath1-rathnode", [x1, y1], each copses[1]],
					["togpath1-rathnode", [x0, y1], each copses[2]],
					["togpath1-rathnode", [x0, y0], each copses[3]],
				])
			);
			// rounded_square([panel_size[0]-margin*2, panel_size[1]-margin*2], corner_radius);
			
			for( pos=bowtie_positions(panel_size, [bowtie_length*bowtie_spacing, bowtie_length*bowtie_spacing], bowtie_position_offset*bowtie_length, edges=eff_bowtie_edges ) ) {
				translate([pos[0],pos[1]]) rotate([0,0,pos[2]]) bowtie_of_style_2(bowtie_cutout_shape, bowtie_length, margin);
			}
			if( bowtie_position_offset == 0.5 ) {
				echo("Chopping corners!");
				for( x=[-panel_size[0]/2, panel_size[0]/2] )
				for( y=[-panel_size[1]/2, panel_size[1]/2] )
				// Chop off corners
				translate([x,y]) square([bowtie_length, bowtie_length], center=true);
			}
		}
		
		togmod1_domodule(holes);
		if(beveled_grooves_enabled) for( y=fencepost_positions_ofe(panel_size[1], grid_unit_size, grid_unit_size/2) ) {
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
			for( pos=hole2_positions ) {
				translate([pos[0], pos[1]]) circle(d=hole2_surface_diameter+pocket_wall_thickness*2);
			}
			for( pos=hole3_positions ) {
				translate([pos[0], pos[1]]) circle(d=hole3_surface_diameter+pocket_wall_thickness*2);
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
