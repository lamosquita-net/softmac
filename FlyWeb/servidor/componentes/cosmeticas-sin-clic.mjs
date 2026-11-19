// Reglas cosméticas que dependen de un clic «trusted» que FlyWeb no tiene.
//
// Las listas de avisos de cookies combinan, para un mismo sitio, un scriptlet que pulsa «Rechazar»
// (+js(trusted-click-element, …)) con una regla que oculta el diálogo mientras tanto. FlyWeb quita
// todos los scriptlets «trusted» de sus recursos (recursos-157.mjs, recursos-20.mjs), así que el clic
// no llega nunca y la página queda oculta. Caso real: consent.google.com/m?…&pc=cws (Chrome Web Store)
// se queda en blanco con un perfil nuevo (uAssets annoyances-cookies.txt, l.128 y l.130).
//
// Regla: en las listas de LISTAS_CON_CLIC, a cada regla cosmética (## o #?#, sin +js ni ##^) se le
// quitan los hosts que en la MISMA lista tienen algún +js(trusted-…); si no le queda ninguno, se quita
// la línea. Las reglas genéricas (sin host), las excepciones (#@#), las de red y los hosts negados (~)
// no se tocan. Los hosts se comparan como texto exacto (consent.google.* ≠ google.*), igual que los
// escribe la lista.
//
// Solo se aplica a la lista de avisos de cookies: en las listas de anuncios, ocultar un anuncio no
// depende de ningún clic, y quitarlo dejaría el anuncio a la vista.

// «Cookie notice blocker» (kCookieListUuid, brave_shield_constants.h).
export const LISTAS_CON_CLIC = new Set(['AC023D22-AE88-4060-A978-4FEEEC4221693'])

const COSMETICA = /^([^#\s]*)(##|#\?#)(.+)$/
const TRUSTED = /^([^#\s]+)##\+js\(\s*trusted-/

const hostsDe = (campo) => campo.split(',').map((h) => h.trim()).filter(Boolean)

// lineas: array de líneas ya preprocesadas. Devuelve { lineas, quitadas, recortadas, hosts }.
export function quitarCosmeticasSinClic (lineas) {
  const conClic = new Set()
  for (const l of lineas) {
    const m = l.match(TRUSTED)
    if (m) for (const h of hostsDe(m[1])) if (!h.startsWith('~')) conClic.add(h)
  }
  const out = []; let quitadas = 0; let recortadas = 0
  for (const l of lineas) {
    const m = l.startsWith('!') ? null : l.match(COSMETICA)
    // Sin host (genérica), scriptlet o filtrado de HTML: se deja como está.
    if (!m || !m[1] || m[3].startsWith('+js(') || m[3].startsWith('^')) { out.push(l); continue }
    const hosts = hostsDe(m[1])
    const quedan = hosts.filter((h) => !conClic.has(h))
    if (quedan.length === hosts.length) { out.push(l); continue }
    // Solo quedan hosts negados: la regla pasaría a ser genérica. Se quita entera.
    if (!quedan.some((h) => !h.startsWith('~'))) { quitadas++; continue }
    recortadas++
    out.push(`${quedan.join(',')}${m[2]}${m[3]}`)
  }
  return { lineas: out, quitadas, recortadas, hosts: conClic.size }
}
