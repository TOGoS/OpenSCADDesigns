use <../lib/TOGUnits1.scad>

function togunits1__todo(message) = assert(false, str("TODO: ", message));

module togunits1__assert_eq(a, b, scale=undef) {
	as = is_undef(scale) ? a : round(a*scale);
	bs = is_undef(scale) ? b : round(b*scale);
	if( as != bs ) {
		assert( a == b, str(a, " != ", b) );
	}
}


togunits1__assert_eq(10  , togunits1_to_mm(10));
togunits1__assert_eq(10  , togunits1_to_mm("10mm"));
togunits1__assert_eq(25.4, togunits1_to_mm("1inch"));
togunits1__assert_eq(38.1, togunits1_to_mm("1+1/2inch"));
togunits1__assert_eq(38.1, togunits1_to_mm([1.5, "inch"]), 100);
togunits1__assert_eq(38.1, togunits1_to_mm([3  , "atom"]), 100);

cube([togunits1_to_mm("1inch"),togunits1_to_mm("1atom"),togunits1_to_mm("2u")], center=true);
