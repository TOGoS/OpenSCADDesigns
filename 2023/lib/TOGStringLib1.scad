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

function togstr1__normalize_rat(rat) =
	// TODO: find LCD, divide top and bottom by it
	rat[0] < 0 && rat[1] < 0 ? [-rat[0], -rat[1]] :
	rat;

/** <decnum>[/<decnum>] -> [[num, den], end_index] */
function togstr1__multiply_rat(a, b) =
	togstr1__normalize_rat(
		a[1] == b[1] ? [a[0]*b[0]/a[1], a[1]] : // TODO: LCD instead of special case
		[a[0]*b[0], a[1]*b[1]]
	);
function togstr1__divide_rat(a, b) = togstr1__normalize_rat([a[0]*b[1], a[1]*b[0]]);


/** Return [[num, den], end_index] */
function togstr1_parse_rational_number(str, index=0) =
	let( numr = togstr1_parse_decimal_number(str, index) )
	str[numr[1]] != "/" ? numr :
	let( denr = togstr1_parse_decimal_number(str, numr[1]+1) )
	[togstr1__divide_rat(numr[0], denr[0]), denr[1]];

togstr1__assert_eq( [[   123,  1],3], togstr1_parse_rational_number( "123") );
togstr1__assert_eq( [[   123,  1],4], togstr1_parse_rational_number("+123") );
togstr1__assert_eq( [[-  123,  1],4], togstr1_parse_rational_number("-123") );
togstr1__assert_eq( [[   123,  1],6], togstr1_parse_rational_number("-+-123") );
togstr1__assert_eq( [[ 12345,100],6], togstr1_parse_rational_number("123.45") );
togstr1__assert_eq( [[ 12345,200],8], togstr1_parse_rational_number("123.45/2") );
togstr1__assert_eq( [[-12345,2400],10], togstr1_parse_rational_number("-123.45/24") );


/** Return [[[num, den], unit], end_index] */
function togstr1_parse_quantity(str) =
	let( numr = togstr1_parse_rational_number(str) )
	// For now, just let the unit be the rest of the string;
	// can revisit to stop at delimiters if needed in the future.
	let( unit = togstr1_slice(str, numr[1], len(str)) ) 
	[[numr[0], unit], len(str)];

togstr1__assert_eq( [[[  3,  1], "acre"],  5], togstr1_parse_quantity("3acre") );
togstr1__assert_eq( [[[  3,  5], "acre"],  7], togstr1_parse_quantity("3/5acre") );
togstr1__assert_eq( [[[301,500], "acre"], 10], togstr1_parse_quantity("3.01/5acre") );
