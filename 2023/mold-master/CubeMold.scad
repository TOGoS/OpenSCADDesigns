// CubeMold-v1.0

use <../lib/TOGShapeLib-v1.scad>

inch = 25.4;

floor_thickness = 1/16*inch;
wall_thickness = 1/16*inch;
mold_size = [3*inch, 3*inch, 2.25*inch];
raft_height = 1/16*inch;
cube_size = [1.5*inch, 1.5*inch, 1.5*inch];
cube_hole_diameter = 7.5;

difference() {
	linear_extrude(mold_size[2]) tog_shapelib_rounded_beveled_square(mold_size);
	
	translate([0,0,floor_thickness+mold_size[2]/2]) cube([mold_size[0]-wall_thickness, mold_size[1]-wall_thickness, mold_size[2]], center=true);
}
translate([0,0,floor_thickness]) {
	linear_extrude(cube_size[2]) difference() {
		tog_shapelib_rounded_beveled_square(cube_size);
		
		circle(d=cube_hole_diameter);
	}
}
