// TroughJig-v2.0

use <../lib/TOGShapeLib-v1.scad>

inch = 25.4;

block_size = [6*inch,6*inch, 5.25*inch];
cargo_size = [undef, 4.5*inch, 4.5*inch];
hole_spacing = 3/4*inch;

$fn = $preview ? 16 : 64;

linear_extrude(3/4*inch) difference() {
	tog_shapelib_rounded_beveled_square([block_size[1], block_size[2]], 1/8*inch, 1/8*inch);
	
	translate([0,-block_size[2]/2]) square([cargo_size[1], cargo_size[2]*2], center=true);
	for( xm=[-block_size[1]/2 + hole_spacing/2 : hole_spacing : block_size[1]/2] )
	for( ym=[-block_size[2]/2 + hole_spacing/2 : hole_spacing : block_size[2]/2] )
		{
		translate([xm,ym]) circle(d=4);
	}
}