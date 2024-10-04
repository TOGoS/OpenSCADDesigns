// CigarettHolder1Cap, v1.0
//

module __cigaretteholder1cap__end_params() { }

use <../lib/SimpleCap0.scad>
use <../lib/TOGMod1.scad>

inch = 25.4;
$fn = 64;

togmod1_domodule(simplecap0_make_cap(["oval-wh", [1*inch, 1/2*inch]], 3/4*inch, 3.175, 3.175));
