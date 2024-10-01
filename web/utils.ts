import { t } from 'vitest/dist/types-198fd1d9.js';
import { Principal } from '@dfinity/principal';

import {DataItemMap,  DataItem } from '../src/declarations/icrc75/icrc75.did.js';

  export function dataItemStringify(key, value) {
    if (typeof value === 'bigint') {
      return value.toString();
    } else if (key === 'Blob' && value instanceof Uint8Array) {
      return Array.from(value).map(byte => byte.toString(16).padStart(2, '0')).join('');
    } else if (key === 'Principal' && value instanceof Object) {
      return value.__principal__;
    } else {
      return value;
    }
  };

  export function dataItemReviver(key, value) {

    if (key === 'Blob' && typeof key === 'string') {
      if (isHex(value)) {
        // Convert hex string to Uint8Array
        const hex = value;
        const bytes = new Uint8Array(hex.length / 2);
        for (let i = 0; i < hex.length; i += 2) {
          bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }
        return bytes;
      } else {
        // Convert base64 string to Uint8Array
        return Uint8Array.from(atob(value), c => c.charCodeAt(0));
      }
    } else if (key === 'Principal' && typeof value === 'string') {
      return Principal.fromText(value);
    } else if ((key === 'Nat' || key==='Int' || key==="Nat64" || key==="Int64") && typeof value === 'string') {
      return BigInt(value);
    } else {
      return value;
    };
  };

  export function validateMetadata(metadataStr: string, bAlert: boolean): DataItemMap{
  // The metadata should be a JSON object that gets converted to a candid submission.
  // Variants become an object of {variant: value}
  // Nulls are represented as an empty array []. An opt Nat would be [1n].
  // This particular item is an array of candid (Text, Value) tuples.
  // These candid tuples (Text, Value) are represented as an Array in JSON [Text, Value]

  // The candid type for a Value is:
  // type DataItem__1 = 
  // variant {
  //   Array: vec DataItem__1;
  //   Blob: blob;
  //   Bool: bool;
  //   Bytes: vec nat8;
  //   Class: vec PropertyShared__1;
  //   Float: float64;
  //   Floats: vec float64;
  //   Int: int;
  //   Int16: int16;
  //   Int32: int32;
  //   Int64: int64;
  //   Int8: int8;
  //   Ints: vec int;
  //   Map: DataItemMap__1;
  //   Nat: nat;
  //   Nat16: nat16;
  //   Nat32: nat32;
  //   Nat64: nat64;
  //   Nat8: nat8;
  //   Nats: vec nat;
  //   Option: opt DataItem__1;
  //   Principal: principal;
  //   Set: vec DataItem__1;
  //   Text: text;
  //   ValueMap: vec record {
  //                 DataItem__1;
  //                 DataItem__1;
  //               };
  // };

  // Validate the metadata string

  let valid = parseMetadata(metadataStr, bAlert);

  console.log("got a valid", valid, metadataStr);

  if (!valid) {
    if (bAlert) {
      alert('Invalid metadata format');
    }
    throw new Error('Invalid metadata format');
  };

  let json = JSON.parse(metadataStr, dataItemReviver);


  return json;

};

export function validateValueAsString(metadataStr: string, bAlert: boolean): DataItem{
  // The metadata should be a JSON object that gets converted to a candid submission.
  // Variants become an object of {variant: value}
  // Nulls are represented as an empty array []. An opt Nat would be [1n].
  // This particular item is an array of candid (Text, Value) tuples.
  // These candid tuples (Text, Value) are represented as an Array in JSON [Text, Value]

  // The candid type for a Value is:
  // type DataItem__1 = 
  // variant {
  //   Array: vec DataItem__1;
  //   Blob: blob;
  //   Bool: bool;
  //   Bytes: vec nat8;
  //   Class: vec PropertyShared__1;
  //   Float: float64;
  //   Floats: vec float64;
  //   Int: int;
  //   Int16: int16;
  //   Int32: int32;
  //   Int64: int64;
  //   Int8: int8;
  //   Ints: vec int;
  //   Map: DataItemMap__1;
  //   Nat: nat;
  //   Nat16: nat16;
  //   Nat32: nat32;
  //   Nat64: nat64;
  //   Nat8: nat8;
  //   Nats: vec nat;
  //   Option: opt DataItem__1;
  //   Principal: principal;
  //   Set: vec DataItem__1;
  //   Text: text;
  //   ValueMap: vec record {
  //                 DataItem__1;
  //                 DataItem__1;
  //               };
  // };

  // Validate the metadata string

  try {
    let item = JSON.parse(metadataStr, dataItemReviver);
   
    
    let valid = validateValue(item);
    

    console.log("got a valid", valid, metadataStr);

    if (!valid) {
      if (bAlert) {
        alert('Invalid value format');
      }
      throw new Error('Invalid value format');
    };

    return JSON.parse(metadataStr, dataItemReviver);
  } catch (error) {
    if (bAlert) {
      alert('Invalid value format');
    }
    throw new Error('Invalid value format');
  };

};

export function isHex(str: string): boolean{
  return /^[0-9a-fA-F]+$/.test(str);
};

export function validateValue(value: DataItem): boolean {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const keys = Object.keys(value);
  if (keys.length !== 1) {
    return false;
  }

  const key: keyof DataItem = keys[0] as keyof DataItem;
  const val: DataItem[keyof DataItem] = value[key];

  console.log("key", key, "val", val, value);

  switch (key) {
    case 'Array':
    case 'Class':
    case 'Set':
      let anArray : DataItem[] = val as DataItem[];
      return Array.isArray(val) && anArray.every(validateValue);
    case 'Blob':
      // Validate for base64 string
      if (!(val as any instanceof Uint8Array)) {
        return false;
      }
      return true;
    case 'Bool':
      return typeof val === 'boolean';
    case 'Bytes':
      return Array.isArray(val) && (val as any[]).every((item: any) => typeof item === 'number' && item >= 0 && item <= 255);
    case 'Float':
    return typeof val === 'number';
    case 'Floats':
    return Array.isArray(val) && (val as any[]).every((item: any) => typeof item === 'number');
    case 'Int':
      return typeof val === 'bigint';
    case 'Int16':
      return typeof val === 'number' && Number.isInteger(val) && val >= -32768 && val <= 32767;
    case 'Int32':
      return typeof val === 'number' && Number.isInteger(val) && val >= -2147483648 && val <= 2147483647;
    case 'Int64':
      return typeof val === 'bigint' && val >= BigInt(-9223372036854775808) && val <= BigInt(9223372036854775807);
    case 'Int8':
      return typeof val === 'number' && Number.isInteger(val) && val >= -128 && val <= 127;
    case 'Nat':
      return typeof val === 'bigint' && val >= 0n;
    case 'Nat16':
      return typeof val === 'number' && Number.isInteger(val) && val >= 0 && val <= 65535;
    case 'Nat32':
      return typeof val === 'number' && Number.isInteger(val) && val >= 0 && val <= 4294967295;
    case 'Nat64':
      return typeof val === 'bigint' && val >= BigInt(0) && val <= BigInt(18446744073709551615);
    case 'Nat8':
      return typeof val === 'number' && Number.isInteger(val) && val >= 0 && val <= 255;
    case 'Ints':
    case 'Nats':
    return Array.isArray(val) && (val as any[]).every((item: any) => typeof item === 'number');
    case 'Map':
    return Array.isArray(val) && (val as any[]).every((item: any) => Array.isArray(item) && item.length === 2 && typeof item[0] === 'string' && validateValue(item[1]));
    case 'Option':
    return Array.isArray(val) && ((val as any[]).length === 0 || ((val as any[]).length === 1 && validateValue((val as any[])[0])));
    case 'Principal':
     return val as any instanceof Principal;
    case 'Text':
    return typeof val === 'string';
    case 'ValueMap':
    return Array.isArray(val) && (val as any[]).every((item: any) => Array.isArray(item) && item.length === 2 && validateValue(item[0]) && validateValue(item[1]));
    default:
      return false;
  }
};

export function parseMetadata(metadataStr: string, bAlert: boolean): boolean {
  try {
    let items = JSON.parse(metadataStr, dataItemReviver);
    //let aMap: DataItemMap = [];
    /* for (let key in items) {
      console.log("key", key, "items[key]", items[key]);
      if (typeof items[key] === 'string') {
        console.log("pushing", key, items[key]);
        aMap.push([key, { Text: items[key] }]);
      }
    } */

      console.log("items from parser", items);
    
    let valid = validateValue({ Map : items});
    
    return valid;
  } catch (error) {
    return false;
  };


  
};