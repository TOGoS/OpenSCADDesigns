// Cyl-v1.0
// A cylinder

thickness = 3.175;
diameter  = 20;
$fn = max(24, min(360, sqrt(diameter) * ($preview ? 6 : 12)));

cylinder(d=diameter, h=thickness);
