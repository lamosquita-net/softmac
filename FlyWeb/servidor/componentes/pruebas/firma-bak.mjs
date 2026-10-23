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
  for (const n of ['publicador', 'defecto', 'primera-parte', 'recursos', 'recursos-20', 'catalogo', 'lista-ES', 'datos-locales', 'ajena']) {
    pem[n] = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 }).privateKey.export({ type: 'pkcs8', format: 'pem' })
    if (n !== 'ajena') fs.writeFileSync(path.join(CLAVES, `${n}.pem`), pem[n], { mode: 0o600 })
  }
  const b64 = (n) => spki(pem[n]).toString('base64')
  const recursos1 = '[{"name":"noop.js","aliases":[],"kind":{"mime":"application/javascript"},"content":""}]'
  // Recursos de la 2.0 (adblock-rust 0.8): con dependencies, sin envolver.
  const recursos2 = '[{"name":"noop.js","aliases":[],"kind":{"mime":"application/javascript"},"content":"","dependencies":[]},{"name":"a.js","aliases":["b.js"],"kind":{"mime":"application/javascript"},"content":"","dependencies":["noop.js"]}]'
  fs.writeFileSync(APROBADOS, `# aprobados\n${hex(recursos1)}  # versión de prueba\n${hex(recursos2)}  # recursos 2.0 de prueba\n`)

  // Fabrica un origen como el de GitHub Actions. cambios: { nombre: { datos, clave, extra, version, shaFalso } }
  const lista = (n) => Array.from({ length: n }, (_, i) => `||anuncio${i}.example^`).join('\n')
  const comp = (n) => ({ component_id: id(spki(pem[n])), base64_public_key: b64(n) })
  const entrada = (uuid, n, extra = {}) => ({ uuid, url: 'https://example.com/lista.txt', title: uuid, langs: [], support_url: 'https://example.com/', desc: '',
    hidden: false, default_enabled: false, first_party_protections: false, permission_mask: 1, list_text_component: comp(n), ...extra })
  const listCatalog = (cambio = (x) => x) => JSON.stringify(cambio([entrada('default', 'defecto', { hidden: true, default_enabled: true, first_party_protections: true }),
    entrada('FP', 'primera-parte', { hidden: true, default_enabled: true }), entrada('ES', 'lista-ES', { langs: ['es'], platforms: ['MAC'] })]))
  const regional = JSON.stringify([{ uuid: 'ES', title: 'es', langs: ['es'], list_text_component: comp('lista-ES') }])
  const catalogos = () => ({ 'regional_catalog.json': regional, 'list_catalog.json': listCatalog() })
  const construir = (version, cambios = {}) => {
    fs.rmSync(ORIGEN, { recursive: true, force: true }); fs.mkdirSync(ORIGEN)
    const base = {
      defecto: lista(1000), 'primera-parte': lista(50), recursos: recursos1, 'recursos-20': recursos2, 'lista-ES': lista(200),
      catalogo: catalogos()
    }
    const reglasLocales = (n) => JSON.stringify(Array.from({ length: n }, (_, i) => ({ include: [`*://r${i}.example/*`], exclude: [] })))
    base['datos-locales'] = { '1/debounce.json': reglasLocales(40), '1/clean-urls.json': reglasLocales(40), '1/request-otr.json': reglasLocales(5),
      '1/https-upgrade-exceptions-list.txt': 'a.example\n', '1/localhost-permission-allow-list.txt': '# x\nb.example\n', '1/Greaselion.json': '[]' }
    const fichero = (n) => n === 'recursos' || n === 'recursos-20' ? 'resources.json' : 'list.txt'
    const componentes = Object.entries(base).map(([n, datos]) => {
      const c = cambios[n] ?? {}
      const v = c.version ?? version
      const d = c.datos ?? datos
      const f = [{ nombre: 'manifest.json', datos: Buffer.from(JSON.stringify({ manifest_version: 2, name: n, version: v, key: c.clave ?? b64(n) })) },
        ...(typeof d === 'string' ? [{ nombre: fichero(n), datos: Buffer.from(d) }] : Object.entries(d).map(([nombre, x]) => ({ nombre, datos: Buffer.from(x) })))]
      if (c.extra) f.push({ nombre: 'extra.js', datos: Buffer.from('alert(1)') })
      const zip = crearZip(f); fs.writeFileSync(path.join(ORIGEN, `${n}.zip`), zip)
      return { nombre: n, version: v, zip: `${n}.zip`, sha256: c.shaFalso ? hex('x') : hex(zip) }
    })
    fs.writeFileSync(path.join(tmp, 'locales.json'), JSON.stringify(base['datos-locales']))
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
  comprobar('primera firma de los 7 componentes', r, ['+ defecto', '+ primera-parte', '+ recursos ', '+ recursos-20', '+ lista-ES', '+ catalogo', '+ datos-locales'])
  const estado = JSON.parse(fs.readFileSync(path.join(SALIDA, 'firmado.json'), 'utf8'))
  for (const [n, e] of Object.entries(estado)) {
    const crx = fs.readFileSync(path.join(SALIDA, 'release', e.id, `extension_${e.version.replace(/\./g, '_')}.crx`))
    const v = verifyCrx3(crx, sha(spki(pem[n])), sha(spki(pem.publicador))); fallos += !v.startsWith('OK_FULL')
    console.log(`${v.startsWith('OK_FULL') ? 'ok  ' : 'FALLO'}   verificador 1.57: ${n} ${v}`)
  }
  comprobar('segunda ejecución sin cambios', firmar(), ['= defecto', '= recursos-20', '= catalogo'])
  const firmadoAntes = fs.readFileSync(path.join(SALIDA, 'firmado.json'), 'utf8')
  const crxAntes = fs.readdirSync(path.join(SALIDA, 'release')).flatMap((d) => fs.readdirSync(path.join(SALIDA, 'release', d)).map((f) => `${d}/${f}`)).sort()

  const locales = () => ({ '1/debounce.json': '[]', '1/clean-urls.json': '[]', '1/request-otr.json': '[]', '1/https-upgrade-exceptions-list.txt': '',
    '1/localhost-permission-allow-list.txt': '', '1/Greaselion.json': '[]', ...JSON.parse(fs.readFileSync(path.join(tmp, 'locales.json'), 'utf8')) })
  const casos = [
    ['recursos cambiados sin aprobar', { recursos: { datos: '[{"name":"x.js","aliases":[],"kind":{"mime":"application/javascript"},"content":"YWxlcnQoMSk="}]' } }, ['recursos nuevos SIN APROBAR']],
    ['manifest con clave ajena', { defecto: { datos: lista(1001), clave: b64('ajena') } }, ['defecto: el manifest no lleva nuestra clave']],
    ['fichero de más en el zip', { defecto: { datos: lista(1001), extra: true } }, ['defecto: contenido inesperado']],
    ['zip que no coincide con el índice', { defecto: { datos: lista(1001), shaFalso: true } }, ['defecto: el SHA-256 del zip no coincide']],
    ['versión anterior (vuelta atrás)', { defecto: { datos: lista(1001), version: '2026.1003.800' } }, ['defecto: versión 2026.1003.800 no posterior']],
    ['lista que pierde más de la mitad', { defecto: { datos: lista(400) } }, ['defecto: 400 reglas frente a 1000']],
    ['datos locales con Greaselion no vacío', { 'datos-locales': { datos: { ...locales(), '1/Greaselion.json': '[{"scripts":["x.js"]}]' } } }, ['Greaselion.json no está vacío']],
    ['datos locales con un fichero de más', { 'datos-locales': { datos: { ...locales(), '1/x.js': 'alert(1)' } } }, ['datos-locales: contenido inesperado']],
    ['datos locales que pierden más de la mitad', { 'datos-locales': { datos: { ...locales(), '1/debounce.json': '[]', '1/clean-urls.json': '[]' } } }, ['datos-locales: 7 reglas frente a 87']],
    ['recursos 2.0 cambiados sin aprobar', { 'recursos-20': { datos: recursos2.replace('"a.js"', '"c.js"') } }, ['recursos-20: recursos nuevos SIN APROBAR']],
    ['recursos 2.0 con un scriptlet trusted', { 'recursos-20': { datos: recursos2.replace('"b.js"', '"trusted-b.js"') } }, ['recursos-20 lleva un recurso «trusted» o con permisos: a.js']],
    ['recursos 2.0 con rpnt.js (alias de un trusted)', { 'recursos-20': { datos: recursos2.replace('"b.js"', '"rpnt.js"') } }, ['recursos-20 lleva un recurso «trusted» o con permisos: a.js']],
    ['recursos 2.0 con permisos propios', { 'recursos-20': { datos: recursos2.replace('"dependencies":["noop.js"]', '"dependencies":[],"permission":1') } }, ['recursos-20 lleva un recurso «trusted» o con permisos: a.js']],
    ['recursos 2.0 con la clave de los de la 1.x', { 'recursos-20': { clave: b64('recursos') } }, ['recursos-20: el manifest no lleva nuestra clave']],
    ['catálogo con una lista ajena', { catalogo: { datos: { 'regional_catalog.json': JSON.stringify([{ uuid: 'ES', list_text_component: { component_id: id(spki(pem.ajena)), base64_public_key: b64('ajena') } }]), 'list_catalog.json': listCatalog() } } }, ['la lista ES del catálogo no usa nuestra clave']],
    ['catálogo solo con el fichero de la 1.x', { catalogo: { datos: { 'regional_catalog.json': '[]' } } }, ['catalogo: contenido inesperado']],
    ['list_catalog con una lista ajena', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => [...c, entrada('X', 'ajena')]) } } }, ['la lista X del list_catalog no usa nuestra clave']],
    ['list_catalog con una clave de recursos', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => [...c, entrada('X', 'recursos-20')]) } } }, ['la lista X del list_catalog no usa nuestra clave']],
    ['list_catalog con el mismo componente dos veces', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => [...c, entrada('otra', 'defecto')]) } } }, ['sale dos veces en list_catalog']],
    ['list_catalog con más permisos', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => c.map((e) => ({ ...e, permission_mask: 255 }))) } } }, ['permission_mask no válido']],
    ['list_catalog con un enlace que no es https', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => c.map((e) => ({ ...e, url: 'http://example.com/x' }))) } } }, ['enlace que no es https']],
    ['list_catalog con un uuid «constructor» y sin componente', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => [...c, { ...entrada('constructor', 'lista-ES'), list_text_component: {} }]) } } }, ['la lista constructor del list_catalog no usa nuestra clave']],
    ['list_catalog con uuid «__proto__»', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => [...c, { ...entrada('__proto__', 'lista-ES'), list_text_component: { component_id: 1, base64_public_key: 2 } }]) } } }, ['la lista __proto__ del list_catalog no usa nuestra clave']],
    ['list_catalog con la clave en un tipo que no es texto', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => c.map((e) => e.uuid === 'ES' ? { ...e, list_text_component: { component_id: ['x'], base64_public_key: ['y'] } } : e)) } } }, ['la lista ES del list_catalog no usa nuestra clave']],
    ['regional_catalog con uuid «constructor»', { catalogo: { datos: { ...catalogos(), 'regional_catalog.json': JSON.stringify([{ uuid: 'constructor', list_text_component: {} }]) } } }, ['la lista constructor del catálogo no usa nuestra clave']],
    ['list_catalog sin la lista por defecto', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => c.filter((e) => e.uuid !== 'default')) } } }, ['list_catalog no lleva la entrada de defecto']],
    ['list_catalog sin la lista de primera parte', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': listCatalog((c) => c.filter((e) => e.uuid !== 'FP')) } } }, ['list_catalog no lleva la entrada de primera-parte']],
    ['list_catalog vacío', { catalogo: { datos: { ...catalogos(), 'list_catalog.json': '[]' } } }, ['list_catalog.json vacío']]
  ]
  for (const [nombre, cambios, esperado] of casos) {
    construir('2026.1003.1000', cambios); r = firmar()
    comprobar(nombre, { salida: r.salida + (r.codigo === 1 ? ' [código 1]' : '') }, [...esperado, '[código 1]'])
  }
  // Nada de lo rechazado cambia lo firmado: ni una versión, ni un hash, ni un CRX (todos los componentes, también recursos-20 y catalogo).
  const despues = fs.readFileSync(path.join(SALIDA, 'firmado.json'), 'utf8')
  const crxDespues = fs.readdirSync(path.join(SALIDA, 'release')).flatMap((d) => fs.readdirSync(path.join(SALIDA, 'release', d)).map((f) => `${d}/${f}`)).sort()
  const intacto = despues === firmadoAntes && JSON.stringify(crxDespues) === JSON.stringify(crxAntes) &&
    ['recursos-20', 'catalogo', 'primera-parte'].every((n) => JSON.parse(despues)[n]?.version === '2026.1003.900')
  fallos += !intacto; console.log(`${intacto ? 'ok  ' : 'FALLO'} lo rechazado no ha cambiado lo firmado (recursos-20 y catalogo incluidos)`)
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}
process.exit(fallos ? 1 : 0)
