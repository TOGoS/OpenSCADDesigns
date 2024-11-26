// BucketTableAdapter1.3
// 
// Bolt it to the bottom of a 'table top' so that the whole thing can
// sit relatively securely on top of a 5-gallon bucket.
// 
// Versions:
// v1.1:
// - Holes in the 'floot' (or 'ceiling')
// v1.2:
// - Allow finer adjustments to parameters
// v1.3:
// - Add an optional (if inner_rim_height > outer_rim_height) inner rim
// - Rename 'thickness' parameter to 'outer_rim_height'

use <../lib/TOGMod1.scad>
use <../lib/TOGMod1Constructors.scad>
use <../lib/TOGPath1.scad>
use <../lib/TOGPolyhedronLib1.scad>
use <../lib/TOGArrayLib1.scad>

outer_rim_height    =  12.7;   // 0.01
min_rim_width       =   6.35;  // 0.01
// 311mm = about 12+1/4"
lid_pocket_diameter = 311;     // 0.1
lid_pocket_depth    =   9.525; // 0.01
inner_rim_width     =   3.175;
inner_rim_height    =   0;     // 0.01
hole_grid_size      =  38.1;   // 0.01
$fn = 32;

module __akjdnweubd__end_params() { }

min_outer_diameter = lid_pocket_diameter + min_rim_width*2;
chunk = hole_grid_size;

function bta1__clamp(v, min, max) =
	min > max ? (max+min)/2 :
	v < min ? min :
	v > max ? max :
	v;

function bta1__dist(a, b) =
	sqrt(pow(a[0]-b[0], 2) + pow(a[1]-b[1],2));

total_height  = max(inner_rim_height, outer_rim_height);
z_high = total_height+1;

gb_hole = tphl1_make_z_cylinder(zrange=[-1, z_high], d=5/16*25.4);
gb_ring_2d = togmod1_make_circle(d=25.4);

function generate_grid_positions( ang_to_guess_func, guess_to_grid_func, validity_check ) =
	tal1_uniq([for(a=[0 : 10 : 360])
		let(pos_guess = ang_to_guess_func(a))
		let(pos_grid = guess_to_grid_func(pos_guess))
		if( validity_check(pos_grid) ) pos_grid
	]);

floor_hole_positions =
let( outer_diameter = lid_pocket_diameter + chunk )
let( outer_diameter_chunks = round(outer_diameter/chunk) )
[
	for( ym=[-outer_diameter_chunks/2 + 0.5 : 0.5 : outer_diameter_chunks/2] )
	for( xm=[-outer_diameter_chunks/2 + 0.5 : 0.5 : outer_diameter_chunks/2] )
	let( pos=[xm*chunk, ym*chunk] )
	if( bta1__dist([0,0], pos) < lid_pocket_diameter/2 - 6.35 )
	pos
];

// TODO: floor_hole_positions and rim_hole_positions
// can both be calculated the same way; just use a mask
// to determine where the holes may/not be placed.


rim_hole_positions =
	let( outer_diameter = lid_pocket_diameter + chunk )
	let( outer_diameter_chunks = round(outer_diameter/chunk) )
	let( x0 = chunk * (-outer_diameter_chunks/2 + 0.5) )
	let( min_dist = lid_pocket_diameter/2+6.35 )
	let( max_dist = outer_diameter/2-6.35 )
	let( min_dist_squared = min_dist*min_dist )
	let( max_dist_squared = max_dist*max_dist )
	generate_grid_positions(
		function(ang) [cos(ang)*(min_dist+max_dist)/2, sin(ang)*(min_dist+max_dist)/2],
		function(pos) [x0+chunk*round((pos[0]-x0)/chunk), x0+chunk*round((pos[1]-x0)/chunk)],
		function(pos) let(dist_squared = pos[0]*pos[0] + pos[1]*pos[1]) dist_squared >= min_dist_squared /* && dist_squared <= max_dist_squared */
	);
echo(len(rim_hole_positions));

function bta1__circle(r) =
	togmod1_make_circle(d=r*2, $fn=bta1__clamp(r, $fn, 365));

togmod1_domodule(["difference",
	// TODO: Grating instead of solid floor?
	["union",
		togmod1_linear_extrude_z([0, outer_rim_height], ["hull",
		   bta1__circle(min_outer_diameter/2),
			for( h=rim_hole_positions ) ["translate", h, gb_ring_2d]
		]),
		// Inner rim
		if( inner_rim_height > outer_rim_height )
		togmod1_linear_extrude_z([0, inner_rim_height], bta1__circle(lid_pocket_diameter/2+inner_rim_width)),
	],
	
	tphl1_make_z_cylinder(zrange=[lid_pocket_depth >= total_height ? -1 : total_height-lid_pocket_depth, z_high],
		d=lid_pocket_diameter, $fn=bta1__clamp(lid_pocket_diameter/2, $fn, 365)),
	for( h=rim_hole_positions ) ["translate", h, gb_hole],
	for( h=floor_hole_positions ) ["translate", h, gb_hole],
]);
