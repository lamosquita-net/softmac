// Plan B: ¿un CRX firmado con lib/crx.js del empaquetador (Node puro, sin navegador) lo acepta FlyWeb 1.57?
// Verificador: verificador-157.mjs (port de VerifyCrx3 de Chromium 116 con el parche de Brave 1.57).
// Claves RSA-2048 DESECHABLES en un directorio temporal que se borra al terminar. Uso: PACKAGER=<checkout> node …
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { verifyCrx3, sha, spki, crxIdToAscii } from './verificador-157.mjs'
const crx = (await import(path.join(process.env.PACKAGER, 'lib/crx.js'))).default

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
