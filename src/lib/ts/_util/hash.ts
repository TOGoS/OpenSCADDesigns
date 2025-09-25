import * as stdHash from 'https://deno.land/std@0.119.0/hash/mod.ts';
import { toUint8Array } from './bufutil.ts';
import * as base32 from './base32.ts';

type Hash = Uint8Array;
type Digestable = string|Uint8Array|ArrayBuffer;

class UnrecognizedScheme extends Error { }

export interface Hasher {
  update(data: Digestable): this;
  digest(): Uint8Array;
  toString(): string;
}

export function createHash(name:stdHash.SupportedAlgorithm) {
		// 2025-09-04: Something in the library changed (angry face)
	// so that things that previously were okay no longer type check.
	// In practice, the Hashers created by std@0.119.0 createHash
	// are compatible with this usage:
	return stdHash.createHash(name) as any as Hasher;
}

type PostSectorPath = string;

export interface HashAlgorithm {
	createHasher() : Hasher;
	getPostSectorPath(hash:Hash) : PostSectorPath;
	getUrn(hash:Hash) : string;
	decodeUrn(urn:string) : Hash;
}

export class TreeHasher implements Hasher {
	protected buffer:Uint8Array;
	protected bufferOffset = 1;
	protected blockCount = 0;
	protected nodes:Uint8Array[] = [];
	constructor(
		protected blockSize:number,
		protected hashSize:number,
		protected blockHashFunction: (block:Uint8Array) => Uint8Array
	) {
		this.buffer = new Uint8Array(blockSize+1);
		this.buffer[0] = 0; // 0 means leaf
	}

	protected appendToBuffer(stuff:Uint8Array) : void {
		if( stuff.length + this.bufferOffset > this.buffer.length ) {
			throw new Error("appendToBuffer passed more than will fit in the block!");
		}
		this.buffer.set(stuff, this.bufferOffset);
		this.bufferOffset += stuff.length;
	}

	public update(data: Digestable) : this {
		let datarr = toUint8Array(data);
		
		let remainingInBlock;
		while( datarr.length >= (remainingInBlock = this.buffer.length - this.bufferOffset) ) {
			this.appendToBuffer(datarr.subarray(0, remainingInBlock));
			this.blockUpdate();
			this.bufferOffset = 1;
			datarr = datarr.subarray(remainingInBlock);
		}
		this.appendToBuffer(datarr);

		return this;
	}

	protected processBlock(block:Uint8Array) : Uint8Array {
		const hash = this.blockHashFunction(block);
		if( hash.length != this.hashSize ) {
			throw new Error(`Length of hash (${hash.length} bytes) did not match expected (${this.hashSize})`);
		}
		// If we wanted to store [non-leaf] blocks, we could do that here.
		return hash;
	}

	protected blockUpdate() {
		this.nodes.push(
			this.processBlock(
				this.bufferOffset == this.buffer.length ? this.buffer : this.buffer.subarray(0, this.bufferOffset)
			)
		);
		++this.blockCount;
		let interimNode = this.blockCount;
		while( (interimNode % 2) == 0 ) {
			this.composeNodes();
			interimNode >>= 1;
		}
	}

	protected composeNodes() {
		const right = this.nodes.pop();
		const left = this.nodes.pop();
		if( left == undefined || right == undefined ) {
			throw new Error("Node underflow in TreeHasher#composeNodes()");
		}
		const block = new Uint8Array(1+this.hashSize*2);
		block[0] = 1; // 1 means internal node
		block.set(left, 1);
		block.set(right, 1+this.hashSize);
		this.nodes.push(this.processBlock(block));
	}

	public digest() : Uint8Array {
		if(this.bufferOffset > 1 || this.nodes.length == 0 ) {
			this.blockUpdate();
		}
		while( this.nodes.length > 1 ) {
			this.composeNodes();
		}
		return this.nodes[0];
	}
}

export class BitprintHasher implements Hasher {
	protected shasher : Hasher = createHash("sha1");
	protected tthasher : Hasher = new TreeHasher(1024, 24, (block:Uint8Array) => {
		const tigerHash = createHash("tiger");
		tigerHash.update(block);
		return new Uint8Array(tigerHash.digest());
	});

	public update(data: Digestable) : this {
		this.shasher.update(data);
		this.tthasher.update(data);
		return this;
	}

	public digest() {
		const bitprint = new Uint8Array(44);
		bitprint.set(new Uint8Array(this.shasher.digest()), 0);
		bitprint.set(new Uint8Array(this.tthasher.digest()), 20);
		return bitprint;
	}
}

export const SHA1_ALGORITHM : HashAlgorithm = {
	createHasher() : Hasher {
		return createHash("sha1");
	},
	getPostSectorPath(data:Hash) {
		const b32 = base32.encode(data);
		return b32.substr(0,2) + "/" + b32;
	},
	getUrn(data:Hash) {
		return "urn:sha1:" + base32.encode(data);
	},
	decodeUrn(urn:string) : Hash {
		const m = /^urn:(?:sha1|bitprint):([a-zA-Z2-7]{32})/.exec(urn);
		if( m == undefined ) throw new UnrecognizedScheme(`Can't decode '${urn}' as SHA-1 URN`);
		return base32.decode(m[1]);
	}
};

export const BITPRINT_ALGORITHM : HashAlgorithm = {
	createHasher() : Hasher {
		return new BitprintHasher();
	},
	getPostSectorPath(data:Hash) {
		const b32 = base32.encode(data.slice(0,20));
		return b32.substr(0,2) + "/" + b32;
	},
	getUrn(data:Hash) {
		return "urn:bitprint:" + base32.encode(data.subarray(0, 20)) + "." + base32.encode(data.subarray(20, 44));
	},
	decodeUrn(urn:string) : Hash {
		const m = /^urn:bitprint:([a-zA-Z2-7]{32})\.([a-zA-Z2-7]{39})/.exec(urn);
		if( m == undefined ) throw new UnrecognizedScheme(`Can't decode '${urn}' as bitprint URN`);
		const bitprint = new Uint8Array(44);
		bitprint.set(base32.decode(m[1]),  0);
		bitprint.set(base32.decode(m[2]), 20);
		return bitprint;
	}
}
