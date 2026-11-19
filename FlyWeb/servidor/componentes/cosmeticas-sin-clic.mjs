// Reglas cosméticas que dependen de un clic «trusted» que FlyWeb no tiene.
//
// Las listas de avisos de cookies combinan, para un mismo sitio, un scriptlet que pulsa «Rechazar»
// (+js(trusted-click-element, …)) con una regla que oculta el diálogo mientras tanto. FlyWeb quita
// todos los scriptlets «trusted» de sus recursos (recursos-157.mjs, recursos-20.mjs), así que el clic
// no llega nunca y la página queda oculta. Caso real: consent.google.com/m?…&pc=cws (Chrome Web Store)
// se queda en blanco con un perfil nuevo (uAssets annoyances-cookies.txt, l.128 y l.130).
//
// Regla: en las listas de LISTAS_CON_CLIC, a cada regla cosmética (## o #?#, sin +js ni ##^) se le
// quitan los hosts que en la MISMA lista tienen un +js(trusted-click-element, …); si no le queda
// ninguno, se quita la línea. Solo el clic (decisión de Titín, 19-11-2026): es el caso en que la página
// espera a que se pulse algo. Con los demás «trusted» (trusted-set-cookie, …) la ocultación no deja la
// página vacía, así que se conserva. Las reglas genéricas (sin host), las excepciones (#@#), las de red y los hosts negados (~)
// no se tocan. Un host está «afectado» si el clic se ejecutaría en él: es el mismo host, un subdominio
// (www.ejemplo.com con el clic en ejemplo.com) o lo cubre un comodín de TLD (consent.google.com con el
// clic en consent.google.*). Al revés no: un comodín en la ocultación (google.*) no se quita por un
// clic en un host concreto (google.com), porque la ocultación sigue valiendo en los demás TLD.
//
// Solo se aplica a la lista de avisos de cookies: en las listas de anuncios, ocultar un anuncio no
// depende de ningún clic, y quitarlo dejaría el anuncio a la vista.

// «Cookie notice blocker» (kCookieListUuid, brave_shield_constants.h).
export const LISTAS_CON_CLIC = new Set(['AC023D22-AE88-4060-A978-4FEEEC4221693'])

const COSMETICA = /^([^#\s]*)(##|#\?#)(.+)$/
const TRUSTED = /^([^#\s]+)##\+js\(\s*trusted-click-element\s*[,)]/

const hostsDe = (campo) => campo.split(',').map((h) => h.trim()).filter(Boolean)

// ¿El clic de `t` (host o entidad «base.*») se ejecuta en el host `h` de una ocultación?
export function cubre (t, h) {
  t = t.toLowerCase(); h = h.toLowerCase()
  if (t === h || h.endsWith('.' + t)) return true // mismo host o subdominio (también entidad con entidad)
  if (!t.endsWith('.*') || h.endsWith('.*')) return false
  // t = base.*: h concreto con forma [algo.]base.<1 o 2 etiquetas de TLD>
  const base = t.slice(0, -2)
  for (const pre of [base + '.', '.' + base + '.']) {
    const i = pre[0] === '.' ? h.indexOf(pre) : (h.startsWith(pre) ? 0 : -1)
    if (i < 0) continue
    const tld = h.slice(i + pre.length)
    if (/^[a-z0-9-]+(\.[a-z0-9-]+)?$/.test(tld)) return true
  }
  return false
}

// lineas: array de líneas ya preprocesadas. Devuelve { lineas, quitadas, recortadas, hosts (con clic),
// hostsQuitados (Map host → reglas de las que sale) }.
export function quitarCosmeticasSinClic (lineas) {
  const conClic = new Set()
  for (const l of lineas) {
    const m = l.match(TRUSTED)
    if (m) for (const h of hostsDe(m[1])) if (!h.startsWith('~')) conClic.add(h.toLowerCase())
  }
  // Índice por última etiqueta «útil» para no comparar con los miles de hosts uno a uno.
  const clave = (h) => { const p = h.replace(/\.\*$/, '').split('.'); return p.length > 1 && !h.endsWith('.*') ? p[p.length - 2] : p[p.length - 1] }
  const porClave = new Map()
  for (const t of conClic) { const k = clave(t); if (!porClave.has(k)) porClave.set(k, []); porClave.get(k).push(t) }
  const etiquetas = (h) => h.toLowerCase().replace(/\.\*$/, '').split('.')
  const afectado = (h) => {
    if (h.startsWith('~')) return false
    for (const k of new Set(etiquetas(h))) for (const t of porClave.get(k) ?? []) if (cubre(t, h)) return true
    return false
  }
  const out = []; let quitadas = 0; let recortadas = 0; const hostsQuitados = new Map()
  for (const l of lineas) {
    const m = l.startsWith('!') ? null : l.match(COSMETICA)
    // Sin host (genérica), scriptlet o filtrado de HTML: se deja como está.
    if (!m || !m[1] || m[3].startsWith('+js(') || m[3].startsWith('^')) { out.push(l); continue }
    const hosts = hostsDe(m[1])
    const quedan = hosts.filter((h) => !afectado(h))
    if (quedan.length === hosts.length) { out.push(l); continue }
    for (const h of hosts) if (!quedan.includes(h)) hostsQuitados.set(h, (hostsQuitados.get(h) ?? 0) + 1)
    // Solo quedan hosts negados: la regla pasaría a ser genérica. Se quita entera.
    if (!quedan.some((h) => !h.startsWith('~'))) { quitadas++; continue }
    recortadas++
    out.push(`${quedan.join(',')}${m[2]}${m[3]}`)
  }
  return { lineas: out, quitadas, recortadas, hosts: conClic.size, hostsQuitados }
}
