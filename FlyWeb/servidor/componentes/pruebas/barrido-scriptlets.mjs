import { createRequire } from 'module'; import path from 'path'
const require = createRequire(import.meta.url)
const uBO = path.join(process.env.PACKAGER, 'submodules/uBlock')
const { builtinScriptlets } = await import(path.join(uBO, 'src/js/resources/scriptlets.js'))
const depMap = Object.fromEntries(builtinScriptlets.map(s => [s.name, s]))
const missingDeps = new Set()
const items = builtinScriptlets.filter(s => !s.name.endsWith('.fn') && !s.requiresTrust).map(s => {
  const req = [...(s.dependencies ?? [])]
  for (let i = 0; i < req.length; i++) for (const d of depMap[req[i]]?.dependencies ?? []) if (!req.includes(d)) req.push(d)
  req.filter(d => !depMap[d]).forEach(d => missingDeps.add(`${s.name} -> ${d}`))
  let prelude = 'const scriptletGlobals = {};\n'; for (const d of [...req].reverse()) prelude += (depMap[d]?.fn.toString() ?? '') + '\n'
  return { name: s.name, code: `{ ${prelude}\n (${s.fn.toString()})('x', 'y') }` }
})
console.log('dependencias que faltan:', [...missingDeps])
const { chromium } = require(path.join(process.env.NODE_PATH_PW, 'playwright'))
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' }); const p = await b.newPage()
await p.goto('data:text/html,<p>x</p>')
const fails = []
for (const it of items) {
  const r = await p.evaluate(c => { try { (0, eval)(c); return null } catch (e) { return String(e).slice(0, 160) } }, it.code)
  if (r && /ReferenceError|SyntaxError/.test(r)) fails.push(`${it.name}: ${r}`)
}
console.log(`scriptlets: ${items.length}, con ReferenceError/SyntaxError: ${fails.length}`); fails.forEach(f => console.log('  ', f))
console.log('scriptlets "trusted" excluidos (como hacía Brave en 2023):', builtinScriptlets.filter(s => s.requiresTrust).length)
await b.close()
