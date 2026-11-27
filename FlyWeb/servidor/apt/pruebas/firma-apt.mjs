// Prueba del firmador del repositorio apt, sin red y con una clave OpenPGP desechable v4 (principal Ed25519 solo para
// certificar, fuera del GNUPGHOME de «bak»; allí solo la subclave de firma). Usa gpg, gpgv, dpkg-deb, dpkg, xz y ar del
// sistema. La firma la verifica gpgv contra el llavero que va dentro del .deb, como hará apt.
// Uso: node pruebas/firma-apt.mjs
// Con FLYWEB_APT_GUARDAR=<dir> deja allí el repositorio, el llavero y los .deb para verificarlos con el gpgv de 22.04,
// con sqv y con apt en contenedores (pruebas/contenedores.sh).
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { firmar, retirar, refirmar, comprobar, publicar, ejecutar, comprobarReloj, comprobarClave, leerControl, parrafoPackages, aprobado, mayor } from '../bak/firmar-apt.mjs'

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'fwapt-'))
let fallos = 0
const ok = (c, m) => { fallos += !c; console.log(`${c ? 'ok  ' : 'FALLO'} ${m}`) }
const falla = async (f, texto, m) => {
  try { await f(); ok(false, `${m} (no falló)`) } catch (e) { ok(e.message.includes(texto), `${m} (${e.message})`) }
}
const run = (cmd, args, { input, env } = {}) =>
  execFileSync(cmd, args, { input, env: env ?? process.env, stdio: ['pipe', 'pipe', 'pipe'], maxBuffer: 1 << 26 })
const registro = []
const ej = (cmd, args, o) => { registro.push(cmd); return run(cmd, args, o) }
const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const nada = () => {}
const DESC = 'FlyWeb web browser\n FlyWeb, the web browser from lamosquita.'

function gpg (home, args, input) {
  return run('gpg', ['--batch', '--pinentry-mode', 'loopback', '--passphrase', '', ...args], { input, env: { ...process.env, GNUPGHOME: home } })
}
function huellas (home, tipo) {
  const out = gpg(home, ['--with-colons', '--fixed-list-mode', '--list-keys']).toString().split('\n')
  return out.flatMap((l, i) => l.startsWith(`${tipo}:`) ? [out[i + 1].split(':')[9]] : [])
}
function nuevoHome (n) { const h = path.join(tmp, n); fs.mkdirSync(h, { mode: 0o700 }); return h }

function hacerDeb (dir, { paquete = 'flyweb', version, llavero, nombre }) {
  const r = path.join(tmp, `raiz-${crypto.randomBytes(4).toString('hex')}`)
  fs.mkdirSync(path.join(r, 'DEBIAN'), { recursive: true })
  fs.writeFileSync(path.join(r, 'DEBIAN', 'control'), [`Package: ${paquete}`, `Version: ${version}`, 'Architecture: amd64',
    'Maintainer: FlyWeb <admin@lamosquita.net>', 'Installed-Size: 1', 'Pre-Depends: dpkg (>= 1.14.0)', 'Depends: ca-certificates',
    'Provides: www-browser', 'Section: web', 'Priority: optional', 'Homepage: https://flyweb.lamosquita.net/',
    'X-Prueba: no debe salir en Packages', `Description: ${DESC}`].join('\n') + '\n')
  fs.mkdirSync(path.join(r, 'opt/lamosquita/flyweb'), { recursive: true })
  fs.writeFileSync(path.join(r, 'opt/lamosquita/flyweb/LEEME'), `prueba ${version} ${crypto.randomBytes(8).toString('hex')}\n`)
  if (llavero) {
    fs.mkdirSync(path.join(r, 'usr/share/keyrings'), { recursive: true })
    fs.writeFileSync(path.join(r, 'usr/share/keyrings/flyweb.gpg'), llavero)
  }
  fs.mkdirSync(dir, { recursive: true })
  const f = path.join(dir, nombre ?? `flyweb_${version}_amd64.deb`)
  run('dpkg-deb', ['--root-owner-group', '-Zgzip', '-b', r, f])
  return f
}

// Un .deb con el control manipulado (un segundo párrafo con otro Filename), hecho con ar para saltarse dpkg-deb -b.
function debInyectado (dir, base, control) {
  const d = path.join(tmp, `ar-${crypto.randomBytes(4).toString('hex')}`); fs.mkdirSync(path.join(d, 'c'), { recursive: true })
  execFileSync('ar', ['x', path.resolve(base)], { cwd: d })
  fs.writeFileSync(path.join(d, 'c', 'control'), control)
  execFileSync('tar', ['-czf', path.join(d, 'control.tar.gz'), '-C', path.join(d, 'c'), './control'])
  const f = path.join(dir, path.basename(base)); const out = path.join(d, 'nuevo.deb')
  execFileSync('ar', ['rc', out, 'debian-binary', 'control.tar.gz', 'data.tar.gz'], { cwd: d })
  fs.mkdirSync(dir, { recursive: true }); fs.copyFileSync(out, f)
  return f
}

try {
  // --- La clave desechable: principal solo para certificar y subclaves de firma (2 años, 60 días y 200 días).
  const maestra = nuevoHome('maestra')
  gpg(maestra, ['--quick-gen-key', 'FlyWeb apt PRUEBA DESECHABLE <prueba@flyweb.invalid>', 'ed25519', 'cert', '10y'])
  const [principal] = huellas(maestra, 'pub')
  for (const c of ['2y', '60d', '200d']) gpg(maestra, ['--quick-add-key', principal, 'ed25519', 'sign', c])
  const [sub2y, sub60, sub200] = huellas(maestra, 'sub')
  const llavero = gpg(maestra, ['--export', principal])
  const paquetes = run('gpg', ['--list-packets'], { input: llavero }).toString()
  const versiones = [...paquetes.matchAll(/\bversion (\d+)/g)].map((m) => m[1])
  ok(versiones.length > 0 && versiones.every((v) => v === '4'), `clave desechable OpenPGP v4 (gpg --list-packets: ${versiones.length} paquetes, todos version 4)`)
  ok(principal.length === 40 && sub2y.length === 40, 'huellas v4 de 40 hexadecimales')

  // «bak»: solo la subclave de firma de 2 años (la principal queda como stub).
  const bak = nuevoHome('bak')
  gpg(bak, ['--import'], gpg(maestra, ['--export-secret-subkeys', `${sub2y}!`]))
  const secBak = gpg(bak, ['--with-colons', '--list-secret-keys']).toString()
  ok(/^sec:([^:]*:){13}#:/m.test(secBak), 'en el GNUPGHOME de bak la principal es un stub (sin parte secreta)')
  const caduca = nuevoHome('caduca')
  gpg(caduca, ['--import'], gpg(maestra, ['--export-secret-subkeys', `${sub60}!`, `${sub200}!`]))
  // Otra clave, para un .deb con un llavero que no es el nuestro.
  const otra = nuevoHome('otra')
  gpg(otra, ['--quick-gen-key', 'Otra <otra@flyweb.invalid>', 'ed25519', 'cert,sign', '1y'])
  const llaveroOtro = gpg(otra, ['--export'])

  // --- Funciones sueltas.
  const H = 'ab'.repeat(32)
  ok(aprobado(`${H}  3.2.2-50  stable # x`, H, '3.2.2-50') && !aprobado(`${H}  3.2.2-51  stable`, H, '3.2.2-50'), 'la aprobación ata SHA-256 y versión')
  ok(!aprobado(`${H}  3.2.2-50`, H, '3.2.2-50', 'stable') && aprobado(`${H}  3.2.2-50`, H, '3.2.2-50', 'pruebas'), 'sin suite, la aprobación solo vale para pruebas')
  ok(aprobado(`${H}  3.2.2-50  stable`, H, '3.2.2-50', 'pruebas') && !aprobado(`${H}  3.2.2-50  pruebas`, H, '3.2.2-50', 'stable'), 'con stable vale para las dos; con pruebas, solo para pruebas')
  ok(!aprobado(`${H}  3.2.2-50  otra`, H, '3.2.2-50', 'pruebas') && !aprobado(`${H.toUpperCase()}x  3.2.2-50  stable`, H, '3.2.2-50'), 'una suite desconocida o un SHA-256 mal formado no aprueban nada')
  ok(mayor('3.2.2-51', '3.2.2-50') && mayor('3.2.10-1', '3.2.9-99') && !mayor('3.2.2-50', '3.2.2-50'), 'versiones comparadas con dpkg')
  const ctl = leerControl(`Package: flyweb\nVersion: 1\nDescription: a\n b\n .\n c\n`)
  ok(ctl.Description === 'a\n b\n .\n c', 'control normal con descripción de varias líneas')
  await falla(() => leerControl('Package: flyweb\nDescription: a\n\nPackage: flyweb\nFilename: pool/malo.deb\n'), 'línea no válida', 'control con un párrafo inyectado (línea en blanco)')
  await falla(() => leerControl('Package: flyweb\nDescription: a\n \nFilename: pool/malo.deb\n'), 'línea no válida', 'control con una línea de solo espacios')
  await falla(() => leerControl('Package: flyweb\nVersion: 1\nversion: 2\n'), 'campo repetido', 'control con un campo repetido')
  await falla(() => leerControl('Package: flyweb\nPre-depends: dpkg\n'), 'otras mayúsculas', 'control con un campo de la lista blanca con otras mayúsculas')
  await falla(() => leerControl('Package: flyweb\r\nVersion: 1\n'), 'caracteres de control', 'control con caracteres de control')
  const p = parrafoPackages({ Package: 'flyweb', Version: '1', Filename: 'pool/malo.deb', 'X-Prueba': 'x', Description: DESC }, { filename: 'pool/main/f/flyweb/flyweb_1_amd64.deb', tam: 3, sha256: 'ab' })
  ok(!p.includes('malo') && !p.includes('X-Prueba') && p.includes('Filename: pool/main/f/flyweb/flyweb_1_amd64.deb') && p.endsWith('SHA256: ab\n'), 'Packages solo con la lista blanca; Filename lo pone bak')

  // --- La clave.
  await falla(() => comprobarClave({ gnupghome: maestra, subclave: sub2y }, { ej, log: nada }), 'parte secreta', 'no firma si la principal tiene su parte secreta en el GNUPGHOME')
  await falla(() => comprobarClave({ gnupghome: bak, subclave: principal }, { ej, log: nada }), 'no está la subclave', 'no firma con la principal ni con una huella que no es la subclave')
  await falla(() => comprobarClave({ gnupghome: caduca, subclave: sub60 }, { ej, log: nada }), 'menos de 3 meses', 'se niega con la subclave a menos de 3 meses de caducar')
  let avisos = []
  comprobarClave({ gnupghome: caduca, subclave: sub200 }, { ej, log: (m) => avisos.push(m) })
  ok(avisos.some((m) => m.includes('menos de 9 meses')), 'avisa con la subclave a menos de 9 meses de caducar')
  avisos = []
  comprobarClave({ gnupghome: bak, subclave: sub2y }, { ej, log: (m) => avisos.push(m) })
  ok(avisos.length === 0, 'con 2 años por delante, sin avisos')

  // --- Los .deb y los aprobados.
  const pool = path.join(tmp, 'pool')
  const d50 = hacerDeb(pool, { version: '3.2.2-50', llavero })
  const d51 = hacerDeb(pool, { version: '3.2.2-51', llavero })
  const d52 = hacerDeb(pool, { version: '3.2.2-52', llavero })
  const dOtro = hacerDeb(path.join(tmp, 'otro'), { paquete: 'otro', version: '3.2.2-52', llavero })
  const dSin = hacerDeb(path.join(tmp, 'sin'), { version: '3.2.2-52' })
  const dAjeno = hacerDeb(path.join(tmp, 'ajeno'), { version: '3.2.2-52', llavero: llaveroOtro })
  const d50como51 = path.join(tmp, 'renombrado', 'flyweb_3.2.2-51_amd64.deb')
  fs.mkdirSync(path.dirname(d50como51)); fs.copyFileSync(d50, d50como51)
  const dIny = debInyectado(path.join(tmp, 'iny'), d52, 'Package: flyweb\nVersion: 3.2.2-52\nArchitecture: amd64\nDescription: x\n\nPackage: flyweb\nFilename: pool/main/f/flyweb/malo.deb\n')
  const sha = (f) => sha256(fs.readFileSync(f))
  const aprob = path.join(tmp, 'apt-aprobados')
  fs.writeFileSync(aprob, ['# aprobados de prueba', `${sha(d50)}  3.2.2-50  stable`, `${sha(d51)}  3.2.2-51  stable`, `${sha(d52)}  3.2.2-52  stable`,
    `${sha(dOtro)}  3.2.2-52  stable`, `${sha(dSin)}  3.2.2-52  stable`, `${sha(dAjeno)}  3.2.2-52  stable`, `${sha(dIny)}  3.2.2-52  stable`,
    `${sha(d50)}  3.2.2-51  stable  # aprobado con la versión equivocada`].join('\n') + '\n')
  const vacio = path.join(tmp, 'vacio'); fs.writeFileSync(vacio, '')
  const salida = path.join(tmp, 'salida')
  const base = { aprobados: aprob, gnupghome: bak, subclave: sub2y, salida }
  const t0 = Date.now()
  const url = (v) => `https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_${v}_amd64.deb`
  const descargas = []
  // ns2 de mentira: la raíz da la cabecera Date (el reloj de ns2 = el de la prueba, salvo desfase), pool/ da los .deb y
  // dists/ lo que haya en `servido` (por defecto, nada: 404).
  const RAIZ = 'https://apt.flyweb.lamosquita.net/'
  const respuesta = (status, datos = Buffer.from(''), cab = {}) => ({ status, headers: new Headers(cab), arrayBuffer: async () => datos })
  const ns2 = ({ ahora, desfase = 0, servido = () => null, raizCae = false }) => async (u) => {
    if (u === RAIZ) { if (raizCae) throw new Error('sin red'); return respuesta(200, undefined, { date: new Date(ahora + desfase).toUTCString() }) }
    const m = u.match(/flyweb_(.*)_amd64\.deb$/)
    if (m) { descargas.push(u); return respuesta(200, fs.readFileSync(path.join(pool, `flyweb_${m[1]}_amd64.deb`))) }
    const r = u.match(/^https:\/\/apt\.flyweb\.lamosquita\.net\/(dists\/[^?]*)/)
    const d = r && servido(r[1])
    return d ? respuesta(200, d) : respuesta(404)
  }
  const opc = (dt = 0, mas = {}) => { const ahora = t0 + dt * 1000; return { fetchFn: ns2({ ahora, ...mas }), ej, ahora, log: nada } }

  // --- Rechazos antes de firmar.
  registro.length = 0
  await falla(() => firmar({ ...base, aprobados: vacio, deb: d50, version: '3.2.2-50' }, opc()), 'no aprobado', 'rechaza un .deb sin aprobar')
  ok(!registro.includes('dpkg-deb'), 'el SHA-256 se comprueba antes de pasar el .deb a dpkg-deb (dpkg-deb no se llamó)')
  await falla(() => firmar({ ...base, aprobados: vacio, deb: d50como51, version: '3.2.2-51' }, opc()), 'no aprobado', 'rechaza otra versión con el mismo .deb')
  fs.writeFileSync(path.join(tmp, 'aprob-mal'), `${sha(d50)}  3.2.2-51  stable\n`)
  await falla(() => firmar({ ...base, aprobados: path.join(tmp, 'aprob-mal'), deb: d50como51, version: '3.2.2-51' }, opc()), 'no la 3.2.2-51 aprobada', 'rechaza un .deb cuyo control dice otra versión que la aprobada')
  await falla(() => firmar({ ...base, deb: dOtro, version: '3.2.2-52' }, opc()), 'solo se firma flyweb', 'rechaza otro Package')
  descargas.length = 0
  for (const [u, m] of [
    ['https://ejemplo.com/pool/main/f/flyweb/flyweb_3.2.2-50_amd64.deb', 'otro servidor'],
    ['http://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_3.2.2-50_amd64.deb', 'http'],
    ['https://apt.flyweb.lamosquita.net:8443/pool/main/f/flyweb/flyweb_3.2.2-50_amd64.deb', 'otro puerto'],
    ['https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/../../../flyweb_3.2.2-50_amd64.deb', 'fuera de pool/'],
    ['https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_3.2.2-50_amd64.deb?x=1', 'con consulta'],
    ['https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_3.2.2-49_amd64.deb', 'nombre de otra versión']]) {
    await falla(() => firmar({ ...base, deb: u, version: '3.2.2-50' }, opc()), 'solo .deb por https', `rechaza otra URL: ${m}`)
  }
  ok(descargas.length === 0, 'con una URL no permitida no se descarga nada')
  await falla(() => firmar({ ...base, deb: path.join(path.dirname(dSin), 'flyweb_3.2.2-52_amd64.deb'), version: '3.2.2-52' }, opc()), 'no lleva usr/share/keyrings/flyweb.gpg', 'rechaza un .deb sin llavero')
  await falla(() => firmar({ ...base, deb: path.join(path.dirname(dAjeno), 'flyweb_3.2.2-52_amd64.deb'), version: '3.2.2-52' }, opc()), 'no verifica el índice con el llavero', 'rechaza si la firma no verifica con el llavero que va en el .deb')
  await falla(() => firmar({ ...base, deb: dIny, version: '3.2.2-52' }, opc()), 'línea no válida', 'rechaza un .deb aprobado con un párrafo inyectado en el control')
  await falla(() => firmar({ ...base, gnupghome: caduca, subclave: sub60, deb: url('3.2.2-50'), version: '3.2.2-50' }, opc()), 'menos de 3 meses', 'firmar se niega con la subclave a punto de caducar')
  await falla(() => firmar({ ...base, gnupghome: maestra, deb: url('3.2.2-50'), version: '3.2.2-50' }, opc()), 'parte secreta', 'firmar se niega con la principal en el GNUPGHOME')

  // --- Primera publicación, descargando de la URL permitida.
  const n50 = await firmar({ ...base, deb: url('3.2.2-50'), version: '3.2.2-50' }, opc(0))
  const dist = path.join(salida, 'stable', 'web', 'dists', 'stable'); const bin = path.join(dist, 'main', 'binary-amd64')
  const rel = fs.readFileSync(path.join(dist, 'Release'), 'utf8')
  ok(descargas.length === 1 && n50.sha256 === sha(d50), 'firma la 3.2.2-50 descargada de https://apt.flyweb.lamosquita.net/pool/')
  ok(!/Valid-Until/.test(rel) && /^Origin: FlyWeb$/m.test(rel) && /^Label: FlyWeb$/m.test(rel) && /^Suite: stable$/m.test(rel) &&
     /^Codename: stable$/m.test(rel) && /^Acquire-By-Hash: yes$/m.test(rel) && /^Date: .* UTC$/m.test(rel), 'Release sin Valid-Until, con Origin, Label, Suite, Codename, Date y Acquire-By-Hash')
  const pk = fs.readFileSync(path.join(bin, 'Packages')); const pkx = fs.readFileSync(path.join(bin, 'Packages.xz'))
  ok(rel.includes(` ${sha256(pk)} `) && rel.includes(` ${sha256(pkx)} `), 'Release da el SHA-256 de Packages y Packages.xz')
  ok(run('xz', ['-dc'], { input: pkx }).equals(pk), 'Packages.xz es Packages comprimido')
  ok(fs.existsSync(path.join(bin, 'by-hash', 'SHA256', sha256(pk))) && fs.existsSync(path.join(bin, 'by-hash', 'SHA256', sha256(pkx))), 'by-hash con Packages y Packages.xz')
  const pks = pk.toString()
  ok(pks.includes('Filename: pool/main/f/flyweb/flyweb_3.2.2-50_amd64.deb') && pks.includes(`SHA256: ${sha(d50)}`) &&
     pks.includes(`Size: ${fs.statSync(d50).size}`) && !pks.includes('X-Prueba') && pks.includes('Pre-Depends: dpkg'), 'Packages con Filename, Size y SHA256 de bak y sin campos fuera de la lista blanca')
  fs.writeFileSync(path.join(tmp, 'llavero.gpg'), llavero)
  const vg = run('gpgv', ['--status-fd', '1', '--keyring', path.join(tmp, 'llavero.gpg'), path.join(dist, 'InRelease')], { env: { ...process.env, GNUPGHOME: nuevoHome('gpgv') } }).toString()
  const vs = vg.split('\n').find((l) => l.startsWith('[GNUPG:] VALIDSIG')).split(' ')
  ok(vs[2] === sub2y && vs[11] === principal, `gpgv ${run('gpgv', ['--version']).toString().split('\n')[0].split(' ').pop()} acepta InRelease, firmado por la subclave y no por la principal`)
  ok(/Hash: SHA512/.test(fs.readFileSync(path.join(dist, 'InRelease'), 'utf8')), 'InRelease firmado con SHA512')

  // --- Versión y Date.
  await falla(() => firmar({ ...base, deb: d50, version: '3.2.2-50' }, opc(10)), 'no es mayor', 'rechaza la misma versión')
  await falla(() => firmar({ ...base, deb: d51, version: '3.2.2-51' }, opc(-5)), 'Date nuevo', 'rechaza un Date no mayor que el publicado (reloj atrasado)')
  await falla(() => firmar({ ...base, deb: d51, version: '3.2.2-51' }, opc(0)), 'Date nuevo', 'rechaza un Date igual al publicado')
  await firmar({ ...base, deb: d51, version: '3.2.2-51' }, opc(20))
  const pk51 = fs.readFileSync(path.join(bin, 'Packages'), 'utf8')
  ok(pk51.includes('Version: 3.2.2-51') && !pk51.includes('3.2.2-50'), 'en Packages solo la versión más nueva')

  // --- Retirar.
  await falla(() => retirar({ ...base, version: '3.2.2-49' }, opc(30)), 'no está publicada', 'retirar rechaza una versión que no está')
  await falla(() => retirar({ ...base, version: '3.2.2-51' }, opc(20)), 'Date nuevo', 'retirar tampoco firma con un Date no mayor')
  const queda = await retirar({ ...base, version: '3.2.2-51' }, opc(30))
  const pkr = fs.readFileSync(path.join(bin, 'Packages'), 'utf8')
  ok(queda.version === '3.2.2-50' && pkr.includes('Version: 3.2.2-50') && !pkr.includes('3.2.2-51'), 'retirar vuelve a la anterior en Packages')
  const est = JSON.parse(fs.readFileSync(path.join(salida, 'stable', 'estado.json'), 'utf8'))
  ok(est.retiradas.length === 1 && est.retiradas[0].version === '3.2.2-51', 'la retirada queda anotada')
  ok(fs.readdirSync(path.join(salida, 'stable')).some((f) => f.startsWith('estado.json.')), 'retirar guarda copia del estado anterior')
  await falla(() => firmar({ ...base, deb: d51, version: '3.2.2-51' }, opc(40)), 'no es mayor', 'no se puede volver a firmar un número retirado')

  // --- Refirmar y subir.
  const pkAntes = fs.readFileSync(path.join(bin, 'Packages')); const dateAntes = rel.match(/^Date: (.*)$/m)[1]
  const rsync = []
  const ejSubida = (cmd, args, o) => { if (cmd === 'rsync') { rsync.push(args); return Buffer.from('') } return ej(cmd, args, o) }
  await refirmar({ ...base, subir: 'ns2-apt' }, { ...opc(50), ej: ejSubida })
  const rel2 = fs.readFileSync(path.join(dist, 'Release'), 'utf8')
  ok(fs.readFileSync(path.join(bin, 'Packages')).equals(pkAntes) && rel2.match(/^Date: (.*)$/m)[1] !== dateAntes, 'refirmar: mismo Packages, Date nuevo')
  const orden = rsync.map((a) => a.includes('--delete') ? 'borrar-by-hash' : a.some((x) => x.endsWith('/by-hash/')) ? 'by-hash' : a.some((x) => x.endsWith('InRelease')) ? 'InRelease' : a.some((x) => x.endsWith('/Packages')) ? 'Packages' : '?')
  ok(orden.join(',') === 'by-hash,InRelease,Packages,borrar-by-hash', `orden de subida: ${orden.join(' → ')}`)
  ok(rsync.every((a) => a.at(-1).startsWith('ns2-apt:dists/stable/')), 'todo se sube bajo dists/stable/ (pool/ lo sube la Ubuntu)')
  ok(rsync.slice(0, 3).every((a) => !a.includes('--delete')), 'sin --delete en la pasada de publicación')
  const bh = fs.readdirSync(path.join(bin, 'by-hash', 'SHA256'))
  ok(bh.length <= 6 && bh.includes(sha256(pkAntes)), `by-hash guarda solo las últimas generaciones (${bh.length} ficheros)`)

  // --- Siguiente versión tras la retirada; el llavero de la publicada también la verifica.
  await firmar({ ...base, deb: d52, version: '3.2.2-52' }, opc(60))
  ok(fs.readFileSync(path.join(bin, 'Packages'), 'utf8').includes('Version: 3.2.2-52'), 'después de retirar se publica la siguiente')

  // --- Reloj de bak contra ns2 (cota superior del Date).
  ok(await comprobarReloj({ fetchFn: ns2({ ahora: t0, desfase: 60000 }), ahora: t0 }) === 'ns2', 'reloj: un minuto de diferencia con ns2 vale')
  await falla(() => comprobarReloj({ fetchFn: ns2({ ahora: t0, desfase: -10 * 60000 }), ahora: t0 }), 'adelantado', 'reloj: se niega con bak 10 min adelantado respecto a ns2')
  await falla(() => comprobarReloj({ fetchFn: ns2({ ahora: t0, desfase: 10 * 60000 }), ahora: t0 }), 'atrasado', 'reloj: se niega con bak 10 min atrasado')
  const ejNtp = (v) => (cmd, args, o) => cmd === 'timedatectl' ? Buffer.from(`${v}\n`) : ej(cmd, args, o)
  ok(await comprobarReloj({ fetchFn: ns2({ ahora: t0, raizCae: true }), ej: ejNtp('yes'), ahora: t0 }) === 'ntp', 'reloj: si ns2 no contesta, vale NTPSynchronized=yes')
  await falla(() => comprobarReloj({ fetchFn: ns2({ ahora: t0, raizCae: true }), ej: ejNtp('no'), ahora: t0 }), 'no se puede comprobar el reloj', 'reloj: sin ns2 ni NTP, no se firma')
  descargas.length = 0
  await falla(() => firmar({ ...base, deb: url('3.2.2-53'), version: '3.2.2-53' }, opc(70, { desfase: -10 * 60000 })), 'adelantado', 'firmar se niega con el reloj de bak adelantado')
  ok(descargas.length === 0, 'con el reloj mal no se descarga nada')
  const d53 = hacerDeb(pool, { version: '3.2.2-53', llavero })
  fs.appendFileSync(aprob, `${sha(d53)}  3.2.2-53  stable\n`)
  await falla(() => firmar({ ...base, deb: url('3.2.2-53'), version: '3.2.2-53' }, opc(-600)), 'en el futuro', 'si el Date publicado quedó en el futuro, lo dice')
  await falla(() => retirar({ ...base, version: '3.2.2-52' }, opc(70, { desfase: -10 * 60000 })), 'adelantado', 'retirar se niega con el reloj adelantado')
  await falla(() => refirmar(base, opc(70, { desfase: -10 * 60000 })), 'adelantado', 'refirmar se niega con el reloj adelantado')

  // --- La aprobación atada a la suite.
  const aprob2 = path.join(tmp, 'aprob-2col'); fs.writeFileSync(aprob2, `${sha(d53)}  3.2.2-53\n`)
  await falla(() => firmar({ ...base, aprobados: aprob2, deb: url('3.2.2-53'), version: '3.2.2-53' }, opc(80)), 'no aprobado para stable', 'una aprobación sin suite no vale para stable')
  await firmar({ ...base, aprobados: aprob2, deb: url('3.2.2-53'), version: '3.2.2-53', suite: 'pruebas' }, opc(80))
  ok(fs.readFileSync(path.join(salida, 'pruebas', 'web', 'dists', 'pruebas', 'main', 'binary-amd64', 'Packages'), 'utf8').includes('Version: 3.2.2-53'), 'la misma aprobación sin suite sí vale para pruebas')

  // --- Sin estado.json pero con índice publicado: no firma salvo con --primera si.
  const ejNoSube = (cmd, args, o) => cmd === 'rsync' ? Buffer.from('') : ej(cmd, args, o)
  const hayIndice = (r) => r === 'dists/stable/InRelease' ? Buffer.from('InRelease de otra época') : null
  const sal1 = path.join(tmp, 'salida-primera')
  await falla(() => firmar({ ...base, salida: sal1, subir: 'ns2-apt', deb: url('3.2.2-50'), version: '3.2.2-50' }, { ...opc(90, { servido: hayIndice }), ej: ejNoSube }), 'estado perdido', 'sin estado.json pero con InRelease publicado, no firma')
  await firmar({ ...base, salida: sal1, subir: 'ns2-apt', primera: 'si', deb: url('3.2.2-50'), version: '3.2.2-50' }, { ...opc(90, { servido: hayIndice }), ej: ejNoSube })
  ok(fs.existsSync(path.join(sal1, 'stable', 'estado.json')), 'con --primera si, firma')
  const sal1b = path.join(tmp, 'salida-primera-404')
  await firmar({ ...base, salida: sal1b, subir: 'ns2-apt', deb: url('3.2.2-50'), version: '3.2.2-50' }, { ...opc(90), ej: ejNoSube })
  ok(fs.existsSync(path.join(sal1b, 'stable', 'estado.json')), 'sin estado y sin índice publicado (404): es la primera, firma')

  // --- Rotación: también se verifica con el llavero de la versión más alta firmada nunca, aunque esté retirada.
  gpg(maestra, ['--quick-add-key', principal, 'ed25519', 'sign', '2y'])
  const subNueva = huellas(maestra, 'sub').find((h) => ![sub2y, sub60, sub200].includes(h))
  const llaveroNuevo = gpg(maestra, ['--export', principal])
  const bakNueva = nuevoHome('bak-nueva')
  gpg(bakNueva, ['--import'], gpg(maestra, ['--export-secret-subkeys', `${subNueva}!`]))
  const pool2 = path.join(tmp, 'pool2')
  const d80 = hacerDeb(pool2, { version: '3.2.2-80', llavero: llaveroNuevo })
  const d81 = hacerDeb(pool2, { version: '3.2.2-81', llavero })
  const aprob3 = path.join(tmp, 'aprob-rot'); fs.writeFileSync(aprob3, `${sha(d80)}  3.2.2-80  stable\n${sha(d81)}  3.2.2-81  stable\n`)
  const b3 = { ...base, aprobados: aprob3, salida: path.join(tmp, 'salida-rot') }
  await firmar({ ...b3, deb: d80, version: '3.2.2-80' }, opc(100))
  await firmar({ ...b3, deb: d81, version: '3.2.2-81' }, opc(110))
  await retirar({ ...b3, version: '3.2.2-81' }, opc(120))
  await falla(() => refirmar({ ...b3, gnupghome: bakNueva, subclave: subNueva }, opc(130)), 'con el llavero de 3.2.2-81', 'tras rotar, refirmar verifica también con el llavero de la más alta firmada nunca (retirada): los equipos que la tienen no verían la firma nueva')

  // --- comprobar: lo publicado en ns2 contra lo firmado.
  const webDe = (sal) => (r) => { const f = path.join(sal, r.split('/')[1], 'web', r); return fs.existsSync(f) ? fs.readFileSync(f) : null }
  const pedidas = []
  const anota = (servido) => (r) => { pedidas.push(r); return servido(r) }
  const rapido = { log: nada, intentos: 2, esperar: async () => {} }
  const logs = []
  await comprobar({ salida, version: '3.2.2-52', sha256: sha(d52) }, { ...rapido, fetchFn: ns2({ ahora: t0, servido: anota(webDe(salida)) }), log: (m) => logs.push(m) })
  ok(logs.some((m) => m.startsWith('comprobado stable')), 'comprobar: lo servido es lo firmado, cuadra')
  ok(pedidas.some((r) => r.includes('by-hash')) && pedidas.length >= 4, `comprobar mira InRelease, Packages y los dos by-hash (${pedidas.length} peticiones)`)
  const servidas = []
  const fUrls = async (u, op) => { if (u !== RAIZ) servidas.push([u, op]); return ns2({ ahora: t0, servido: webDe(salida) })(u, op) }
  await comprobar({ salida, version: '3.2.2-52', sha256: sha(d52) }, { ...rapido, fetchFn: fUrls })
  ok(servidas.every(([u, op]) => /\?sin-cache=[0-9a-f]{12}$/.test(u) && op.headers['Cache-Control'] === 'no-cache' && op.cache === 'no-store'), 'comprobar esquiva cachés (consulta aleatoria, Cache-Control: no-cache)')
  const viejo = (r) => r.endsWith('InRelease') ? Buffer.from('InRelease viejo') : webDe(salida)(r)
  await falla(() => comprobar({ salida, version: '3.2.2-52', sha256: sha(d52) }, { ...rapido, fetchFn: ns2({ ahora: t0, servido: viejo }) }), 'no es el que ha firmado bak', 'comprobar: un InRelease viejo (caché o subida a medias) no cuadra')
  const sinByHash = (r) => r.includes('by-hash') ? null : webDe(salida)(r)
  await falla(() => comprobar({ salida, version: '3.2.2-52', sha256: sha(d52) }, { ...rapido, fetchFn: ns2({ ahora: t0, servido: sinByHash }) }), 'HTTP 404', 'comprobar: sin by-hash publicado no cuadra')
  await falla(() => comprobar({ salida, version: '3.2.2-52', sha256: sha(d51) }, { ...rapido, fetchFn: ns2({ ahora: t0, servido: webDe(salida) }) }), 'no está publicada', 'comprobar: otro SHA-256 que el firmado no cuadra')

  // --- publicar: una orden para pruebas y stable.
  const sal4 = path.join(tmp, 'salida-publicar'); const aprob4 = path.join(tmp, 'aprob-publicar')
  fs.writeFileSync(aprob4, '# aprobados'); fs.chmodSync(aprob4, 0o644)
  const conf = path.join(tmp, 'apt.conf')
  fs.writeFileSync(conf, `# apt.conf de prueba\nsubclave=${sub2y}\naprobados=${aprob4}\ngnupghome=${bak}\nsalida=${sal4}\nsubir=ns2-apt\n`)
  const d90 = hacerDeb(pool, { version: '3.2.2-90', llavero }); const d91 = hacerDeb(pool, { version: '3.2.2-91', llavero })
  const llamadas = []
  const depsPub = (dt, servido = webDe(sal4)) => {
    const o = opc(dt, { servido }); const hijo = { ...o, ej: ejNoSube, intentos: 1, esperar: async () => {} }
    return { comoUsuario: async (u, args) => { llamadas.push([u, args[0], args[args.indexOf('--suite') + 1]]); await ejecutar(args, hijo) },
      getuid: () => process.getuid(), uidRoot: process.getuid(), ahora: o.ahora, log: nada }
  }
  const pub = (v, s, deps, mas = {}) => publicar({ config: conf, version: v, sha256: s, ...mas }, deps)
  await falla(() => pub('3.2.2-90', sha(d90), { ...depsPub(200), getuid: () => 1000, uidRoot: 0 }), 'sudo', 'publicar se niega sin sudo')
  fs.chmodSync(aprob4, 0o666)
  await falla(() => pub('3.2.2-90', sha(d90), depsPub(200)), 'lo puede escribir', 'publicar se niega si alguien más que root puede escribir los aprobados')
  fs.chmodSync(aprob4, 0o644)
  await falla(() => pub('3.2.2-90', sha(d90), depsPub(200), { config: path.join(tmp, 'no-existe.conf') }), 'falta la subclave', 'publicar sin subclave en apt.conf')
  await falla(() => pub('3.2.2-90', 'x'.repeat(64), depsPub(200)), 'SHA-256 no válido', 'publicar con un SHA-256 mal formado')
  llamadas.length = 0
  await pub('3.2.2-90', sha(d90).toUpperCase(), depsPub(200))
  ok(llamadas.map((l) => `${l[1]}:${l[2]}`).join(',') === 'firmar:pruebas,comprobar:pruebas,firmar:stable,comprobar:stable', `publicar: ${llamadas.map((l) => `${l[1]} ${l[2]}`).join(' → ')}`)
  ok(llamadas.every((l) => l[0] === 'flywebfirma'), 'publicar firma y comprueba como el usuario de firma (flywebfirma por defecto)')
  ok(aprobado(fs.readFileSync(aprob4, 'utf8'), sha(d90), '3.2.2-90', 'stable') && fs.readFileSync(aprob4, 'utf8').startsWith('# aprobados\n'), 'publicar apunta «<sha256>  <versión>  stable» (en una línea nueva)')
  for (const s of ['pruebas', 'stable']) ok(JSON.parse(fs.readFileSync(path.join(sal4, s, 'estado.json'), 'utf8')).publicadas[0].version === '3.2.2-90', `publicar: ${s} queda con la 3.2.2-90`)
  llamadas.length = 0; const lineas = fs.readFileSync(aprob4, 'utf8')
  await pub('3.2.2-90', sha(d90), depsPub(210))
  ok(llamadas.every((l) => l[1] === 'comprobar') && llamadas.length === 2 && fs.readFileSync(aprob4, 'utf8') === lineas, 'publicar otra vez: no vuelve a firmar ni a apuntar, solo comprueba')
  fs.appendFileSync(aprob4, `${sha(d50)}  3.2.2-91  pruebas\n`)
  await falla(() => pub('3.2.2-91', sha(d91), depsPub(220)), "sed -i '/^" + sha(d50) + "[[:space:]]/Id'", 'publicar se para si la versión ya está aprobada con otro SHA-256 y dice qué línea quitar')
  execFileSync('sed', ['-i', `/^${sha(d50).toUpperCase()}[[:space:]]/Id`, aprob4])
  ok(fs.readFileSync(aprob4, 'utf8') === lineas && (fs.statSync(aprob4).mode & 0o777) === 0o644, 'la orden sed del mensaje quita solo esa línea (aunque el SHA-256 vaya en mayúsculas) y deja el modo')
  const antesStable = fs.readFileSync(path.join(sal4, 'stable', 'estado.json'))
  const viejoPruebas = (r) => r === 'dists/pruebas/InRelease' ? Buffer.from('InRelease viejo') : webDe(sal4)(r)
  llamadas.length = 0
  await falla(() => pub('3.2.2-91', sha(d91), depsPub(230, viejoPruebas)), 'stable no se ha tocado', 'publicar: si lo publicado en pruebas no cuadra, se para')
  ok(fs.readFileSync(path.join(sal4, 'stable', 'estado.json')).equals(antesStable) && !llamadas.some((l) => l[2] === 'stable'), '... y stable no se ha firmado')
  llamadas.length = 0
  await pub('3.2.2-91', sha(d91), depsPub(240))
  ok(llamadas.map((l) => `${l[1]}:${l[2]}`).join(',') === 'comprobar:pruebas,firmar:stable,comprobar:stable', 'al repetir, pruebas solo se comprueba y stable se firma')
  ok(JSON.parse(fs.readFileSync(path.join(sal4, 'stable', 'estado.json'), 'utf8')).publicadas[0].version === '3.2.2-91', 'stable queda con la 3.2.2-91')

  if (process.env.FLYWEB_APT_GUARDAR) {
    const g = process.env.FLYWEB_APT_GUARDAR
    fs.cpSync(path.join(salida, 'stable', 'web'), g, { recursive: true })
    fs.mkdirSync(path.join(g, 'pool/main/f/flyweb'), { recursive: true })
    for (const f of [d50, d51, d52]) fs.copyFileSync(f, path.join(g, 'pool/main/f/flyweb', path.basename(f)))
    fs.writeFileSync(path.join(g, 'flyweb.gpg'), llavero)
    fs.writeFileSync(path.join(g, 'subclave.txt'), `${sub2y}\n${principal}\n`)
    console.log(`(repositorio guardado en ${g})`)
  }
} finally {
  try { run('gpgconf', ['--kill', 'all'], { env: { ...process.env, GNUPGHOME: path.join(tmp, 'maestra') } }) } catch {}
  for (const h of ['bak', 'bak-nueva', 'caduca', 'otra', 'gpgv']) try { run('gpgconf', ['--kill', 'all'], { env: { ...process.env, GNUPGHOME: path.join(tmp, h) } }) } catch {}
  fs.rmSync(tmp, { recursive: true, force: true })
}
console.log(fallos ? `\n${fallos} FALLOS` : '\nTodo correcto'); process.exit(fallos ? 1 : 0)
