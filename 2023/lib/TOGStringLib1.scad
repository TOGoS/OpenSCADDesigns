// TOGStringLib1.6
// 
// Functions for parsing quantities
// and other misc. string handling.
// 
// v1.5
// - togstr1_parse_quantity will treat unit-only strings as meaning 1/1 of that unit.
//   e.g. togstr1_parse_quantity("foot") = [[[1,1], "foot", 4]]
// v1.6:
// - togstr1_parse_quantity allows unit name to be omitted when quantity is zero and $togunits1_default_unit is defined
// 
// Globals: $togunits1_default_unit - affects what 'unit' is returned
// when interpreting numbers or strings that lack the unit.


function togstr1__todo(message) = assert(false, str("TODO: ", message));

module togstr1__assert_eq(a, b) {
	if( a != b ) {
		assert( a == b, str(a, " != ", b) );
	}
}



function togstr1_slice(source, i0, i1) =
	i0 == i1 ? "" :
	str(source[i0], togstr1_slice(source, i0+1, i1));

function togstr1_tokenize(source, sep, maxcount=9999, i=0, tokenstart=0) =
	len(source) == i ? (
		(tokenstart < i) ? [togstr1_slice(source, tokenstart, i)] : []
	) :
	source[i] == sep ? (
		(tokenstart < i) ? concat([togstr1_slice(source, tokenstart, i)], togstr1_tokenize(source, sep, maxcount-1, i+1, i+1)) :
		togstr1_tokenize(source, sep, maxcount, i+1, i+1)
	) :
	maxcount <= 1 ? [togstr1_slice(source, tokenstart, len(source))] :
	togstr1_tokenize(source, sep, maxcount, i+1, tokenstart);

togstr1__assert_eq( ["foo","bar","baz"], togstr1_tokenize("foo-bar-baz", "-") );
// Duplicate delimiters are ignored
togstr1__assert_eq( ["foo","bar","baz"], togstr1_tokenize("foo--bar--baz", "-") );
// Trailing delimiters are ignored
togstr1__assert_eq( ["foo","bar","baz"], togstr1_tokenize("foo--bar--baz--", "-") );
// Leading delimiters are ignored
togstr1__assert_eq( ["foo","bar","baz"], togstr1_tokenize("--foo--bar--baz", "-") );
// Can limit number of tokens returned
togstr1__assert_eq( ["foo","bar-baz"], togstr1_tokenize("foo-bar-baz", "-", 2) );
togstr1__assert_eq( ["foo","bar-baz"], togstr1_tokenize("--foo--bar-baz", "-", 2) );
togstr1__assert_eq( ["foo","bar--baz"], togstr1_tokenize("--foo--bar--baz", "-", 2) );
togstr1__assert_eq( ["foo"], togstr1_tokenize("--foo--", "-", 2) );




/** \d+ -> [num, end_index] */
function togstr1_parse_decimal_nat(str, index=0, current=0) =
	len(str) == index ? [current, index] :
	let( dig = ord(str[index]) - ord("0") )
	(dig >= 0 && dig <= 9) ? togstr1_parse_decimal_nat(str, index+1, current*10 + dig) :
	[current, index];

togstr1__assert_eq( [123,3], togstr1_parse_decimal_nat("123") );
togstr1__assert_eq( [123,3], togstr1_parse_decimal_nat("123.45") );

/** [+-]*\d+ ->  [[num, den], end_index] */
function togstr1_parse_decimal_number(str, index=0) =
	str[index] == "+" ? togstr1_parse_decimal_number(str, index+1) :
	str[index] == "-" ? let(r=togstr1_parse_decimal_number(str, index+1)) [[-r[0][0], r[0][1]], r[1]] :
	let(r = togstr1_parse_decimal_nat(str, index))
	str[r[1]] != "." ? [[r[0], 1], r[1]] :
	let(fracr = togstr1_parse_decimal_nat(str, r[1]+1))
	let(mult = pow(10, fracr[1]-(r[1]+1)))
	[[r[0]*mult + fracr[0], mult], fracr[1]];

togstr1__assert_eq( [[   36,   1], 2], togstr1_parse_decimal_number( "36"   ) );
togstr1__assert_eq( [[ 3524, 100], 5], togstr1_parse_decimal_number( "35.24") );
togstr1__assert_eq( [[-3524, 100], 6], togstr1_parse_decimal_number("-35.24") );
togstr1__assert_eq( [[    0,   1], 0], togstr1_parse_decimal_number( "NotANumber") );

function togstr1__gcd(a, b) = b == 0 ? abs(a) : togstr1__gcd(b, a % b);

togstr1__assert_eq(10, togstr1__gcd(10, 20));
togstr1__assert_eq( 5, togstr1__gcd(10, 15));
togstr1__assert_eq( 2, togstr1__gcd(10, 14));


function togstr1__normalize_rat(rat) =
	let(gcd = togstr1__gcd(rat[0], rat[1]))
	// TODO: find LCD, divide top and bottom by it
	rat[0] < 0 && rat[1] < 0 ? [-rat[0]/gcd, -rat[1]/gcd] :
	[rat[0]/gcd, rat[1]/gcd];

/** <decnum>[/<decnum>] -> [[num, den], end_index] */
function togstr1__multiply_rat(a, b) =
	togstr1__normalize_rat(
		a[1] == b[1] ? [a[0]*b[0]/a[1], a[1]] : // TODO: LCD instead of special case
		[a[0]*b[0], a[1]*b[1]]
	);
function togstr1__divide_rat(a, b) = togstr1__normalize_rat([a[0]*b[1], a[1]*b[0]]);


function togstr1__add_rat(a, b) =
	togstr1__normalize_rat([a[0]*b[1] + b[0]*a[1], a[1]*b[1]]);
	
togstr1__assert_eq([1, 2], togstr1__add_rat([1, 3], [1, 6]));


/** Return [[num, den], end_index] */
function togstr1_parse_rational_number(str, index=0) =
	let( numr = togstr1_parse_decimal_number(str, index) )
	str[numr[1]] == "+" ?
		let(numrb = togstr1_parse_rational_number(str, numr[1]+1))
		[togstr1__add_rat(numr[0], numrb[0]), numrb[1]]	:
	str[numr[1]] == "/" ?
		let( denr = togstr1_parse_decimal_number(str, numr[1]+1) )
		[togstr1__divide_rat(numr[0], denr[0]), denr[1]] :
	numr;

togstr1__assert_eq( [[   123,  1],3], togstr1_parse_rational_number( "123") );
togstr1__assert_eq( [[   123,  1],4], togstr1_parse_rational_number("+123") );
togstr1__assert_eq( [[-  123,  1],4], togstr1_parse_rational_number("-123") );
togstr1__assert_eq( [[   123,  1],6], togstr1_parse_rational_number("-+-123") );
togstr1__assert_eq( [[ 12345,100],6], togstr1_parse_rational_number("123.45") );
togstr1__assert_eq( [[  2469, 40],8], togstr1_parse_rational_number("123.45/2") );
togstr1__assert_eq( [[-  823,160],10], togstr1_parse_rational_number("-123.45/24") );
togstr1__assert_eq( [[     4,  3],5], togstr1_parse_rational_number( "1+1/3") );
togstr1__assert_eq( [[     0,  1],0], togstr1_parse_rational_number( "NotANumber!!") );


/** Return [[[num, den], unit], end_index] */
function togstr1_parse_quantity(str) =
	let( numr = togstr1_parse_rational_number(str) )
	// For now, just let the unit be the rest of the string;
	// can revisit to stop at delimiters if needed in the future.
	numr[1] > 0 && numr[1] == len(str) && numr[0][0] == 0 && !is_undef($togunits1_default_unit) ? [[[0,1], $togunits1_default_unit], numr[1]] :
	assert( numr[1] < len(str), str("Quantity string missing unit: '", str, "'; note that '0' is acceptable if $togunits1_default_unit is defined"))
	let( unit = togstr1_slice(str, numr[1], len(str)) )
	let( quant = numr[1] > 0 ? numr[0] : [1,1] ) // No number = 1 (possibly this should be an error instead)
	[[quant, unit], len(str)];

togstr1__assert_eq( [[[  3,  1], "acre"],  5], togstr1_parse_quantity("3acre") );
togstr1__assert_eq( [[[  3,  5], "acre"],  7], togstr1_parse_quantity("3/5acre") );
togstr1__assert_eq( [[[301,500], "acre"], 10], togstr1_parse_quantity("3.01/5acre") );
togstr1__assert_eq( [[[  1,  1], "acre"],  4], togstr1_parse_quantity("acre") ); // Should either treat as one or throw an error!
togstr1__assert_eq( [[[  0,  1],"hectare"],1], togstr1_parse_quantity("0", $togunits1_default_unit="hectare") ); // Zero is fine if $togunits1_default_unit is defined
