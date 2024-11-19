boxLength = 230;
boxWidth = 95;
boxHeight = 60;
floorThickness = 6;
wallThickness = 5;
ceilingHeight = boxHeight-floorThickness-0.02;
powerHoleDiameter = 0.25*25.4;
powerHoleRecessDiameter = 0.4*25.4+2;
powerHoleRecessDepth = 2;
powerHoleY = 30;
powerHoleZ = 20;
switchHoleDiameter = 0.26*25.4;
switchHoleRecessDiameter = 0.4*25.4;
switchHoleRecessDepth = floorThickness-2;
switchHoleX = 0;
switchHoleY = 62;

circuitBoardX = 120;
circuitBoardY = 12;
circuitBoardSpacerSize = 5;
circuitBoardSpacerHeight = 4;
circuitBoardSpacerHoleDiameter = 1.7;
circuitBoardPoints=[
        [0,0],
        [0,71.1],
        [50.8,58.42],
        [50.8,22.86]
      ];


wireX = 4;
wireY = 10;

elevatorHoleX = 88;
elevatorHoleSpaceX = 52;
elevatorHoleY = 22;
elevatorHoleSpaceY = 16;
elevatorHoleDiameter = 2.3;
elevatorWireX = 77;
elevatorWireY = 18;

gripperHoleX = 166;
gripperHoleY = 27;
gripperHoleSpaceX = 22;
gripperHoleSpaceY = 36;
gripperHoleDiameter = 2.3;
gripperWireX = 192;
gripperWireY = 39;

sensorHoleX = 0;
sensorHoleY = 0;
sensorHoleSpaceY = 42;
sensorHoleDiameter = 2.3;
sensorWireX = 8;
sensorWireY = 1;

module ElevatorHoles()
{
  translate([elevatorHoleX, elevatorHoleY,0])
    cylinder(floorThickness+1, d=elevatorHoleDiameter);
  translate([elevatorHoleX+elevatorHoleSpaceX, elevatorHoleY,0])
    cylinder(floorThickness+1, d=elevatorHoleDiameter);
  translate([elevatorHoleX, elevatorHoleY+elevatorHoleSpaceY,0])
    cylinder(floorThickness+1, d=elevatorHoleDiameter);
  translate([elevatorHoleX+elevatorHoleSpaceX, elevatorHoleY+elevatorHoleSpaceY,0])
    cylinder(floorThickness+1, d=elevatorHoleDiameter);
  
};

module ElevatorWire()
{
  translate([elevatorWireX, elevatorWireY,0])
  cube([wireX, wireY, floorThickness+1]);
};

module GripperWire()
{
  translate([sensorWireX, sensorWireY,0])
  cube([wireX, wireY, floorThickness+1]);
};

module SensorWire()
{
  translate([gripperWireX, gripperWireY,0])
  cube([wireX, wireY, floorThickness+1]);
};

module GripperHoles()
{
  translate([gripperHoleX, gripperHoleY,0])
    cylinder(floorThickness+1, d=gripperHoleDiameter);
  translate([gripperHoleX+gripperHoleSpaceX, gripperHoleY,0])
    cylinder(floorThickness+1, d=gripperHoleDiameter);
  translate([gripperHoleX, gripperHoleY+gripperHoleSpaceY,0])
    cylinder(floorThickness+1, d=gripperHoleDiameter);
  translate([gripperHoleX+gripperHoleSpaceX, gripperHoleY+gripperHoleSpaceY,0])
    cylinder(floorThickness+1, d=gripperHoleDiameter);
};

module SensorHoles()
{
  translate([sensorHoleX, sensorHoleY, 0])
    cylinder(floorThickness+1, d=sensorHoleDiameter);
  translate([sensorHoleX, sensorHoleY+sensorHoleSpaceY, 0])
    cylinder(floorThickness+1, d=sensorHoleDiameter);
};

module PowerHole()
{
  cylinder(wallThickness+2, d=powerHoleDiameter);
  cylinder(powerHoleRecessDepth, d=powerHoleRecessDiameter);
};

module SwitchHole()
{
  translate([switchHoleX, switchHoleY,0])
    union()
    {
      cylinder(floorThickness+2, d=switchHoleDiameter);
      cylinder(switchHoleRecessDepth,d=switchHoleRecessDiameter);
    };
};

module Spacer(p)
{
  d=circuitBoardSpacerSize/2;
  h = circuitBoardSpacerHeight;
  difference()
  {
    linear_extrude(h)
      polygon([[p.x-d,p.y-d],[p.x+d,p.y-d],[p.x+d,p.y+d],[p.x-d,p.y+d]]);
    translate([p.x,p.y,-1])
      cylinder(circuitBoardSpacerHeight+2, d=circuitBoardSpacerHoleDiameter);
  };
};

module CircuitBoardSpacers()
{
  translate([circuitBoardX,
             circuitBoardY,
             ceilingHeight-circuitBoardSpacerHeight+0.01])
    for (i=[0:3])
      Spacer(circuitBoardPoints[i]);
};

module USBSlot()
{
  translate([boxLength-wallThickness-1,boxWidth/2-3,1])
  rotate([0,90,0])
  cylinder(wallThickness+2,d=10);
};


rotate([180,0,0])
union()
{
difference()
{
  cube([boxLength,boxWidth,boxHeight]);
  translate([wallThickness, wallThickness,-0.01])
    cube([boxLength-2*wallThickness,
          boxWidth-2*wallThickness,
          boxHeight-floorThickness]);
  translate([22,13,ceilingHeight])
    union()
    {  
      ElevatorHoles();
      GripperHoles();
      SensorHoles();
      ElevatorWire();
      GripperWire();
      SensorWire();
      SwitchHole();
    };
  translate([boxLength+0.01,powerHoleY,powerHoleZ])
    rotate([0,-90,0])
      PowerHole();
  USBSlot();
};

CircuitBoardSpacers();
};