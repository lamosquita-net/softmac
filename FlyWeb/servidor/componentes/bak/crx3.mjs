// Firma CRX3 sin dependencias (solo crypto de Node), con prueba de publicador. Mismo formato que
// components/crx_file (crx3.proto) de Chromium 116; comprobado con pruebas/verificador-157.mjs.
import crypto from 'crypto'

const varint = (n) => { const b = []; while (n > 0x7f) { b.push((n & 0x7f) | 0x80); n = Math.floor(n / 128) } b.push(n); return Buffer.from(b) }
const campo = (num, datos) => Buffer.concat([varint(num * 8 + 2), varint(datos.length), datos])

export const spki = (pem) => crypto.createPublicKey(pem).export({ type: 'spki', format: 'der' })
export const idDe = (der) => [...crypto.createHash('sha256').update(der).digest('hex').slice(0, 32)]
  .map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')

// zip: el archivo del componente. claveComponente y clavesPublicador: claves privadas PEM.
export function firmarCrx (zip, claveComponente, clavesPublicador) {
  const der = spki(claveComponente)
  const crxId = crypto.createHash('sha256').update(der).digest().subarray(0, 16)
  const firmado = campo(1, crxId) // SignedData { crx_id }
  const tam = Buffer.alloc(4); tam.writeUInt32LE(firmado.length)
  const mensaje = Buffer.concat([Buffer.from('CRX3 SignedData\x00', 'latin1'), tam, firmado, zip])
  const pruebas = [claveComponente, ...clavesPublicador].map((k) => campo(2, Buffer.concat([ // sha256_with_rsa
    campo(1, spki(k)),
    campo(2, crypto.sign('sha256', mensaje, { key: k, padding: crypto.constants.RSA_PKCS1_PADDING }))
  ])))
  const cabecera = Buffer.concat([...pruebas, campo(10000, firmado)])
  const pre = Buffer.alloc(12); pre.write('Cr24', 0, 'latin1'); pre.writeUInt32LE(3, 4); pre.writeUInt32LE(cabecera.length, 8)
  return Buffer.concat([pre, cabecera, zip])
}
