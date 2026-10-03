// Prueba de bak/firmar.mjs sin red: claves desechables y zips fabricados aquí. Comprueba que firma lo correcto
// (verificado con verificador-157.mjs) y que rechaza cada manipulación. Uso: node pruebas/firma-bak.mjs
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { crearZip } from '../bak/zip.mjs'
import { verifyCrx3, sha, spki } from './verificador-157.mjs'

const FIRMAR = new URL('../bak/firmar.mjs', import.meta.url).pathname
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-bak-'))
const CLAVES = path.join(tmp, 'claves'); const ORIGEN = path.join(tmp, 'origen'); const SALIDA = path.join(tmp, 'salida')
const APROBADOS = path.join(tmp, 'aprobados')
const hex = (b) => crypto.createHash('sha256').update(b).digest('hex')
const id = (der) => [...hex(der).slice(0, 32)].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')
let fallos = 0

try {
  fs.mkdirSync(CLAVES, { mode: 0o700 }); fs.mkdirSync(SALIDA)
  const pem = {}
  for (const n of ['publicador', 'defecto', 'recursos', 'catalogo', 'lista-ES', 'ajena']) {
    pem[n] = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 }).privateKey.export({ type: 'pkcs8', format: 'pem' })
    if (n !== 'ajena') fs.writeFileSync(path.join(CLAVES, `${n}.pem`), pem[n], { mode: 0o600 })
  }
  const b64 = (n) => spki(pem[n]).toString('base64')
  const recursos1 = '[{"name":"noop.js","aliases":[],"kind":{"mime":"application/javascript"},"content":""}]'
  fs.writeFileSync(APROBADOS, `# aprobados\n${hex(recursos1)}  # versión de prueba\n`)

  // Fabrica un origen como el de GitHub Actions. cambios: { nombre: { datos, clave, extra, version, shaFalso } }
  const lista = (n) => Array.from({ length: n }, (_, i) => `||anuncio${i}.example^`).join('\n')
  const construir = (version, cambios = {}) => {
    fs.rmSync(ORIGEN, { recursive: true, force: true }); fs.mkdirSync(ORIGEN)
    const base = {
      defecto: lista(1000), recursos: recursos1, 'lista-ES': lista(200),
      catalogo: JSON.stringify([{ uuid: 'ES', title: 'es', langs: ['es'], list_text_component: { component_id: id(spki(pem['lista-ES'])), base64_public_key: b64('lista-ES') } }])
    }
    const fichero = (n) => n === 'recursos' ? 'resources.json' : n === 'catalogo' ? 'regional_catalog.json' : 'list.txt'
    const componentes = Object.entries(base).map(([n, datos]) => {
      const c = cambios[n] ?? {}
      const v = c.version ?? version
      const f = [{ nombre: 'manifest.json', datos: Buffer.from(JSON.stringify({ manifest_version: 2, name: n, version: v, key: c.clave ?? b64(n) })) },
        { nombre: fichero(n), datos: Buffer.from(c.datos ?? datos) }]
      if (c.extra) f.push({ nombre: 'extra.js', datos: Buffer.from('alert(1)') })
      const zip = crearZip(f); fs.writeFileSync(path.join(ORIGEN, `${n}.zip`), zip)
      return { nombre: n, version: v, zip: `${n}.zip`, sha256: c.shaFalso ? hex('x') : hex(zip) }
    })
    fs.writeFileSync(path.join(ORIGEN, 'indice.json'), JSON.stringify({ ublock: 'prueba', esperados: Object.keys(base), componentes }))
  }
  const firmar = () => {
    try { return { codigo: 0, salida: execFileSync('node', [FIRMAR, '--origen', ORIGEN, '--claves', CLAVES, '--salida', SALIDA, '--aprobados', APROBADOS], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }) } } catch (e) { return { codigo: e.status, salida: e.stdout + e.stderr } }
  }
  const comprobar = (nombre, r, esperado) => {
    const ok = esperado.every((x) => r.salida.includes(x)); fallos += !ok
    console.log(`${ok ? 'ok  ' : 'FALLO'} ${nombre}`); if (!ok) console.log(r.salida)
  }

  construir('2026.1003.900')
  let r = firmar()
  comprobar('primera firma de los 4 componentes', r, ['+ defecto', '+ recursos', '+ lista-ES', '+ catalogo'])
  const estado = JSON.parse(fs.readFileSync(path.join(SALIDA, 'firmado.json'), 'utf8'))
  for (const [n, e] of Object.entries(estado)) {
    const crx = fs.readFileSync(path.join(SALIDA, 'release', e.id, `extension_${e.version.replace(/\./g, '_')}.crx`))
    const v = verifyCrx3(crx, sha(spki(pem[n])), sha(spki(pem.publicador))); fallos += !v.startsWith('OK_FULL')
    console.log(`${v.startsWith('OK_FULL') ? 'ok  ' : 'FALLO'}   verificador 1.57: ${n} ${v}`)
  }
  comprobar('segunda ejecución sin cambios', firmar(), ['= defecto', '= recursos', '= catalogo'])

  const casos = [
    ['recursos cambiados sin aprobar', { recursos: { datos: '[{"name":"x.js","aliases":[],"kind":{"mime":"application/javascript"},"content":"YWxlcnQoMSk="}]' } }, ['recursos nuevos SIN APROBAR']],
    ['manifest con clave ajena', { defecto: { datos: lista(1001), clave: b64('ajena') } }, ['defecto: el manifest no lleva nuestra clave']],
    ['fichero de más en el zip', { defecto: { datos: lista(1001), extra: true } }, ['defecto: contenido inesperado']],
    ['zip que no coincide con el índice', { defecto: { datos: lista(1001), shaFalso: true } }, ['defecto: el SHA-256 del zip no coincide']],
    ['versión anterior (vuelta atrás)', { defecto: { datos: lista(1001), version: '2026.1003.800' } }, ['defecto: versión 2026.1003.800 no posterior']],
    ['lista que pierde más de la mitad', { defecto: { datos: lista(400) } }, ['defecto: 400 reglas frente a 1000']],
    ['catálogo con una lista ajena', { catalogo: { datos: JSON.stringify([{ uuid: 'ES', list_text_component: { component_id: id(spki(pem.ajena)), base64_public_key: b64('ajena') } }]) } }, ['la lista ES del catálogo no usa nuestra clave']]
  ]
  for (const [nombre, cambios, esperado] of casos) {
    construir('2026.1003.1000', cambios); r = firmar()
    comprobar(nombre, { salida: r.salida + (r.codigo === 1 ? ' [código 1]' : '') }, [...esperado, '[código 1]'])
  }
  const despues = JSON.parse(fs.readFileSync(path.join(SALIDA, 'firmado.json'), 'utf8'))
  const intacto = despues.defecto.version === '2026.1003.900' && despues.recursos.version === '2026.1003.900'
  fallos += !intacto; console.log(`${intacto ? 'ok  ' : 'FALLO'} lo rechazado no ha cambiado lo firmado`)
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}
process.exit(fallos ? 1 : 0)
