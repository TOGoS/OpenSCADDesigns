// Q: Does OpenSCAD know about infinity?
// A: Seems not.

// Q: In lieu of infinity, will the builtin min/max functions
//    handle undef as meaning disregard?
// A: No; min(undef, x) is an error.

// Q: Can I define a recursive function with 'let' that refers to itself by name?
// A: Yes.

minmax =
	let( undef_to_ident = function(f) function(x,y) x == undef ? y : y == undef ? x : f(x,y) )
	// Functions declared as `function NAME(..) = ...` live in a separate
	// namespace and cannot be referred to as values, sadface.
	let( oldmin = function(x,y) min(x,y) )
	let( oldmax = function(x,y) max(x,y) )
	// That said, `X(...)` will work whether X is defined in the function
	// or value namespace.
	let( min = undef_to_ident(oldmin) )
	let( max = undef_to_ident(oldmax) )
	let( negative_infinity = undef )
	let( infinity = undef )
	let( findminmax = function(list, extractor=function(item) item[0], curmin=negative_infinity, curmax=infinity, index=0)
		len(list) == index ? [curmin, curmax] :
		let( cur = extractor(list[index]) )
		findminmax(list, extractor, min(curmin, cur), max(curmax, cur), index+1)
	)
	findminmax([[-30],[10],[27],[99],[-5]]);

echo(minmax=minmax);
