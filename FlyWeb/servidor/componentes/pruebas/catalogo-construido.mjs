// Comprueba el catálogo que ha construido empaquetar.mjs (<salida>/catalogo.zip + indice.json): los dos ficheros
// (regional_catalog.json para la 1.x y list_catalog.json para la 2.0), una entrada de list_catalog por componente y cada
// una con el ID y la clave de SU componente (los mismos que firmará bak). Uso: node pruebas/catalogo-construido.mjs <salida>
import fs from 'fs'
import path from 'path'
import { leerZip } from '../bak/zip.mjs'

const salida = process.argv[2]
if (!salida) { console.error('Uso: node pruebas/catalogo-construido.mjs <salida>'); process.exit(2) }
const indice = JSON.parse(fs.readFileSync(path.join(salida, 'indice.json'), 'utf8'))
const listas = JSON.parse(fs.readFileSync(new URL('../listas.json', import.meta.url), 'utf8'))
const ficheros = leerZip(fs.readFileSync(path.join(salida, 'catalogo.zip')))
let fallos = 0
const ok = (nombre, cond, detalle = '') => { fallos += !cond; console.log(`${cond ? 'ok  ' : 'FALLO'} ${nombre}${cond ? '' : ' ' + detalle}`) }

ok('catalogo.zip: manifest.json + los dos catálogos', [...ficheros.keys()].sort().join() === 'list_catalog.json,manifest.json,regional_catalog.json', [...ficheros.keys()].join())
const idDe = (n) => indice.componentes.find((c) => c.nombre === n)?.id
const regional = JSON.parse(ficheros.get('regional_catalog.json'))
const lista = JSON.parse(ficheros.get('list_catalog.json'))
ok('regional_catalog: las regionales de listas.json', regional.map((e) => e.uuid).join() === listas.regionales.join())
ok('list_catalog: defecto + primera parte + regionales', lista.length === 2 + listas.regionales.length, `${lista.length} entradas`)
const esperado = [['defecto', lista[0]], ['primera-parte', lista[1]], ...listas.regionales.map((u, i) => [`lista-${u}`, lista[2 + i]])]
for (const [nombre, e] of esperado) {
  ok(`list_catalog: ${e?.uuid} usa el ID de ${nombre}`, idDe(nombre) && e?.list_text_component?.component_id === idDe(nombre), `${idDe(nombre)} / ${e?.list_text_component?.component_id}`)
}
ok('list_catalog: componentes sin repetir', new Set(lista.map((e) => e.list_text_component.component_id)).size === lista.length)
ok('list_catalog: permission_mask solo con el bit de uBlock Origin', lista.every((e) => e.permission_mask === 0 || e.permission_mask === 1))
ok('list_catalog: las de defecto/primera parte están ocultas y activas', lista.slice(0, 2).every((e) => e.hidden && e.default_enabled))
for (const e of lista) console.log(`    ${e.uuid} ${e.title} hidden=${e.hidden} default=${e.default_enabled} fpp=${e.first_party_protections} mask=${e.permission_mask} → ${e.list_text_component.component_id}`)
process.exit(fallos ? 1 : 0)
