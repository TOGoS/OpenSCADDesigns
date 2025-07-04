// Muchly borrowed from TSHash.

type Bytesable = string|Uint8Array|ArrayBuffer;

export function asciiEncode(str:string, maxAllowed=127):Uint8Array {
	const data = new Uint8Array(str.length);
	for( let i=0; i < str.length; ++i ) {
		const cp = str.charCodeAt(i);
		if( cp > maxAllowed ) throw new Error("Code point is >"+maxAllowed+": "+cp);
		data[i] = cp;
	}
	return data;
}

export function utf8Encode(str:string):Uint8Array {
	if( str.length == 0 ) return new Uint8Array(0);
	
	if( typeof TextEncoder != 'undefined' ) {
		return (new TextEncoder()).encode(str);
	}
	
	// Otherwise fall back to the ASCII encoder and hope that it's good enough.
	return asciiEncode(str);
}

export function toUint8Array(data:Bytesable):Uint8Array {
	if( data instanceof Uint8Array ) {
		return data;
	} else if( typeof(data) == 'string' ) {
		return utf8Encode(data);
	} else if( data instanceof ArrayBuffer ) {
		return new Uint8Array(data);
	} else {
		throw new Error("Don't know how to convert "+JSON.stringify(data)+" to Uint8Array");
	}
}


export async function toUint8Array2(data:Bytesable|Blob):Promise<Uint8Array> {
	if( data instanceof Blob ) {
		data = await data.arrayBuffer();
	}
	if( data instanceof Uint8Array ) {
		return data;
	} else if( typeof(data) == 'string' ) {
		return utf8Encode(data);
	} else if( data instanceof ArrayBuffer ) {
		return new Uint8Array(data);
	} else {
		throw new Error("Don't know how to convert "+JSON.stringify(data)+" to Uint8Array");
	}
}
