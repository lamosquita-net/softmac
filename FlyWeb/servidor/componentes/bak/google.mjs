// Espejo de componentes de Google (F2.2). Lo llama firmar.mjs con --google; también se puede ejecutar solo, sin
// subir nada, para probarlo (el CI lo hace contra Google de verdad): node google.mjs --salida <dir>
//
// Pide a update.googleapis.com, como un Chrome 116 de Mac, la versión vigente de cada componente de GOOGLE; descarga
// los CRX nuevos y los deja en <salida>/release/<id>/ SIN TOCARLOS: el navegador comprueba la firma de Google, así
// que no hace falta volver a firmarlos. Los navegadores nunca hablan con Google; solo bak, una vez al día.
//
// Antes de aceptar un CRX: SHA-256 y tamaño iguales a los de la respuesta; CRX3 con todas sus firmas válidas, el ID
// del componente y la prueba del publicador de Google (la misma clave que exige Chromium 116); versión posterior a la
// ya copiada (un CRLSet antiguo «des-revocaría» certificados). Widevine queda fuera a propósito.
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { verificarCrx } from './crx3.mjs'

export const GOOGLE = {
  hfnkpimlhhgieaddgfemjhofmfblmnib: 'CRLSet',
  khaoiebndkojlmppeemjhbpbandiljpe: 'File Type Policies',
  efniojlnjndmcbiieegkicadnoecjjef: 'PKI Metadata',
  giekcmmlnklenlaomppkphknjmnnpneh: 'Certificate Error Assistant',
  jflookgnkcckhobaglndicnbbgbonegd: 'Safety Tips',
  ggkkehgbnfjpeggfpleeakpidbkibbmn: 'Crowd Deny',
  laoigpblnllgcgjnjnllmfolckpjlhki: 'MEI Preload'
}
// kPublisherKeyHash de Chromium 116 (components/crx_file/crx_verifier.cc): SHA-256 de la clave ECDSA de Google.
export const GOOGLE_PUBLICADOR = '61f7f2a6bfcf74cd0bc1fe2497cc9b04254c658f79f2145392867ea8366367cf'
const SERVIDOR = 'https://update.googleapis.com/service/update2/json'
const HOSTS = new Set(['dl.google.com', 'edgedl.me.gvt1.com', 'redirector.gvt1.com', 'www.google.com'])
const MAXIMO = 32 * 1024 * 1024
const NAVEGADOR = '116.0.5845.188'

// Versiones como base::Version: de 1 a 4 números separados por puntos.
export const versionValida = (v) => typeof v === 'string' && /^\d{1,10}(\.\d{1,10}){0,3}$/.test(v) && v.split('.').every((p) => +p < 2 ** 32)
export const comparar = (a, b) => {
  const x = a.split('.').map(Number); const y = b.split('.').map(Number)
  for (let i = 0; i < Math.max(x.length, y.length); i++) if ((x[i] ?? 0) !== (y[i] ?? 0)) return (x[i] ?? 0) > (y[i] ?? 0) ? 1 : -1
  return 0
}
const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const fichero = (v) => `extension_${v.replace(/\./g, '_')}.crx`

const peticion = () => JSON.stringify({ request: {
  protocol: '3.1', dedup: 'cr', acceptformat: 'crx3', ismachine: 0, prodversion: NAVEGADOR, updaterversion: NAVEGADOR,
  prodchannel: 'stable', updaterchannel: 'stable', '@os': 'mac', arch: 'x64', nacl_arch: 'x86-64',
  os: { platform: 'Mac OS X', version: '10.14.6', arch: 'x86_64' },
  // Siempre 0.0.0.0: la respuesta trae el CRX completo de la versión vigente, sin diferencias.
  app: Object.keys(GOOGLE).map((appid) => ({ appid, version: '0.0.0.0', enabled: true, updatecheck: {} }))
} })

// salida: directorio de salida de firmar.mjs. Lee y escribe <salida>/google.json (lo ya copiado).
// Devuelve { componentes: [{ id, titulo, version, sha256, tamano }], fallos: [texto] }. Nunca lanza.
export async function espejoGoogle (salida, { fetch = globalThis.fetch, servidor = SERVIDOR, publicador = GOOGLE_PUBLICADOR, log = console.log } = {}) {
  const ESTADO = path.join(salida, 'google.json')
  const estado = fs.existsSync(ESTADO) ? JSON.parse(fs.readFileSync(ESTADO, 'utf8')) : {}
  const fallos = []
  let apps = []
  try {
    const r = await fetch(servidor, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: peticion() })
    if (r.status !== 200) throw new Error(`HTTP ${r.status}`)
    apps = JSON.parse((await r.text()).replace(/^\)\]\}'\s*/, '')).response?.app ?? []
  } catch (e) { fallos.push(`google: consulta: ${e.message}`) }

  for (const [id, titulo] of Object.entries(GOOGLE)) {
    if (!apps.length) break
    try {
      const a = apps.find((x) => x.appid === id)
      const u = a?.updatecheck
      if (!u || u.status !== 'ok') throw new Error(`sin actualización (${a?.status ?? 'falta'} / ${u?.status ?? '-'})`)
      const v = u.manifest?.version; const p = u.manifest?.packages?.package
      if (!versionValida(v)) throw new Error(`versión no válida: ${v}`)
      if (!Array.isArray(p) || p.length !== 1) throw new Error('se esperaba un solo paquete')
      const { hash_sha256: hash, size, name } = p[0]
      if (!/^[0-9a-f]{64}$/.test(hash) || !Number.isInteger(size) || size < 1 || size > MAXIMO || !/^[A-Za-z0-9._-]+$/.test(name)) throw new Error('paquete mal descrito')
      const prev = estado[id]
      if (prev && prev.version === v) {
        if (prev.sha256 !== hash) throw new Error(`misma versión ${v} con otro SHA-256`)
        if (fs.existsSync(path.join(salida, 'release', id, fichero(v)))) { log(`= ${titulo.padEnd(46)} sin cambios (${v})`); continue }
      } else if (prev && comparar(v, prev.version) < 0) throw new Error(`versión ${v} anterior a la copiada (${prev.version})`)

      const base = (u.urls?.url ?? []).map((x) => x.codebase).find((c) => {
        try { const h = new URL(c); return h.protocol === 'https:' && HOSTS.has(h.hostname) } catch { return false }
      })
      if (!base) throw new Error('sin URL https de Google')
      const d = await fetch(new URL(name, base))
      if (d.status !== 200) throw new Error(`descarga: HTTP ${d.status}`)
      const crx = Buffer.from(await d.arrayBuffer())
      if (crx.length !== size || sha256(crx) !== hash) throw new Error('el CRX no coincide con el tamaño o el SHA-256 anunciados')
      const motivo = verificarCrx(crx, id, publicador)
      if (motivo) throw new Error(`CRX rechazado: ${motivo}`)

      const dir = path.join(salida, 'release', id); fs.mkdirSync(dir, { recursive: true })
      fs.writeFileSync(path.join(dir, fichero(v) + '.tmp'), crx); fs.renameSync(path.join(dir, fichero(v) + '.tmp'), path.join(dir, fichero(v)))
      const quedan = new Set([fichero(v), prev && fichero(prev.version)])
      for (const f of fs.readdirSync(dir)) if (!quedan.has(f)) fs.rmSync(path.join(dir, f))
      estado[id] = { titulo, version: v, sha256: hash, tamano: size }
      log(`+ ${titulo.padEnd(46)} ${v} ${id}`)
    } catch (e) { fallos.push(`google ${titulo}: ${e.message}`) }
  }
  fs.writeFileSync(ESTADO + '.tmp', JSON.stringify(estado, null, 1)); fs.renameSync(ESTADO + '.tmp', ESTADO)
  return { componentes: Object.entries(estado).filter(([id]) => GOOGLE[id]).map(([id, e]) => ({ id, ...e })), fallos }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const i = process.argv.indexOf('--salida'); const salida = i > 0 && process.argv[i + 1]
  if (!salida) { console.error('Uso: node google.mjs --salida <dir>'); process.exit(2) }
  fs.mkdirSync(salida, { recursive: true })
  const r = await espejoGoogle(salida)
  for (const f of r.fallos) console.error('FALLO ' + f)
  process.exit(r.fallos.length ? 1 : 0)
}
