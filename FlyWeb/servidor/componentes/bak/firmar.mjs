// Firma en bak de los componentes de Shields de FlyWeb (plan B). Sin dependencias: solo Node (≥ 18) y este
// directorio (zip.mjs, crx3.mjs). Lo ejecuta flyweb-firma.service una vez al día, como el usuario flywebfirma.
//
// 1. Descarga indice.json y los zips sin firmar que construye GitHub Actions (release «shields» del repo).
// 2. Comprueba cada zip: SHA-256 del índice; solo manifest.json y su fichero de datos; la clave del manifest es la
//    NUESTRA; la versión es mayor que la ya firmada (nada de volver atrás); en el catálogo, cada lista apunta a
//    nuestro ID y nuestra clave; una lista no pierde más de la mitad de sus reglas.
// 3. resources.json (el único componente con JavaScript) solo se firma si su SHA-256 está en el fichero de
//    aprobados, que mantiene el HUMANO. Si no, no se firma y se avisa con el hash.
// 4. Firma (CRX3 + prueba de publicador), deja <salida>/release/<id>/extension_<versión>.crx, catalog.json
//    (go-update) y _estado.json (público), y lo sube a ns2 con rsync (clave restringida a ese directorio).
//
// Uso: node firmar.mjs --origen <URL o dir> --claves <dir> --salida <dir> --aprobados <fichero> [--subir <host ssh>]
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { leerZip } from './zip.mjs'
import { firmarCrx, idDe, spki } from './crx3.mjs'

const args = process.argv.slice(2)
const opt = (n) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : undefined }
const ORIGEN = opt('--origen'); const CLAVES = opt('--claves'); const SALIDA = opt('--salida')
const APROBADOS = opt('--aprobados'); const SUBIR = opt('--subir')
if (!ORIGEN || !CLAVES || !SALIDA || !APROBADOS) {
  console.error('Uso: node firmar.mjs --origen <URL o dir> --claves <dir> --salida <dir> --aprobados <f> [--subir <host>]')
  process.exit(2)
}

const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex')
const traer = async (nombre) => {
  if (!/^https:\/\//.test(ORIGEN)) return fs.readFileSync(path.join(ORIGEN, nombre))
  const r = await fetch(`${ORIGEN.replace(/\/$/, '')}/${nombre}`)
  if (r.status !== 200) throw new Error(`${nombre}: HTTP ${r.status}`)
  return Buffer.from(await r.arrayBuffer())
}
const leerClave = (nombre) => {
  const f = path.join(CLAVES, `${nombre}.pem`)
  if (fs.statSync(f).mode & 0o077) throw new Error(`${f}: permisos demasiado abiertos (debe ser 0600)`)
  return fs.readFileSync(f, 'utf8')
}
const escribir = (f, d) => { fs.writeFileSync(f + '.tmp', d); fs.renameSync(f + '.tmp', f) }
const versionValida = (v) => /^\d{1,5}\.\d{1,5}\.\d{1,5}$/.test(v) && v.split('.').every((p) => +p < 65536)
const mayor = (a, b) => { const x = a.split('.').map(Number); const y = b.split('.').map(Number); for (let i = 0; i < 3; i++) if (x[i] !== y[i]) return x[i] > y[i]; return false }
const contarReglas = (t) => t.split('\n').filter((l) => l && !l.startsWith('!') && !l.startsWith('[')).length
const FICHERO = (n) => n === 'recursos' ? 'resources.json' : n === 'catalogo' ? 'regional_catalog.json' : 'list.txt'
const NOMBRE = /^(defecto|primera-parte|recursos|catalogo|lista-[A-Za-z0-9-]{1,64})$/

const ESTADO = path.join(SALIDA, 'firmado.json')
const estado = fs.existsSync(ESTADO) ? JSON.parse(fs.readFileSync(ESTADO, 'utf8')) : {}
const aprobados = new Set(fs.readFileSync(APROBADOS, 'utf8').split('\n').map((l) => l.replace(/#.*/, '').trim()).filter(Boolean))
const publicador = leerClave('publicador')
const fallos = []; const pendientes = []

const indice = JSON.parse(await traer('indice.json'))
// El catálogo se comprueba contra nuestras claves de lista: primero se leen todas las que tenemos.
const nuestras = Object.fromEntries(fs.readdirSync(CLAVES).filter((f) => /^lista-.*\.pem$/.test(f))
  .map((f) => { const der = spki(fs.readFileSync(path.join(CLAVES, f), 'utf8')); return [f.slice(6, -4), { id: idDe(der), b64: der.toString('base64') }] }))

for (const c of indice.componentes ?? []) {
  try {
    if (!NOMBRE.test(c.nombre)) throw new Error('nombre no válido')
    const clave = leerClave(c.nombre); const der = spki(clave); const id = idDe(der)
    const prev = estado[c.nombre]
    const zip = await traer(`${c.nombre}.zip`)
    if (sha256(zip) !== c.sha256) throw new Error('el SHA-256 del zip no coincide con el índice')
    const ficheros = leerZip(zip)
    const esperados = ['manifest.json', FICHERO(c.nombre)]
    if (ficheros.size !== 2 || !esperados.every((f) => ficheros.has(f))) throw new Error(`contenido inesperado: ${[...ficheros.keys()]}`)
    const m = JSON.parse(ficheros.get('manifest.json'))
    if (m.manifest_version !== 2 || m.key !== der.toString('base64')) throw new Error('el manifest no lleva nuestra clave')
    if (!versionValida(m.version) || m.version !== c.version) throw new Error(`versión no válida: ${m.version}`)
    const datos = ficheros.get(FICHERO(c.nombre)); const contenido = sha256(datos)
    if (prev && prev.contenido === contenido) { console.log(`= ${c.nombre.padEnd(46)} sin cambios (${prev.version})`); continue }
    if (prev && !mayor(m.version, prev.version)) throw new Error(`versión ${m.version} no posterior a la firmada (${prev.version})`)
    let reglas
    if (c.nombre === 'recursos') {
      JSON.parse(datos)
      if (!aprobados.has(contenido)) { pendientes.push(contenido); throw new Error(`recursos nuevos SIN APROBAR: ${contenido}`) }
    } else if (c.nombre === 'catalogo') {
      for (const e of JSON.parse(datos)) {
        const k = nuestras[e.uuid]
        if (!k || e.list_text_component?.component_id !== k.id || e.list_text_component?.base64_public_key !== k.b64) {
          throw new Error(`la lista ${e.uuid} del catálogo no usa nuestra clave`)
        }
      }
    } else {
      reglas = contarReglas(datos.toString('utf8'))
      if (prev?.reglas && reglas < prev.reglas / 2) throw new Error(`${reglas} reglas frente a ${prev.reglas}; no se firma`)
    }
    const crx = firmarCrx(zip, clave, [publicador])
    const dir = path.join(SALIDA, 'release', id); fs.mkdirSync(dir, { recursive: true })
    const nombre = `extension_${m.version.replace(/\./g, '_')}.crx`
    escribir(path.join(dir, nombre), crx)
    // Se conservan la versión nueva y la anterior (descargas en curso); el resto se borra.
    const quedan = new Set([nombre, prev && `extension_${prev.version.replace(/\./g, '_')}.crx`])
    for (const f of fs.readdirSync(dir)) if (!quedan.has(f)) fs.rmSync(path.join(dir, f))
    estado[c.nombre] = { id, titulo: m.name, version: m.version, contenido, sha256: sha256(crx), tamano: crx.length, reglas }
    console.log(`+ ${c.nombre.padEnd(46)} ${m.version} ${id}${reglas !== undefined ? ` ${reglas} reglas` : ''}`)
  } catch (e) {
    fallos.push(`${c.nombre}: ${e.message}`)
  }
}
for (const f of indice.fallos ?? []) fallos.push(`(construcción) ${f}`)
if (Array.isArray(indice.esperados)) for (const n of Object.keys(estado)) if (!indice.esperados.includes(n)) { delete estado[n]; console.log(`- ${n} (ya no está en listas.json)`) }

const cat = Object.values(estado).map((e) => ({ ID: e.id, Version: e.version, SHA256: e.sha256, Title: e.titulo, Size: e.tamano }))
escribir(path.join(SALIDA, 'catalog.json'), JSON.stringify(cat, null, 1))
escribir(path.join(SALIDA, '_estado.json'), JSON.stringify({ firmado: new Date().toISOString(), ublock: indice.ublock,
  componentes: Object.entries(estado).map(([nombre, e]) => ({ nombre, id: e.id, version: e.version })),
  fallos: fallos.length, recursos_pendientes: pendientes }, null, 1))
escribir(ESTADO, JSON.stringify(estado, null, 1))

// Subida: primero los CRX, después el catálogo (que nunca apunte a un fichero que aún no está) y al final la limpieza.
if (SUBIR) {
  const rsync = (...a) => execFileSync('rsync', ['-rt', '--chmod=D755,F644', ...a], { stdio: 'inherit' })
  rsync(path.join(SALIDA, 'release') + '/', `${SUBIR}:release/`)
  rsync(path.join(SALIDA, 'catalog.json'), path.join(SALIDA, '_estado.json'), `${SUBIR}:`)
  rsync('--delete', path.join(SALIDA, 'release') + '/', `${SUBIR}:release/`)
}
for (const f of fallos) console.error('FALLO ' + f)
for (const p of pendientes) console.error(`Para aprobar los recursos, tras revisarlos: echo ${p} >> ${APROBADOS}`)
process.exit(fallos.length ? 1 : 0)
