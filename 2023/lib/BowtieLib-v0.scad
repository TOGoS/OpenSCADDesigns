// Minimally-altered copy of BowtieLib from ProjectNotes2/2023/3DPrinting/BowtieConnector/BowtieLib.scad

inch = 25.4;

bowtie_point_data = [
	// X, Y (length/6), offsetX, offsetY (caller units)
	[-3, 2,-1  , 1],
	[-2, 2, 0.5, 1],
	[-1, 1, 0.5, 1],
	[ 1, 1,-0.5, 1],
	[ 2, 2,-0.5, 1],
	[ 3, 2, 1  , 1],
	[ 3,-2, 1  ,-1],
	[ 2,-2,-0.5,-1],
	[ 1,-1,-0.5,-1],
	[-1,-1, 0.5,-1],
	[-2,-2, 0.5,-1],
	[-3,-2,-1  ,-1]
];

module beveled_square(size, r) {
	x0 = -size[0]/2;
	x1 = +size[0]/2;
	y0 = -size[1]/2;
	y1 = +size[1]/2;
	polygon([
		[x0+r, y0  ],
		[x0  , y0+r],
		[x0  , y1-r],
		[x0+r, y1  ],
		[x1-r, y1  ],
		[x1  , y1-r],
		[x1  , y0+r],
		[x1-r, y0  ]
	]);
}

module rounded_square(size, r) {
	hull() {
		for( xm=[-1,1] ) for( ym=[-1,1] ) {
			translate([xm*(size[0]/2-r), ym*(size[1]/2-r)]) circle(r=r);
		}
		// To ensure fullness at small $fns:
		beveled_square(size, r);
	}
}

function grid_cell_center_positions(area_size, cell_size) = [
	for( y=[ -area_size[1]/2+cell_size[1]/2 : cell_size[1] : area_size[1]/2-cell_size[1]/2 ] )
		for( x=[ -area_size[0]/2+cell_size[0]/2 : cell_size[0] : area_size[0]/2-cell_size[0]/2 ] )
			[x,y]
];

/**
 * Given point data of the form
 * [
 *   [x, y, offset_x, offset_y],
 *   ...
 * ]
 * 
 * Returns a list of points where x and y are multiplied by base_multiplier
 * and have offset multiplied by offseT_multiplier added to them.
 */
function offset_points( point_data, base_multiplier, offset_multiplier ) = [
	for( d=point_data ) [d[0]*base_multiplier + d[2]*offset_multiplier, d[1]*base_multiplier + d[3]*offset_multiplier]
];

function bowtie_connector_points( length, offset=0 ) =
	offset_points(bowtie_point_data, length/6, offset);
	//for( d=bowtie_point_data ) [d[0]*length/6 + d[2]*offset, d[1]*length/6 + d[3]*offset];

module bowtie_connector_2d( length, r_offset=0 ) {
	polygon( bowtie_connector_points(length, r_offset) );
}

function is3QuarterInch(number) = round(number*100) == 1905;

// Closest to the angular bowtie of whose shape a a hole could be cut using a quarter-inch diameter router bit
module quarter_bit_cutout_bowtie(length, r_offset) {
	if( !is3QuarterInch(length) ) {
		assert(false, str("'quarter-bit-cutout' bowtie requires length to be 3/4*inch, i.e. 19.05mm; given ", length));
	}
	inner_rad = 1/8*inch + r_offset;
	outer_rad = 1/8*inch - r_offset;
	difference() {
		union() {
			square([4/8*inch, 3/8*inch], center=true);
			for( xm=[-1,1] ) hull() {
				translate([-77/256*inch*xm,  1/8*inch]) circle(r=inner_rad);
				translate([-45/256*inch*xm,  0          ]) circle(r=inner_rad);
				translate([-77/256*inch*xm, -1/8*inch]) circle(r=inner_rad);
			}
		}
		for( ym=[-1,1] ) hull() for( xm=[-1,1] ) {
			translate([19/256*inch*xm, 1/4*inch*ym]) circle(r=outer_rad);
			translate([(1+19/256)*inch*xm, (1+1/4)*inch*ym]) circle(r=outer_rad);
		}
	}
}

// One that will fit into hole made for a rounded one or a straight-edged one
module minimal_bowtie(length, r_offset) {
	if( !is3QuarterInch(length) ) {
		assert(false, str("'minimal' bowtie requires length to be 3/4*inch, i.e. 19.05mm; given ", length));
	}
	intersection() {
		bowtie_connector_2d(length, r_offset);
		quarter_bit_cutout_bowtie(length, r_offset);
	}
}
module maximal_bowtie(length, r_offset) {
	if( !is3QuarterInch(length) ) {
		assert(false, str("'maximal' bowtie requires length to be 3/4*inch, i.e. 19.05mm; given ", length));
	}
	union() {
		bowtie_connector_2d(length, r_offset);
		quarter_bit_cutout_bowtie(length, r_offset);
	}
}
// A good choice for holes meant to accomodate angled or round bowties
module semi_maximal_bowtie(length, r_offset) {
	if( !is3QuarterInch(length) ) {
		assert(false, str("'semi-maximal' bowtie requires length to be 3/4*inch, i.e. 19.05mm; given ", length));
	}
	union() {
		bowtie_connector_2d(3/4*inch, r_offset);
		intersection() {
			quarter_bit_cutout_bowtie(length, r_offset);
			square([3/4*inch + r_offset*2, 1/2*inch + r_offset*2], center=true);
		}
	}
}

module bowtie_of_style(style_name, length, r_offset) {
	if( style_name == "angular" ) {
		bowtie_connector_2d(length, r_offset);
	} else if( style_name == "quarter-bit-cutout" ) {
		quarter_bit_cutout_bowtie(length, r_offset);
	} else if( style_name == "maximal" ) {
		maximal_bowtie(length, r_offset);
	} else if( style_name == "semi-maximal" ) {
		semi_maximal_bowtie(length, r_offset);
	} else {
		assert(false, str("Unsupported bowtie style: '",style_name, "'") ); // lolmao
	}
}

function fencepost_positions_ofe(length, unit_length, offset_from_ends) = [
	for( i=[-length/2 + offset_from_ends : unit_length : +length/2 - offset_from_ends + 0.01] ) i
];
// TODO: hese two could be rewritten in terms of fencepost_positions_ofe
function fencepost_positions(length, unit_length, include_ends) = [
	for( i=[-length/2 + (include_ends ? 0 : unit_length) : unit_length : +length/2 - (include_ends ? 0 : unit_length)] ) i
];
function fencebeam_positions(length, unit_length, include_ends) = [
	for( i=[-length/2 + (include_ends ? unit_length/2 : 3*unit_length/2) : unit_length : +length/2 + 0.01 - (include_ends ? unit_length/2 : 3*unit_length/2)] ) i
];

function fencepost_positions_ofe_2d(area_size, cell_size, offset_from_ends) = [
	for( y=fencepost_positions_ofe(area_size[1], cell_size[1], offset_from_ends) )
		for( x=fencepost_positions_ofe(area_size[0], cell_size[0], offset_from_ends) )
			[x,y]
];

function bowtie_positions(panel_size, unit_size, offset_from_ends) = [
	for( y=fencepost_positions_ofe(panel_size[1], unit_size[1], offset_from_ends) )
	     for( x=[-panel_size[0]/2, panel_size[0]/2] )
		[x,y,0],
	for( x=fencepost_positions_ofe(panel_size[0], unit_size[0], offset_from_ends) )
	     for( y=[-panel_size[1]/2, panel_size[1]/2] )
		[x,y,90],
];

module bowtie_test_plate_2d(panel_size, bowtie_length, offset, corner_radius=3.175, bowtie_position_offset=1, bowtie_style="semi-maximal") {
	difference() {
		beveled_square([panel_size[0]+offset*2, panel_size[1]+offset*2], corner_radius);
		for( pos=bowtie_positions(panel_size, [bowtie_length, bowtie_length], bowtie_position_offset*bowtie_length ) ) {
			translate([pos[0],pos[1]]) rotate([0,0,pos[2]]) bowtie_of_style(bowtie_style, bowtie_length, -offset);
		}
		if( bowtie_position_offset == 0.5 ) {
			// Chop off corners
			for( r=[0:90:270] ) rotate([0,0,r]) {
				translate([bowtie_length*2, bowtie_length*2]) square([bowtie_length, bowtie_length], center=true);
			}
		}
	}
}

// Flathead screw profile data:
// [head_surface_diam, head_base_diam, head_height]

module countersunk_hole(head_surface_diam, head_height, shaft_diam, hole_depth) {
	cylinder(d1=shaft_diam, d2=head_surface_diam+(head_surface_diam-shaft_diam), h=head_height*2, center=true);
	translate([0,0,-hole_depth/2]) cylinder(d=shaft_diam, h=hole_depth, center=true);
}
