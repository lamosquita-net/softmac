// Prueba del firmador de actualizaciones, sin red y con una clave desechable. La firma se comprueba además con
// OpenSSL (implementación independiente de la de Node), igual que la comprobará Sparkle: ed25519 sobre el DMG entero.
// Uso: node pruebas/firma-actualizacion.mjs
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { firmar, comparar, clavePublica, aprobado } from '../bak/firmar-actualizacion.mjs'

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'flyweb-act-'))
let fallos = 0
const ok = (c, m) => { fallos += !c; console.log(`${c ? 'ok  ' : 'FALLO'} ${m}`) }
const falla = async (f, texto, m) => {
  try { await f(); ok(false, m) } catch (e) { ok(e.message.includes(texto), `${m} (${e.message})`) }
}

try {
  const { privateKey, publicKey } = crypto.generateKeyPairSync('ed25519')
  const clave = path.join(tmp, 'act.pem'); fs.writeFileSync(clave, privateKey.export({ type: 'pkcs8', format: 'pem' }))
  const dmg = path.join(tmp, 'FlyWeb-1.0.1.dmg'); fs.writeFileSync(dmg, crypto.randomBytes(1 << 20))
  const sha = crypto.createHash('sha256').update(fs.readFileSync(dmg)).digest('hex')
  const aprob = path.join(tmp, 'aprobados'); fs.writeFileSync(aprob, `# FlyWeb\n${sha}  157.64.1  # 1.0.1\n`)
  const salida = path.join(tmp, 'salida')
  const base = { dmg, version: '157.64.1', visible: '1.0.1', clave, aprobados: aprob, salida, log: () => {} }

  ok(clavePublica(privateKey) === publicKey.export({ type: 'spki', format: 'der' }).subarray(12).toString('base64'), 'clave pública = 32 bytes crudos en base64 (SUPublicEDKey)')
  ok(comparar('157.64.1', '157.64') === 1 && comparar('157.64.10', '157.64.9') === 1 && comparar('157.64', '157.64.0') === 0, 'comparación de versiones como Sparkle')
  ok(aprobado(`${sha}  157.64.1 # x`, sha, '157.64.1') && !aprobado(`${sha}  157.64.2`, sha, '157.64.1'), 'la aprobación ata SHA-256 y versión')

  await falla(() => firmar({ ...base, aprobados: (fs.writeFileSync(path.join(tmp, 'vacio'), ''), path.join(tmp, 'vacio')) }, { log: () => {} }), 'no aprobado', 'rechaza un DMG sin aprobar')
  await falla(() => firmar({ ...base, version: '157.64.2' }, { log: () => {} }), 'no aprobado', 'rechaza otra versión con el mismo DMG')
  await falla(() => firmar({ ...base, dmg: 'https://ejemplo.com/FlyWeb.dmg' }, { log: () => {} }), 'solo DMG por https', 'rechaza descargas fuera de updates.flyweb.lamosquita.net')
  await falla(() => firmar({ ...base, dmg: 'http://updates.flyweb.lamosquita.net/FlyWeb.dmg' }, { log: () => {} }), 'solo DMG por https', 'rechaza http')
  await falla(() => firmar({ ...base, canal: '../x' }, { log: () => {} }), 'canal no válido', 'rechaza canales raros (rutas)')

  const it = await firmar(base, { log: () => {} })
  const xml = fs.readFileSync(path.join(salida, 'stable', 'appcast.xml'), 'utf8')
  ok(xml.includes('sparkle:version="157.64.1"') && xml.includes('sparkle:shortVersionString="1.0.1"') &&
     xml.includes(`length="${1 << 20}"`) && xml.includes('<sparkle:minimumSystemVersion>10.13.0<') &&
     xml.includes('url="https://updates.flyweb.lamosquita.net/FlyWeb-1.0.1.dmg"'), 'appcast con versión, tamaño, macOS mínimo y URL')

  // Verificación independiente con OpenSSL.
  fs.writeFileSync(path.join(tmp, 'pub.pem'), publicKey.export({ type: 'spki', format: 'pem' }))
  fs.writeFileSync(path.join(tmp, 'sig'), Buffer.from(it.firma, 'base64'))
  let opensslOk = false
  try {
    execFileSync('openssl', ['pkeyutl', '-verify', '-pubin', '-inkey', path.join(tmp, 'pub.pem'), '-rawin', '-in', dmg, '-sigfile', path.join(tmp, 'sig')], { stdio: 'pipe' })
    opensslOk = true
  } catch {}
  ok(opensslOk, 'OpenSSL verifica la firma ed25519 del DMG')
  const roto = Buffer.from(fs.readFileSync(dmg)); roto[100] ^= 1; fs.writeFileSync(path.join(tmp, 'roto.dmg'), roto)
  let rotoOk = true
  try { execFileSync('openssl', ['pkeyutl', '-verify', '-pubin', '-inkey', path.join(tmp, 'pub.pem'), '-rawin', '-in', path.join(tmp, 'roto.dmg'), '-sigfile', path.join(tmp, 'sig')], { stdio: 'pipe' }) } catch { rotoOk = false }
  ok(!rotoOk, 'la firma no vale para un DMG con un bit cambiado')

  await falla(() => firmar(base, { log: () => {} }), 'no es posterior', 'rechaza volver a publicar la misma versión (o una anterior)')

  // Segunda versión: queda la primera en el appcast, la nueva arriba.
  const dmg2 = path.join(tmp, 'FlyWeb-1.0.2.dmg'); fs.writeFileSync(dmg2, crypto.randomBytes(4096))
  const sha2 = crypto.createHash('sha256').update(fs.readFileSync(dmg2)).digest('hex')
  fs.appendFileSync(aprob, `${sha2}  157.64.2\n`)
  await firmar({ ...base, dmg: dmg2, version: '157.64.2', visible: '1.0.2' }, { log: () => {} })
  const xml2 = fs.readFileSync(path.join(salida, 'stable', 'appcast.xml'), 'utf8')
  ok(xml2.indexOf('157.64.2') < xml2.indexOf('157.64.1') && (xml2.match(/<item>/g) || []).length === 2, 'appcast con la nueva arriba y la anterior debajo')
  ok(!xml2.includes(sha) && !xml2.includes('BEGIN PRIVATE'), 'el appcast no lleva SHA ni nada privado')
} finally {
  fs.rmSync(tmp, { recursive: true, force: true })
}
console.log(fallos ? `\n${fallos} FALLOS` : '\nTodo correcto'); process.exit(fallos ? 1 : 0)
