// Import necessary modules or libraries
// Note: You'll need to install appropriate libraries for SHA256 hashing and BigInt support if not already available.
import { compare } from '@dfinity/agent';

// Define the Value type
type Value = { 'Int' : bigint } |
{ 'Map' : Array<[string, Value]> } |
{ 'Nat' : bigint } |
{ 'Blob' : Uint8Array | number[] } |
{ 'Text' : string } |
{ 'Array' : Array<Value> };

// Function to compute the SHA256 hash of a Value
export function hash_val(v: Value): Uint8Array {
  const encoded = encode_val(v);
  return sha256(encoded);
}

// Function to encode a Value into a Uint8Array
function encode_val(v: Value): Uint8Array {
  if("Int" in v) {
    return sleb128_encode(v.Int);
  } else if("Map" in v) {
    const entries = v.Map.map(([k, val]) => {
      const keyHash = hash_val({  "Text": k });
      const valHash = hash_val(val);
      return concat_arrays(keyHash, valHash);
    });
    // Sort entries lexicographically
    entries.sort(compareUint8Arrays);
    return array_concat(entries);
  } else if("Nat" in v) {
    return  leb128_encode(v.Nat);  
  } else if("Blob" in v) {
    return v.Blob instanceof Uint8Array ? v.Blob : new Uint8Array(v.Blob);
  } else if("Text" in v) {
    return new TextEncoder().encode(v.Text);
  } else if("Array" in v) {
    const hashes = v.Array.map(hash_val);
    return array_concat(hashes);
  } else {
    throw new Error("Unknown value kind");
  };

    
};

export function equalBuffers(a: ArrayBuffer, b: ArrayBuffer): boolean {
  return compare(a, b) === 0;
}

// Function to encode a BigInt as LEB128
function leb128_encode(value: bigint): Uint8Array {
  const bytes = [];
  let n = value;
  while (true) {
    let byte = Number(n & 0x7fn);
    n >>= 7n;
    if (n === 0n) {
      bytes.push(byte);
      break;
    } else {
      bytes.push(byte | 0x80);
    }
  }
  return Uint8Array.from(bytes);
}

//encode big endian for a bigint
export function big_endian_encode(value: bigint): Uint8Array {
  const bytes = [];
  let n = value;
  while (n > 0) {
    bytes.push(Number(n & 0xffn));
    n >>= 8n;
  }
  return Uint8Array.from(bytes.reverse());
};


// Function to encode a BigInt as signed LEB128
function sleb128_encode(value: bigint): Uint8Array {
  const bytes = [];
  let more = true;
  let n = value;

  while (more) {
    let byte = Number(n & 0x7fn);
    n >>= BigInt(7);

    const signBit = (byte & 0x40) !== 0;

    if (
      (n === BigInt(0) && !signBit) ||
      (n === BigInt(-1) && signBit)
    ) {
      more = false;
    } else {
      byte |= 0x80;
    }

    bytes.push(byte);
  }

  return Uint8Array.from(bytes);
}

// Helper function to concatenate an array of Uint8Arrays
function array_concat(arrays: Uint8Array[]): Uint8Array {
  let totalLength = arrays.reduce((sum, arr) => sum + arr.length, 0);
  const result = new Uint8Array(totalLength);
  let offset = 0;
  for (const arr of arrays) {
    result.set(arr, offset);
    offset += arr.length;
  }
  return result;
}

// Helper function to concatenate two Uint8Arrays
function concat_arrays(a: Uint8Array, b: Uint8Array): Uint8Array {
  const result = new Uint8Array(a.length + b.length);
  result.set(a, 0);
  result.set(b, a.length);
  return result;
}

// Helper function to compare two Uint8Arrays lexicographically
function compareUint8Arrays(a: Uint8Array, b: Uint8Array): number {
  const len = Math.min(a.length, b.length);
  for (let i = 0; i < len; i++) {
    if (a[i] !== b[i]) {
      return a[i] - b[i];
    }
  }
  return a.length - b.length;
}

// Placeholder for SHA256 hash function
function sha256(data: Uint8Array): Uint8Array {
  // Implementation depends on environment
  // For Node.js:
  // const crypto = require('crypto');
  // return crypto.createHash('sha256').update(data).digest();
  // For browser:
  // return crypto.subtle.digest('SHA-256', data);
  throw new Error("sha256 function not implemented");
}

// Function equivalent to 'h' in Motoko code
function h(b1: Uint8Array): Uint8Array {
  return sha256(b1);
}
