// Prueba de bak/google.mjs sin red: un «Google» falso (respuestas y CRX fabricados aquí, con una clave de publicador
// ECDSA desechable, como la de Google). Comprueba que copia lo correcto y rechaza cada manipulación.
// Uso: node pruebas/google-bak.mjs
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { crearZip } from '../bak/zip.mjs'
import { espejoGoogle, GOOGLE, comparar, versionValida } from '../bak/google.mjs'

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-google-'))
const hex = (b) => crypto.createHash('sha256').update(b).digest('hex')
const der = (k) => crypto.createPublicKey(k).export({ type: 'spki', format: 'der' })
const idDe = (d) => [...hex(d).slice(0, 32)].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')
const varint = (n) => { const b = []; while (n > 0x7f) { b.push((n & 0x7f) | 0x80); n = Math.floor(n / 128) } b.push(n); return Buffer.from(b) }
const campo = (num, d) => Buffer.concat([varint(num * 8 + 2), varint(d.length), d])
let fallos = 0

// CRX3 como los de Google: prueba RSA del componente (campo 2) y prueba ECDSA del publicador (campo 3).
const crx = (zip, componente, publicador, { idDeclarado, manipular } = {}) => {
  const firmado = campo(1, idDeclarado ?? crypto.createHash('sha256').update(der(componente)).digest().subarray(0, 16))
  const t = Buffer.alloc(4); t.writeUInt32LE(firmado.length)
  const msg = Buffer.concat([Buffer.from('CRX3 SignedData\x00', 'latin1'), t, firmado, zip])
  const rsa = campo(2, Buffer.concat([campo(1, der(componente)), campo(2, crypto.sign('sha256', msg, { key: componente, padding: crypto.constants.RSA_PKCS1_PADDING }))]))
  const ec = campo(3, Buffer.concat([campo(1, der(publicador)), campo(2, crypto.sign('sha256', msg, { key: publicador, dsaEncoding: 'der' }))]))
  const cab = Buffer.concat([rsa, ec, campo(10000, firmado)])
  const pre = Buffer.alloc(12); pre.write('Cr24', 0, 'latin1'); pre.writeUInt32LE(3, 4); pre.writeUInt32LE(cab.length, 8)
  const z = Buffer.from(zip); if (manipular) z[z.length - 1] ^= 1
  return Buffer.concat([pre, cab, z])
}

try {
  const publicador = crypto.generateKeyPairSync('ec', { namedCurve: 'P-256' }).privateKey
  const otroPublicador = crypto.generateKeyPairSync('ec', { namedCurve: 'P-256' }).privateKey
  const PUB = hex(der(publicador))
  // Clave del «CRLSet» de prueba; para el resto de GOOGLE, el falso Google no tiene actualización.
  const clave = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 }).privateKey
  const otra = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 }).privateKey
  const ID = idDe(der(clave))
  GOOGLE[ID] = 'Prueba'

  // escenario: { version, crx, sha256, host }
  let esc
  const falsoFetch = async (url, opts) => {
    const u = String(url)
    if (opts?.method === 'POST') {
      const app = JSON.parse(opts.body).request.app.map(({ appid }) => appid === ID
        ? { appid, status: 'ok', updatecheck: { status: 'ok', urls: { url: [{ codebase: `http://${esc.host}/x/` }, { codebase: `https://${esc.host}/x/` }] },
            manifest: { version: esc.version, packages: { package: [{ name: 'c.crx3', size: esc.crx.length, hash_sha256: esc.sha256 ?? hex(esc.crx) }] } } } }
        : { appid, status: 'ok', updatecheck: { status: 'noupdate' } })
      return { status: 200, text: async () => `)]}'\n${JSON.stringify({ response: { app } })}` }
    }
    if (u !== `https://${esc.host}/x/c.crx3`) return { status: 404, arrayBuffer: async () => new ArrayBuffer(0) }
    return { status: 200, arrayBuffer: async () => esc.crx }
  }
  const zip = (n) => crearZip([{ nombre: 'manifest.json', datos: Buffer.from(`{"version":"${n}"}`) }])
  const correr = async (e) => {
    esc = { host: 'dl.google.com', ...e }; const log = []
    const r = await espejoGoogle(tmp, { fetch: falsoFetch, publicador: PUB, log: (l) => log.push(l) })
    const mios = r.fallos.filter((f) => f.startsWith('google Prueba'))
    return { ...r, texto: [...log, ...mios].join('\n'), mios }
  }
  const comprobar = (nombre, r, esperado, conFallo) => {
    const ok = esperado.every((x) => r.texto.includes(x)) && (conFallo ? r.mios.length > 0 : r.mios.length === 0)
    fallos += !ok; console.log(`${ok ? 'ok  ' : 'FALLO'} ${nombre}`); if (!ok) console.log(r.texto)
  }
  const fichero = (v) => path.join(tmp, 'release', ID, `extension_${v.replace(/\./g, '_')}.crx`)

  let r = await correr({ version: '100', crx: crx(zip(100), clave, publicador) })
  comprobar('copia un CRX válido de Google', r, ['+ Prueba', '100'])
  if (!fs.existsSync(fichero('100')) || r.componentes.find((c) => c.id === ID)?.version !== '100') { fallos++; console.log('FALLO no está en release/ o en el estado') }
  r = await correr({ version: '100', crx: crx(zip(100), clave, publicador) })
  // (cada firma ECDSA es distinta: mismo contenido, otro SHA-256; Google nunca hace eso)
  comprobar('rechaza la misma versión con otro SHA-256', r, ['misma versión 100 con otro SHA-256'], true)
  r = await correr({ version: '99', crx: crx(zip(99), clave, publicador) })
  comprobar('rechaza volver a una versión anterior', r, ['anterior a la copiada'], true)
  r = await correr({ version: '101', crx: crx(zip(101), clave, otroPublicador) })
  comprobar('rechaza otro publicador', r, ['falta la prueba del publicador'], true)
  r = await correr({ version: '101', crx: crx(zip(101), otra, publicador) })
  comprobar('rechaza un CRX de otro componente', r, ['crx_id declarado'], true)
  r = await correr({ version: '101', crx: crx(zip(101), clave, publicador, { manipular: true }) })
  comprobar('rechaza un archivo manipulado (con su SHA-256 anunciado)', r, ['firma no válida'], true)
  r = await correr({ version: '101', crx: crx(zip(101), clave, publicador), sha256: hex('otro') })
  comprobar('rechaza si el SHA-256 no es el anunciado', r, ['no coincide'], true)
  r = await correr({ version: '101', crx: crx(zip(101), clave, publicador), host: 'ejemplo.com' })
  comprobar('rechaza URL fuera de los dominios de Google', r, ['sin URL https de Google'], true)
  r = await correr({ version: '1.2.x', crx: crx(zip(101), clave, publicador) })
  comprobar('rechaza versiones no válidas', r, ['versión no válida'], true)
  r = await correr({ version: '101', crx: crx(zip(101), clave, publicador) })
  comprobar('copia la versión siguiente y conserva la anterior', r, ['+ Prueba', '101'])
  if (!fs.existsSync(fichero('101')) || !fs.existsSync(fichero('100'))) { fallos++; console.log('FALLO no conserva la anterior') }
  r = await correr({ version: '102', crx: crx(zip(102), clave, publicador) })
  if (fs.existsSync(fichero('100')) || !fs.existsSync(fichero('101'))) { fallos++; console.log('FALLO no borra la penúltima') } else console.log('ok   borra la penúltima versión')

  const casos = [[comparar('10816', '9999'), 1], [comparar('1.1.0.3', '1.1.0.3'), 0], [comparar('145.0.7584.0', '145.0.7584'), 0],
    [comparar('2026.10.1.64', '2026.9.30.1'), 1], [versionValida('1.2.3.4.5'), false], [versionValida('10816'), true]]
  const ok = casos.every(([a, b]) => a === b); fallos += !ok; console.log(`${ok ? 'ok  ' : 'FALLO'} comparación de versiones`)
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}
console.log(fallos ? `\n${fallos} FALLOS` : '\nTodo correcto'); process.exit(fallos ? 1 : 0)
