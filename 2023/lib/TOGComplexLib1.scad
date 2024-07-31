function tcplx1_multiply(a, b) =
	[a[0]*b[0] - a[1]*b[1], a[0]*b[1] + a[1]*b[0]];
function tcplx1_rotate(vec, angle) =
	tcplx1_multiply(vec, [cos(angle),sin(angle)]);
function tcplx1_divide(a, b) =
	let(bot = (b[0]*b[0] + b[1]*b[1]))
	[
		(a[0]*b[0] + a[1]*b[1])/bot,
		(a[1]*b[0] - a[0]*b[1])/bot
	];

assert([-11,23] == tcplx1_multiply([3,2], [1,7]));

assert([-1,3] == tcplx1_multiply([3,1], [0,1]));
assert([-1,3] == tcplx1_multiply([0,1], [3,1]));

echo(tcplx1_divide([-1,3], [3,1]));
assert([0,1] == tcplx1_divide([-1,3], [3,1]));

function tcplx1_normalize(vec) =
	let(veclen = sqrt(vec[0]*vec[0]+vec[1]*vec[1]))
	[vec[0] / veclen, vec[1] / veclen];

function tcplx1_relative_turnvec_vv(v0, v1) =
	tcplx1_divide(tcplx1_normalize(v1), tcplx1_normalize(v0));

function tcplx1_relative_turnvec_abc(p0, p1, p2) = tcplx1_relative_turnvec_vv(p1-p0, p2-p1);

// A 90-degree turn
assert([0,1] == tcplx1_relative_turnvec_abc([0,0], [1,0], [1,1]));
assert([0,1] == tcplx1_relative_turnvec_abc([0,0], [0,1], [-1,1]));

// A 45-degree turn
assert(tcplx1_normalize([1,1]) == tcplx1_relative_turnvec_abc([0,0], [1,0], [ 2,1]));
assert(tcplx1_normalize([1,1]) == tcplx1_relative_turnvec_abc([0,0], [0,1], [-1,2]));


function tcplx1_relative_angle_abc(p0, p1, p2) =
	let(turnvec = tcplx1_relative_turnvec_abc(p0, p1, p2))
	atan2(turnvec[1], turnvec[0]);

assert(-135 == tcplx1_relative_angle_abc([0,0], [1,0], [0,-1]));
assert( -90 == tcplx1_relative_angle_abc([0,0], [1,0], [1,-1]));
assert(   0 == tcplx1_relative_angle_abc([0,0], [1,0], [2, 0]));
assert(  90 == tcplx1_relative_angle_abc([0,0], [1,0], [1, 1]));
assert( 135 == tcplx1_relative_angle_abc([0,0], [1,0], [0, 1]));

assert(  90 == tcplx1_relative_angle_abc([1,1], [3,3], [1, 5]));
