// MasonJarCapTest-v1.7
//
// Changes:
// v1.1:
// - Prefix functions in preparation of librarification
// v1.2:
// - Explicitly pass thread_pitch to tog_jtl1_thread_profile_function
// v1.3:
// - Show cross section and inner cylinder in preview
// v1.4:
// - thread_angle_from_vertical = 45
// v1.5:
// - Improve cross-section display
// v1.6:
// - male, female, both modes
// v1.7:
// - Increase default diameter, decrease margin

inch = 25.4;

hull_height = 19.05; // 0.01
bottom_hole_diameter = 60; // 1.0

$fn = $preview ? 32 : 64;

threaded_length = 11/16*inch;
thread_pitch = 1/5*inch;

inner_diameter = 82.0; // 0.1
outer_diameter = 86.5; // 0.1

// Added to diameter for female threads, subtracted for male threads
diametrical_margin = 0.1;

thread_angle_from_vertical = 45;
thread_taper_distance = 5;

mode = "female"; // ["female","male","both"]
interior_thread_radius_bias =  0.5; // 0.1
exterior_thread_radius_bias = -0.2; // 0.1

function tog_jtl1_lerp(a, b, ratio) = a * (1-ratio) + b * ratio;
function tog_jtl1_polar_to_xy(angle, dist) = [cos(angle) * dist, sin(angle) * dist];

// 
function tog_jtl1_tog_jtl1_thread_profile_function_2(
	inner_radius, outer_radius, // Clamp between these
	thread_inner_radius, thread_outer_radius // Triangle wave between these radii
) =
	function (t) max(inner_radius, min(
		outer_radius,
		tog_jtl1_lerp(thread_inner_radius, thread_outer_radius, t * 2    ),
		tog_jtl1_lerp(thread_outer_radius, thread_inner_radius, t * 2 - 1)
	));

function tog_jtl1_thread_profile_function(inner_radius, outer_radius, angle_from_vertical, thread_pitch, thread_radius_bias) =
	let(thread_slope = sin(angle_from_vertical)/cos(angle_from_vertical))
	let(thread_mid_radius = (outer_radius+inner_radius)/2 + thread_radius_bias)
	tog_jtl1_tog_jtl1_thread_profile_function_2(
		inner_radius, outer_radius,
		thread_inner_radius = thread_mid_radius - thread_pitch / 4 * thread_slope,
		thread_outer_radius = thread_mid_radius + thread_pitch / 4 * thread_slope
	);

module tog_jtl1_threaded_cylinder(thread_radius_function, pitch, bottom_z, top_z, bottom_scale, top_scale) {
	length = top_z - bottom_z;
	// rotate() is right-handed, but
	// linear_extrude twists left-handed!
	translate([0,0,bottom_z]) scale(bottom_scale) rotate([0,0,360 * bottom_z / pitch]) linear_extrude(
		height = length,
		twist = -360 * length / pitch,
		scale = top_scale / bottom_scale
	) polygon([for (t = [0:1/60:1]) tog_jtl1_polar_to_xy(t * 360, thread_radius_function(t)) ]);
}

module the_cross_section_cube() translate([0,50,0]) cube([100,100,100], center=true);

function the_tpf(inner_diameter, outer_diameter, thread_radius_bias) = tog_jtl1_thread_profile_function(
	inner_diameter / 2,
	outer_diameter / 2,
	angle_from_vertical = thread_angle_from_vertical,
	thread_pitch = thread_pitch,
	thread_radius_bias = thread_radius_bias * (outer_diameter - inner_diameter) / 4
);

epsilon = 0.1;

module the_cap() difference() {
	tpf = the_tpf(inner_diameter + diametrical_margin, outer_diameter + diametrical_margin, interior_thread_radius_bias);
	
	union() {
		intersection() {
			cylinder(d=3.5*inch, h=hull_height);
			if( $preview ) the_cross_section_cube();
		}

		if( $preview ) {
			# intersection() {
				translate([0,0,threaded_start_height+epsilon]) cylinder(d=inner_diameter, h=hull_height);
				the_cross_section_cube();
			}
		}
	}

	cylinder(d=bottom_hole_diameter, h=hull_height*3, center=true);

	threaded_start_height = hull_height - threaded_length;
 	taper_start_height = threaded_start_height + threaded_length - thread_taper_distance;
	tog_jtl1_threaded_cylinder(tpf, thread_pitch, threaded_start_height, taper_start_height + epsilon, 1, 1);
	tog_jtl1_threaded_cylinder(tpf, thread_pitch, taper_start_height, hull_height+epsilon, 1, 1.01);
}

module the_neck() intersection() {
	tpf = the_tpf(inner_diameter - diametrical_margin, outer_diameter - diametrical_margin, exterior_thread_radius_bias);
	
	plate_thickness = 3.175;
	threaded_start_height = plate_thickness - epsilon;
	taper_start_height = threaded_start_height + threaded_length - thread_taper_distance;

	difference() {
		union() {
			cylinder(d=3.75*inch, h=plate_thickness);
			
			tog_jtl1_threaded_cylinder(tpf, thread_pitch, threaded_start_height, taper_start_height + epsilon, 1, 1);
			tog_jtl1_threaded_cylinder(tpf, thread_pitch, taper_start_height, hull_height, 1, 0.98);
		}

		cylinder(d=inner_diameter-6, h=hull_height*3, center=true);
	}

	if( $preview ) the_cross_section_cube();
}

if( mode == "female" ) the_cap();
if( mode == "male" ) the_neck();
if( mode == "both" ) union() { the_cap(); the_neck(); }
