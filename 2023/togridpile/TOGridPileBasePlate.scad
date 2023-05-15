// TOGridPileBasePlate-v2.1
//
// Changes:
//
// v2.0:
// - Replace THL-1002 holes with small nubbins which should fit into the
//   small holes of the blocks above
// v2.1:
// - Make magnet holes and nubbins optional

/* [Features] */

// X/Y size, in togridpile grid units
size_tgpu = [3,3];
// Thickness of base plate, not including lip; set to zero for lip-only
base_thickness = 3.175;

small_nubbins_enabled = false;
magnet_holes_enabled = true;
small_hole_style = "THL-1001"; // ["none", "THL-1001", "THL-1002"]

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

magnet_hole_depth = 2;
magnet_hole_diameter = 6;

small_nubbin_height = 1.5875;
small_nubbin_diameter = 4.4;

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

sb_x_positions = [[-1,-1],[-1,1],[1,1],[1,-1]];
sb_p_positions = [[0,-1],[0,1],[1,0],[-1,0]];

sb_positions = [
	[-1,-1],[-1,0],[-1,1],
	[ 0,-1],[ 0,0],[ 0,1],
	[ 1,-1],[ 1,0],[ 1,1],
];
full_position_mask = [
	1, 1, 1,
	1, 1, 1,
	1, 1, 1,
];
empty_position_mask = [
	0, 0, 0,
	0, 0, 0,
	0, 0, 0,
];
sb_x_position_mask = [
	1, 0, 1,
	0, 0, 0,
	1, 0, 1,
];
sb_p_position_mask = [
	0, 1, 0,
	1, 0, 1,
	0, 1, 0,
];

function flatmap(a, fn) = [for(v=a) each fn(v)];
function map(a, fn) = flatmap(a, function(a2) [fn(a2)]);

function flatzip(a, b, fn) = [
	for( i=[0:1:len(a)-1] ) each fn(a[i], b[i])
];

function zip(a, b, fn) = flatzip(a, b, function(a2,b2) [fn(a2,b2)]);
function vec_and(a, b) = zip(a, b, function(a2, b2) a2 && b2);
function vec_or(a, b)  = zip(a, b, function(a2, b2) a2 || b2);
function vec_not(a)    = map(a, function(a) !a);

function select_masked(source, mask) = flatzip(source, mask, function(s,m) m ? [s] : []);

small_nubbin_sb_position_mask = small_nubbins_enabled ? sb_p_position_mask : empty_position_mask;
magnet_sb_position_mask       = magnet_holes_enabled  ? sb_x_position_mask : empty_position_mask;
small_hole_sb_position_mask   = small_hole_style != "none" ? vec_not(vec_or(small_nubbin_sb_position_mask, magnet_sb_position_mask)) : empty_position_mask;

small_nubbin_sb_positions = select_masked(sb_positions, small_nubbin_sb_position_mask);
magnet_sb_positions       = select_masked(sb_positions, magnet_sb_position_mask);
small_hole_sb_positions   = select_masked(sb_positions, small_hole_sb_position_mask);

difference() {
	translate([0,0,body_size[2]/2]) togridpile__xy_rounded_cube(body_size, corner_radius=baseplate_corner_radius);
	for( ym=[-size_tgpu[1]/2+0.5 : 1 : size_tgpu[1]/2-0.5] ) for( xm=[-size_tgpu[0]/2+0.5 : 1 : size_tgpu[0]/2-0.5] ) translate([xm*togridpile_pitch, ym*togridpile_pitch, base_thickness]) render() {
		translate([0, 0, togridpile_pitch/2]) {
			render() togridpile_hull_of_style(togridpile_lip_style, block_size, offset=-margin);
		}
		tog_holelib_hole("THL-1002", depth=base_thickness+1);			
		for( sbp=magnet_sb_positions ) translate(sbp * togridpile_pitch/3) {
			cylinder(d=magnet_hole_diameter, h=magnet_hole_depth*2, center=true);
		}
		for( sbp=small_hole_sb_positions ) translate(sbp * togridpile_pitch/3) {
			tog_holelib_hole("THL-1001", depth=base_thickness+1);
		}
	}
}
for( ym=[-size_tgpu[1]/2+0.5 : 1 : size_tgpu[1]/2-0.5] ) for( xm=[-size_tgpu[0]/2+0.5 : 1 : size_tgpu[0]/2-0.5] ) translate([xm*togridpile_pitch, ym*togridpile_pitch, base_thickness]) render() {
	for( sbp=small_nubbin_sb_positions ) translate(sbp * togridpile_pitch/3) {
		cylinder(h=small_nubbin_height*2, d=small_nubbin_diameter, center=true);
	}
}
