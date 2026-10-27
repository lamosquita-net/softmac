// Plan B: ¿los scriptlets actuales de uBO, convertidos al formato de 2023, funcionan en adblock-rust 0.7.x?
import { createRequire } from 'module'
import path from 'path'
import vm from 'vm'
const require = createRequire(import.meta.url)
const ABR = process.env.ADBLOCK_RS || 'adblock-rs'
const { Engine, FilterSet, uBlockResources } = require(ABR)
const CRXP = process.env.PACKAGER
const uBO = path.join(CRXP, 'submodules/uBlock')

// --- Conversión de 2023 (brave-core-crx-packager c74d7d2, lib/adBlockRustUtils.js) ---
const wrapScriptletArgFormat = (fnString, dependencyPrelude) => `{
  const args = ['{{1}}', '{{2}}', '{{3}}', '{{4}}', '{{5}}', '{{6}}', '{{7}}', '{{8}}', '{{9}}'];
  let last_arg_index = 0;
  for (const arg_index in args) {
    if (args[arg_index] === '{{' + (Number(arg_index) + 1) + '}}') {
      break;
    }
    last_arg_index += 1;
  }
  const scriptletGlobals = {};
  ${dependencyPrelude}
  (${fnString})(...args.slice(0, last_arg_index))
}`
const { builtinScriptlets } = await import(path.join(uBO, 'src/js/resources/scriptlets.js'))
const depMap = Object.fromEntries(builtinScriptlets.map(s => [s.name, s]))
let missing = 0
const converted = builtinScriptlets.filter(s => !s.name.endsWith('.fn') && !s.requiresTrust).map(s => {
  const req = [...(s.dependencies ?? [])]
  for (let i = 0; i < req.length; i++) for (const d of depMap[req[i]]?.dependencies ?? []) if (!req.includes(d)) req.push(d)
  let prelude = ''
  for (const d of req.reverse()) { if (!depMap[d]) { missing++; continue } prelude += depMap[d].fn.toString() + '\n' }
  return { name: s.name, aliases: s.aliases ?? [], kind: { mime: 'application/javascript' },
           content: Buffer.from(wrapScriptletArgFormat(s.fn.toString(), prelude)).toString('base64') }
})
const resources = uBlockResources(path.join(uBO, 'src/web_accessible_resources'), path.join(uBO, 'src/js/redirect-resources.js'))
resources.push(...converted)
console.log(`scriptlets convertidos: ${converted.length} (dependencias que faltan: ${missing}); recursos totales: ${resources.length}`)

// --- Motor 0.7.x con reglas de prueba ---
const rules = [
  'example.com##+js(set-constant, flywebPrueba, true)',
  'example.com##+js(abort-on-property-read, anuncioMalo)',
  'example.com##+js(no-setTimeout-if, publi)',
  'example.com##+js(json-prune, ads)',
  'example.com##+js(nowoif)',
  '||ads.example.com^$script,redirect=noopjs',
]
const fs_ = new FilterSet(true); fs_.addFilters(rules)
const engine = new Engine(fs_, true)
engine.useResources(resources)
const cos = engine.urlCosmeticResources('https://example.com/')
const js = cos.injected_script
console.log(`script inyectado: ${js.length} bytes`)
try { new vm.Script(js) ; console.log('sintaxis: OK') } catch (e) { console.log('sintaxis: ERROR', e.message) }

// Ejecutarlo en un entorno de navegador mínimo y comprobar efectos
const win = { location: { href: 'https://example.com/', hostname: 'example.com' }, document: { currentScript: null, readyState: 'loading', addEventListener(){}, querySelectorAll(){ return [] } },
              setTimeout: (f, t) => 1, console, Object, JSON, Array, String, Number, RegExp, Math, Error, Promise, Proxy, Reflect, Map, Set, WeakMap, Symbol, Date, Function, URL, TypeError,
              EventTarget: class {}, Node: class {}, Element: class {}, HTMLElement: class {}, Event: class {}, open: () => null, fetch: async () => ({}), Response: class {}, Request: class {} }
win.window = win; win.self = win; win.globalThis = win; win.top = win
const ctx = vm.createContext(win)
let errs = 0
try { vm.runInContext(js, ctx, { timeout: 2000 }) } catch (e) { errs++; console.log('ejecución: ERROR', e.message.slice(0, 200)) }
console.log('ejecución sin excepciones:', errs === 0)
console.log('set-constant aplicado (window.flywebPrueba === true):', vm.runInContext('window.flywebPrueba === true', ctx))
let abortOk = false; try { vm.runInContext('window.anuncioMalo', ctx) } catch (e) { abortOk = true }
console.log('abort-on-property-read aplicado (leer anuncioMalo lanza error):', abortOk)
const net = engine.check('https://ads.example.com/x.js', 'https://example.com/', 'script', true)
console.log('redirect=noopjs:', JSON.stringify({ matched: net.matched, redirect: net.redirect ? net.redirect.slice(0, 40) : null }))

// --- En un Chromium real ---
const { chromium } = require(path.join(process.env.NODE_PATH_PW, 'playwright'))
const http = await import('http')
const srv = http.createServer((q, r) => { r.writeHead(200, { 'content-type': 'text/html' }); r.end(`<!doctype html><script>
  window.__r = { setConst: window.flywebPrueba === true, abort: (() => { try { window.anuncioMalo; return false } catch (e) { return true } })(),
                 timeoutBlocked: (() => { let hit = false; const id = setTimeout(() => { hit = true }, 0); return typeof id })() }
</script>`) }).listen(18765)
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' })
const p = await b.newPage()
const errors = []; p.on('pageerror', e => errors.push(e.message)); p.on('console', m => { if (m.type() === 'error') errors.push(m.text()) })
await p.addInitScript(js)
await p.goto('http://127.0.0.1:18765/')
console.log('Chromium real:', JSON.stringify(await p.evaluate(() => window.__r)), 'errores:', errors.length, errors.slice(0, 3))
await b.close(); srv.close()
