// Construcción de los componentes de Shields de FlyWeb 1.57 (plan B). SIN claves privadas: corre en GitHub Actions
// (.github/workflows/flyweb-shields.yml) y deja zips sin firmar que firma bak (bak/firmar.mjs).
//
// Construye:
//   - la lista por defecto (list.txt): las fuentes de las entradas de "defecto" de listas.json;
//   - la lista de primera parte (list.txt, "primera_parte"): el componente kAdBlockExceptionComponent de la 1.57,
//     que va a un motor aparte y se aplica también a las peticiones del propio sitio;
//   - los recursos (resources.json), con recursos-157.mjs y el uBlock Origin fijado en fijado.json;
//   - el catálogo (regional_catalog.json): las entradas de "regionales", con NUESTROS ID y claves públicas;
//   - cada lista regional (list.txt);
//   - los datos locales (kLocalDataFilesComponentId de la 1.57): debounce, limpieza de URL, Request-OTR, excepciones de
//     HTTPS por defecto y permiso de localhost, de brave/adblock-lists, en la carpeta 1/; Greaselion vacío (no se
//     inyecta ningún script). Solo si claves-publicas.json ya tiene su clave.
// Cada componente sale como <salida>/<nombre>.zip (manifest.json con la clave pública + el fichero de datos), y
// <salida>/indice.json los describe (versión, SHA-256 del zip y del contenido, reglas).
//
// Uso:
//   node empaquetar.mjs --packager <checkout fijado> --ublock <checkout fijado> --salida <dir> [--listas listas.json]
//                       [--claves-publicas claves-publicas.json]
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
import { crearZip } from './bak/zip.mjs'

const require = createRequire(import.meta.url)
const CATALOGO_URL = 'https://raw.githubusercontent.com/brave/adblock-resources/master/filter_lists/list_catalog.json'
const MIRROR = 'https://raw.githubusercontent.com/brave/adblock-lists-mirror/refs/heads/lists/lists/'
const SERVIDOR = 'https://flyweb.lamosquita.net'
const LISTAS_BRAVE = 'https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/'
const aqui = (f) => new URL(f, import.meta.url).pathname

const args = process.argv.slice(2)
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d }
const PACKAGER = opt('--packager'); const UBLOCK = opt('--ublock'); const SALIDA = opt('--salida')
const LISTAS = opt('--listas', aqui('./listas.json'))
const PUBLICAS = opt('--claves-publicas', aqui('./claves-publicas.json'))
if (!PACKAGER || !UBLOCK || !SALIDA) {
  console.error('Uso: node empaquetar.mjs --packager <dir> --ublock <dir> --salida <dir> [--listas f] [--claves-publicas f]')
  process.exit(2)
}
const { Engine, FilterSet } = require(process.env.ADBLOCK_RS || 'adblock-rs')

const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const idDe = (der) => [...sha256(der).slice(0, 32)].map((c) => String.fromCharCode(97 + parseInt(c, 16))).join('')
const descargar = async (url) => {
  const r = await fetch(url)
  if (r.status !== 200) throw new Error(`${url}: HTTP ${r.status}`)
  return r.text()
}
const publicas = JSON.parse(fs.readFileSync(PUBLICAS, 'utf8')).claves
const clave = (nombre) => {
  const b64 = publicas[nombre]
  if (!b64) throw new Error(`falta la clave pública de ${nombre} en ${path.basename(PUBLICAS)}`)
  return { b64, id: idDe(Buffer.from(b64, 'base64')) }
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
const fijado = JSON.parse(fs.readFileSync(aqui('./fijado.json'), 'utf8'))
const catalogoBrave = JSON.parse(await descargar(CATALOGO_URL))
const porUuid = new Map(catalogoBrave.map((e) => [e.uuid, e]))
const buscar = (u) => { const e = porUuid.get(u); if (!e) throw new Error(`UUID ${u} no está en el catálogo de Brave`); return e }

const componentes = [] // { nombre, titulo, fichero, datos, reglas, quitadas }
const fallos = []
const intentar = async (nombre, f) => { try { await f() } catch (e) { fallos.push(`${nombre}: ${e.message}`) } }

await intentar('defecto', async () => {
  const { texto, quitadas } = await construirLista(listas.defecto.map(buscar))
  componentes.push({ nombre: 'defecto', titulo: 'FlyWeb Shields: lista por defecto', fichero: 'list.txt', datos: texto, reglas: validarLista('defecto', texto, true), quitadas })
})
await intentar('primera-parte', async () => {
  const { texto, quitadas } = await construirLista(listas.primera_parte.map(buscar))
  componentes.push({ nombre: 'primera-parte', titulo: 'FlyWeb Shields: first-party list', fichero: 'list.txt', datos: texto, reglas: validarLista('primera-parte', texto, false), quitadas })
})
await intentar('recursos', async () => {
  const { resources } = await generarRecursos(UBLOCK)
  componentes.push({ nombre: 'recursos', titulo: 'FlyWeb Shields: recursos', fichero: 'resources.json', datos: JSON.stringify(resources) })
})
const catalogo = []
for (const uuid of listas.regionales) {
  await intentar(`lista-${uuid}`, async () => {
    const e = buscar(uuid); const k = clave(`lista-${uuid}`)
    const { texto, quitadas } = await construirLista([e])
    componentes.push({ nombre: `lista-${uuid}`, titulo: `FlyWeb Shields: ${e.title}`, fichero: 'list.txt', datos: texto, reglas: validarLista(e.title, texto, false), quitadas })
    // Solo los campos que lee la 1.57 (filter_list_catalog_entry.cc), con nuestro ID y nuestra clave.
    catalogo.push({ uuid: e.uuid, url: e.sources[0]?.url ?? '', title: e.title, langs: e.langs ?? [],
      support_url: e.support_url ?? e.sources[0]?.support_url ?? '', desc: e.desc ?? '',
      list_text_component: { component_id: k.id, base64_public_key: k.b64 } })
  })
}
// Si falla alguna lista, no sale catálogo: bak conserva el anterior y la lista no desaparece de los navegadores.
await intentar('catalogo', async () => {
  if (catalogo.length !== listas.regionales.length) throw new Error('falta alguna lista regional; no se genera catálogo')
  componentes.push({ nombre: 'catalogo', titulo: 'FlyWeb Shields: catálogo de listas', fichero: 'regional_catalog.json', datos: JSON.stringify(catalogo) })
})

// Datos locales. Formatos comprobados con los lectores de la 1.57 (debounce_rule.cc, url_sanitizer_service.cc,
// request_otr_rule.cc, localhost_permission_component.cc, https_upgrade_exceptions_service.cc); las acciones de
// debounce que no conoce (p. ej. regex-path-template) las ignora regla a regla. webcompat-exceptions.json y
// clean-urls-permissions.json no los lee la 1.57.
const conDatosLocales = Boolean(publicas['datos-locales'])
if (conDatosLocales) {
  await intentar('datos-locales', async () => {
    const json = { 'debounce.json': 20, 'clean-urls.json': 20, 'request-otr.json': 1 }
    const texto = ['https-upgrade-exceptions-list.txt', 'localhost-permission-allow-list.txt']
    const ficheros = []; let reglas = 0
    for (const [f, minimo] of Object.entries(json)) {
      const d = await descargar(LISTAS_BRAVE + f); const r = JSON.parse(d)
      if (!Array.isArray(r) || r.length < minimo || !r.every((x) => x && Array.isArray(x.include) && x.include.every((i) => typeof i === 'string'))) throw new Error(`${f}: formato inesperado`)
      ficheros.push({ nombre: `1/${f}`, datos: d }); reglas += r.length
    }
    for (const f of texto) {
      const d = await descargar(LISTAS_BRAVE + f); const n = d.split('\n').filter((l) => l.trim() && !l.trim().startsWith('#')).length
      if (!n) throw new Error(`${f}: vacío`)
      ficheros.push({ nombre: `1/${f}`, datos: d }); reglas += n
    }
    ficheros.push({ nombre: '1/Greaselion.json', datos: '[]' })
    componentes.push({ nombre: 'datos-locales', titulo: 'FlyWeb Local Data', ficheros, reglas, quitadas: 0 })
  })
} else console.log('datos-locales: sin clave pública todavía; no se construye')

fs.mkdirSync(SALIDA, { recursive: true })
// esperados: lo que pide listas.json; bak deja de servir lo que ya no esté (un fallo de hoy no lo quita).
const esperados = ['defecto', 'primera-parte', 'recursos', ...listas.regionales.map((u) => `lista-${u}`), 'catalogo',
  ...(conDatosLocales ? ['datos-locales'] : [])]
const indice = { generado: ahora.toISOString(), version: VERSION, ublock: fijado.ublock.tag, esperados, componentes: [] }
for (const c of componentes) {
  await intentar(c.nombre, async () => {
    const k = clave(c.nombre)
    const manifest = { manifest_version: 2, name: c.titulo, version: VERSION, key: k.b64 }
    const ficheros = (c.ficheros ?? [{ nombre: c.fichero, datos: c.datos }]).map((f) => ({ nombre: f.nombre, datos: Buffer.from(f.datos) }))
    const zip = crearZip([{ nombre: 'manifest.json', datos: Buffer.from(JSON.stringify(manifest, null, 1)) }, ...ficheros])
    fs.writeFileSync(path.join(SALIDA, `${c.nombre}.zip`), zip)
    indice.componentes.push({ nombre: c.nombre, id: k.id, version: VERSION, zip: `${c.nombre}.zip`, sha256: sha256(zip),
      contenido: sha256(c.ficheros ? Buffer.concat(ficheros.flatMap((f) => [Buffer.from(f.nombre + '\0'), f.datos, Buffer.from('\0')])) : c.datos), ...(c.reglas !== undefined && { reglas: c.reglas, quitadas: c.quitadas }) })
    console.log(`+ ${c.nombre.padEnd(46)} ${VERSION} ${k.id}${c.reglas !== undefined ? ` ${c.reglas} reglas (${c.quitadas} quitadas)` : ''}`)
  })
}
indice.fallos = fallos
fs.writeFileSync(path.join(SALIDA, 'indice.json'), JSON.stringify(indice, null, 1))
for (const f of fallos) console.error('FALLO ' + f)
process.exit(fallos.length ? 1 : 0)
