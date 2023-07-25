// TOGHoleLib-v1.4
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

tog_holelib_hole_types = [
	["THL-1001", "Suitable for #6 flathead"],
	["THL-1002", "Suitable for 1/4\" flathead"],
	["THL-1013", "Suitable for CRE24F2HBBNE SPDT rocker switche"],
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
