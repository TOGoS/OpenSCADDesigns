// MasonJarCapTest-v1.0

inch = 25.4;

hull_height = 19.05; // 0.01
bottom_hole_diameter = 60; // 1.0

$fn = $preview ? 32 : 64;

threaded_length = 11/16*inch;
thread_pitch = 1/5*inch;

inner_diameter = 82; // 0.01
outer_diameter = 86.5; // 0.01
thread_angle_from_vertical = 35;
thread_taper_distance = 5;

function lerp(a, b, ratio) = a * (1-ratio) + b * ratio;
function polar_to_xy(angle, dist) = [cos(angle) * dist, sin(angle) * dist];

// 
function thread_profile_function_2(
	inner_radius, outer_radius, // Clamp between these
	thread_inner_radius, thread_outer_radius // Triangle wave between these radii
) =
	function (t) max(inner_radius, min(
		outer_radius,
		lerp(thread_inner_radius, thread_outer_radius, t * 2    ),
		lerp(thread_outer_radius, thread_inner_radius, t * 2 - 1)
	));

function thread_profile_function(inner_radius, outer_radius, angle_from_vertical, thread_radius_bias) =
	let(thread_slope = sin(angle_from_vertical)/cos(angle_from_vertical))
	let(thread_mid_radius = (outer_radius+inner_radius)/2 + thread_radius_bias)
	thread_profile_function_2(
		inner_radius, outer_radius,
		thread_inner_radius = thread_mid_radius - thread_pitch / 4 * thread_slope,
		thread_outer_radius = thread_mid_radius + thread_pitch / 4 * thread_slope
	);

module threads(thread_radius_function, pitch, bottom_z, top_z, bottom_scale, top_scale) {
	length = top_z - bottom_z;
	// rotate() is right-handed, but
	// linear_extrude twists left-handed!
	translate([0,0,bottom_z]) scale(bottom_scale) rotate([0,0,360 * bottom_z / pitch]) linear_extrude(
		height = length,
		twist = -360 * length / pitch,
		scale = top_scale / bottom_scale
	) polygon([for (t = [0:1/60:1]) polar_to_xy(t * 360, thread_radius_function(t)) ]);
}

difference() {
	cylinder(d=3.5*inch, h=hull_height);

	cylinder(d=bottom_hole_diameter, h=hull_height*3, center=true);

	tpf = thread_profile_function(
		 inner_diameter / 2,
		 outer_diameter / 2,
		 angle_from_vertical = thread_angle_from_vertical,
		 thread_radius_bias = (outer_diameter - inner_diameter) / 4
	);

	threaded_start_height = hull_height - threaded_length;
	epsilon = 0.1;
 	taper_start_height = threaded_start_height + threaded_length - thread_taper_distance;
	threads(tpf, thread_pitch, threaded_start_height, taper_start_height + epsilon, 1, 1);
	threads(tpf, thread_pitch, taper_start_height, hull_height+epsilon, 1, 1.01);

	// translate([0,-50,0]) cube([100,100,100], center=true);
}
