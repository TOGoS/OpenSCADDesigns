// Library of hole shapes!
// Mostly to accommodate counterbored/countersunk screws.

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
	tog_holelib_countersunk_hole(8, 4, 2, depth, 5, 0, overhead_bore_height);
}

// Suitable for 1/4" flatheads
module tog_holelib_hole1002(depth, overhead_bore_height=1) {
	tog_holelib_countersunk_hole(1/2*inch, 1/4*inch, 1/8*inch, depth, 5/16*inch, 0, overhead_bore_height);
}

// Hole type names:
// 
// THL-1001: Countersunk hole for #6 machine screws or 6x sheet metal screws
// THL-1002: Countersunk hole for 1/4" flathead machine screws

module tog_holelib_hole(type_name, depth=1000, overhead_bore_height=1) {
	if( type_name == "THL-1001" ) {
		tog_holelib_hole1001(depth, overhead_bore_height);
	} else if( type_name == "THL-1002" ) {
		tog_holelib_hole1002(depth, overhead_bore_height);
	} else {
		assert(false, str("Unknown hole type: '", type_name, "'"));
	}
}