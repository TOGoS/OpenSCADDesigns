// PanelConnector2.1
// 
// Improvements over old regular PanelConnector.scad:
// - Uses TOGMod1!
// - Option to make it L-shaped or U-shaped by setting left_jut_u or right_jut_u!
// - u = 1/16'
// 
// Changes:
// v2.1:
// - Fix zig size so that tooth pitch is 1/8" instead of 1/4"

// Width of thing (u)
width_u = 16;
// Length of thing (u)
length_u = 48;
// Thickness of center section (u)
base_thickness_u = 6;
// How high shoud left section jut up above base (u)
left_jut_u = 6;
// How high shoud right section jut up above base (u)
right_jut_u = 0;
// Width of the flat center section (u)
center_width_u = 8;
// How much to slope upwards towards the ends
slope = 0.05; // 0.01

// Unit size numerator (mm)
u_num = 254;
// Unit size denominator
u_den = 160;

$fn = 48;

module __panelconnector2__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPolyhedronLib1.scad>

function panelconnector2_make_xz_outline_points(length, top_z_func) =
	let( zig = u_num/u_den )
	let( len_zigs = ceil(length/zig/2)*2 )
	let( xz0 = -len_zigs/2, xz1 = len_zigs/2 )
	[
		[xz1*zig,              0],
		for( xz=[xz1 : -2 : xz0] ) each [
			[(xz  )*zig, top_z_func((xz  )*zig) + 0*zig],
			[(xz-1)*zig, top_z_func((xz-1)*zig) - 1*zig],
		],
		[xz0*zig,              0],
	];

togmod1_domodule(
	let( length = length_u * u_num / u_den )
	let( width  = width_u * u_num / u_den )
	let( the_top_z = function(x)
		let( u = u_num/u_den )
		let( t_b = base_thickness_u )
		let( t_l = left_jut_u )
		let( t_r = right_jut_u )
		let( lc  = center_width_u/2 )
		lookup(x, [
			[-length  , (t_b+t_l)*u + slope*length],
			[(-lc-1)*u, (t_b+t_l)*u               ],
			[(-lc  )*u, (t_b    )*u               ],
			[( lc  )*u, (t_b    )*u               ],
			[( lc+1)*u, (t_b+t_r)*u               ],
			[ length  , (t_b+t_r)*u + slope*length],
		])
	)
	["difference",
		["intersection",
			togmod1_linear_extrude_z([-50, 50], togmod1_make_rounded_rect([length, width], r=7)),
			
			togmod1_linear_extrude_y([-width, width], togmod1_make_polygon(panelconnector2_make_xz_outline_points(length, the_top_z))),
		],
		
		tphl1_make_z_cylinder(zrange=[-1, +51], d=8.5)
	]
);
