$fn = 50;

function mm(millimeters) = millimeters;
function inches(inc) = mm(25.4 * inc);
function pvunits(hole_count) = mm(2.54 * hole_count);
// For 3D printing stuff, Dad says make thickness a multiple of 0.3mm.
// Width is less important but a multiple of 0.42mm might work best.
function extruded_layers(layer_count) = mm(0.3 * layer_count);
function extruded_beads(bead_count) = mm(0.42 * bead_count);

function unit_ceil(unit, value) =
	ceil(value / unit) * unit;

// Let's say wires going along z,
// so connection interface is the x/y plane.

// Using https://www.amazon.com/dp/B01NAB4GT6 as guide,
// a connector is 14mm long, 2.54 thick, and up to 0.1mm longer
// wider than you'd expect (e.g. their 1p is listed as 2.64mm wide,
// while their 2p is exactly 2x2.54mm = 5.08mm).  *shrug*
// The pins themselves are about 0.65mm square

bulkhead_lip_width = mm(0.5);
bulkhead_thickness = bulkhead_lip_width*2;
connector_length = mm(14);
margin = mm(0.4); // v2: Increased from 0.2 to 0.4
back_margin = mm(0.3);
front_margin = mm(0.5);

cm_straight = 1;
cm_bulkhead = 2;
cm_diff = 3;
cm_default = cm_straight;

flange_thickness = extruded_layers(3);

module pyramid(width, depth, height) {
	polyhedron([
		[-width/2, -depth/2, 0],
		[+width/2, -depth/2, 0],
		[-width/2, +depth/2, 0],
		[+width/2, +depth/2, 0],
		[0, 0, height]
	], [
		[0, 1, 3, 2],
		[0, 4, 1],
		[1, 4, 3],
		[3, 4, 2],
		[2, 4, 0]
	]);
}

// Overhangy prism
module ohprism(width, depth, height) {
	polyhedron([
		[-width/2,-depth/2,+height/2],
		[-width/2,+depth/2,+height/2],
		[-width/2,-depth/2,-height/2],
		[+width/2,-depth/2,+height/2],
		[+width/2,+depth/2,+height/2],
		[+width/2,-depth/2,-height/2]
	], [
		[0,2,1],
		[3,4,5],
		[2,0,3,5],
		[0,1,4,3],
		[4,1,2,5]
	]);
}

module bulkhead(columns, rows) {
	for( rot=[0:180:180] ) {
		rotate([0,0,rot]) {
			translate([0,-pvunits(rows)/2,0]) {
				ohprism(pvunits(columns)+margin*4, bulkhead_lip_width*2, bulkhead_lip_width*4);
			}
		}
	}
	for( rot=[90,180,270] ) {
		rotate([0,0,rot]) {
			translate([0,-pvunits(columns)/2,0]) {
				ohprism(pvunits(rows)+margin*4, bulkhead_lip_width*2, bulkhead_lip_width*4);
			}
		}
	}
	/*
	difference() {
		cube([
			pvunits(columns)+margin+0.05,
			pvunits(rows)+margin+0.05,
			bulkhead_thickness
		], true);
		// Hole big enough for pins to go through, but that blocks
		// connector housing
		cube([
			pvunits(columns - 1) + mm(1.5),
			pvunits(rows - 1) + mm(1.5),
			1,
		], true);
	}
	*/
}

sleeve_length = connector_length + bulkhead_thickness;
pin_marker_size = mm(1);

function sleeve_cavity_width(columns, margin=margin) = pvunits(columns) + margin*2;
function sleeve_cavity_diagonal(columns,rows,margin=margin) =
	sqrt(pow(pvunits(columns) + margin*2, 2) +
		 pow(pvunits(rows) + margin*2, 2));

module rectangular_opening_widener(width, height, border) {
	polyhedron([
		[-width/2-border, -height/2-border, -border],
		[+width/2+border, -height/2-border, -border],
		[-width/2-border, +height/2+border, -border],
		[+width/2+border, +height/2+border, -border],
		[-width/2-border, -height/2-border, 0],
		[+width/2+border, -height/2-border, 0],
		[-width/2-border, +height/2+border, 0],
		[+width/2+border, +height/2+border, 0],
		[-width/2, -height/2, +border*2],
		[+width/2, -height/2, +border*2],
		[-width/2, +height/2, +border*2],
		[+width/2, +height/2, +border*2]
	], [
		[2,3,1,0], // bottom
		[2,0,4,6], // flat sides...
		[0,1,5,4],
		[1,3,7,5],
		[3,2,6,7],
		[6,4,8,10], // tapered sides...
		[4,5,9,8],
		[5,7,11,9],
		[7,6,10,11],
		[8,9,11,10] // top
	]);
}

module diff_sleeve_cavity(
	columns, rows,
	sleeve_length=connector_length*2,
	back_margin=back_margin,
	front_margin=front_margin
) {
	back_hole_width = sleeve_cavity_width(columns, back_margin);
	back_hole_height = sleeve_cavity_width(rows, back_margin);
	front_hole_width = sleeve_cavity_width(columns, front_margin);
	front_hole_height = sleeve_cavity_width(rows, front_margin);
	taper_dx = front_margin - back_margin;
	taper_dz = taper_dx * 2;
	half_length = (sleeve_length+2)/2;
	translate([0, 0, +half_length/2-taper_dz]) cube([back_hole_width,back_hole_height,half_length], true);
	translate([0, 0, -half_length/2-taper_dz]) cube([front_hole_width,front_hole_height,half_length], true);
	translate([0, 0, -taper_dz]) rectangular_opening_widener(back_hole_width, back_hole_height, taper_dx);
	translate([0,0,-sleeve_length/2])
		rectangular_opening_widener(front_hole_width, front_hole_height, mm(0.5));
}

module sleeve_cavity(
	columns, rows,
	sleeve_length=connector_length*2,
	cavity_mode = cm_default,
	back_margin = back_margin,
	front_margin = front_margin
) {
	if( cavity_mode == cm_diff ) {
		diff_sleeve_cavity(
			columns, rows,
			sleeve_length=sleeve_length,
			cavity_mode = cavity_mode,
			back_margin = back_margin,
			front_margin = front_margin
		);
	} else {
		hole_width = sleeve_cavity_width(columns);
		hole_height = sleeve_cavity_width(rows);
		difference() {
			union() {
				cube([hole_width,hole_height,sleeve_length + 1], true);
				translate([0,0,-sleeve_length/2])
					rectangular_opening_widener(hole_width, hole_height, mm(0.5));
			}
			if(cavity_mode == cm_bulkhead) bulkhead(columns,rows);
		}
	}
}

module pin_marker() {
	/* let's leave it out for now
	translate([0,0,-pin_marker_size*2]) {
		pyramid(pin_marker_size*2, pin_marker_size*2, pin_marker_size*4);
	}
	*/
}

module rectangular_sleeve(
	columns, rows,
	sleeve_wall_thickness = extruded_beads(3),
	flange_width = 0,
	flange_height = 0,
	flange_thickness = flange_thickness,
	cavity_mode = cm_default
) {
	hole_width = sleeve_cavity_width(columns);
	hole_height = sleeve_cavity_width(rows);
	inner_box_width = hole_width + sleeve_wall_thickness * 2;
	inner_box_height = hole_height + sleeve_wall_thickness * 2;
		
	adj_flange_width = max(flange_width, inner_box_width);
	adj_flange_height = max(flange_height, inner_box_height);
	
	//cube([
	difference() {
		union() {
			cube([inner_box_width,inner_box_height,sleeve_length], true);
			
			translate([0, (adj_flange_height - inner_box_height)/2, 0 - sleeve_length/2 + flange_thickness/2]) {
				cube([adj_flange_width, adj_flange_height, flange_thickness], true);
			}
		}
		sleeve_cavity(columns, rows, sleeve_length=sleeve_length, cavity_mode=cavity_mode);
		translate([pvunits(columns-1)/2, pvunits(rows)/2+margin+sleeve_wall_thickness/2, -sleeve_length/2]) {
			pin_marker();
		}
	};
}

module round_sleeve(
	columns, rows,
	diameter = 0,
	flange_diameter = 0,
	flange_thickness = flange_thickness,
	cavity_mode = cm_default
) {
	diameter = unit_ceil(inches(1/16), sleeve_cavity_diagonal(columns, rows)+extruded_beads(2));
	echo(columns, "x", rows, " peg is ", (diameter / inches(1/16)), " sixteenths of an inch in diameter");
	
	difference() {
		union() {
			cylinder(d=diameter, h=sleeve_length, center=true);
			translate([0, 0, 0 - sleeve_length/2 + flange_thickness/2]) {
				cylinder(d=flange_diameter, h=flange_thickness, center=true);
			}
		}
		sleeve_cavity(columns, rows, sleeve_length=sleeve_length, cavity_mode=cavity_mode);
		translate([pvunits(columns-1)/2, pvunits(rows)/2+margin+pin_marker_size, -sleeve_length/2]) {
			pin_marker();
		}
	}
}

function sample_spacing(samps) = inches(samps);
function sample_position(sx,sy) = [sample_spacing(sx), sample_spacing(sy), 0];

module outer_shape_variations(
	columns, rows,
	cavity_mode = cm_default
) {
	// Connector for burying in epoxy
	translate(sample_position(-1, 0)) {
		rectangular_sleeve(columns, rows,
			flange_width=inches(3/4),
			flange_height=inches(1/4),
			cavity_mode=cavity_mode
		);
	}
	// Inline connector
	translate(sample_position( 0, 0)) {
		rectangular_sleeve(columns, rows,
			flange_width=0,
			cavity_mode=cavity_mode
		);
	}
	// Round connector for inserting into drilled hole
	translate(sample_position(+1, 0)) {
		round_sleeve(4,1,
			flange_diameter=inches(3/4),
			cavity_mode=cavity_mode
		);
	}
}

module variations(
	columns, rows
) {
	translate(sample_position(0,0)) {
		outer_shape_variations(columns, rows, cavity_mode=cm_diff);
	}
}

variations(4, 1);
