// BarCap0.1
// 
// Generic cap for round bars.
// 
// Presets are for some almost-30mm galvanized stell conduit
// that Renee wants to use as a pullup bar.  These will cap
// those so that they fit snugly into 1+1/4" slots.

inner_diameter = 30;
outer_diameter = 31.75;
floor_thickness = 6.35;
total_height = 19.05;
$fn = 48;

module __barcap0__end_params() { }

use <../lib/TOGMod1.scad>
use <../lib/SimpleCap0.scad>

togmod1_domodule(simplecap0_make_cap(["circle-d", inner_diameter], total_height, floor_thickness, (outer_diameter-inner_diameter)/2));
