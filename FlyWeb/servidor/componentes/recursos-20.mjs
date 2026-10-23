// Recursos de Shields (resources.json) para FlyWeb 2.0 (Brave 1.69, adblock-rust 0.8.x).
//
// A diferencia de recursos-157.mjs, aquí no se envuelven ni se inlinan los scriptlets: adblock-rust 0.8 admite
// `dependencies` por recurso y las resuelve él (formato del empaquetador actual de Brave, lib/adBlockRustUtils.js:
// name, aliases, kind.mime, content en base64, dependencies). Lo que se conserva de la política de la 1.x:
//   - se excluyen los scriptlets «trusted» (requiresTrust): ninguna lista puede inyectarlos;
//   - no se incluyen los recursos propios de Brave (adblock-resources dist/resources.json): las reglas +js(brave-…)
//     no hacen nada (README, «Qué NO hacemos», punto 5). Así no entra más código de terceros que uBlock Origin.
// Se quita además google-ima-dai.js, como hace Brave.
//
// Uso: node recursos-20.mjs <checkout de uBlock Origin, o del empaquetador con submodules/uBlock> <salida.json>
// o como módulo: generarRecursos20(dir) (lo usa empaquetar.mjs con el uBlock Origin fijado en fijado.json).
// Necesita adblock-rs 0.8.x (npm, motor-08/) para uBlockResources: ADBLOCK_RS_20=/ruta/node_modules/adblock-rs
// Licencias: uBlock Origin GPLv3 (scriptlets y recursos); brave-core-crx-packager MPL-2.0.
import { createRequire } from 'module'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const require = createRequire(import.meta.url)

export const MIME_JS = 'application/javascript'
const EXCLUIDOS = new Set(['google-ima-dai.js'])

// Pura (se prueba sin motor): de la lista builtinScriptlets de uBlock Origin saca los recursos de 0.8.
// Falla si un scriptlet que se conserva depende de uno que se excluye o que no existe.
export function convertirScriptlets (builtinScriptlets) {
  const porNombre = new Map(builtinScriptlets.map((s) => [s.name, s]))
  const conservados = builtinScriptlets.filter((s) => !s.requiresTrust)
  const nombres = new Set(conservados.map((s) => s.name))
  for (const s of conservados) {
    for (const d of s.dependencies ?? []) {
      if (!porNombre.has(d)) throw new Error(`${s.name}: falta la dependencia ${d}`)
      if (!nombres.has(d)) throw new Error(`${s.name}: depende de ${d}, que es «trusted» y se excluye`)
    }
  }
  const scriptlets = conservados.map((s) => ({
    name: s.name,
    aliases: s.aliases ?? [],
    kind: { mime: MIME_JS },
    content: Buffer.from(s.fn.toString()).toString('base64'),
    dependencies: s.dependencies ?? []
  }))
  return { scriptlets, excluidos: builtinScriptlets.length - conservados.length }
}

export async function generarRecursos20 (dir, uBlockResources) {
  uBlockResources ??= require(process.env.ADBLOCK_RS_20 || 'adblock-rs').uBlockResources
  const sub = path.join(dir, 'submodules/uBlock')
  const uBO = fs.existsSync(sub) ? sub : dir
  const { builtinScriptlets } = await import(path.resolve(uBO, 'src/js/resources/scriptlets.js'))
  const { scriptlets, excluidos } = convertirScriptlets(builtinScriptlets)
  const resources = uBlockResources(path.join(uBO, 'src/web_accessible_resources'),
                                    path.join(uBO, 'src/js/redirect-resources.js')).filter((r) => !EXCLUIDOS.has(r.name))
  const nombres = new Set(resources.map((r) => r.name))
  const repetidos = scriptlets.filter((s) => nombres.has(s.name)).map((s) => s.name)
  if (repetidos.length) console.warn(`aviso: nombres repetidos entre redirecciones y scriptlets (como en el empaquetador de Brave): ${repetidos}`)
  resources.push(...scriptlets)
  return { resources, scriptlets: scriptlets.length, excluidos }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, out] = process.argv.slice(2)
  const { resources, scriptlets, excluidos } = await generarRecursos20(dir)
  fs.writeFileSync(out, JSON.stringify(resources))
  console.log(`${out}: ${scriptlets} scriptlets (${excluidos} «trusted» excluidos), ${resources.length} recursos`)
}
