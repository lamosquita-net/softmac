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
import { firmar, retirar, refirmar, comprobarClave, leerControl, parrafoPackages, aprobado, mayor } from '../bak/firmar-apt.mjs'

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
  ok(aprobado('abc  3.2.2-50 # x', 'abc', '3.2.2-50') && !aprobado('abc  3.2.2-51', 'abc', '3.2.2-50'), 'la aprobación ata SHA-256 y versión')
  ok(mayor('3.2.2-51', '3.2.2-50') && mayor('3.2.10-1', '3.2.9-99') && !mayor('3.2.2-50', '3.2.2-50'), 'versiones comparadas con dpkg')
  const ctl = leerControl(`Package: flyweb\nVersion: 1\nDescription: a\n b\n .\n c\n`)
  ok(ctl.Description === 'a\n b\n .\n c', 'control normal con descripción de varias líneas')
  await falla(() => leerControl('Package: flyweb\nDescription: a\n\nPackage: flyweb\nFilename: pool/malo.deb\n'), 'línea no válida', 'control con un párrafo inyectado (línea en blanco)')
  await falla(() => leerControl('Package: flyweb\nDescription: a\n \nFilename: pool/malo.deb\n'), 'línea no válida', 'control con una línea de solo espacios')
  await falla(() => leerControl('Package: flyweb\nVersion: 1\nversion: 2\n'), 'campo repetido', 'control con un campo repetido')
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
  fs.writeFileSync(aprob, ['# aprobados de prueba', `${sha(d50)}  3.2.2-50`, `${sha(d51)}  3.2.2-51`, `${sha(d52)}  3.2.2-52`,
    `${sha(dOtro)}  3.2.2-52`, `${sha(dSin)}  3.2.2-52`, `${sha(dAjeno)}  3.2.2-52`, `${sha(dIny)}  3.2.2-52`,
    `${sha(d50)}  3.2.2-51  # aprobado con la versión equivocada`].join('\n') + '\n')
  const vacio = path.join(tmp, 'vacio'); fs.writeFileSync(vacio, '')
  const salida = path.join(tmp, 'salida')
  const base = { aprobados: aprob, gnupghome: bak, subclave: sub2y, salida }
  const t0 = Date.now()
  const url = (v) => `https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_${v}_amd64.deb`
  const descargas = []
  const fetchFn = async (u) => { descargas.push(u); const v = u.match(/flyweb_(.*)_amd64/)[1]; return { status: 200, arrayBuffer: async () => fs.readFileSync(path.join(pool, `flyweb_${v}_amd64.deb`)) } }
  const opc = (dt = 0) => ({ fetchFn, ej, ahora: t0 + dt * 1000, log: nada })

  // --- Rechazos antes de firmar.
  registro.length = 0
  await falla(() => firmar({ ...base, aprobados: vacio, deb: d50, version: '3.2.2-50' }, opc()), 'no aprobado', 'rechaza un .deb sin aprobar')
  ok(!registro.includes('dpkg-deb'), 'el SHA-256 se comprueba antes de pasar el .deb a dpkg-deb (dpkg-deb no se llamó)')
  await falla(() => firmar({ ...base, aprobados: vacio, deb: d50como51, version: '3.2.2-51' }, opc()), 'no aprobado', 'rechaza otra versión con el mismo .deb')
  fs.writeFileSync(path.join(tmp, 'aprob-mal'), `${sha(d50)}  3.2.2-51\n`)
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
  const queda = retirar({ ...base, version: '3.2.2-51' }, opc(30))
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
  refirmar({ ...base, subir: 'ns2-apt' }, { ej: ejSubida, ahora: t0 + 50000, log: nada })
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
  for (const h of ['bak', 'caduca', 'otra', 'gpgv']) try { run('gpgconf', ['--kill', 'all'], { env: { ...process.env, GNUPGHOME: path.join(tmp, h) } }) } catch {}
  fs.rmSync(tmp, { recursive: true, force: true })
}
console.log(fallos ? `\n${fallos} FALLOS` : '\nTodo correcto'); process.exit(fallos ? 1 : 0)
