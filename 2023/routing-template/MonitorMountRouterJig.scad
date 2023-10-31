mode = "front-template"; // ["front-template", "back-template", "panel", "panel-front", "panel-back"]

inch = 25.4;

height = 9*inch;
top_y = height/2;
top_gb_hole_y = top_y - 3/4*inch;
top_monmount_hole_y = top_y - 9/4*inch;

counterbore_diameter = 7/8*inch;
counterbore_template_diameter = counterbore_diameter;
hole_diameter = 5/16*inch;
// 12mm fits my 7/16" router bushing
hole_template_diameter = 12;

template_thickness = 6.35;

cuts = [
	for( xm=[-1.5 : 1 : 1.5] ) for( ym=[2.5, -2.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	for( xm=[-1.5, 1.5] ) for( ym=[-1.5, 1.5] ) ["front-counterbored-slot", [[xm*1.5*inch, ym*1.5*inch]]],
	["back-counterbored-slot", [[0, top_monmount_hole_y], [0, top_monmount_hole_y-1.5*inch]]],
	["back-counterbored-slot", [[0, top_monmount_hole_y-3*inch], [0, top_monmount_hole_y-4.5*inch]]],
	for( xm=[-1, 1] ) for( ym=[-2, 0, 2] ) ["alignment-hole", [xm*1.5*inch, ym*1.5*inch]],
];

use <../lib/TOGMod1.scad>
use <../lib/TOGHoleLib-v1.scad>

$fn = $preview ? 24 : 72;

module fat_polyline(diameter, points) {
	if( len(points) == 0 ) {
	} else if( len(points) == 1 ) {
		translate(points[0]) circle(d=diameter);
	} else {
		for( i=[0 : 1 : len(points)-2] ) hull() {
			translate(points[i  ]) circle(d=diameter);
			translate(points[i+1]) circle(d=diameter);
		}
	}
}

function mkpoly(verts) = ["polygon-vp", verts, [[for( i=[0:1:len(verts)-1] ) i%len(verts)]]];

function make_rounded_rect(size, rad) =
	let(quarterfn=max($fn/4, 1))
	mkpoly([
		for(a=[0 : 1 : quarterfn]) let(ang=      a*90/quarterfn) [ size[0]/2-rad + rad*cos(ang),  size[1]/2-rad + rad*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang= 90 + a*90/quarterfn) [-size[0]/2+rad + rad*cos(ang),  size[1]/2-rad + rad*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang=180 + a*90/quarterfn) [-size[0]/2+rad + rad*cos(ang), -size[1]/2+rad + rad*sin(ang)],
		for(a=[0 : 1 : quarterfn]) let(ang=270 + a*90/quarterfn) [ size[0]/2-rad + rad*cos(ang), -size[1]/2+rad + rad*sin(ang)],
	]);

function make_circle(rad, pos=[0,0]) =
	let(fn = max($fn, 6))
	mkpoly([ for(i=[0 : 1 : fn-1]) [pos[0]+rad*cos(i*360/fn), pos[1]+rad*sin(i*360/fn)]]);

function make_x_axis_oval(rad, x0, x1) =
	x0 == x1 ? make_circle(rad, [x0, 0]) :
	let(fn = max(6, $fn))
	let(halffn = ceil(fn/2))
	mkpoly([
		for(i=[0 : 1 : halffn]) let(ang=-90 + i*180/halffn) [x1+rad*cos(ang), rad*sin(ang)],
		for(i=[0 : 1 : halffn]) let(ang= 90 + i*180/halffn) [x0+rad*cos(ang), rad*sin(ang)]
	]);

// TODO: Do it without hull
function make_oval(rad, p0, p1) = ["hull", make_circle(rad, p0), make_circle(rad, p1)];

// function oval(diameter, p0, p1) = ["hull", ["circle", 

function fat_polyline_to_togmod(rad, points) =
	len(points) == 0 ? ["union"] :
	len(points) == 1 ? make_circle(rad, points[0]) :
	["union",
		for( i=[0 : 1 : len(points)-2] ) make_oval(rad, points[i], points[i+1])];

// fat_polyline(20, [[0,0], [100,100], [0,200]], $fn = 60);

function decode_for_panel(moddesc, z1) =
	assert(false, "not yet lol");
	
function decode_for_front_template(moddesc) =
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", counterbore_template_diameter/2, moddesc[1]] :
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	assert(false, str("Unsupported front template shape: '", moddesc[0], "'"));

function decode_for_back_template(moddesc) =
	moddesc[0] == "back-counterbored-slot" ? ["fat-polyline-rp", counterbore_template_diameter/2, moddesc[1]] :
	moddesc[0] == "front-counterbored-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	moddesc[0] == "normal-slot" ? ["fat-polyline-rp", hole_template_diameter/2, moddesc[1]] :
	assert(false, str("Unsupported front template shape: '", moddesc[0], "'"));

function decode2(moddesc) =
	moddesc[0] == "fat-polyline-rp" ? fat_polyline_to_togmod(moddesc[1], moddesc[2]) :
	moddesc;

// togmod1_domodule(fat_polyline_to_togmod(20, [[-10, -20], [10, 0], [10,20]]));

echo(cuts);
echo(decode_for_front_template(cuts[0]));

function decode_template_2d_cuts(scale, block, cuts, cut_decoder) = ["scale", scale, ["difference",
	block,
	for(cut=cuts) each cut[0] == "alignment-hole" ? [] : [decode2(cut_decoder(cut))]
]];

function make_the_template(hull_shape, cuts, mode) =
	mode == "front-template" ? decode_template_2d_cuts([ 1,1,1], hull_2d, cuts, function (c) decode_for_front_template(c)) :
	mode == "back-template"  ? decode_template_2d_cuts([-1,1,1], hull_2d, cuts, function (c) decode_for_back_template(c) ) :
	assert(str("Don't know how to make template in mode '", mode, "'"));

hull_2d = make_rounded_rect([6*inch, 9*inch], 3/4*inch);

if( mode == "front-template" || mode == "back-template" ) {
	// TODO: Translate THL-1001 to TOGMod1 so you can do the whole thing in TOGMod1
	difference() {
		togmod1_domodule(["linear-extrude-zs", [0, template_thickness], make_the_template(hull_2d, cuts, mode)]);
		
		for( cut=cuts ) {
			if( cut[0] == "alignment-hole" ) {
				translate([cut[1][0], cut[1][1], template_thickness]) tog_holelib_hole("THL-1001");
			}
		}
	}
} else if( mode == "panel" ) {
	togmod1_domodule(["difference",
		["linear-extrude-zs", [0, 3/4*inch], hull_2d],
		for( cut=cuts ) decode2(decode_for_panel(cut))
	]);
} else {
	assert(false, str("Unknown mode: '", mode, "'"));
}
