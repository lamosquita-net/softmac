// Recursos de Shields (resources.json) para FlyWeb 2.0 (Brave 1.69, adblock-rust 0.8.x).
//
// adblock-rust 0.8.11 (el de Brave 1.69) IGNORA el campo `dependencies` de los recursos: su doc dice «Currently ignored,
// but will be respected in a future release. Bundle any required dependencies inside the resource for now». Por eso
// los scriptlets van como en el empaquetador de Brave de esa época (lib/adBlockRustUtils.js, 2024): cada uno
// autocontenido, con sus dependencias inlinadas y envuelto en la plantilla {{1}}..{{9}} (wrap157, el mismo de la 1.x).
// Lo que cambia respecto a recursos-157.mjs es la política de «trusted»:
//   - se excluyen TODOS los scriptlets «trusted»: los que llevan requiresTrust, los que se llaman trusted-… y los que
//     tienen un alias trusted-… (uBlock Origin 1.75 no marca requiresTrust en todos: trusted-prevent-xhr.js no lo
//     lleva, y rpnt.js / replace-node-text.js son alias de uno «trusted»). Ninguna lista puede inyectarlos;
//   - si un scriptlet que se conserva depende de uno «trusted» (que no sea una función .fn), el generador falla.
// Como en la 1.x, no se incluyen los recursos propios de Brave (adblock-resources dist/resources.json): las reglas
// +js(brave-…) no hacen nada (README, «Pendiente», punto 5). Se quita google-ima-dai.js, como hace Brave.
//
// Uso: node recursos-20.mjs <checkout de uBlock Origin, o del empaquetador con submodules/uBlock> <salida.json>
// o como módulo: generarRecursos20(dir) (lo usa empaquetar.mjs con el uBlock Origin fijado en fijado.json).
// Necesita adblock-rs 0.8.x (npm, motor-08/) para uBlockResources: ADBLOCK_RS_20=/ruta/node_modules/adblock-rs
// Licencias: uBlock Origin GPLv3 (scriptlets y recursos); brave-core-crx-packager MPL-2.0.
import { createRequire } from 'module'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { wrap157 } from './recursos-157.mjs'

const require = createRequire(import.meta.url)

export const MIME_JS = 'application/javascript'
const EXCLUIDOS = new Set(['google-ima-dai.js'])

// Un scriptlet es «trusted» si lo dice uBlock Origin o si se llama (o se puede llamar) trusted-….
export const esTrusted = (s) => s.requiresTrust === true || s.name.startsWith('trusted-') || (s.aliases ?? []).some((a) => a.startsWith('trusted-'))

// Pura (se prueba sin motor): de la lista builtinScriptlets de uBlock Origin saca los scriptlets de la 2.0.
export function convertirScriptlets (builtinScriptlets) {
  const porNombre = Object.fromEntries(builtinScriptlets.map((s) => [s.name, s]))
  const conservados = builtinScriptlets.filter((s) => !s.name.endsWith('.fn') && !esTrusted(s))
  const scriptlets = conservados.map((s) => {
    const req = [...(s.dependencies ?? [])]
    for (let i = 0; i < req.length; i++) {
      if (!porNombre[req[i]]) throw new Error(`${s.name}: falta la dependencia ${req[i]}`)
      for (const d of porNombre[req[i]].dependencies ?? []) if (!req.includes(d)) req.push(d)
    }
    for (const d of req) {
      if (!d.endsWith('.fn') && esTrusted(porNombre[d])) throw new Error(`${s.name}: depende de ${d}, que es «trusted» y se excluye`)
    }
    const prelude = [...req].reverse().map((d) => porNombre[d].fn.toString()).join('\n')
    return {
      name: s.name,
      aliases: s.aliases ?? [],
      kind: { mime: MIME_JS },
      content: Buffer.from(wrap157(s.fn.toString(), prelude)).toString('base64')
    }
  })
  return { scriptlets, excluidos: builtinScriptlets.filter((s) => !s.name.endsWith('.fn') && esTrusted(s)).length }
}

export async function generarRecursos20 (dir, uBlockResources) {
  uBlockResources ??= require(process.env.ADBLOCK_RS_20 || 'adblock-rs').uBlockResources
  const sub = path.join(dir, 'submodules/uBlock')
  const uBO = fs.existsSync(sub) ? sub : dir
  const { builtinScriptlets } = await import(path.resolve(uBO, 'src/js/resources/scriptlets.js'))
  const { scriptlets, excluidos } = convertirScriptlets(builtinScriptlets)
  const resources = uBlockResources(path.join(uBO, 'src/web_accessible_resources'),
                                    path.join(uBO, 'src/js/redirect-resources.js')).filter((r) => !EXCLUIDOS.has(r.name))
  const nombres = new Set(resources.flatMap((r) => [r.name, ...(r.aliases ?? [])]))
  const repetidos = scriptlets.flatMap((s) => [s.name, ...s.aliases]).filter((n) => nombres.has(n))
  if (repetidos.length) console.warn(`aviso: nombres repetidos entre redirecciones y scriptlets (adblock-rust se queda con el primero): ${repetidos}`)
  resources.push(...scriptlets)
  return { resources, scriptlets: scriptlets.length, excluidos }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, out] = process.argv.slice(2)
  const { resources, scriptlets, excluidos } = await generarRecursos20(dir)
  fs.writeFileSync(out, JSON.stringify(resources))
  console.log(`${out}: ${scriptlets} scriptlets (${excluidos} «trusted» excluidos), ${resources.length} recursos`)
}
