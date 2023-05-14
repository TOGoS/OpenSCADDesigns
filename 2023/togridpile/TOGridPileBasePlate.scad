// TOGridPileBasePlate-v1.0

/* [Features] */

// X/Y size, in togridpile grid units
size_tgpu = [3,3];
// Thickness of base plate, not including lip; set to zero for lip-only
base_thickness = 3.175;

magnet_hole_diameter = 6;
magnet_hole_depth = 2;


/* [Grid / Stacking System] */

// 38.1mm = 1+1/2"
togridpile_pitch = 38.1;

beveled_corner_radius = 3.175;
rounded_corner_radius = 4.7625;

// Style for purposes of lip cutout; "maximal" will accomodate all others; "hybrid1-inner" will accomodate rounded or hybrid1 bottoms
togridpile_lip_style = "hybrid2"; // [ "rounded", "beveled", "hybrid1-inner", "hybrid2", "maximal" ]

// Experimental platform under the lip
sublip_platform_enabled = true;

/* [Sizing Tweaks] */

// How much to shrink blocks and expand cutouts for them for better fits
margin = 0.1;            // 0.01
lip_height = 2.54;       // 0.01

baseplate_corner_radius = 4.7625;

/* [Detail] */

preview_fn = 12; // 4
render_fn  = 48; // 4



module __end_params() { }

$fn = $preview ? preview_fn : render_fn;

include <../lib/TOGHoleLib-v1.scad>
include <../lib/TOGridPileLib-v1.scad>


body_size = [
	size_tgpu[0] * togridpile_pitch - margin*2,
	size_tgpu[1] * togridpile_pitch - margin*2,
	base_thickness+lip_height
];

block_size = [togridpile_pitch, togridpile_pitch, togridpile_pitch];

difference() {
	translate([0,0,body_size[2]/2]) togridpile__xy_rounded_cube(body_size, corner_radius=baseplate_corner_radius);
	for( ym=[-size_tgpu[1]/2+0.5 : 1 : size_tgpu[1]/2-0.5] ) for( xm=[-size_tgpu[0]/2+0.5 : 1 : size_tgpu[0]/2-0.5] ) translate([xm*togridpile_pitch, ym*togridpile_pitch, base_thickness]) render() {
		translate([0, 0, togridpile_pitch/2]) {
			render() togridpile_hull_of_style(togridpile_lip_style, block_size, offset=-margin);
		}
		render() tog_holelib_hole("THL-1002");			
		for( mym=[-1,1] ) for( mxm=[-1,1] ) translate([mxm*togridpile_pitch/3, mym*togridpile_pitch/3, 0]) {
			render() cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
		}
		for( rot=[0:90:270] ) rotate([0,0,rot]) translate([togridpile_pitch/3, 0, 0]) {
			render() tog_holelib_hole("THL-1001");			
		}
	}
}
