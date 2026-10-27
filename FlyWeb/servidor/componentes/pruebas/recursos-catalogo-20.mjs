// Prueba sin red ni motor de recursos-20.mjs (convertirScriptlets) y catalogo-20.mjs (construirCatalogoV2).
// Uso: node pruebas/recursos-catalogo-20.mjs
import { convertirScriptlets, esTrusted } from '../recursos-20.mjs'
import { construirCatalogoV2 } from '../catalogo-20.mjs'

let fallos = 0
const ok = (nombre, cond) => { fallos += !cond; console.log(`${cond ? 'ok  ' : 'FALLO'} ${nombre}`) }
const lanza = (f) => { try { f(); return '' } catch (e) { return e.message } }

// --- Recursos ---
const fn = (t) => ({ toString: () => t })
const s = (name, extra = {}) => ({ name, fn: fn(`function ${name.replace(/\W/g, '_')}(){}`), ...extra })
const base = [s('a.fn'), s('b.fn', { dependencies: ['a.fn'] }), s('set-constant.js', { aliases: ['set.js'], dependencies: ['b.fn'] }),
  s('trusted-x.js', { requiresTrust: true }), s('trusted-prevent-xhr.js'), s('replace-node-text.js', { aliases: ['trusted-rpnt.js', 'rpnt.js'] }),
  s('con-alias.js', { aliases: ['trusted-viejo.js'] })]
const r = convertirScriptlets(base)
const nombres = r.scriptlets.map((x) => x.name).join()
ok('quedan solo los que no son «trusted» ni .fn', nombres === 'set-constant.js', nombres)
ok('«trusted» excluidos por bandera, por nombre y por alias', r.excluidos === 4)
const sc = r.scriptlets[0]
const js = Buffer.from(sc.content, 'base64').toString()
ok('dependencias inlinadas (0.8.11 ignora `dependencies`), de la más profunda a la más cercana', js.indexOf('function a_fn') >= 0 && js.indexOf('function a_fn') < js.indexOf('function b_fn') && js.includes('(function set_constant_js(){})(...args.slice(0, last_arg_index))'))
ok('plantilla {{1}}..{{9}} y scriptletGlobals', js.includes("'{{9}}'") && js.includes('const scriptletGlobals = {}'))
ok('forma del recurso: sin dependencies ni permission', sc.aliases[0] === 'set.js' && sc.kind.mime === 'application/javascript' && Object.keys(sc).sort().join() === 'aliases,content,kind,name')
ok('esTrusted', esTrusted(s('trusted-a.js')) && esTrusted(s('x.js', { requiresTrust: true })) && esTrusted(s('x.js', { aliases: ['trusted-y.js'] })) && !esTrusted(s('set-constant.js')))
ok('falta una dependencia', /falta la dependencia z\.fn/.test(lanza(() => convertirScriptlets([s('a.js', { dependencies: ['z.fn'] })]))))
ok('depende de un scriptlet «trusted»', /es «trusted»/.test(lanza(() => convertirScriptlets([s('trusted-t.js'), s('a.js', { dependencies: ['trusted-t.js'] })]))))
ok('depender de una función .fn sí vale', lanza(() => convertirScriptlets([s('t.fn'), s('a.js', { dependencies: ['t.fn'] })])) === '')

// --- Catálogo ---
const e = (uuid, extra = {}) => ({ uuid, title: uuid, desc: 'd', langs: [], sources: [{ url: `https://example.com/${uuid}.txt`, support_url: 'https://example.com/' }],
  hidden: false, default_enabled: false, permission_mask: 1, ...extra })
const brave = new Map([
  ['default', e('default', { hidden: true, default_enabled: true, first_party_protections: true })],
  ['priv', e('priv', { hidden: true, default_enabled: true, first_party_protections: true })],
  ['fp', e('fp', { hidden: true, default_enabled: true })],
  ['ES', e('ES', { langs: ['es'], first_party_protections: true, platforms: ['MAC'] })],
  ['mala', e('mala', { hidden: true, default_enabled: true, first_party_protections: false })]
])
const buscar = (u) => { if (!brave.has(u)) throw new Error(`UUID ${u} no está`); return brave.get(u) }
const clave = (n) => ({ id: `id-${n}`, b64: `clave-${n}` })
const listas = { defecto: ['default', 'priv'], primera_parte: ['fp'], regionales: ['ES'] }
const c = construirCatalogoV2(listas, buscar, clave)
ok('una entrada por componente (defecto fusionado)', c.length === 3 && c.map((x) => x.uuid).join() === 'default,fp,ES')
ok('ID y clave de los componentes de siempre', c[0].list_text_component.component_id === 'id-defecto' && c[1].list_text_component.component_id === 'id-primera-parte' && c[2].list_text_component.component_id === 'id-lista-ES')
ok('banderas copiadas de Brave', c[0].hidden && c[0].default_enabled && c[0].first_party_protections && c[0].permission_mask === 1 && !c[2].hidden && c[2].first_party_protections)
ok('platforms solo si Brave las pone', c[2].platforms[0] === 'MAC' && !('platforms' in c[0]))
ok('campos que lee la 1.69', ['uuid', 'url', 'title', 'langs', 'support_url', 'desc', 'hidden', 'default_enabled', 'first_party_protections', 'permission_mask', 'list_text_component'].every((k) => k in c[0]) && c[2].url === 'https://example.com/ES.txt')
ok('banderas distintas no se fusionan', /banderas distintas/.test(lanza(() => construirCatalogoV2({ ...listas, defecto: ['default', 'mala'] }, buscar, clave))))
ok('UUID que no está en Brave', /no está/.test(lanza(() => construirCatalogoV2({ ...listas, regionales: ['XX'] }, buscar, clave))))
process.exit(fallos ? 1 : 0)
