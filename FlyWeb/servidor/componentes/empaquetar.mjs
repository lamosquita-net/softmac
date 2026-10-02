// Empaquetado de los componentes de Shields de FlyWeb 1.57 (plan B). Pensado para ejecutarse una vez al día.
//
// Genera y firma:
//   - la lista por defecto (list.txt): las fuentes de las entradas de "defecto" de listas.json;
//   - los recursos (resources.json), con recursos-157.mjs;
//   - el catálogo (regional_catalog.json): las entradas de "regionales", con NUESTROS ID y claves;
//   - cada lista regional (list.txt).
// Escribe <salida>/release/<id>/extension_<versión>.crx y <salida>/catalog.json (el que lee go-update con
// FLYWEB_CATALOG_FILE). Solo publica una versión nueva de un componente si su contenido ha cambiado.
//
// Uso:
//   node empaquetar.mjs --packager <checkout> --claves <dir> --salida <dir> [--listas listas.json] [--sin-firma]
// <dir de claves>: publicador.pem, defecto.pem, recursos.pem, catalogo.pem y lista-<UUID>.pem. Las genera
// generar-claves.sh. Nunca van al repo.
// Entorno: ADBLOCK_RS=<node_modules/adblock-rs 0.7.x> (motor de la 1.57, para validar).
//
// Origen de las listas: el catálogo de brave/adblock-resources y la copia de las listas de
// brave/adblock-lists-mirror (GitHub, solo lectura). No se envía nada a terceros: a diferencia del empaquetador
// de Brave, no se manda la lista a ningún validador remoto.
import { createRequire } from 'module'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { generarRecursos } from './recursos-157.mjs'

const require = createRequire(import.meta.url)
const CATALOGO_URL = 'https://raw.githubusercontent.com/brave/adblock-resources/master/filter_lists/list_catalog.json'
const MIRROR = 'https://raw.githubusercontent.com/brave/adblock-lists-mirror/refs/heads/lists/lists/'
const SERVIDOR = 'https://flyweb.lamosquita.net'

const args = process.argv.slice(2)
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d }
const PACKAGER = opt('--packager'); const CLAVES = opt('--claves'); const SALIDA = opt('--salida')
const LISTAS = opt('--listas', new URL('./listas.json', import.meta.url).pathname)
const SIN_FIRMA = args.includes('--sin-firma')
if (!PACKAGER || !SALIDA || (!CLAVES && !SIN_FIRMA)) {
  console.error('Uso: node empaquetar.mjs --packager <dir> --claves <dir> --salida <dir> [--listas f] [--sin-firma]')
  process.exit(2)
}
const { Engine, FilterSet } = require(process.env.ADBLOCK_RS || 'adblock-rs')
const crx = SIN_FIRMA ? null : (await import(path.resolve(PACKAGER, 'lib/crx.js'))).default

const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const spki = (pem) => crypto.createPublicKey(pem).export({ type: 'spki', format: 'der' })
const idDe = (der) => [...sha256(der).slice(0, 32)].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')
const leerClave = (nombre) => {
  const f = path.join(CLAVES, nombre)
  const modo = fs.statSync(f).mode & 0o077
  if (modo) throw new Error(`${f}: permisos demasiado abiertos (debe ser 0600)`)
  return { fichero: f, der: spki(fs.readFileSync(f)) }
}
const descargar = async (url) => {
  const r = await fetch(url)
  if (r.status !== 200) throw new Error(`${url}: HTTP ${r.status}`)
  return r.text()
}

// Directivas !#if de uBlock Origin, con los mismos valores que usa el empaquetador de Brave.
const CONDICIONES = new Map([['ext_ublock', true], ['ext_devbuild', false], ['env_devbuild', false],
  ['env_chromium', true], ['env_edge', false], ['env_firefox', false], ['env_legacy', false],
  ['env_safari', false], ['cap_html_filtering', false], ['cap_user_stylesheet', true], ['false', false],
  ['ext_abp', false], ['adguard', false], ['adguard_app_android', false], ['adguard_app_ios', false],
  ['adguard_app_mac', false], ['adguard_app_windows', false], ['adguard_ext_android_cb', false],
  ['adguard_ext_chromium', true], ['adguard_ext_edge', false], ['adguard_ext_firefox', false],
  ['adguard_ext_opera', true], ['adguard_ext_safari', false]])
// Misma semántica que preprocess() de Brave: una condición desconocida incluye las dos ramas, y dentro de una
// rama descartada se descarta todo (también tras un !#else anidado, que en Brave la vuelve a abrir).
function preprocesar (titulo, texto) {
  const [SI, NO, CUALQUIERA] = [1, 2, 3]
  const pila = []; const out = []
  const sacar = (d) => { if (!pila.length) throw new Error(`${titulo}: ${d} sin !#if`); return pila.pop() }
  for (const bruta of texto.split('\n')) {
    const l = bruta.trim(); const cima = pila.length ? pila[pila.length - 1] : SI
    const m = l.match(/^!#if (!?)(.*)$/)
    if (m) {
      const v = CONDICIONES.get(m[2])
      pila.push(cima === NO ? NO : v === undefined ? CUALQUIERA : ((m[1] === '!') !== v ? SI : NO))
      continue
    }
    if (l === '!#else') {
      const e = sacar(l); const padre = pila.length ? pila[pila.length - 1] : SI
      pila.push(padre === NO ? NO : e === CUALQUIERA ? e : e === SI ? NO : SI) // (Brave aquí reabre la rama)
      continue
    }
    if (l === '!#endif') { sacar(l); continue }
    if (cima !== NO) out.push(l)
  }
  if (pila.length) throw new Error(`${titulo}: !#if sin cerrar`)
  return out
}

// Reglas que hacen fallar a adblock-rust < 0.8.7 (la 1.57 lleva la 0.7.9): el comprobador wasm del empaquetador.
const { filterIsProblematic } = await import(
  path.resolve(PACKAGER, 'lib/adBlockRust0_8_6/adblock_rust_0_8_6_compat_checker.js'))
// Las reglas +js(brave-…) solo se admiten en listas de Brave, como hace su empaquetador.
const esDeBrave = (t) => t?.startsWith('Brave ') || t === 'Experimental ad blocker'

async function construirLista (entradas) {
  const partes = []; let quitadas = 0
  for (const e of entradas) {
    for (const s of e.sources) {
      const titulo = s.title || e.title
      const texto = await descargar(MIRROR + crypto.createHash('md5').update(s.url).digest('hex') + '.txt')
      const lineas = preprocesar(titulo, texto).filter((l) => {
        const ok = !filterIsProblematic(l) && (esDeBrave(titulo) || !l.includes('+js(brave-'))
        if (!ok) quitadas++
        return ok
      })
      partes.push(lineas.join('\n'))
    }
  }
  return { texto: partes.join('\n'), quitadas }
}

// Comprobación con el motor de la 1.57: carga, no bloquea páginas normales y (la por defecto) sí bloquea anuncios.
function validarLista (nombre, texto, porDefecto) {
  const reglas = texto.split('\n').filter((l) => l && !l.startsWith('!') && !l.startsWith('[')).length
  const fsx = new FilterSet(true); fsx.addFilters(texto.split('\n'))
  const motor = new Engine(fsx, true)
  for (const [u, o, t] of [[SERVIDOR, SERVIDOR, 'document'], [SERVIDOR + '/estilo.css', SERVIDOR, 'stylesheet'],
    ['https://www.wikipedia.org/', 'https://www.wikipedia.org/', 'document'],
    ['https://claude.ai/', 'https://claude.ai/', 'document']]) {
    if (motor.check(u, o, t)) throw new Error(`${nombre}: bloquea ${u}`)
  }
  if (porDefecto && !motor.check('https://securepubads.g.doubleclick.net/tag/js/gpt.js', 'https://elpais.com/', 'script')) {
    throw new Error(`${nombre}: no bloquea doubleclick`)
  }
  return reglas
}

// Versión a partir de la hora UTC: AAAA.MMDD.HHMM (cada parte < 65536, como exige Chromium).
const ahora = new Date()
const VERSION = [ahora.getUTCFullYear(), (ahora.getUTCMonth() + 1) * 100 + ahora.getUTCDate(),
  ahora.getUTCHours() * 100 + ahora.getUTCMinutes()].join('.')

const listas = JSON.parse(fs.readFileSync(LISTAS, 'utf8'))
const catalogoBrave = JSON.parse(await descargar(CATALOGO_URL))
const porUuid = new Map(catalogoBrave.map((e) => [e.uuid, e]))
const buscar = (u) => { const e = porUuid.get(u); if (!e) throw new Error(`UUID ${u} no está en el catálogo de Brave`); return e }

const ESTADO = path.join(SALIDA, 'empaquetado.json')
const estado = fs.existsSync(ESTADO) ? JSON.parse(fs.readFileSync(ESTADO, 'utf8')) : {}
const clave = (n) => SIN_FIRMA ? { fichero: null, der: crypto.createHash('sha256').update(n).digest() } : leerClave(n)

const componentes = [] // { nombre, titulo, fichero, datos, clave, reglas }
const fallos = []
const intentar = async (nombre, f) => { try { await f() } catch (e) { fallos.push(`${nombre}: ${e.message}`) } }

await intentar('defecto', async () => {
  const { texto, quitadas } = await construirLista(listas.defecto.map(buscar))
  const reglas = validarLista('defecto', texto, true)
  componentes.push({ nombre: 'defecto', titulo: 'FlyWeb Shields: lista por defecto', fichero: 'list.txt', datos: texto, clave: clave('defecto.pem'), reglas, quitadas })
})
await intentar('recursos', async () => {
  const { resources } = await generarRecursos(PACKAGER)
  componentes.push({ nombre: 'recursos', titulo: 'FlyWeb Shields: recursos', fichero: 'resources.json', datos: JSON.stringify(resources), clave: clave('recursos.pem') })
})
const catalogo = []
for (const uuid of listas.regionales) {
  await intentar(uuid, async () => {
    const e = buscar(uuid)
    const k = clave(`lista-${uuid}.pem`)
    const { texto, quitadas } = await construirLista([e])
    const reglas = validarLista(e.title, texto, false)
    componentes.push({ nombre: `lista-${uuid}`, titulo: `FlyWeb Shields: ${e.title}`, fichero: 'list.txt', datos: texto, clave: k, reglas, quitadas })
    // Solo los campos que lee la 1.57 (filter_list_catalog_entry.cc), con nuestro ID y nuestra clave.
    catalogo.push({ uuid: e.uuid, url: e.sources[0]?.url ?? '', title: e.title, langs: e.langs ?? [],
      support_url: e.support_url ?? e.sources[0]?.support_url ?? '', desc: e.desc ?? '',
      list_text_component: { component_id: idDe(k.der), base64_public_key: k.der.toString('base64') } })
  })
}
await intentar('catalogo', async () => {
  // Si falla alguna lista, el catálogo se queda como estaba: así no desaparece de los navegadores.
  if (catalogo.length !== listas.regionales.length) throw new Error('falta alguna lista regional; se conserva el catálogo anterior')
  componentes.push({ nombre: 'catalogo', titulo: 'FlyWeb Shields: catálogo de listas', fichero: 'regional_catalog.json', datos: JSON.stringify(catalogo), clave: clave('catalogo.pem') })
})

// Firma y publicación. Un componente sin cambios conserva su versión anterior.
const publicador = SIN_FIRMA ? null : leerClave('publicador.pem')
const nuevoEstado = { ...estado }
const tmp = fs.mkdtempSync(path.join(SALIDA, '.tmp-'))
try {
  for (const c of componentes) {
    const id = idDe(c.clave.der); const hash = sha256(c.datos); const prev = estado[id]
    if (prev && prev.contenido === hash) { console.log(`= ${c.nombre.padEnd(46)} sin cambios (${prev.version})`); continue }
    if (prev?.reglas && c.reglas !== undefined && c.reglas < prev.reglas / 2) {
      fallos.push(`${c.nombre}: ${c.reglas} reglas frente a ${prev.reglas} de la versión anterior; no se publica`); continue
    }
    const stage = path.join(tmp, id); fs.mkdirSync(stage)
    fs.writeFileSync(path.join(stage, 'manifest.json'), JSON.stringify({ manifest_version: 2, name: c.titulo, version: VERSION }))
    fs.writeFileSync(path.join(stage, c.fichero), c.datos)
    const linea = `+ ${c.nombre.padEnd(46)} ${VERSION} ${id}${c.reglas !== undefined ? ` ${c.reglas} reglas` : ''}${c.quitadas ? ` (${c.quitadas} quitadas)` : ''}`
    if (SIN_FIRMA) { console.log(linea + ' [sin firma]'); continue }
    const { crx: bytes } = await crx.generateCrx(stage, c.clave.fichero, [publicador.fichero], null)
    const dir = path.join(SALIDA, 'release', id); fs.mkdirSync(dir, { recursive: true })
    const nombre = `extension_${VERSION.replace(/\./g, '_')}.crx`
    fs.writeFileSync(path.join(dir, nombre + '.tmp'), bytes); fs.renameSync(path.join(dir, nombre + '.tmp'), path.join(dir, nombre))
    nuevoEstado[id] = { nombre: c.nombre, titulo: c.titulo, version: VERSION, contenido: hash, sha256: sha256(bytes), tamano: bytes.length, reglas: c.reglas }
    // Se conservan la versión nueva y la anterior (descargas en curso); el resto se borra.
    const quedan = new Set([nombre, prev && `extension_${prev.version.replace(/\./g, '_')}.crx`])
    for (const f of fs.readdirSync(dir)) if (!quedan.has(f)) fs.rmSync(path.join(dir, f))
    console.log(linea)
  }
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}

if (!SIN_FIRMA) {
  // Solo lo que sigue en listas.json; lo quitado deja de servirse.
  const esperados = new Set(['defecto', 'recursos', 'catalogo', ...listas.regionales.map((u) => `lista-${u}`)])
  for (const [id, e] of Object.entries(nuevoEstado)) if (!esperados.has(e.nombre)) delete nuevoEstado[id]
  const cat = Object.entries(nuevoEstado).map(([id, e]) => ({ ID: id, Version: e.version, SHA256: e.sha256, Title: e.titulo, Size: e.tamano }))
  const escribir = (f, d) => { fs.writeFileSync(f + '.tmp', d); fs.renameSync(f + '.tmp', f) }
  escribir(path.join(SALIDA, 'catalog.json'), JSON.stringify(cat, null, 1))
  escribir(ESTADO, JSON.stringify(nuevoEstado, null, 1))
}
for (const f of fallos) console.error('FALLO ' + f)
process.exit(fallos.length ? 1 : 0)
