import {
  Cbor,
  Certificate,
  HashTree,
  reconstruct,
  compare,
  lookupResultToBuffer,
  LookupResultAbsent,
  LookupResultFound,
  LookupResultUnknown,
  LookupResult
} from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { PipeArrayBuffer, lebDecode } from '@dfinity/candid';
import { CertificateTimeError, CertificateVerificationError } from './vererrs';

import { decodeTime as lebDecodeTime } from '@dfinity/agent/lib/cjs/utils/leb';

export interface VerifyCertificationParams {
  canisterId: Principal;
  encodedCertificate: ArrayBuffer;
  encodedTree: ArrayBuffer;
  rootKey: ArrayBuffer;
  maxCertificateTimeOffsetMs: number;
}

export async function verifyCertification({
  canisterId,
  encodedCertificate,
  encodedTree,
  rootKey,
  maxCertificateTimeOffsetMs,
}: VerifyCertificationParams): Promise<HashTree> {
  const nowMs = Date.now();
  console.log("creating certificate");
  const certificate = await Certificate.create({
    certificate: encodedCertificate,
    canisterId,
    rootKey,
  });
  console.log("certificate created");
  const tree = Cbor.decode<HashTree>(encodedTree);

  validateCertificateTime(certificate, maxCertificateTimeOffsetMs, nowMs);
  await validateTree(tree, certificate, canisterId);

  return tree;
}

function validateCertificateTime(
  certificate: Certificate,
  maxCertificateTimeOffsetMs: number,
  nowMs: number,
): void {
  let lookup = certificate.lookup(['time']);
  if(!lookup) throw new Error("lookup not found");
  if(!("byteLenth" in lookup)) throw new Error("lookup byteLength not found");
  
  let lebbuffer = lookupResultToBuffer(lookup);
  if(!lebbuffer) throw new Error("lebbuffer not found");

  let x = lebDecodeTime(lebbuffer) ;
  if(!x) throw new Error("x not found");

  const certificateTimeNs = BigInt(x.getUTCDate() * 1_000_000);

  const certificateTimeMs = Number(certificateTimeNs / BigInt(1_000_000));

  if (certificateTimeMs - maxCertificateTimeOffsetMs > nowMs) {
    throw new CertificateTimeError(
      `Invalid certificate: time ${certificateTimeMs} is too far in the future (current time: ${nowMs})`,
    );
  }

  if (certificateTimeMs + maxCertificateTimeOffsetMs < nowMs) {
    throw new CertificateTimeError(
      `Invalid certificate: time ${certificateTimeMs} is too far in the past (current time: ${nowMs})`,
    );
  }
}

export async function validateTree(
  tree: HashTree,
  certificate: Certificate,
  canisterId: Principal,
): Promise<void> {
  const treeRootHash = await reconstruct(tree);
  const certifiedData = certificate.lookup([
    'canister',
    canisterId.toUint8Array(),
    'certified_data',
  ]);

  console.log("certifiedData", certifiedData);
  console.log("treeRootHash", treeRootHash);

  if (!certifiedData) {
    throw new CertificateVerificationError(
      'Could not find certified data in the certificate.',
    );
  };

  if(!("value" in certifiedData)) throw new Error("certifiedData is not Found");

  if(!(certifiedData.value instanceof ArrayBuffer)) throw new Error("certifiedData is not ArrayBuffer");

  if (!equal(certifiedData.value, treeRootHash)) {
    throw new CertificateVerificationError(
      'Tree root hash did not match the certified data in the certificate.',
    );
  }
}

function equal(a: ArrayBuffer, b: ArrayBuffer): boolean {
  return compare(a, b) === 0;
}