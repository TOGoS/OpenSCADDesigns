outer_diameter = 12.7; // 0.001
inner_diameter = 11.2; // 0.001
// 6.35
thickness      = 3.175; // 0.001
notch_count    = 1;
notch_width    = 2;
notch_depth    = 1;

$fn = 100;

difference() {
	cylinder(d=outer_diameter, h=thickness  , center=true);
	cylinder(d=inner_diameter, h=thickness*2, center=true);

	mid_diameter = (outer_diameter+inner_diameter)/2;
	circumference = mid_diameter * PI;
	total_notch_places = circumference / (notch_width*2);
	notch_angular_spacing = 360 / total_notch_places;
	for( i=[0:1:notch_count-1] ) {
		rotate([0, 0, i*notch_angular_spacing]) {
			translate([mid_diameter/2, 0, thickness/2]) {
				cube([(outer_diameter-inner_diameter)*2, notch_width, notch_depth*2], center=true);
			}
		}
	}
}
