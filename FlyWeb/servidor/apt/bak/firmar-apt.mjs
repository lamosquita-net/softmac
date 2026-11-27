// Firma del repositorio apt de FlyWeb para Linux (U4) en bak. Solo Node, sin dependencias: usa gpg, gpgv, dpkg-deb,
// dpkg, xz, rsync y runuser del sistema, y sqv si está.
//
// Como firmar-actualizacion.mjs con los DMG: bak solo firma un .deb cuyo SHA-256 y versión ha aprobado Titín en un
// fichero de root. El SHA-256 se comprueba antes de pasar el .deb a dpkg-deb, así que solo se analizan bytes aprobados.
// En el GNUPGHOME de bak solo está la subclave de firma (la principal como «stub», sin parte secreta): si encuentra la
// parte secreta de la principal, no firma. Diseño: U4-diseno.md v3, §3 y §4.
//
// Uso normal, una orden por versión (Titín, con sudo; el resto de valores sale de /etc/flyweb-firma/apt.conf):
//   sudo node firmar-apt.mjs publicar --version <3.2.2-52> --sha256 <sha256 del .deb>
// publicar apunta la aprobación «<sha256>  <versión>  stable» en el fichero de aprobados (de root), firma `pruebas`
// como el usuario de firma, comprueba lo publicado en ns2 y, solo si cuadra, firma `stable` y lo comprueba igual.
//
// Órdenes sueltas (como el usuario de firma):
//   node firmar-apt.mjs firmar --deb <URL https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/… o fichero> \
//        --version <3.2.2-50> --aprobados <fichero> --gnupghome <dir> --subclave <huella> --salida <dir> \
//        [--suite stable] [--subir <host ssh>] [--primera si]
//   node firmar-apt.mjs comprobar --version <v> --sha256 <sha> --salida <dir> [--suite stable]
//   node firmar-apt.mjs retirar --version <v> --gnupghome <dir> --subclave <huella> --salida <dir> [--suite] [--subir]
//   node firmar-apt.mjs refirmar --gnupghome <dir> --subclave <huella> --salida <dir> [--suite] [--subir]
//   node firmar-apt.mjs caducidad --gnupghome <dir> --subclave <huella>
//
// Fichero de aprobados: una línea por versión, «<sha256>  <versión>  [stable|pruebas]  # comentario». Sin tercera
// columna, la línea solo vale para `pruebas`; con `stable`, vale para las dos.
// En el índice (Packages) solo va la versión más nueva no retirada. Retirar la quita y vuelve a la anterior; apt nunca
// baja de versión, así que quien ya la tiene se queda en ella hasta la siguiente. Por eso firmar no acepta nunca un
// número igual o inferior al más alto publicado, aunque se haya retirado; y cada firma se verifica también con el
// llavero de esa versión más alta, que es el que tienen los equipos que la instalaron.
// refirmar vuelve a firmar el mismo índice con Date nuevo, después de cambiar de subclave (§4.4).
// Sin Valid-Until: apt no acepta un InRelease con Date menor que el de su caché, así que Date crece siempre o no se
// firma; y antes de firmar se comprueba el reloj de bak contra ns2, para que Date tampoco quede en el futuro.
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'

const HOST = 'apt.flyweb.lamosquita.net'
const POOL = 'pool/main/f/flyweb/'
const PAQUETE = 'flyweb'
const ARQ = 'amd64'
const LLAVERO_DEB = 'usr/share/keyrings/flyweb.gpg'
const MAX_PUBLICADAS = 2 // en pool/ se quedan las dos últimas
const GENERACIONES_BY_HASH = 3 // la actual y las dos anteriores
const MARGEN_RELOJ = 5 * 60 * 1000 // diferencia máxima entre el reloj de bak y el de ns2
const CONFIG = '/etc/flyweb-firma/apt.conf'
// Valores de publicar si apt.conf no dice otra cosa (los de la instalación del README).
const POR_DEFECTO = { aprobados: '/etc/flyweb-firma/apt-aprobados', gnupghome: '/var/lib/flyweb-firma/claves/apt',
  salida: '/var/lib/flyweb-firma/apt', subir: 'ns2-apt', usuario: 'flywebfirma' }
// Campos del control que pasan a Packages (lista blanca); Filename, Size y SHA256 los calcula bak.
export const CAMPOS = ['Package', 'Version', 'Architecture', 'Maintainer', 'Installed-Size', 'Pre-Depends', 'Depends',
  'Provides', 'Section', 'Priority', 'Homepage', 'Description']

const porDefecto = (cmd, args, { input, env } = {}) =>
  execFileSync(cmd, args, { input, env: env ?? process.env, stdio: ['pipe', 'pipe', 'pipe'], maxBuffer: 1 << 26 })

export const versionValida = (v) => /^\d{1,5}(\.\d{1,5}){1,3}-\d{1,6}$/.test(v ?? '')
const suiteValida = (s) => /^(stable|pruebas)$/.test(s)
const huellaValida = (h) => /^[0-9A-F]{40}$/.test(h ?? '')
const shaValido = (s) => /^[0-9a-f]{64}$/.test(s ?? '')
const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const urlDeb = (version) => `https://${HOST}/${POOL}${PAQUETE}_${version}_${ARQ}.deb`

// Mayor estricto según dpkg (épocas, ~, etc.).
export function mayor (a, b, ej = porDefecto) {
  try { ej('dpkg', ['--compare-versions', a, 'gt', b]); return true } catch { return false }
}

// Líneas del fichero de aprobados: «<sha256>  <versión>  [suite]». Las que no tienen esa forma no cuentan.
function lineasAprobadas (texto) {
  return texto.split('\n').map((l) => l.replace(/#.*/, '').trim().split(/\s+/)).filter((c) => c[0] && c.length <= 3)
    .map(([h, v, s]) => ({ sha: h.toLowerCase(), version: v, suite: s ?? null }))
    .filter((a) => shaValido(a.sha) && a.version && (a.suite === null || suiteValida(a.suite)))
}

// Una línea sin suite solo vale para `pruebas`; con `stable`, para las dos.
export function aprobado (texto, sha, version, suite = 'stable') {
  return lineasAprobadas(texto).some((a) => a.sha === sha && a.version === version &&
    (a.suite === 'stable' || suite === 'pruebas'))
}

// Date de Release: «Thu, 26 Nov 2026 11:24:01 UTC», al segundo.
export function fechaRelease (ms) {
  const d = new Date(Math.floor(ms / 1000) * 1000)
  return d.toUTCString().replace(/GMT$/, 'UTC')
}

// Párrafo de control estricto: un solo párrafo, sin líneas en blanco ni de solo espacios, sin campos repetidos, sin
// caracteres de control, sin campos de la lista blanca con otras mayúsculas, y las continuaciones empiezan por espacio.
// Así un control manipulado no puede inyectar otro párrafo ni otro Filename.
export function leerControl (texto) {
  if (texto.length > 65536) throw new Error('control demasiado grande')
  if (/[\x00-\x08\x0b-\x1f\x7f]/.test(texto)) throw new Error('control con caracteres de control')
  const lineas = texto.replace(/\n$/, '').split('\n')
  const campos = {}; let actual = null
  for (const l of lineas) {
    if (/^[A-Za-z0-9][A-Za-z0-9-]*:/.test(l)) {
      const nombre = l.slice(0, l.indexOf(':'))
      if (Object.keys(campos).some((k) => k.toLowerCase() === nombre.toLowerCase())) throw new Error(`control: campo repetido ${nombre}`)
      const deLista = CAMPOS.find((k) => k.toLowerCase() === nombre.toLowerCase())
      if (deLista && deLista !== nombre) throw new Error(`control: ${nombre} escrito con otras mayúsculas (se espera ${deLista})`)
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
  const otras = claves.filter((k) => k.tipo === 'ssb' && k.fpr !== o.subclave && k.token !== '#' && k.usos.includes('s') && !/[erd]/.test(k.validez))
  if (otras.length) log(`aviso: en ${o.gnupghome} hay otra subclave de firma con su parte secreta (${otras.map((k) => k.fpr).join(', ')}); tras rotar debe quedar solo una (§4.4)`)
  const caduca = sub.caduca ? Number(sub.caduca) * 1000 : null
  const meses = (n) => { const d = new Date(ahora); d.setUTCMonth(d.getUTCMonth() + n); return d.getTime() }
  if (caduca === null) log('aviso: la subclave no caduca (el diseño pide 2 años)')
  else if (caduca < meses(3)) throw new Error(`la subclave caduca el ${new Date(caduca).toISOString().slice(0, 10)}, en menos de 3 meses: no se firma. Hay que rotarla (§4.4)`)
  else if (caduca < meses(9)) log(`AVISO: la subclave caduca el ${new Date(caduca).toISOString().slice(0, 10)}, en menos de 9 meses: hay que rotarla (§4.4)`)
  return { caduca }
}

// El reloj de bak, contra la cabecera Date de ns2 (y, si ns2 no contesta, contra NTP). Si bak va adelantado, el Date
// firmado quedaría en el futuro: apt no lo aceptaría y bak no podría volver a firmar hasta esa fecha.
export async function comprobarReloj ({ fetchFn = fetch, ej = porDefecto, ahora = Date.now() } = {}) {
  let fecha = null
  try {
    const r = await fetchFn(`https://${HOST}/`, { method: 'HEAD', redirect: 'manual', cache: 'no-store' })
    const d = Date.parse(r.headers?.get?.('date') ?? '')
    if (!Number.isNaN(d)) fecha = d
  } catch {}
  if (fecha !== null) {
    const dif = ahora - fecha
    if (Math.abs(dif) > MARGEN_RELOJ) throw new Error(`el reloj de bak va ${Math.round(Math.abs(dif) / 1000)} s ${dif > 0 ? 'adelantado' : 'atrasado'} respecto a ${HOST}: no se firma (arregla la hora de bak)`)
    return 'ns2'
  }
  let ntp = ''
  try { ntp = ej('timedatectl', ['show', '-p', 'NTPSynchronized', '--value']).toString().trim() } catch {}
  if (ntp !== 'yes') throw new Error(`no se puede comprobar el reloj de bak: ${HOST} no contesta y timedatectl no dice NTPSynchronized=yes`)
  return 'ntp'
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

// Sin estado.json pero con un InRelease ya publicado (estado perdido o restaurado de una copia vieja), firmar
// empezaría la cuenta de versiones y de Date de cero: no se hace salvo con --primera si.
async function comprobarPrimera (o, estado, { fetchFn }) {
  if (estado.date !== null || !o.subir || o.primera === 'si') return
  const suite = o.suite ?? 'stable'
  let status
  try { status = (await fetchFn(`https://${HOST}/dists/${suite}/InRelease`, { method: 'HEAD', redirect: 'error', cache: 'no-store' })).status } catch (e) {
    throw new Error(`no hay estado de ${suite} en bak y no se puede mirar si ${HOST} ya tiene un índice (${e.message}): si es la primera publicación, añade --primera si`)
  }
  if (status !== 404) throw new Error(`no hay estado de ${suite} en bak pero ${HOST} ya tiene dists/${suite}/InRelease (HTTP ${status}): estado perdido o restaurado de una copia vieja. Recupera estado.json; solo si de verdad es la primera, --primera si`)
}

// El llavero que lleva dentro el .deb (usr/share/keyrings/flyweb.gpg), sacado con dpkg-deb -x. Tiene que ser un fichero
// normal, no un enlace.
function llaveroDeb (deb, ej) {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-apt-deb-'))
  try {
    const f = path.join(tmp, 'p.deb'); fs.writeFileSync(f, deb)
    ej('dpkg-deb', ['-x', f, path.join(tmp, 'x')])
    const k = path.join(tmp, 'x', LLAVERO_DEB)
    let st
    try { st = fs.lstatSync(k) } catch { throw new Error(`el .deb no lleva ${LLAVERO_DEB}: los equipos no podrían verificar el índice`) }
    if (!st.isFile()) throw new Error(`${LLAVERO_DEB} en el .deb no es un fichero normal (¿enlace?)`)
    return fs.readFileSync(k)
  } finally { fs.rmSync(tmp, { recursive: true, force: true }) }
}

// Verifica InRelease y Release.gpg con gpgv (y sqv si está) contra un llavero; las dos firmas tienen que ser de la
// subclave.
export function verificar (dist, llavero, subclave, ej = porDefecto) {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-apt-gpgv-'))
  try {
    const k = path.join(tmp, 'llavero.gpg'); fs.writeFileSync(k, llavero)
    const env = { ...process.env, GNUPGHOME: tmp }
    let st, stg
    try {
      st = ej('gpgv', ['--status-fd', '1', '--keyring', k, path.join(dist, 'InRelease')], { env }).toString()
      stg = ej('gpgv', ['--status-fd', '1', '--keyring', k, path.join(dist, 'Release.gpg'), path.join(dist, 'Release')], { env }).toString()
    } catch (e) { throw new Error(`gpgv no verifica el índice con el llavero del .deb: ${String(e.stderr ?? e.message).trim()}`) }
    const valida = (s) => s.split('\n').find((l) => l.startsWith('[GNUPG:] VALIDSIG '))?.split(' ')
    const vi = valida(st); const vg = valida(stg)
    if (!vi || vi[2] !== subclave) throw new Error(`InRelease no está firmado con la subclave ${subclave}`)
    if (!vg || vg[2] !== subclave) throw new Error(`Release.gpg no está firmado con la subclave ${subclave}`)
    if (vi[11] === subclave) throw new Error('el índice está firmado con la clave principal')
    let sqv = false
    try { ej('sqv', ['--version']); sqv = true } catch {}
    if (sqv) {
      try { ej('sqv', ['--keyring', k, path.join(dist, 'Release.gpg'), path.join(dist, 'Release')]) } catch (e) {
        throw new Error(`sqv no verifica el índice con el llavero del .deb: ${String(e.stderr ?? e.message).trim()}`)
      }
    }
    return { principal: vi[11], sqv }
  } finally { fs.rmSync(tmp, { recursive: true, force: true }) }
}

// Genera Packages, by-hash, Release, InRelease y Release.gpg en <dir>/web, firma y verifica. Devuelve el estado nuevo.
function generar (o, dir, estado, llaveros, { ej, ahora, log }) {
  const suite = o.suite ?? 'stable'
  const ms = Math.floor(ahora / 1000) * 1000
  if (estado.date !== null && ms <= estado.date) {
    const futuro = estado.date > ahora + MARGEN_RELOJ
    throw new Error(`el Date nuevo (${fechaRelease(ms)}) no es mayor que el publicado (${fechaRelease(estado.date)}): apt lo ignoraría. ` +
      (futuro ? 'El publicado está en el futuro: el reloj de bak se adelantó al firmarlo (ver «Reloj» en el README).' : '¿Reloj de bak atrasado?'))
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
  for (const k of llaveros) {
    try { verificar(dist, k.datos, o.subclave, ej) } catch (e) { throw new Error(`con ${k.de}: ${e.message}`) }
  }
  log(`firmado ${suite}: ${actual ? `${actual.version} (sha256 ${actual.sha256})` : 'índice vacío'}, Date ${fecha}; verificado con ${llaveros.map((k) => k.de).join(', ')}`)
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

const llaveroDe = (dir, p) => {
  const f = path.join(dir, 'llaveros', `${p.sha256}.gpg`)
  if (!fs.existsSync(f)) throw new Error(`falta el llavero de ${p.version} (${f})`)
  return { de: `el llavero de ${p.version}`, sha: p.sha256, datos: fs.readFileSync(f) }
}

// La versión más alta firmada nunca en la suite, publicada o retirada: su llavero es el que tienen los equipos que la
// instalaron (apt no baja de versión).
function masAlta (estado, ej) {
  return [...estado.publicadas, ...estado.retiradas].reduce((m, p) => (!m || mayor(p.version, m.version, ej) ? p : m), null)
}

// Llaveros con los que verificar: los que se pasan más el de la más alta firmada nunca, sin repetir.
function llaverosCon (dir, estado, base, ej) {
  const alta = masAlta(estado, ej)
  const todos = alta ? [...base, llaveroDe(dir, alta)] : base
  return todos.filter((k, i) => todos.findIndex((x) => x.sha === k.sha) === i)
}

export async function firmar (o, { fetchFn = fetch, ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  const suite = o.suite ?? 'stable'
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  await comprobarReloj({ fetchFn, ej, ahora })
  const deb = await leerDeb(o.deb, o.version, fetchFn)
  // Primero el SHA-256 aprobado; hasta aquí ningún programa ha leído el .deb.
  const sha = sha256(deb)
  if (!aprobado(fs.readFileSync(o.aprobados, 'utf8'), sha, o.version, suite)) {
    throw new Error(`.deb no aprobado para ${suite}: «${sha}  ${o.version}${suite === 'stable' ? '  stable' : ''}» no está en ${o.aprobados}`)
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
  await comprobarPrimera(o, estado, { fetchFn })
  for (const v of [...estado.publicadas, ...estado.retiradas].map((p) => p.version)) {
    if (!mayor(o.version, v, ej)) throw new Error(`la versión ${o.version} no es mayor que la ${v} ya publicada (aunque se haya retirado)`)
  }
  const llavero = llaveroDeb(deb, ej)
  fs.writeFileSync(path.join(dir, 'llaveros', `${sha}.gpg`), llavero)
  const nueva = { version: o.version, sha256: sha, tam: deb.length, filename: `${POOL}${PAQUETE}_${o.version}_${ARQ}.deb`, campos }
  const anterior = estado.publicadas[0]
  // Con el llavero del .deb nuevo (lo tendrán los equipos al instalarlo), con el del publicado ahora (el que tienen) y
  // con el de la más alta firmada nunca.
  const llaveros = llaverosCon(dir, estado, [{ de: `el llavero de ${o.version}`, sha, datos: llavero }, ...(anterior ? [llaveroDe(dir, anterior)] : [])], ej)
  const nuevo = generar(o, dir, { ...estado, publicadas: [nueva, ...estado.publicadas].slice(0, MAX_PUBLICADAS) }, llaveros, { ej, ahora, log })
  guardarEstado(dir, nuevo)
  subir(o, dir, { ej, log })
  return nueva
}

export async function retirar (o, { fetchFn = fetch, ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  await comprobarReloj({ fetchFn, ej, ahora })
  const estado = leerEstado(dir)
  const quitada = estado.publicadas.find((p) => p.version === o.version)
  if (!quitada) throw new Error(`la versión ${o.version} no está publicada en ${o.suite ?? 'stable'}`)
  const publicadas = estado.publicadas.filter((p) => p.version !== o.version)
  const llaveros = llaverosCon(dir, estado, [llaveroDe(dir, estado.publicadas[0]), ...(publicadas[0] ? [llaveroDe(dir, publicadas[0])] : [])], ej)
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

export async function refirmar (o, { fetchFn = fetch, ej = porDefecto, ahora = Date.now(), log = console.log } = {}) {
  const dir = preparar(o)
  comprobarClave(o, { ej, ahora, log })
  await comprobarReloj({ fetchFn, ej, ahora })
  const estado = leerEstado(dir)
  if (!estado.publicadas[0]) throw new Error('no hay ninguna versión publicada que volver a firmar')
  const nuevo = generar(o, dir, estado, llaverosCon(dir, estado, [llaveroDe(dir, estado.publicadas[0])], ej), { ej, ahora, log })
  guardarEstado(dir, nuevo)
  subir(o, dir, { ej, log })
}

// Comprueba lo publicado en ns2 contra lo que firmó bak, esquivando cachés: InRelease byte a byte (con el Date del
// estado), Packages y Packages.xz por su ruta y por by-hash, y en Packages la versión, el SHA-256 y el tamaño.
export async function comprobar (o, { fetchFn = fetch, log = console.log, intentos = 3, esperar = (ms) => new Promise((r) => setTimeout(r, ms)) } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  if (!shaValido(o.sha256)) throw new Error(`SHA-256 no válido: ${o.sha256}`)
  const suite = o.suite ?? 'stable'
  if (!suiteValida(suite)) throw new Error(`suite no válida: ${suite}`)
  const dir = path.join(o.salida, suite)
  const estado = leerEstado(dir)
  const p = estado.publicadas[0]
  if (!p || p.version !== o.version || p.sha256 !== o.sha256) throw new Error(`en el estado de ${suite} en bak no está publicada la ${o.version} con ese SHA-256`)
  const dist = path.join(dir, 'web', 'dists', suite); const bin = `main/binary-${ARQ}`
  const local = { inrelease: fs.readFileSync(path.join(dist, 'InRelease')), packages: fs.readFileSync(path.join(dist, bin, 'Packages')),
    xz: fs.readFileSync(path.join(dist, bin, 'Packages.xz')) }
  const bajar = async (ruta) => {
    const r = await fetchFn(`https://${HOST}/dists/${suite}/${ruta}?sin-cache=${crypto.randomBytes(6).toString('hex')}`,
      { redirect: 'error', cache: 'no-store', headers: { 'Cache-Control': 'no-cache', Pragma: 'no-cache' } })
    if (r.status !== 200) throw new Error(`${ruta}: HTTP ${r.status}`)
    return Buffer.from(await r.arrayBuffer())
  }
  const una = async () => {
    const inr = await bajar('InRelease')
    if (!inr.equals(local.inrelease)) throw new Error('el InRelease publicado no es el que ha firmado bak')
    const fecha = inr.toString().match(/^Date: (.*)$/m)?.[1]
    if (fecha !== fechaRelease(estado.date)) throw new Error(`el InRelease publicado tiene Date ${fecha}, no ${fechaRelease(estado.date)}`)
    const pk = await bajar(`${bin}/Packages`)
    if (!pk.equals(local.packages)) throw new Error('el Packages publicado no es el que ha firmado bak')
    for (const [nombre, datos] of [['Packages', local.packages], ['Packages.xz', local.xz]]) {
      const h = sha256(datos)
      if (!inr.includes(` ${h} `)) throw new Error(`InRelease no lista el SHA-256 de ${nombre}`)
      if (!(await bajar(`${bin}/by-hash/SHA256/${h}`)).equals(datos)) throw new Error(`by-hash de ${nombre} no coincide`)
    }
    const t = pk.toString()
    const campo = (k) => t.match(new RegExp(`^${k}: (.*)$`, 'm'))?.[1]
    if (campo('Version') !== o.version) throw new Error(`Packages publicado: Version ${campo('Version')}, no ${o.version}`)
    if (campo('SHA256') !== o.sha256) throw new Error(`Packages publicado: SHA256 ${campo('SHA256')}, no el aprobado`)
    if (campo('Size') !== String(p.tam)) throw new Error(`Packages publicado: Size ${campo('Size')}, no ${p.tam}`)
  }
  for (let i = 1; ; i++) {
    try { await una(); break } catch (e) {
      if (i >= intentos) throw new Error(`lo publicado en ${HOST}/dists/${suite} no cuadra: ${e.message}`)
      await esperar(5000)
    }
  }
  log(`comprobado ${suite} en ${HOST}: ${o.version}, sha256 ${o.sha256}, ${p.tam} bytes, Date ${fechaRelease(estado.date)}`)
}

// apt.conf: «clave=valor» por línea (subclave, y si cambian: aprobados, gnupghome, salida, subir, usuario).
export function leerConfig (f) {
  const c = { ...POR_DEFECTO }
  if (fs.existsSync(f)) {
    for (const l of fs.readFileSync(f, 'utf8').split('\n')) {
      const m = l.replace(/#.*/, '').trim().match(/^([a-z]+)\s*=\s*(\S+)$/)
      if (m) c[m[1]] = m[2]
    }
  }
  return c
}

// La aprobación la apunta root: el fichero tiene que ser de root y no escribible por nadie más.
function comprobarAprobados (f, uidRoot) {
  const st = fs.statSync(f)
  if (st.uid !== uidRoot) throw new Error(`${f} no es de root`)
  if (st.mode & 0o022) throw new Error(`${f} lo puede escribir alguien más que root (modo ${(st.mode & 0o777).toString(8)})`)
}

// Apunta «<sha256>  <versión>  stable» si no está. Si la versión ya está aprobada con otro SHA-256, se para.
function apuntarAprobacion (f, sha, version, { ahora, log }) {
  const texto = fs.readFileSync(f, 'utf8')
  const otra = lineasAprobadas(texto).find((a) => a.version === version && a.sha !== sha)
  if (otra) throw new Error(`la ${version} ya está aprobada en ${f} con otro SHA-256 (${otra.sha}): no se publica. Si ese SHA-256 ` +
    `está mal y no se llegó a firmar, quita su línea (sudo sed -i '/^${otra.sha}[[:space:]]/Id' ${f}) y repite la orden`)
  if (aprobado(texto, sha, version, 'stable')) { log(`aprobación ya apuntada en ${f}`); return }
  fs.appendFileSync(f, `${texto && !texto.endsWith('\n') ? '\n' : ''}${sha}  ${version}  stable  # publicar, ${new Date(ahora).toISOString()}\n`)
  log(`aprobación apuntada en ${f}: ${sha}  ${version}  stable`)
}

// Una orden por versión. Como root: apunta la aprobación y, como el usuario de firma, firma y comprueba `pruebas` y
// después `stable`. Si algo de `pruebas` no cuadra, `stable` no se toca. Se puede repetir: lo ya firmado no se vuelve
// a firmar, solo se comprueba.
export async function publicar (o, { comoUsuario = ejecutarComo, getuid = process.getuid, uidRoot = 0, ahora = Date.now(), log = console.log } = {}) {
  if (!versionValida(o.version)) throw new Error(`versión no válida: ${o.version}`)
  const sha = (o.sha256 ?? '').toLowerCase()
  if (!shaValido(sha)) throw new Error(`SHA-256 no válido (64 hexadecimales): ${o.sha256}`)
  if (getuid?.() !== uidRoot) throw new Error('publicar se ejecuta con sudo: apunta la aprobación en un fichero de root')
  const c = { ...leerConfig(o.config ?? CONFIG), ...Object.fromEntries(Object.entries(o).filter(([k]) => k in POR_DEFECTO || k === 'subclave')) }
  if (!huellaValida(c.subclave)) throw new Error(`falta la subclave en ${o.config ?? CONFIG} («subclave=<huella>») o no es válida`)
  if (!/^[a-z_][a-z0-9_-]*$/.test(c.usuario)) throw new Error(`usuario no válido: ${c.usuario}`)
  comprobarAprobados(c.aprobados, uidRoot)
  apuntarAprobacion(c.aprobados, sha, o.version, { ahora, log })
  const deb = o.deb ?? urlDeb(o.version)
  for (const suite of ['pruebas', 'stable']) {
    const estado = leerEstado(path.join(c.salida, suite))
    const ya = estado.publicadas[0]
    try {
      if (ya?.version === o.version) {
        if (ya.sha256 !== sha) throw new Error(`${suite} ya tiene la ${o.version} con otro SHA-256 (${ya.sha256})`)
        log(`${suite} ya tiene la ${o.version}: no se vuelve a firmar, solo se comprueba`)
      } else {
        await comoUsuario(c.usuario, ['firmar', '--deb', deb, '--version', o.version, '--aprobados', c.aprobados,
          '--gnupghome', c.gnupghome, '--subclave', c.subclave, '--salida', c.salida, '--suite', suite, '--subir', c.subir])
      }
      await comoUsuario(c.usuario, ['comprobar', '--version', o.version, '--sha256', sha, '--salida', c.salida, '--suite', suite])
    } catch (e) {
      throw new Error(`${suite}: ${e.message}${suite === 'pruebas' ? ' — stable no se ha tocado' : ''}`)
    }
  }
  log(`publicada ${o.version} en pruebas y stable (sha256 ${sha})`)
}

// Vuelve a ejecutar este mismo script como el usuario de firma, sin pasar por la shell.
function ejecutarComo (usuario, args) {
  try {
    execFileSync('runuser', ['-u', usuario, '--', process.execPath, fileURLToPath(import.meta.url), ...args], { stdio: ['ignore', 'inherit', 'pipe'] })
  } catch (e) { throw new Error(String(e.stderr ?? '').trim().replace(/^ERROR: /, '') || e.message) }
}

export async function ejecutar (argv, deps = {}) {
  const [orden, ...resto] = argv
  const o = {}
  for (let i = 0; i < resto.length; i += 2) o[resto[i].replace(/^--/, '').replace(/-(\w)/g, (_, c) => c.toUpperCase())] = resto[i + 1]
  const falta = (ks) => { for (const k of ks) if (!o[k]) throw new Error(`falta --${k}`) }
  if (orden === 'publicar') {
    falta(['version', 'sha256'])
    await publicar(o, deps)
  } else if (orden === 'firmar') {
    falta(['deb', 'version', 'aprobados', 'gnupghome', 'subclave', 'salida'])
    await firmar(o, deps)
  } else if (orden === 'comprobar') {
    falta(['version', 'sha256', 'salida'])
    await comprobar(o, deps)
  } else if (orden === 'retirar') {
    falta(['version', 'gnupghome', 'subclave', 'salida'])
    await retirar(o, deps)
  } else if (orden === 'refirmar') {
    falta(['gnupghome', 'subclave', 'salida'])
    await refirmar(o, deps)
  } else if (orden === 'caducidad') {
    falta(['gnupghome', 'subclave'])
    const { caduca } = comprobarClave(o, deps)
    ;(deps.log ?? console.log)(`subclave ${o.subclave}: ${caduca ? `caduca el ${new Date(caduca).toISOString().slice(0, 10)}` : 'no caduca'}`)
  } else {
    throw new Error('uso: firmar-apt.mjs publicar|firmar|comprobar|retirar|refirmar|caducidad … (ver la cabecera)')
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  ejecutar(process.argv.slice(2)).catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1) })
}
