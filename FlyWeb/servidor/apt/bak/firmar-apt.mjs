// Firma del repositorio apt de FlyWeb para Linux (U4) en bak. Solo Node, sin dependencias: usa gpg, gpgv, dpkg-deb,
// dpkg, xz y rsync del sistema, y sqv si está.
//
// Como firmar-actualizacion.mjs con los DMG: bak solo firma un .deb cuyo SHA-256 y versión ha aprobado Titín en un
// fichero de root. El SHA-256 se comprueba antes de pasar el .deb a dpkg-deb, así que solo se analizan bytes aprobados.
// En el GNUPGHOME de bak solo está la subclave de firma (la principal como «stub», sin parte secreta): si encuentra la
// parte secreta de la principal, no firma. Diseño: U4-diseno.md v3, §3 y §4.
//
// Uso:
//   node firmar-apt.mjs firmar --deb <URL https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/… o fichero> \
//        --version <3.2.2-50> --aprobados <fichero> --gnupghome <dir> --subclave <huella> --salida <dir> \
//        [--suite stable] [--subir <host ssh>]
//   node firmar-apt.mjs retirar --version <v> --gnupghome <dir> --subclave <huella> --salida <dir> [--suite] [--subir]
//   node firmar-apt.mjs refirmar --gnupghome <dir> --subclave <huella> --salida <dir> [--suite] [--subir]
//   node firmar-apt.mjs caducidad --gnupghome <dir> --subclave <huella>
//
// Fichero de aprobados: una línea por versión, «<sha256>  <versión>  # comentario».
// En el índice (Packages) solo va la versión más nueva no retirada. Retirar la quita y vuelve a la anterior; apt nunca
// baja de versión, así que quien ya la tiene se queda en ella hasta la siguiente. Por eso firmar no acepta nunca un
// número igual o inferior al más alto publicado, aunque se haya retirado. refirmar vuelve a firmar el mismo índice con
// Date nuevo, después de cambiar de subclave (§4.4).
// Sin Valid-Until: apt no acepta un InRelease con Date menor que el de su caché, así que Date crece siempre o no se firma.
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'

const HOST = 'apt.flyweb.lamosquita.net'
const POOL = 'pool/main/f/flyweb/'
const PAQUETE = 'flyweb'
const ARQ = 'amd64'
const LLAVERO_DEB = 'usr/share/keyrings/flyweb.gpg'
const MAX_PUBLICADAS = 2 // en pool/ se quedan las dos últimas
const GENERACIONES_BY_HASH = 3 // la actual y las dos anteriores
// Campos del control que pasan a Packages (lista blanca); Filename, Size y SHA256 los calcula bak.
export const CAMPOS = ['Package', 'Version', 'Architecture', 'Maintainer', 'Installed-Size', 'Pre-Depends', 'Depends',
  'Provides', 'Section', 'Priority', 'Homepage', 'Description']

const porDefecto = (cmd, args, { input, env } = {}) =>
  execFileSync(cmd, args, { input, env: env ?? process.env, stdio: ['pipe', 'pipe', 'pipe'], maxBuffer: 1 << 26 })

export const versionValida = (v) => /^\d{1,5}(\.\d{1,5}){1,3}-\d{1,6}$/.test(v ?? '')
const suiteValida = (s) => /^(stable|pruebas)$/.test(s)
const huellaValida = (h) => /^[0-9A-F]{40}$/.test(h ?? '')
const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')

// Mayor estricto según dpkg (épocas, ~, etc.).
export function mayor (a, b, ej = porDefecto) {
  try { ej('dpkg', ['--compare-versions', a, 'gt', b]); return true } catch { return false }
}

export function aprobado (texto, sha, version) {
  return texto.split('\n').some((l) => {
    const [h, v] = l.replace(/#.*/, '').trim().split(/\s+/)
    return h?.toLowerCase() === sha && v === version
  })
}

// Date de Release: «Thu, 26 Nov 2026 11:24:01 UTC», al segundo.
export function fechaRelease (ms) {
  const d = new Date(Math.floor(ms / 1000) * 1000)
  return d.toUTCString().replace(/GMT$/, 'UTC')
}

// Párrafo de control estricto: un solo párrafo, sin líneas en blanco ni de solo espacios, sin campos repetidos, y las
// continuaciones empiezan por espacio. Así un control manipulado no puede inyectar otro párrafo ni otro Filename.
export function leerControl (texto) {
  if (texto.length > 65536) throw new Error('control demasiado grande')
  const lineas = texto.replace(/\n$/, '').split('\n')
  const campos = {}; let actual = null
  for (const l of lineas) {
    if (/^[A-Za-z0-9][A-Za-z0-9-]*:/.test(l)) {
      const nombre = l.slice(0, l.indexOf(':'))
      if (Object.keys(campos).some((k) => k.toLowerCase() === nombre.toLowerCase())) throw new Error(`control: campo repetido ${nombre}`)
      campos[nombre] = l.slice(l.indexOf(':') + 1).trim(); actual = nombre
    } else if (/^[ \t]/.test(l) && l.trim() !== '' && actual) {
      campos[actual] += '\n' + l
    } else {
      throw new Error(`control: línea no válida ${JSON.stringify(l)} (línea en blanco o párrafo nuevo)`)
    }
  }
  return campos
}

export function parrafoPackages (campos, { filename, tam, sha256 }) {
  const lineas = []
  for (const k of CAMPOS) {
    if (campos[k] === undefined) continue
    const v = campos[k]
    if (k !== 'Description' && v.includes('\n')) throw new Error(`control: ${k} con varias líneas`)
    if (v.split('\n').some((l, i) => i > 0 && (!/^[ \t]/.test(l) || l.trim() === ''))) throw new Error(`control: ${k} con una línea que empieza un campo nuevo`)
    lineas.push(`${k}: ${v}`)
  }
  lineas.push(`Filename: ${filename}`, `Size: ${tam}`, `SHA256: ${sha256}`)
  return lineas.join('\n') + '\n'
}

export function release (suite, fecha, ficheros) {
  return [`Origin: FlyWeb`, `Label: FlyWeb`, `Suite: ${suite}`, `Codename: ${suite}`, `Date: ${fecha}`,
    `Architectures: ${ARQ}`, 'Components: main', 'Acquire-By-Hash: yes', 'SHA256:',
    ...ficheros.map((f) => ` ${f.sha} ${String(f.tam).padStart(10)} ${f.ruta}`)].join('\n') + '\n'
}

// La subclave en el GNUPGHOME de bak: v4, de firma, con su parte secreta; la principal sin la suya (stub).
export function comprobarClave (o, { ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  if (!huellaValida(o.subclave)) throw new Error(`huella de subclave no válida (40 hexadecimales en mayúsculas, v4): ${o.subclave}`)
  const env = { ...process.env, GNUPGHOME: o.gnupghome }
  const sec = ej('gpg', ['--batch', '--with-colons', '--fixed-list-mode', '--list-secret-keys'], { env }).toString()
  // Cada «sec»/«ssb» va seguida de su «fpr». El campo 15 es «#» cuando la parte secreta no está (stub).
  const claves = []; let ultima = null
  for (const c of sec.split('\n').map((l) => l.split(':'))) {
    if (c[0] === 'sec' || c[0] === 'ssb') ultima = { tipo: c[0], validez: c[1], caduca: c[6], usos: c[11], token: c[14] }
    else if (c[0] === 'fpr' && ultima) { claves.push({ ...ultima, fpr: c[9] }); ultima = null }
  }
  for (const p of claves.filter((k) => k.tipo === 'sec')) {
    if (p.fpr.length !== 40) throw new Error(`la clave ${p.fpr} no es OpenPGP v4 (el gpgv de 22.04 y Debian 12 no la verifica)`)
    if (p.token !== '#') throw new Error(`la clave principal ${p.fpr} tiene su parte secreta en ${o.gnupghome}; en bak solo debe estar la subclave (--export-secret-subkeys)`)
  }
  const sub = claves.find((k) => k.tipo === 'ssb' && k.fpr === o.subclave)
  if (!sub) throw new Error(`no está la subclave ${o.subclave} con su parte secreta en ${o.gnupghome}`)
  if (sub.token === '#') throw new Error(`la subclave ${o.subclave} no tiene su parte secreta en ${o.gnupghome}`)
  if (!sub.usos.includes('s')) throw new Error(`la subclave ${o.subclave} no es de firma`)
  if (/[erd]/.test(sub.validez)) throw new Error(`la subclave ${o.subclave} está caducada o revocada`)
  const caduca = sub.caduca ? Number(sub.caduca) * 1000 : null
  const meses = (n) => { const d = new Date(ahora); d.setUTCMonth(d.getUTCMonth() + n); return d.getTime() }
  if (caduca === null) log('aviso: la subclave no caduca (el diseño pide 2 años)')
  else if (caduca < meses(3)) throw new Error(`la subclave caduca el ${new Date(caduca).toISOString().slice(0, 10)}, en menos de 3 meses: no se firma. Hay que rotarla (§4.4)`)
  else if (caduca < meses(9)) log(`AVISO: la subclave caduca el ${new Date(caduca).toISOString().slice(0, 10)}, en menos de 9 meses: hay que rotarla (§4.4)`)
  return { caduca }
}

async function leerDeb (origen, version, fetchFn) {
  const nombre = `${PAQUETE}_${version}_${ARQ}.deb`
  if (/^[a-z]+:\/\//i.test(origen)) {
    const u = new URL(origen)
    if (u.protocol !== 'https:' || u.hostname !== HOST || u.port || u.search || u.pathname !== `/${POOL}${nombre}`) {
      throw new Error(`solo .deb por https de ${HOST}/${POOL}${nombre}: ${origen}`)
    }
    const r = await fetchFn(origen, { redirect: 'error' })
    if (r.status !== 200) throw new Error(`descarga: HTTP ${r.status}`)
    return Buffer.from(await r.arrayBuffer())
  }
  if (path.basename(origen) !== nombre) throw new Error(`el fichero tiene que llamarse ${nombre}: ${origen}`)
  return fs.readFileSync(origen)
}

function leerEstado (dir) {
  const f = path.join(dir, 'estado.json')
  return fs.existsSync(f) ? JSON.parse(fs.readFileSync(f, 'utf8')) : { date: null, publicadas: [], retiradas: [], byHash: [] }
}

// El llavero que lleva dentro el .deb (usr/share/keyrings/flyweb.gpg), sacado con dpkg-deb -x.
function llaveroDeb (deb, ej) {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-apt-deb-'))
  try {
    const f = path.join(tmp, 'p.deb'); fs.writeFileSync(f, deb)
    ej('dpkg-deb', ['-x', f, path.join(tmp, 'x')])
    const k = path.join(tmp, 'x', LLAVERO_DEB)
    if (!fs.existsSync(k)) throw new Error(`el .deb no lleva ${LLAVERO_DEB}: los equipos no podrían verificar el índice`)
    return fs.readFileSync(k)
  } finally { fs.rmSync(tmp, { recursive: true, force: true }) }
}

// Verifica InRelease y Release.gpg con gpgv (y sqv si está) contra un llavero; la firma tiene que ser de la subclave.
export function verificar (dist, llavero, subclave, ej = porDefecto) {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-apt-gpgv-'))
  try {
    const k = path.join(tmp, 'llavero.gpg'); fs.writeFileSync(k, llavero)
    const env = { ...process.env, GNUPGHOME: tmp }
    let st
    try {
      st = ej('gpgv', ['--status-fd', '1', '--keyring', k, path.join(dist, 'InRelease')], { env }).toString()
      ej('gpgv', ['--keyring', k, path.join(dist, 'Release.gpg'), path.join(dist, 'Release')], { env })
    } catch (e) { throw new Error(`gpgv no verifica el índice con el llavero del .deb: ${String(e.stderr ?? e.message).trim()}`) }
    const valida = st.split('\n').find((l) => l.startsWith('[GNUPG:] VALIDSIG '))?.split(' ')
    if (!valida || valida[2] !== subclave) throw new Error(`el índice no está firmado con la subclave ${subclave}`)
    if (valida[11] === subclave) throw new Error('el índice está firmado con la clave principal')
    let sqv = false
    try { ej('sqv', ['--version']); sqv = true } catch {}
    if (sqv) {
      try { ej('sqv', ['--keyring', k, path.join(dist, 'Release.gpg'), path.join(dist, 'Release')]) } catch (e) {
        throw new Error(`sqv no verifica el índice con el llavero del .deb: ${String(e.stderr ?? e.message).trim()}`)
      }
    }
    return { principal: valida[11], sqv }
  } finally { fs.rmSync(tmp, { recursive: true, force: true }) }
}

// Genera Packages, by-hash, Release, InRelease y Release.gpg en <dir>/web, firma y verifica. Devuelve el estado nuevo.
function generar (o, dir, estado, llaveros, { ej, ahora, log }) {
  const suite = o.suite ?? 'stable'
  const ms = Math.floor(ahora / 1000) * 1000
  if (estado.date !== null && ms <= estado.date) {
    throw new Error(`el Date nuevo (${fechaRelease(ms)}) no es mayor que el publicado (${fechaRelease(estado.date)}): apt lo ignoraría. ¿Reloj de bak atrasado?`)
  }
  const fecha = fechaRelease(ms)
  const web = path.join(dir, 'web'); const dist = path.join(web, 'dists', suite)
  const bin = path.join(dist, 'main', `binary-${ARQ}`); const bh = path.join(bin, 'by-hash', 'SHA256')
  fs.mkdirSync(bh, { recursive: true })
  const actual = estado.publicadas[0]
  const packages = Buffer.from(actual ? parrafoPackages(actual.campos, actual) : '')
  const xz = ej('xz', ['-9', '-c', '-T1'], { input: packages })
  const ficheros = [{ ruta: `main/binary-${ARQ}/Packages`, datos: packages }, { ruta: `main/binary-${ARQ}/Packages.xz`, datos: xz }]
    .map((f) => ({ ...f, sha: sha256(f.datos), tam: f.datos.length }))
  for (const f of ficheros) {
    fs.writeFileSync(path.join(bh, f.sha), f.datos)
    fs.writeFileSync(path.join(dist, f.ruta), f.datos)
  }
  const gen = [...new Set(ficheros.map((f) => f.sha))]
  const byHash = [gen, ...estado.byHash.filter((g) => g.join() !== gen.join())].slice(0, GENERACIONES_BY_HASH)
  const guardar = new Set(byHash.flat())
  for (const f of fs.readdirSync(bh)) if (!guardar.has(f)) fs.rmSync(path.join(bh, f))
  const rel = release(suite, fecha, ficheros)
  if (/^Valid-Until:/m.test(rel)) throw new Error('Release con Valid-Until')
  fs.writeFileSync(path.join(dist, 'Release'), rel)
  const env = { ...process.env, GNUPGHOME: o.gnupghome }
  const comun = ['--batch', '--yes', '--local-user', `${o.subclave}!`, '--digest-algo', 'SHA512']
  ej('gpg', [...comun, '--clearsign', '--output', path.join(dist, 'InRelease'), path.join(dist, 'Release')], { env })
  ej('gpg', [...comun, '--detach-sign', '--armor', '--output', path.join(dist, 'Release.gpg'), path.join(dist, 'Release')], { env })
  for (const k of llaveros) verificar(dist, k.datos, o.subclave, ej)
  log(`firmado ${suite}: ${actual ? `${actual.version} (sha256 ${actual.sha256})` : 'índice vacío'}, Date ${fecha}; verificado con ${llaveros.map((k) => k.de).join(' y ')}`)
  return { ...estado, date: ms, byHash }
}

function guardarEstado (dir, estado) {
  fs.writeFileSync(path.join(dir, 'estado.json'), JSON.stringify(estado, null, 2))
}

// Orden de subida (§4.2): by-hash nuevos; InRelease, Release y Release.gpg; Packages planos; y en otra pasada, los
// by-hash viejos (con --delete solo ahí). El .deb lo sube antes la Ubuntu a pool/, con su propia clave.
export function subir (o, dir, { ej = porDefecto, log = console.log } = {}) {
  if (!o.subir) return
  const suite = o.suite ?? 'stable'
  const dist = path.join(dir, 'web', 'dists', suite); const rd = `${o.subir}:dists/${suite}`
  const bin = `main/binary-${ARQ}`
  const r = (args) => ej('rsync', ['-t', '--chmod=D755,F644', ...args])
  r(['-r', path.join(dist, bin, 'by-hash') + '/', `${rd}/${bin}/by-hash/`])
  r(['InRelease', 'Release', 'Release.gpg'].map((f) => path.join(dist, f)).concat(`${rd}/`))
  r(['Packages', 'Packages.xz'].map((f) => path.join(dist, bin, f)).concat(`${rd}/${bin}/`))
  r(['-r', '--delete', path.join(dist, bin, 'by-hash') + '/', `${rd}/${bin}/by-hash/`])
  log(`subido a ${rd}`)
}

function preparar (o) {
  const suite = o.suite ?? 'stable'
  if (!suiteValida(suite)) throw new Error(`suite no válida: ${suite}`)
  const dir = path.join(o.salida, suite)
  fs.mkdirSync(path.join(dir, 'llaveros'), { recursive: true })
  return dir
}

const llaveroDe = (dir, p) => ({ de: `el llavero de ${p.version}`, datos: fs.readFileSync(path.join(dir, 'llaveros', `${p.sha256}.gpg`)) })

export async function firmar (o, { fetchFn = fetch, ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  const deb = await leerDeb(o.deb, o.version, fetchFn)
  // Primero el SHA-256 aprobado; hasta aquí ningún programa ha leído el .deb.
  const sha = sha256(deb)
  if (!aprobado(fs.readFileSync(o.aprobados, 'utf8'), sha, o.version)) {
    throw new Error(`.deb no aprobado: «${sha}  ${o.version}» no está en ${o.aprobados}`)
  }
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-apt-'))
  let campos
  try {
    const f = path.join(tmp, 'p.deb'); fs.writeFileSync(f, deb)
    campos = leerControl(ej('dpkg-deb', ['-I', f, 'control']).toString())
  } finally { fs.rmSync(tmp, { recursive: true, force: true }) }
  if (campos.Package !== PAQUETE) throw new Error(`Package ${campos.Package}: solo se firma ${PAQUETE}`)
  if (campos.Version !== o.version) throw new Error(`el .deb es la versión ${campos.Version}, no la ${o.version} aprobada`)
  if (campos.Architecture !== ARQ) throw new Error(`Architecture ${campos.Architecture}: solo ${ARQ}`)
  const estado = leerEstado(dir)
  for (const v of [...estado.publicadas, ...estado.retiradas].map((p) => p.version)) {
    if (!mayor(o.version, v, ej)) throw new Error(`la versión ${o.version} no es mayor que la ${v} ya publicada (aunque se haya retirado)`)
  }
  const llavero = llaveroDeb(deb, ej)
  fs.writeFileSync(path.join(dir, 'llaveros', `${sha}.gpg`), llavero)
  const nueva = { version: o.version, sha256: sha, tam: deb.length, filename: `${POOL}${PAQUETE}_${o.version}_${ARQ}.deb`, campos }
  const anterior = estado.publicadas[0]
  // Con el llavero del .deb nuevo (lo tendrán los equipos al instalarlo) y con el del publicado ahora (el que tienen).
  const llaveros = [{ de: `el llavero de ${o.version}`, datos: llavero }, ...(anterior ? [llaveroDe(dir, anterior)] : [])]
  const nuevo = generar(o, dir, { ...estado, publicadas: [nueva, ...estado.publicadas].slice(0, MAX_PUBLICADAS) }, llaveros, { ej, ahora, log })
  guardarEstado(dir, nuevo)
  subir(o, dir, { ej, log })
  return nueva
}

export function retirar (o, { ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  const estado = leerEstado(dir)
  const quitada = estado.publicadas.find((p) => p.version === o.version)
  if (!quitada) throw new Error(`la versión ${o.version} no está publicada en ${o.suite ?? 'stable'}`)
  const publicadas = estado.publicadas.filter((p) => p.version !== o.version)
  const llaveros = [llaveroDe(dir, estado.publicadas[0]), ...(publicadas[0] && publicadas[0] !== estado.publicadas[0] ? [llaveroDe(dir, publicadas[0])] : [])]
  const sello = new Date(ahora).toISOString().replace(/[:.]/g, '-')
  const nuevo = generar(o, dir, { ...estado, publicadas,
    retiradas: [...estado.retiradas, { version: quitada.version, sha256: quitada.sha256, retirada: new Date(ahora).toUTCString() }] }, llaveros, { ej, ahora, log })
  if (fs.existsSync(path.join(dir, 'estado.json'))) fs.copyFileSync(path.join(dir, 'estado.json'), path.join(dir, `estado.json.${sello}`))
  guardarEstado(dir, nuevo)
  log(`retirada ${o.version}; en el índice queda: ${publicadas[0]?.version ?? 'ninguna'}`)
  if (estado.publicadas[0].version === o.version) log('ojo: era la más nueva; quien ya la tiene se queda en ella hasta que se publique una posterior')
  subir(o, dir, { ej, log })
  return publicadas[0] ?? null
}

export function refirmar (o, { ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  const estado = leerEstado(dir)
  if (!estado.publicadas[0]) throw new Error('no hay ninguna versión publicada que volver a firmar')
  const nuevo = generar(o, dir, estado, [llaveroDe(dir, estado.publicadas[0])], { ej, ahora, log })
  guardarEstado(dir, nuevo)
  subir(o, dir, { ej, log })
}

async function main () {
  const [orden, ...resto] = process.argv.slice(2)
  const o = {}
  for (let i = 0; i < resto.length; i += 2) o[resto[i].replace(/^--/, '').replace(/-(\w)/g, (_, c) => c.toUpperCase())] = resto[i + 1]
  const falta = (ks) => { for (const k of ks) if (!o[k]) throw new Error(`falta --${k}`) }
  if (orden === 'firmar') {
    falta(['deb', 'version', 'aprobados', 'gnupghome', 'subclave', 'salida'])
    await firmar(o)
  } else if (orden === 'retirar') {
    falta(['version', 'gnupghome', 'subclave', 'salida'])
    retirar(o)
  } else if (orden === 'refirmar') {
    falta(['gnupghome', 'subclave', 'salida'])
    refirmar(o)
  } else if (orden === 'caducidad') {
    falta(['gnupghome', 'subclave'])
    const { caduca } = comprobarClave(o)
    console.log(`subclave ${o.subclave}: ${caduca ? `caduca el ${new Date(caduca).toISOString().slice(0, 10)}` : 'no caduca'}`)
  } else {
    console.error('Uso: firmar-apt.mjs firmar|retirar|refirmar|caducidad … (ver la cabecera)')
    process.exit(2)
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === new URL(import.meta.url).pathname) {
  main().catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1) })
}
