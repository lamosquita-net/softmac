// Plan B: ¿un CRX firmado con lib/crx.js del empaquetador (Node puro, sin navegador) lo acepta FlyWeb 1.57?
// Verificador: port independiente de VerifyCrx3 de Chromium 116.0.5845.188
// (components/crx_file/crx_verifier.cc) con el parche de Brave 1.57 (IsBravePublisher), que es lo que exige el
// actualizador de componentes (CRX3_WITH_PUBLISHER_PROOF, chromium_src/components/component_updater/).
// Claves RSA-2048 DESECHABLES en un directorio temporal que se borra al terminar. Uso: PACKAGER=<checkout> node …
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
const crx = (await import(path.join(process.env.PACKAGER, 'lib/crx.js'))).default

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
const sha = (x) => crypto.createHash('sha256').update(x).digest()
const spki = (pem) => crypto.createPublicKey(pem).export({ type: 'spki', format: 'der' })
const crxIdToAscii = (b) => [...b.toString('hex')].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')

// required: hash de la clave del componente (lo que registra el instalador); publisher: hash del publicador.
function verifyCrx3 (d, required, publisher) {
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

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-crx-'))
let fallos = 0
try {
  const key = (n) => {
    const { privateKey } = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 })
    const pem = privateKey.export({ type: 'pkcs8', format: 'pem' })
    fs.writeFileSync(path.join(tmp, n), pem, { mode: 0o600 }); return pem
  }
  const ext = key('ext.pem'); const pub = key('pub.pem'); const otra = key('otra.pem')
  const stage = path.join(tmp, 'stage'); fs.mkdirSync(stage)
  fs.writeFileSync(path.join(stage, 'manifest.json'), '{"manifest_version":2,"name":"prueba","version":"1.0.1"}')
  fs.writeFileSync(path.join(stage, 'list.txt'), '||doubleclick.net^\n')
  const build = async (pubs) => (await crx.generateCrx(stage, path.join(tmp, 'ext.pem'), pubs.map((p) => path.join(tmp, p)), null)).crx

  const conPub = await build(['pub.pem'])
  const manip = Buffer.from(conPub); manip[manip.length - 30] ^= 1
  const id = crxIdToAscii(sha(spki(ext)).subarray(0, 16))
  const casos = [
    ['con publicador', conPub, ext, 'OK_FULL ' + id],
    ['sin publicador', await build([]), ext, 'ERROR_REQUIRED_PROOF_MISSING (publicador)'],
    ['publicador ajeno', await build(['otra.pem']), ext, 'ERROR_REQUIRED_PROOF_MISSING (publicador)'],
    ['un byte cambiado', manip, ext, 'ERROR_SIGNATURE_VERIFICATION_FAILED'],
    ['otro componente', conPub, otra, 'ERROR_REQUIRED_PROOF_MISSING']
  ]
  for (const [nombre, d, req, esperado] of casos) {
    const r = verifyCrx3(d, sha(spki(req)), sha(spki(pub)))
    const ok = r === esperado; fallos += !ok
    console.log(`${ok ? 'ok  ' : 'FALLO'} ${nombre.padEnd(18)} ${r}`)
  }
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}
process.exit(fallos ? 1 : 0)
