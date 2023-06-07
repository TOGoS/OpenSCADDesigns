// Cap diameter: ~13.5mm
// Total length: ~131mm = ~5.16"

inch = 25.4;
block_depth = 38.1;
lip_height = 2.54;
wall_thickness = 3;
floor_thickness = 9.525;

female_segmentation = "chunk";
female_column_style = "v3";

margin = 0.05;

$fn = 24;

use <../lib/TOGridPileLib-v2.scad>

block_size_chunks = [4,4,1];
block_size = [
	block_size_chunks[0]*12.7*3,
	block_size_chunks[1]*12.7*3,
	block_depth,
];
cavity_size = [
	block_size[0] - wall_thickness*2,
	block_size[1] - wall_thickness*2,
	block_size[2] - floor_thickness,
];


module minkoround(r=0) {
	if( r <= 0 ) {
		children();
	} else {
		minkowski() {
			sphere(r=r);
			
			children();
		}
	}
}

module a_hook() rotate([180,-90,0]) {
	corner_rad = 2;
	minkoround(corner_rad) {
		linear_extrude(12.7, center=true) intersection() {
			difference() {
				circle(r=1*inch - corner_rad, $fn=$fn*2);
				translate([6,0]) circle(r=14 + corner_rad, $fn=$fn*2);
			}
			square([25,25], center=false);
		}
	}
}

module a_marker_shelf() {
	for(xi=[-1 + 1/4, 1.5]) translate([xi*inch, 0, 0]) render(2) a_hook();
}

cs1 = [cavity_size[0]+0.1, cavity_size[1]+0.1]; // For sticking things in the walls

module the_sublip() {
	sublip_width = 2;
	sublip_angwid = sublip_width/sin(45);
	sublip_angwid2 = sublip_angwid*2*1.414;
	for(xm=[-1,1]) translate([xm*cs1[0]/2, 0, 0]) rotate([0,45,0])
		cube([sublip_angwid,block_size[1],sublip_angwid], center=true);
	for(ym=[-1,1]) translate([0, ym*cs1[1]/2, 0]) rotate([45,0,0])
		cube([block_size[0],sublip_angwid,sublip_angwid], center=true);
	for(ym=[-1,1]) for(xm=[-1,1]) translate([xm*cs1[0]/2, ym*cs1[1]/2, 0]) rotate([0,0,ym*xm*45]) rotate([0,45,0])
		cube([sublip_angwid2,sublip_angwid2,sublip_angwid2], center=true);
}

module the_pocket() {
	difference() {
		translate([0,0,block_depth]) togridpile2_chunk_body(
			style="v1",
			size=[cavity_size[0], cavity_size[1], cavity_size[2]*2],
			offset=0
		);

		for(yi=[-2.25 : 1.5 : +2.25]) {
			translate([0, yi*inch, floor_thickness]) a_marker_shelf();
		}
		
		translate([0,0,block_depth]) the_sublip();
	}
}

module unused__here_for_reference__the_cup_cavity() if(cavity_size[2] > 0) difference() {
	togridpile2_chunk_body(
		style="v1",
		size=[cavity_size[0], cavity_size[1], cavity_size[2]*2],
		offset=0
	);
	the_sublip();
	the_label_platform();
	translate([0,0,-cavity_size[2]]) the_fingerslide();
	for( i=cavity_bulkhead_positions ) {
		maybeswapxy = cavity_bulkhead_axis == "x" ? function(v) kasjhd_swapxy(v) : function(v) v;
		translate(maybeswapxy([i,0,0])) cube(maybeswapxy([wall_thickness, block_size[1], block_size[2]*2]), center=true);
	}
}

module the_lip_cavity() togridpile2_block(
	block_size_chunks = [
		block_size_chunks[0],
		block_size_chunks[1],
		1
	],
	//chunk_pitch_atoms = chunk_pitch_atoms,
	//atom_pitch = atom_pitch,
	column_style = female_column_style,
	side_column_style = "v6",
	chunk_side_column_placement = "grid",
	//chunk_column_placement = chunk_column_placement,
	//chunk_body_style = chunk_body_style,
	bottom_segmentation = "chunk",
	//side_segmentation = "atom",
	offset = margin,
	origin = "bottom"
);

module the_block() difference() {
	// translate([0,0,block_depth/2]) cube([6*inch, 6*inch, block_depth], center=true);
	intersection() {
		togridpile2_block(block_size_chunks=[4,4,2], origin="bottom", side_column_style="none", offset=-margin);
		cube([9*inch, 9*inch, (block_depth+lip_height)*2], center=true);
	}
	
	the_pocket();
	translate([0,0,block_depth]) render() the_lip_cavity();
}

the_block();

// a_hook();
