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

// Verificación CRX3 como VerifyCrx3 de Chromium 116 (components/crx_file/crx_verifier.cc), para los CRX ajenos
// (los de Google, F2.2): todas las firmas (RSA o ECDSA) deben ser válidas, el crx_id declarado debe ser `id`, una
// prueba debe llevar la clave de ese ID y otra la del publicador (hash SHA-256 de su SPKI, en hex). Devuelve null
// si es válido, o el motivo.
const leerVarint = (b, i) => {
  let r = 0; let m = 1
  for (let n = 0; n < 5; n++) { if (i >= b.length) throw new Error('protobuf truncado'); const c = b[i++]; r += (c & 0x7f) * m; if (c < 0x80) return [r, i]; m *= 128 }
  throw new Error('varint demasiado largo')
}
const leerCampos = (b) => {
  const o = []; let i = 0
  while (i < b.length) {
    let k; [k, i] = leerVarint(b, i); const t = k % 8; const f = Math.floor(k / 8)
    if (t === 2) { let n; [n, i] = leerVarint(b, i); if (i + n > b.length) throw new Error('protobuf truncado'); o.push([f, b.subarray(i, i + n)]); i += n } else if (t === 0) { let v; [v, i] = leerVarint(b, i); o.push([f, v]) } else throw new Error(`protobuf: tipo ${t}`)
  }
  return o
}
const sha = (b) => crypto.createHash('sha256').update(b).digest()
export function verificarCrx (crx, id, publicadorSha256) {
  try {
    if (crx.length < 12 || crx.subarray(0, 4).toString('latin1') !== 'Cr24' || crx.readUInt32LE(4) !== 3) return 'no es CRX3'
    const tam = crx.readUInt32LE(8); if (12 + tam > crx.length) return 'cabecera truncada'
    const cabecera = leerCampos(crx.subarray(12, 12 + tam)); const archivo = crx.subarray(12 + tam)
    const firmados = cabecera.filter(([f]) => f === 10000).map(([, v]) => v)
    if (firmados.length !== 1 || !Buffer.isBuffer(firmados[0])) return 'sin signed_header_data'
    const crxId = Buffer.concat(leerCampos(firmados[0]).filter(([f, v]) => f === 1 && Buffer.isBuffer(v)).map(([, v]) => v))
    const declarado = [...crxId.toString('hex')].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')
    if (declarado !== id) return `crx_id declarado ${declarado || '(vacío)'}, se esperaba ${id}`
    const t = Buffer.alloc(4); t.writeUInt32LE(firmados[0].length)
    const mensaje = Buffer.concat([Buffer.from('CRX3 SignedData\x00', 'latin1'), t, firmados[0], archivo])
    let deId = false; let dePublicador = false
    for (const [f, v] of cabecera.filter(([f]) => f === 2 || f === 3)) {
      if (!Buffer.isBuffer(v)) return 'prueba mal formada'
      const p = leerCampos(v); const clave = p.find(([n]) => n === 1)?.[1]; const firma = p.find(([n]) => n === 2)?.[1]
      if (!Buffer.isBuffer(clave) || !Buffer.isBuffer(firma)) return 'prueba sin clave o firma'
      const h = sha(clave)
      if (h.subarray(0, 16).equals(crxId)) deId = true
      if (h.toString('hex') === publicadorSha256) dePublicador = true
      const k = crypto.createPublicKey({ key: clave, format: 'der', type: 'spki' })
      if (k.asymmetricKeyType !== (f === 2 ? 'rsa' : 'ec')) return 'tipo de clave incorrecto'
      const ok = crypto.verify('sha256', mensaje, f === 2 ? { key: k, padding: crypto.constants.RSA_PKCS1_PADDING } : { key: k, dsaEncoding: 'der' }, firma)
      if (!ok) return 'firma no válida'
    }
    if (!deId) return 'falta la prueba de la clave del componente'
    if (!dePublicador) return 'falta la prueba del publicador'
    return null
  } catch (e) { return `CRX mal formado: ${e.message}` }
}
