// TOGHoleLib-v1.5.1
//
// Library of hole shapes!
// Mostly to accommodate counterbored/countersunk screws.
//
// Changes:
// v1.1:
// - Reduced #6 counterunk holes from 8, 4, 2, 5 to  7.5, 3.5, 1.7, 4.5
//   WSITEM-200448 was the first print to use this new, smaller size,
//   and it seems just about perfect, at least as far as the flat top
//   sitting just barely below the surface
// v1.2:
// - Add 'none' hole style, which does nothing
// v1.3:
// - Add 'tog_holelib_get_hole_types()' and `tog_holelib_is_hole_type(name)` functions
// v1.4:
// - Add THL-1013, a hole for the CRE24F2HBBNE SPDT rocker switches I got from DigiKey years ago
// v1.5:
// - Add partial, experimental, unstable support for THL-1021, a square hole for Mini-PV/Dupont connectors
// v1.5.1:
// - tog_holelib_hole1021: change default margins (0.2mm and 0.3mm) and include_pin1_marker (false)

module tog_holelib_countersunk_hole_2(surface_d, neck_d, head_h, depth, bore_d, overhead_bore_d, overhead_bore_height) {
	rotate_extrude() {
		union() {
			// Bore
			polygon([
				[     0  , -depth],
				[bore_d/2, -depth],
				[bore_d/2, -0.01],
				[     0  , -0.01],
			]);
			// Head and headbore
			polygon([
				[              0  ,               -head_h],
				[         neck_d/2,               -head_h],
				// Try to avoid points exactly at the surface:
				[      surface_d/2,                 0.01 ],
				[overhead_bore_d/2,                 0.01 ],
				[overhead_bore_d/2,  overhead_bore_height],
				[              0  ,  overhead_bore_height],
			]);
		}
	}
}

module tog_holelib_countersunk_hole(surface_d, neck_d, head_h, depth, bore_d=-1, overhead_bore_d=0, overhead_bore_height=1) {
	tog_holelib_countersunk_hole_2(surface_d, neck_d, head_h, depth, bore_d == -1 ? neck_d : bore_d, max(surface_d, overhead_bore_d), overhead_bore_height);
}

// Suitable for #6 flatheads
module tog_holelib_hole1001(depth, overhead_bore_height=1) {
	tog_holelib_countersunk_hole(7.5, 3.5, 1.7, depth, 4.5, 0, overhead_bore_height);
}

// Suitable for 1/4" flatheads
module tog_holelib_hole1002(depth, overhead_bore_height=1) {
	inch = 25.4;
	tog_holelib_countersunk_hole(1/2*inch, 1/4*inch, 1/8*inch, depth, 5/16*inch, 0, overhead_bore_height);
}

// Suitable for the 3-way switches I got from DigiKey years ago:
// https://www.digikey.com/en/products/detail/zf-electronics/CRE24F2HBBNE/446073
// (Manufacturer part number: CRE24F2HBBNE, DigiKey part number: CH807-ND)
module tog_holelib_hole1013(
	depth, overhead_bore_height=1,
	hole_length    = 30,
	hole_width     = 12,
	shaft_inner_diameter = 35,
) intersection() {
	// Some hardcoded values:
	shaft_diameter = shaft_inner_diameter+2;

	bevel_length = (shaft_diameter-hole_length)/2;
	bevel_start_z = 0.5;
	
	rotate([-90,0,0]) linear_extrude(hole_width, center=true) polygon([
		[-hole_length/2               ,                           -1],
		[-hole_length/2               , bevel_start_z               ],
		[-hole_length/2 - bevel_length, bevel_start_z + bevel_length],
		[-hole_length/2 - bevel_length,                        depth],
		[+hole_length/2 + bevel_length,                        depth],
		[+hole_length/2 + bevel_length, bevel_start_z + bevel_length],
		[+hole_length/2               , bevel_start_z               ],
		[+hole_length/2               ,                           -1]
	]);

	translate([0,0,-depth-1]) linear_extrude(depth+overhead_bore_height+2) circle(d=shaft_inner_diameter);	
}


/**
 * A wide-at-the-bottom (z=0), narrow (width, height)-at-the-top (z=border) wedge..thing
 */
module tog_holelib_hole1021__widener(width, height, border) {
	polyhedron([
		[-width/2-border, -height/2-border, -border  ],
		[+width/2+border, -height/2-border, -border  ],
		[-width/2-border, +height/2+border, -border  ],
		[+width/2+border, +height/2+border, -border  ],
		[-width/2-border, -height/2-border,         0],
		[+width/2+border, -height/2-border,         0],
		[-width/2-border, +height/2+border,         0],
		[+width/2+border, +height/2+border,         0],
		[-width/2       , -height/2       , +border*2],
		[+width/2       , -height/2       , +border*2],
		[-width/2       , +height/2       , +border*2],
		[+width/2       , +height/2       , +border*2]
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

// Experimental/unstable.
// Don't rely on this not changing just yet.
module tog_holelib_hole1021(
	hole_size,
	front_depth = 7,
	depth = 28,
	back_margin = 0.2,
	front_margin = 0.3,
	include_pin1_marker = false,
) rotate([180,0,0]) {
	// This is written upside-down because
	// that's how it was done in the old MiniPVSleeve-v3.
	// But in TOGHoleLib-v1, holes go down!
	back_hole_width   = 2.54 * hole_size[0] + back_margin*2;
	back_hole_height  = 2.54 * hole_size[1] + back_margin*2;
	front_hole_width  = 2.54 * hole_size[0] + front_margin*2;
	front_hole_height = 2.54 * hole_size[1] + front_margin*2;
	taper_dx = front_margin - back_margin;
	taper_dz = taper_dx * 2;
	translate([0, 0, depth/2]) cube([back_hole_width,back_hole_height,depth], true);
	translate([0, 0, front_depth/2]) cube([front_hole_width,front_hole_height,front_depth], true);
	translate([0, 0, front_depth])
		tog_holelib_hole1021__widener(back_hole_width, back_hole_height, taper_dx);
	translate([0, 0, 0])
	   tog_holelib_hole1021__widener(front_hole_width, front_hole_height, 0.5);
	if( include_pin1_marker ) {
		translate([-hole_size[0]*2.54/2 + 0.5, -hole_size[1]*2.54/2 - 1, 0]) cube([1, 1.1, 1], center=true);
	}
}

tog_holelib_hole_types = [
	["THL-1001", "Suitable for #6 flathead"],
	["THL-1002", "Suitable for 1/4\" flathead"],
	// ["THL-1003", "Suitable for #6 hex nuts or pan heads"],
	// ["THL-1004", "Suitable for #6 flathead, but roomier than 1001"],
	// ["THL-1005", "Countersunk for #6 flathead, but can also accept a hex nut"],
	["THL-1013", "Suitable for CRE24F2HBBNE SPDT rocker switche"],
	// ["THL-1021-(W)x(H)", "Mini-PV sleeve hole"]
	// ["THL-1023", "Counterbored for M3 pan-head screws"],
	// ["THL-1024", "Counterbored for M4 pan-head screws"],
	// ["THL-1025", "Counterbored for M5 pan-head screws"],
];

function tog_holelib_get_hole_types() = tog_holelib_hole_types;

function tog_holelib_is_hole_type(type_name, idx=0) =
	idx > len(tog_holelib_hole_types) ? false :
	tog_holelib_hole_types[idx][0] == type_name ? true :
	tog_holelib_is_hole_type(type_name, idx=idx + 1);

module tog_holelib_hole(type_name, depth=1000, overhead_bore_height=1) {
	if( type_name == "none" ) {
		// Here so callers don't need to make a special case for it
	} else if( type_name == "THL-1001" ) {
		tog_holelib_hole1001(depth, overhead_bore_height);
	} else if( type_name == "THL-1002" ) {
		tog_holelib_hole1002(depth, overhead_bore_height);
	} else if( type_name == "THL-1013" ) {
		tog_holelib_hole1013(depth, overhead_bore_height);
	} else {
		assert(false, str("Unknown hole type: '", type_name, "'"));
	}
}
