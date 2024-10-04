// TrikeBarEndCaps0.1
// 
// End caps for the rusty metal bar
// I tied to the tricycle handle

module __cigaretteholder1cap__end_params() { }

use <../lib/SimpleCap0.scad>
use <../lib/TOGMod1.scad>

inch = 25.4;
$fn = 64;

togmod1_domodule(["union",
	["translate", [-15,0,0], simplecap0_make_cap(["circle-d", 16.65, 3/4*inch, 3.175, 3.175])],
	["translate", [ 15,0,0], simplecap0_make_cap(["circle-d", 19.05, 3/4*inch, 3.175, 3.175])],
]);
