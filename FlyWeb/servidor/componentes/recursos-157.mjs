// Recursos de Shields (resources.json) compatibles con FlyWeb 1.57 (adblock-rust 0.7.x).
//
// FlyWeb 1.57 lleva adblock-rust 0.7.9: sus scriptlets son plantillas con argumentos {{1}}..{{9}} y no
// conocen las dependencias ni "scriptletGlobals" de los scriptlets actuales de uBlock Origin. Este
// generador hace lo mismo que el empaquetador de Brave de agosto de 2023 (brave-core-crx-packager
// c74d7d2, wrapScriptletArgFormat): mete las dependencias dentro de cada scriptlet y lo envuelve en
// el formato antiguo. Añade "const scriptletGlobals = {}", que los scriptlets actuales necesitan.
// Excluye los scriptlets "trusted" (requiresTrust), como hacía Brave entonces.
//
// Uso: node recursos-157.mjs <checkout de brave-core-crx-packager con submodules/uBlock> <salida.json>
// o como módulo: generarRecursos(packager) (lo usa empaquetar.mjs).
// Necesita adblock-rs 0.7.x (npm) para uBlockResources: ADBLOCK_RS=/ruta/node_modules/adblock-rs
// Licencias: uBlock Origin GPLv3 (scriptlets y recursos); brave-core-crx-packager MPL-2.0.
import { createRequire } from 'module'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const require = createRequire(import.meta.url)

export const wrap157 = (fnString, prelude) => `{
  const args = ['{{1}}', '{{2}}', '{{3}}', '{{4}}', '{{5}}', '{{6}}', '{{7}}', '{{8}}', '{{9}}'];
  let last_arg_index = 0;
  for (const arg_index in args) {
    if (args[arg_index] === '{{' + (Number(arg_index) + 1) + '}}') {
      break;
    }
    last_arg_index += 1;
  }
  const scriptletGlobals = {};
  ${prelude}
  (${fnString})(...args.slice(0, last_arg_index))
}`

export async function generarRecursos (packager) {
  const { uBlockResources } = require(process.env.ADBLOCK_RS || 'adblock-rs')
  const uBO = path.join(packager, 'submodules/uBlock')
  const { builtinScriptlets } = await import(path.resolve(uBO, 'src/js/resources/scriptlets.js'))
  const byName = Object.fromEntries(builtinScriptlets.map(s => [s.name, s]))
  const scriptlets = builtinScriptlets.filter(s => !s.name.endsWith('.fn') && !s.requiresTrust).map(s => {
    const req = [...(s.dependencies ?? [])]
    for (let i = 0; i < req.length; i++) {
      for (const d of byName[req[i]]?.dependencies ?? []) if (!req.includes(d)) req.push(d)
    }
    const prelude = [...req].reverse().map(d => {
      if (!byName[d]) throw new Error(`${s.name}: falta la dependencia ${d}`)
      return byName[d].fn.toString()
    }).join('\n')
    return {
      name: s.name,
      aliases: s.aliases ?? [],
      kind: { mime: 'application/javascript' },
      content: Buffer.from(wrap157(s.fn.toString(), prelude)).toString('base64'),
    }
  })
  const resources = uBlockResources(path.join(uBO, 'src/web_accessible_resources'),
                                    path.join(uBO, 'src/js/redirect-resources.js'))
  resources.push(...scriptlets)
  return { resources, scriptlets: scriptlets.length }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [packager, out] = process.argv.slice(2)
  const { resources, scriptlets } = await generarRecursos(packager)
  fs.writeFileSync(out, JSON.stringify(resources))
  console.log(`${out}: ${scriptlets} scriptlets, ${resources.length} recursos`)
}
