import { describe, it, expect, vi } from 'vitest';
import { validateMetadata, dataItemReviver, dataItemStringify } from '../utils';

describe('validateMetadata', () => {
  it('should return a valid DataItemMap for valid metadata string', () => {
    const validMetadataStr = JSON.stringify([
      ["key1", { Text: "value1" }],
      ["key2", { Int: 123n }],
      ["key3", { Bool: true }],
      ["key4", { Blob: Uint8Array.from([0xaa, 0xbb, 0xcc]) }]
    ], dataItemStringify);

    console.log('validMetadataStr', validMetadataStr);

    const result = validateMetadata(validMetadataStr, false);

    console.log('result', result);

    expect(result).toEqual([
      ["key1", { Text: "value1" }],
      ["key2", { Int: 123n }],
      ["key3", { Bool: true }],
      ["key4", { Blob: Uint8Array.from([0xaa, 0xbb, 0xcc]) }]
    ]);
  });

  it('should throw an error for invalid metadata string', () => {
    const invalidMetadataStr = JSON.stringify([
      ["key1", { InvalidType: "value1" }]
    ]);

    console.log('invalidMetadataStr', invalidMetadataStr);

    expect(() => validateMetadata(invalidMetadataStr, false)).toThrow('Invalid metadata format');
  });

  it('should alert and throw an error for invalid metadata string when bAlert is true', () => {
    const invalidMetadataStr = JSON.stringify([
      ["key1",{ InvalidType: "value1" }]
    ]);

    global.alert = vi.fn();

    expect(() => validateMetadata(invalidMetadataStr, true)).toThrow('Invalid metadata format');
    expect(global.alert).toHaveBeenCalledWith('Invalid metadata format');
  });

  it('should throw an error for non-JSON metadata string', () => {
    const nonJsonMetadataStr = "not a json string";

    expect(() => validateMetadata(nonJsonMetadataStr, false)).toThrow('Invalid metadata format');
  });

  it('should alert and throw an error for non-JSON metadata string when bAlert is true', () => {
    const nonJsonMetadataStr = "not a json string";

    global.alert = vi.fn();

    expect(() => validateMetadata(nonJsonMetadataStr, true)).toThrow('Invalid metadata format');
    expect(global.alert).toHaveBeenCalledWith('Invalid metadata format');
  });
});