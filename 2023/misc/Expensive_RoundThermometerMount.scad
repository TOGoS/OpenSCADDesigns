thermometerRadius = 40/2;
thermometerHeight = thermometerRadius+12;
thermometerMountThickness = 1.6;
thermometerMountRadius = 35/2;


cylinderTopRadius = 13; //11; //12
cylinderBottomRadius = 10; //10; //12
cylinderBottom = 3;
cylinderRadius = 6;
cylinderSpace = 52.6;
cylinderHeight = thermometerHeight;

baseThickness = 3;
baseHeight = thermometerHeight+9;
baseY = -cylinderBottomRadius+11;
baseLength = cylinderSpace+1.5*cylinderBottomRadius;

skirtThickness = 5;
skirtHeight = 2;
skirtLength = 5;

module Cylinder()
{
  difference()
  {
    union()
    {
      translate([0,0,cylinderBottom])
        cylinder(cylinderHeight,
                 cylinderBottomRadius,
                 cylinderTopRadius);
      translate([0,0,0])
        cylinder(cylinderBottom+0.01,
                 cylinderBottomRadius/2,
                 cylinderBottomRadius);
    };
    translate([cylinderBottomRadius/3,
               -cylinderTopRadius-1, //cylinderBottomRadius
               -1])
      cube([10,100,100]);
    translate([cylinderBottomRadius/3,
               -cylinderBottomRadius+baseThickness,
               -1])
      rotate([0,0,45])
        cube([200,220,200]);
  };
};

module Skirt()
{
  translate([(cylinderSpace-skirtThickness)/2,baseY,0])
    cube([skirtThickness, 
          skirtLength+baseThickness, 
          skirtHeight]);
};


module Base()
{
  Cylinder();
  
  translate([cylinderSpace,0,0])
    mirror([1,0,0])
      Cylinder();
  
  translate([cylinderSpace/2,
             baseY,
             baseHeight/2])
    cube([baseLength,
          baseThickness,
          baseHeight], center=true);
  Skirt();  // This stops my slicer from adding a skirt.
  
};

module Thermometer()
{
  translate([cylinderSpace/2,
             -cylinderRadius-baseThickness,
             thermometerHeight])
    rotate([-90,0,0])
      cylinder(100,thermometerRadius,thermometerRadius);
};

difference()
{
  Base();
  Thermometer();
};

difference()
{
  translate([cylinderSpace/2,
             baseY+baseThickness,
           thermometerHeight])
    rotate([90,0,0])
      difference()
      {
        cylinder(thermometerMountThickness,
                 thermometerMountRadius+5,
                 thermometerMountRadius+5);
        translate([0,0,-1])
          cylinder(thermometerMountThickness+2,
                   thermometerMountRadius,
                   thermometerMountRadius);
      };
  translate([0,0,baseHeight+0.01])
    cube([500,10,20]);
};
