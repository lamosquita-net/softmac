// Port independiente de VerifyCrx3 de Chromium 116.0.5845.188 (components/crx_file/crx_verifier.cc) con el
// parche de Brave 1.57 (IsBravePublisher): lo que exige el actualizador de componentes de FlyWeb
// (CRX3_WITH_PUBLISHER_PROOF). No comparte código con ningún firmador.
import crypto from 'crypto'

const varint = (b, i) => {
  let r = 0n; let s = 0n
  for (;;) { const c = b[i++]; r |= BigInt(c & 0x7f) << s; s += 7n; if (c < 0x80) return [Number(r), i] }
}
const fields = (b) => {
  const o = []; let i = 0
  while (i < b.length) {
    let k; [k, i] = varint(b, i); const f = k >> 3; const t = k & 7
    if (t === 2) { let n; [n, i] = varint(b, i); o.push([f, b.subarray(i, i + n)]); i += n } else if (t === 0) { let v; [v, i] = varint(b, i); o.push([f, v]) } else throw new Error('wire ' + t)
  }
  return o
}
export const sha = (x) => crypto.createHash('sha256').update(x).digest()
export const spki = (pem) => crypto.createPublicKey(pem).export({ type: 'spki', format: 'der' })
export const crxIdToAscii = (b) => [...b.toString('hex')].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')

// required: hash de la clave del componente (lo que registra el instalador); publisher: hash del publicador.
export function verifyCrx3 (d, required, publisher) {
  if (d.subarray(0, 4).toString() !== 'Cr24' || d.readUInt32LE(4) !== 3) return 'ERROR_HEADER_INVALID'
  const hs = d.readUInt32LE(8); const archive = d.subarray(12 + hs)
  const h = fields(d.subarray(12, 12 + hs))
  const sh = Buffer.concat(h.filter(([f]) => f === 10000).map(([, v]) => v))
  const crxId = Buffer.concat(fields(sh).filter(([f]) => f === 1).map(([, v]) => v))
  const len = Buffer.alloc(4); len.writeUInt32LE(sh.length)
  let pendingRequired = !!required; let foundPublisher = false; let declared = false
  for (const [f, v] of h.filter(([f]) => f === 2 || f === 3)) {
    const p = Object.fromEntries(fields(v)); const kh = sha(p[1])
    if (kh.subarray(0, 16).equals(crxId)) declared = true
    if (required && kh.equals(required)) pendingRequired = false
    foundPublisher ||= kh.equals(publisher)
    const ok = f === 2 && crypto.verify('sha256',
      Buffer.concat([Buffer.from('CRX3 SignedData\x00', 'latin1'), len, sh, archive]),
      { key: crypto.createPublicKey({ key: p[1], format: 'der', type: 'spki' }), padding: crypto.constants.RSA_PKCS1_PADDING }, p[2])
    if (!ok) return 'ERROR_SIGNATURE_VERIFICATION_FAILED'
  }
  if (!declared || pendingRequired) return 'ERROR_REQUIRED_PROOF_MISSING'
  if (!foundPublisher) return 'ERROR_REQUIRED_PROOF_MISSING (publicador)'
  return 'OK_FULL ' + crxIdToAscii(crxId)
}
