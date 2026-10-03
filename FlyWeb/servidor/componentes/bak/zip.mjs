// ZIP mínimo, sin dependencias (solo zlib de Node). Lo usan empaquetar.mjs (escribe) y firmar.mjs (lee y comprueba).
// Solo lo necesario para un componente: ficheros en la raíz o en una carpeta numérica ("1/", la versión de datos que
// leen los componentes de datos locales), sin entradas de carpeta, deflate o sin comprimir, sin zip64.
import zlib from 'zlib'

const TABLA = new Uint32Array(256).map((_, n) => {
  let c = n
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1
  return c >>> 0
})
export const crc32 = (b) => {
  let c = 0xffffffff
  for (const x of b) c = TABLA[(c ^ x) & 0xff] ^ (c >>> 8)
  return (c ^ 0xffffffff) >>> 0
}

const NOMBRE_VALIDO = /^(?:\d{1,3}\/)?[A-Za-z0-9_-][A-Za-z0-9_.-]{0,63}$/

// ficheros: [{ nombre, datos: Buffer }]. Fecha fija (1980-01-01) para que el resultado dependa solo del contenido.
export function crearZip (ficheros) {
  const locales = []; const central = []; let pos = 0
  for (const { nombre, datos } of ficheros) {
    if (!NOMBRE_VALIDO.test(nombre)) throw new Error(`nombre no válido: ${nombre}`)
    const n = Buffer.from(nombre); const comp = zlib.deflateRawSync(datos, { level: 9 }); const crc = crc32(datos)
    const cab = Buffer.alloc(30)
    cab.writeUInt32LE(0x04034b50, 0); cab.writeUInt16LE(20, 4); cab.writeUInt16LE(0, 6); cab.writeUInt16LE(8, 8)
    cab.writeUInt16LE(0, 10); cab.writeUInt16LE(0x21, 12); cab.writeUInt32LE(crc, 14)
    cab.writeUInt32LE(comp.length, 18); cab.writeUInt32LE(datos.length, 22); cab.writeUInt16LE(n.length, 26)
    const cen = Buffer.alloc(46)
    cen.writeUInt32LE(0x02014b50, 0); cen.writeUInt16LE(20, 4); cen.writeUInt16LE(20, 6); cen.writeUInt16LE(0, 8)
    cen.writeUInt16LE(8, 10); cen.writeUInt16LE(0, 12); cen.writeUInt16LE(0x21, 14); cen.writeUInt32LE(crc, 16)
    cen.writeUInt32LE(comp.length, 20); cen.writeUInt32LE(datos.length, 24); cen.writeUInt16LE(n.length, 28)
    cen.writeUInt32LE(pos, 42)
    locales.push(cab, n, comp); central.push(cen, n)
    pos += 30 + n.length + comp.length
  }
  const dir = Buffer.concat(central); const fin = Buffer.alloc(22)
  fin.writeUInt32LE(0x06054b50, 0); fin.writeUInt16LE(ficheros.length, 8); fin.writeUInt16LE(ficheros.length, 10)
  fin.writeUInt32LE(dir.length, 12); fin.writeUInt32LE(pos, 16)
  return Buffer.concat([...locales, dir, fin])
}

// Devuelve Map nombre → Buffer. Rechaza lo que no sea un zip simple: entradas de carpeta, rutas, duplicados, cifrado, zip64,
// datos tras el directorio central o un CRC que no cuadre.
export function leerZip (zip) {
  const fin = zip.length - 22
  if (fin < 0 || zip.readUInt32LE(fin) !== 0x06054b50) throw new Error('zip: falta el final del directorio (o hay comentario)')
  const total = zip.readUInt16LE(fin + 10); const tam = zip.readUInt32LE(fin + 12); const ini = zip.readUInt32LE(fin + 16)
  if (ini + tam !== fin) throw new Error('zip: directorio central fuera de sitio')
  const out = new Map(); let p = ini
  for (let i = 0; i < total; i++) {
    if (zip.readUInt32LE(p) !== 0x02014b50) throw new Error('zip: entrada central no válida')
    const flags = zip.readUInt16LE(p + 8); const metodo = zip.readUInt16LE(p + 10); const crc = zip.readUInt32LE(p + 16)
    const comp = zip.readUInt32LE(p + 20); const real = zip.readUInt32LE(p + 24)
    const ln = zip.readUInt16LE(p + 28); const le = zip.readUInt16LE(p + 30); const lc = zip.readUInt16LE(p + 32)
    const local = zip.readUInt32LE(p + 42); const nombre = zip.subarray(p + 46, p + 46 + ln).toString('utf8')
    p += 46 + ln + le + lc
    if (flags & 1) throw new Error(`zip: ${nombre} cifrado`)
    if (comp === 0xffffffff || real === 0xffffffff) throw new Error('zip: zip64 no admitido')
    if (!NOMBRE_VALIDO.test(nombre)) throw new Error(`zip: nombre no válido: ${JSON.stringify(nombre)}`)
    if (out.has(nombre)) throw new Error(`zip: ${nombre} repetido`)
    if (zip.readUInt32LE(local) !== 0x04034b50) throw new Error(`zip: cabecera local de ${nombre} no válida`)
    const d0 = local + 30 + zip.readUInt16LE(local + 26) + zip.readUInt16LE(local + 28)
    const bruto = zip.subarray(d0, d0 + comp)
    const datos = metodo === 8 ? zlib.inflateRawSync(bruto) : metodo === 0 ? Buffer.from(bruto) : null
    if (!datos) throw new Error(`zip: método ${metodo} no admitido`)
    if (datos.length !== real || crc32(datos) !== crc) throw new Error(`zip: ${nombre} dañado`)
    out.set(nombre, datos)
  }
  if (p !== fin) throw new Error('zip: datos sobrantes en el directorio central')
  return out
}
