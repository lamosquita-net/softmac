// Los recursos de la 2.0 (recursos-20.zip, construido por empaquetar.mjs) con el motor de Brave 1.69: adblock-rust 0.8.x
// (motor-08/). Carga resources.json, inyecta scriptlets (con sus dependencias inlinadas: 0.8.11 ignora `dependencies`),
// comprueba que se ejecutan y que ningún scriptlet «trusted» está, ni por nombre ni por alias. Uso: ADBLOCK_RS_20=<node_modules/adblock-rs 0.8.x> node pruebas/prueba-motor-08.mjs <recursos-20.zip>
import { createRequire } from 'module'
import fs from 'fs'
import vm from 'vm'
import { leerZip } from '../bak/zip.mjs'

const require = createRequire(import.meta.url)
const { Engine, FilterSet } = require(process.env.ADBLOCK_RS_20 || 'adblock-rs')
const zip = process.argv[2]
if (!zip) { console.error('Uso: node pruebas/prueba-motor-08.mjs <recursos-20.zip>'); process.exit(2) }
const resources = JSON.parse(leerZip(fs.readFileSync(zip)).get('resources.json'))

let fallos = 0
const ok = (nombre, cond, detalle = '') => { fallos += !cond; console.log(`${cond ? 'ok  ' : 'FALLO'} ${nombre}${cond ? '' : ' ' + detalle}`) }

ok('formato en todos los recursos', resources.every((r) => r.name && Array.isArray(r.aliases) && r.kind?.mime && typeof r.content === 'string'))
const identificadores = resources.flatMap((r) => [r.name, ...r.aliases])
ok('sin nombres repetidos', new Set(identificadores).size === identificadores.length, identificadores.filter((n, i) => identificadores.indexOf(n) !== i).join())
const trusted = identificadores.filter((n) => n.startsWith('trusted-') || ['rpnt.js', 'replace-node-text.js'].includes(n))
ok('sin scriptlets «trusted» (nombre ni alias)', trusted.length === 0, trusted.join())
ok('sin dependencias sueltas (0.8.11 las ignora: todo va inlinado)', resources.every((r) => !r.dependencies?.length))
ok('sin recursos con permisos propios', resources.every((r) => !r.permission))
const scriptlets = resources.filter((r) => r.kind.mime === 'application/javascript')
console.log(`recursos: ${resources.length}, scriptlets/JS: ${scriptlets.length}`)

const reglas = [
  'example.com##+js(set-constant, flywebPrueba, true)',
  'example.com##+js(abort-on-property-read, anuncioMalo)',
  'example.com##+js(trusted-set-cookie, cookieSecreta1, no)',
  'example.com##+js(trusted-prevent-xhr, cookieSecreta2)',
  'example.com##+js(rpnt, cookieSecreta3, x)',
  '||ads.example.com^$script,redirect=noopjs'
]
// Con el permiso de uBlock Origin (bit 0), el que llevan las listas por defecto en el catálogo de Brave, y sin él.
for (const permisos of [0, 1]) {
  const fsx = new FilterSet(true); fsx.addFilters(reglas, { permissions: permisos })
  const motor = new Engine(fsx, true)
  motor.useResources(resources)
  const js = motor.urlCosmeticResources('https://example.com/').injected_script
  ok(`[permiso ${permisos}] hay script inyectado`, typeof js === 'string' && js.length > 0)
  let sintaxis = true; try { new vm.Script(js) } catch (e) { sintaxis = false; console.log(e.message) }
  ok(`[permiso ${permisos}] el script tiene sintaxis válida`, sintaxis)
  ok(`[permiso ${permisos}] no inyecta ningún scriptlet «trusted» (cookie, xhr, rpnt)`, !/cookieSecreta/.test(js), js.slice(0, 200))
  const win = { location: { href: 'https://example.com/', hostname: 'example.com' }, document: { currentScript: null, readyState: 'loading', addEventListener () {}, querySelectorAll () { return [] } },
    setTimeout: () => 1, console, Object, JSON, Array, String, Number, RegExp, Math, Error, Promise, Proxy, Reflect, Map, Set, WeakMap, Symbol, Date, Function, URL, TypeError,
    EventTarget: class {}, Node: class {}, Element: class {}, HTMLElement: class {}, Event: class {}, open: () => null, fetch: async () => ({}), Response: class {}, Request: class {} }
  win.window = win; win.self = win; win.globalThis = win; win.top = win
  const ctx = vm.createContext(win)
  let error = ''; try { vm.runInContext(js, ctx, { timeout: 2000 }) } catch (e) { error = e.message.slice(0, 200) }
  ok(`[permiso ${permisos}] se ejecuta sin excepciones`, error === '', error)
  ok(`[permiso ${permisos}] set-constant aplicado`, vm.runInContext('window.flywebPrueba === true', ctx))
  let aborta = false; try { vm.runInContext('window.anuncioMalo', ctx) } catch { aborta = true }
  ok(`[permiso ${permisos}] abort-on-property-read aplicado`, aborta)
  const red = motor.check('https://ads.example.com/x.js', 'https://example.com/', 'script', true)
  ok(`[permiso ${permisos}] redirect=noopjs`, red.matched && !!red.redirect, JSON.stringify(red).slice(0, 200))
}
process.exit(fallos ? 1 : 0)
