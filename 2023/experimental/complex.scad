function complex_multiply(a, b) =
	[a[0]*b[0] - a[1]*b[1], a[0]*b[1] + a[1]*b[0]];
function complex_divide(a, b) =
	let(bot = (b[0]*b[0] + b[1]*b[1]))
	[
		(a[0]*b[0] + a[1]*b[1])/bot,
		(a[1]*b[0] - a[0]*b[1])/bot
	];

assert([-11,23] == complex_multiply([3,2], [1,7]));

assert([-1,3] == complex_multiply([3,1], [0,1]));
assert([-1,3] == complex_multiply([0,1], [3,1]));

echo(complex_divide([-1,3], [3,1]));
assert([0,1] == complex_divide([-1,3], [3,1]));

function normalize(vec) =
	let(veclen = sqrt(vec[0]*vec[0]+vec[1]*vec[1]))
	[vec[0] / veclen, vec[1] / veclen];

function relative_turnvec_vv(v0, v1) =
	complex_divide(normalize(v1), normalize(v0));

function relative_turnvec_abc(p0, p1, p2) = relative_turnvec_vv(p1-p0, p2-p1);

assert([0,1] == relative_turnvec_abc([0,0], [1,0], [1,1]));
assert([0,1] == relative_turnvec_abc([0,0], [0,1], [-1,1]));
