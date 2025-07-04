import { toUint8Array } from './bufutil.ts';

type Bytesable = string|Uint8Array|ArrayBuffer;

//// Base32 encoding/decoding

const BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
const BASE32_CHAR_VALUES:number[] =	[
	0xFF,0xFF,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F, // '0', '1', '2', '3', '4', '5', '6', '7'
	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, // '8', '9', ':', ';', '<', '=', '>', '?'
	0xFF,0x00,0x01,0x02,0x03,0x04,0x05,0x06, // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
	0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E, // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
	0x0F,0x10,0x11,0x12,0x13,0x14,0x15,0x16, // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
	0x17,0x18,0x19,0xFF,0xFF,0xFF,0xFF,0xFF, // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
	0xFF,0x00,0x01,0x02,0x03,0x04,0x05,0x06, // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
	0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E, // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
	0x0F,0x10,0x11,0x12,0x13,0x14,0x15,0x16, // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
	0x17,0x18,0x19,0xFF,0xFF,0xFF,0xFF,0xFF  // 'x', 'y', 'z', '{', '|', '}', '~', 'DEL'
];

/* 
 * Base32 - encodes and decodes RFC3548 Base32
 * (see http://www.faqs.org/rfcs/rfc3548.html )
 * 
 * Based on Java code by Bitzi (PD) 2006.
 * 
 * @author Robert Kaye
 * @author Gordon Mohr
 * @author TOGoS (converted to TypeScript)
 */

/**
 * Encodes byte array to Base32 String.
 *
 * @param {Uint8Array} bytes - bytes to encode.
 * @return {string}
 */
export function encode(thing:Bytesable):string {
	const bytes:Uint8Array = toUint8Array(thing);
	let i = 0, j = 0, index = 0, digit = 0;
	let currByte:number, nextByte:number;
	
	const base32:string[] = new Array<string>( Math.floor((bytes.length + 7) * 8 / 5) );
	
	while( i < bytes.length ) {
		currByte = bytes[i];
		
		/* Is the current digit going to span a byte boundary? */
		if( index > 3 ) {
			nextByte = (i + 1) < bytes.length ? bytes[i + 1] : 0;
			
			digit = currByte & (0xFF >> index);
			index = (index + 5) % 8;
			digit <<= index;
			digit |= nextByte >> (8 - index);
			++i;
		} else {
			digit = (currByte >> (8 - (index + 5))) & 0x1F;
			index = (index + 5) % 8;
			if( index == 0 ) ++i;
		}
		
		base32[j++] = BASE32_CHARS.charAt(digit);
	}
	
	return base32.slice(0,j).join('');
}

/**
 * Decodes the given Base32 String to a raw byte array.
 * 
 * @param {string|Uint8Array|DataBuffer} base32-encoded data
 * @return {Uint8Array} decoded data
 */
export function decode(base32:string):Uint8Array {
	let i:number, index:number, lookup:number, offset:number, digit:number;
	const bytes = new Uint8Array( Math.floor(base32.length * 5 / 8) );
	const firstCharCode = "0".charCodeAt(0);
	
	for( i = 0, index = 0, offset = 0; i < base32.length; ++i ) {
		lookup = base32.charCodeAt(i) - firstCharCode;
		
		/* Skip chars outside the lookup table */
		if( lookup < 0 || lookup >= BASE32_CHAR_VALUES.length ) continue;
		
		digit = BASE32_CHAR_VALUES[lookup];
		
		/* If this digit is not in the table, ignore it */
		if( digit == 0xFF ) continue;
		
		if( index <= 3 ) {
			index = (index + 5) % 8;
			if( index == 0 ) {
				bytes[offset++] |= digit;
				if( offset >= bytes.length ) break;
			} else {
				bytes[offset] |= digit << (8 - index);
			}
		} else {
			index = (index + 5) % 8;
			bytes[offset] |= (digit >>> index);
			offset++;
			
			if( offset >= bytes.length ) break;
			
			bytes[offset] |= digit << (8 - index);
		}
	}
	return bytes;
}
