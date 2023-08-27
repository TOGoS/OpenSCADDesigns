// MasonJarCapTest-v1.4
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

inch = 25.4;

hull_height = 19.05; // 0.01
bottom_hole_diameter = 60; // 1.0

$fn = $preview ? 32 : 64;

threaded_length = 11/16*inch;
thread_pitch = 1/5*inch;

inner_diameter = 82; // 0.01
outer_diameter = 86.5; // 0.01
thread_angle_from_vertical = 45;
thread_taper_distance = 5;

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

if( $preview ) # cylinder(d=inner_diameter, h=hull_height*1.25);

difference() {
	cylinder(d=3.5*inch, h=hull_height);

	cylinder(d=bottom_hole_diameter, h=hull_height*3, center=true);

	tpf = tog_jtl1_thread_profile_function(
		 inner_diameter / 2,
		 outer_diameter / 2,
		 angle_from_vertical = thread_angle_from_vertical,
		 thread_pitch = thread_pitch,
		 thread_radius_bias = (outer_diameter - inner_diameter) / 4
	);

	threaded_start_height = hull_height - threaded_length;
	epsilon = 0.1;
 	taper_start_height = threaded_start_height + threaded_length - thread_taper_distance;
	tog_jtl1_threaded_cylinder(tpf, thread_pitch, threaded_start_height, taper_start_height + epsilon, 1, 1);
	tog_jtl1_threaded_cylinder(tpf, thread_pitch, taper_start_height, hull_height+epsilon, 1, 1.01);

	if( $preview ) translate([0,-50,0]) cube([100,100,100], center=true);
}
