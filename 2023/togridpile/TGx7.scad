// TOGridPileBlock [experimental] version 7
// An attempt to come up with a simplified block shape

use <../lib/TOGridPileLib-v1.scad>

/* [Content] */

block_size_atoms = [2,2,1];

/* [Sizing Tweaks] */

margin = 0.1;

/* [Stacking System - Do Not Change Unless You Know What You're Doing] */

atom_size = 12.7;
rounded_cube_corner_radius = 4.7625; // 0.0001
// 3.175" = 1/8", 1.5875 = 1/16"
column_corner_radius = 3.175; // 0.0001

/* [Detail Level] */

rounded_cube_fn = 24;
column_fn = 48;

module __end_params() { }

column_inset = rounded_cube_corner_radius-column_corner_radius;
blangle = acos(column_corner_radius/rounded_cube_corner_radius); // Angle from uh
max_lip_height = min(column_inset, column_corner_radius * (1-sin(blangle)));

echo(str("Blangle = ", blangle, " = acos(", column_corner_radius/rounded_cube_corner_radius, ")"));
echo("Max lip height:", max_lip_height);

column_size = atom_size - column_inset*2;

module togridpile_x7_block(block_size_atoms, offset=0, column_end_offset=0) {
	block_size = [
		atom_size*block_size_atoms[0],
		atom_size*block_size_atoms[1],
		atom_size*block_size_atoms[2]
	];
	body_size = [
		block_size[0] - column_inset*2,
		block_size[1] - column_inset*2,
		block_size[2] - column_inset*2
	];
	render() togridpile__rounded_cube(body_size, column_corner_radius, -margin, $fn=rounded_cube_fn);
	//cube([body_size[0]-margin*2, body_size[1]-margin*2, body_size[2]-margin*2], center=true);

	for( xm=[-block_size_atoms[0]/2+0.5 : 1 : block_size_atoms[0]/2-0.5] )
	for( ym=[-block_size_atoms[1]/2+0.5 : 1 : block_size_atoms[1]/2-0.5] )
	for( zm=[-block_size_atoms[2]/2+0.5 : 1 : block_size_atoms[2]/2-0.5] )
	translate([xm*atom_size, ym*atom_size, zm*atom_size]) render() togridpile__rounded_cube([atom_size, atom_size, atom_size], rounded_cube_corner_radius, -margin, $fn=rounded_cube_fn);

	for( xm=[-block_size_atoms[0]/2+0.5 : 1 : block_size_atoms[0]/2-0.5] )
	for( ym=[-block_size_atoms[1]/2+0.5 : 1 : block_size_atoms[1]/2-0.5] )
	{
		translate([xm*atom_size, ym*atom_size, 0]) linear_extrude(atom_size+column_end_offset*2, center=true) {
			togridpile__rounded_square([column_size,column_size], column_corner_radius, -margin, $fn=column_fn);
		}
	}
}

block_size = [atom_size*block_size_atoms[0], atom_size*block_size_atoms[1], atom_size*block_size_atoms[2]];

translate([0,0,block_size[2]/2]) {
	togridpile_x7_block(block_size_atoms, -margin, -margin);
}

translate([block_size[1],0,0]) {
	linear_extrude(max_lip_height, center=false) difference() {
		togridpile__rounded_square(block_size, rounded_cube_corner_radius, -margin, $fn=column_fn);

		for( xm=[-block_size_atoms[0]/2+0.5 : 1 : block_size_atoms[0]/2-0.5] )
		for( ym=[-block_size_atoms[1]/2+0.5 : 1 : block_size_atoms[1]/2-0.5] )
		{
			translate([xm*atom_size, ym*atom_size]) {
				togridpile__rounded_square([column_size,column_size], column_corner_radius, margin, $fn=column_fn);
			}
		}
	}
}
