// Firma de actualizaciones de FlyWeb (Sparkle 1.24, EdDSA) en bak. Solo Node, sin dependencias.
//
// La clave privada ed25519 no sale de bak. Solo se firma un DMG cuyo SHA-256 y versión ha aprobado el HUMANO en un
// fichero de root (como los recursos de Shields). Sparkle comprueba la firma con la clave pública que lleva la app
// (SUPublicEDKey, puesta por build.sh) y que el DMG nuevo esté firmado con el mismo Developer ID.
//
// Uso:
//   node firmar-actualizacion.mjs generar-clave --clave <fichero.pem>
//   node firmar-actualizacion.mjs publica --clave <fichero.pem>
//   node firmar-actualizacion.mjs firmar --dmg <URL https de updates.flyweb.lamosquita.net o fichero> \
//        --version <CFBundleVersion, p. ej. 157.64.1> --visible <p. ej. 1.0.1> --clave <pem> \
//        --aprobados <fichero> --salida <dir> [--canal stable] [--min-macos 10.13.0] [--notas <URL>] \
//        [--subir <host ssh>]
//
// Fichero de aprobados: una línea por versión, «<sha256>  <CFBundleVersion>  # comentario».
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'

const HOST = 'updates.flyweb.lamosquita.net'
const MAX_ITEMS = 5

export function comparar (a, b) {
  // Como SUStandardVersionComparator para versiones numéricas con puntos: 157.64.1 > 157.64.
  const x = a.split('.').map(Number); const y = b.split('.').map(Number)
  for (let i = 0; i < Math.max(x.length, y.length); i++) {
    const d = (x[i] ?? 0) - (y[i] ?? 0)
    if (d) return Math.sign(d)
  }
  return 0
}

export const versionValida = (v) => /^\d{1,5}(\.\d{1,5}){1,3}$/.test(v)

export function clavePublica (privada) {
  const der = crypto.createPublicKey(privada).export({ type: 'spki', format: 'der' })
  return der.subarray(der.length - 32).toString('base64') // los 32 bytes crudos, como SUPublicEDKey
}

const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

export function appcast (canal, items) {
  const its = items.map((i) => `    <item>
      <title>FlyWeb ${esc(i.visible)}</title>
      <pubDate>${esc(i.fecha)}</pubDate>
      <sparkle:minimumSystemVersion>${esc(i.minMacos)}</sparkle:minimumSystemVersion>${i.notas ? `
      <sparkle:releaseNotesLink>${esc(i.notas)}</sparkle:releaseNotesLink>` : ''}
      <enclosure url="${esc(i.url)}" sparkle:version="${esc(i.version)}" sparkle:shortVersionString="${esc(i.visible)}" length="${i.tam}" type="application/octet-stream" sparkle:edSignature="${esc(i.firma)}"/>
    </item>`).join('\n')
  return `<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>FlyWeb (${esc(canal)})</title>
    <link>https://${HOST}/${esc(canal)}/appcast.xml</link>
    <language>es</language>
${its}
  </channel>
</rss>
`
}

export function aprobado (texto, sha, version) {
  return texto.split('\n').some((l) => {
    const [h, v] = l.replace(/#.*/, '').trim().split(/\s+/)
    return h?.toLowerCase() === sha && v === version
  })
}

async function leerDmg (origen, fetchFn) {
  if (/^https?:\/\//.test(origen)) {
    const u = new URL(origen)
    const permitido = u.protocol === 'https:' && u.hostname === HOST && u.pathname.endsWith('.dmg')
    if (!permitido && !process.env.FLYWEB_PRUEBAS) throw new Error(`solo DMG por https de ${HOST}: ${origen}`)
    const r = await fetchFn(origen)
    if (r.status !== 200) throw new Error(`descarga: HTTP ${r.status}`)
    return { datos: Buffer.from(await r.arrayBuffer()), url: origen }
  }
  return { datos: fs.readFileSync(origen), url: `https://${HOST}/${path.basename(origen)}` }
}

export async function firmar (o, { fetchFn = fetch, log = console.log } = {}) {
  const canal = o.canal ?? 'stable'
  if (!/^(stable|beta|dev|nightly)$/.test(canal)) throw new Error(`canal no válido: ${canal}`)
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  if (!/^[\w.\- ]{1,32}$/.test(o.visible ?? '')) throw new Error(`versión visible no válida: ${o.visible}`)
  const { datos, url } = await leerDmg(o.dmg, fetchFn)
  const sha = crypto.createHash('sha256').update(datos).digest('hex')
  if (!aprobado(fs.readFileSync(o.aprobados, 'utf8'), sha, o.version)) {
    throw new Error(`DMG no aprobado: «${sha}  ${o.version}» no está en ${o.aprobados}`)
  }
  const dir = path.join(o.salida, canal)
  fs.mkdirSync(dir, { recursive: true })
  const estadoF = path.join(dir, 'appcast.json')
  const items = fs.existsSync(estadoF) ? JSON.parse(fs.readFileSync(estadoF, 'utf8')) : []
  if (items.length && comparar(o.version, items[0].version) <= 0) {
    throw new Error(`la versión ${o.version} no es posterior a la publicada (${items[0].version})`)
  }
  const privada = crypto.createPrivateKey(fs.readFileSync(o.clave))
  const firma = crypto.sign(null, datos, privada).toString('base64')
  // Comprobación con la clave pública, como hará Sparkle.
  if (!crypto.verify(null, datos, crypto.createPublicKey(privada), Buffer.from(firma, 'base64'))) throw new Error('firma no verificable')
  items.unshift({ version: o.version, visible: o.visible, url, tam: datos.length, sha256: sha, firma,
    minMacos: o.minMacos ?? '10.13.0', notas: o.notas, fecha: new Date().toUTCString() })
  items.splice(MAX_ITEMS)
  fs.writeFileSync(estadoF, JSON.stringify(items, null, 2))
  fs.writeFileSync(path.join(dir, 'appcast.xml'), appcast(canal, items))
  log(`firmado ${o.version} (${o.visible}), ${datos.length} bytes, sha256 ${sha}`)
  if (o.subir) {
    execFileSync('rsync', ['-t', '--chmod=F644', path.join(dir, 'appcast.xml'), `${o.subir}:${canal}/appcast.xml`], { stdio: 'inherit' })
    log(`subido a ${o.subir}:${canal}/appcast.xml`)
  }
  return items[0]
}

async function main () {
  const [orden, ...resto] = process.argv.slice(2)
  const o = {}
  for (let i = 0; i < resto.length; i += 2) o[resto[i].replace(/^--/, '').replace(/-(\w)/g, (_, c) => c.toUpperCase())] = resto[i + 1]
  if (orden === 'generar-clave') {
    if (fs.existsSync(o.clave)) throw new Error(`ya existe ${o.clave}; no se sobrescribe`)
    const { privateKey } = crypto.generateKeyPairSync('ed25519')
    fs.writeFileSync(o.clave, privateKey.export({ type: 'pkcs8', format: 'pem' }), { mode: 0o600 })
    console.log(`SUPublicEDKey (pública, para build.sh): ${clavePublica(privateKey)}`)
  } else if (orden === 'publica') {
    console.log(clavePublica(crypto.createPrivateKey(fs.readFileSync(o.clave))))
  } else if (orden === 'firmar') {
    for (const k of ['dmg', 'version', 'visible', 'clave', 'aprobados', 'salida']) if (!o[k]) throw new Error(`falta --${k}`)
    await firmar(o)
  } else {
    console.error('Uso: firmar-actualizacion.mjs generar-clave|publica|firmar … (ver la cabecera)')
    process.exit(2)
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === new URL(import.meta.url).pathname) {
  main().catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1) })
}
