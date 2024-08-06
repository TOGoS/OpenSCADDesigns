// Floored Division Modulo

function togfdmod(a, b) = a - (b * floor(a / b));

assert( togfdmod( 0,  5) == 0 );
assert( togfdmod( 3,  5) == 3 );
assert( togfdmod( 5,  5) == 0 );
assert( togfdmod(-3,  5) == 2 );
assert( togfdmod(-5,  5) == 0 );
assert( togfdmod(-6,  5) == 4 );

assert( togfdmod( 5, -5) ==  0 );
assert( togfdmod( 1, -5) == -4 );
assert( togfdmod(-6, -5) == -1 );
