// Prueba sin red de cosmeticas-sin-clic.mjs: las ocultaciones que esperan un clic «trusted» salen de la
// lista de avisos de cookies, y el resto de la lista queda igual, línea a línea y en el mismo orden.
// Uso: node pruebas/cosmeticas-sin-clic.mjs [lista.txt]
//   Con una lista (p. ej. el list.txt de la de cookies), además cuenta lo que quitaría.
import fs from 'fs'
import { LISTAS_CON_CLIC, cubre, quitarCosmeticasSinClic } from '../cosmeticas-sin-clic.mjs'

let fallos = 0
const ok = (nombre, cond, detalle = '') => { fallos += !cond; console.log(`${cond ? 'ok  ' : 'FALLO'} ${nombre}${!cond && detalle ? `: ${detalle}` : ''}`) }

// Líneas reales (uBlock Origin filters/annoyances-cookies.txt y brave-lists/brave-cookie-specific.txt, 19-11-2026).
const GOOGLE_CLIC = 'consent.google.*##+js(trusted-click-element, form[action] button[jsname="tWT92d"])'
const GOOGLE_OCULTA = 'consent.google.*##[data-p*="/consent.google."]:has(button[jsname="tWT92d"])'
const YT_CLIC = 'consent.youtube.com##+js(trusted-click-element, [action="https://consent.youtube.com/save"][style="display:inline;"] [name="set_eom"][value="true"] ~ .basebuttonUIModernization[value][aria-label])'
const YT_OCULTA = 'consent.youtube.com##body.bodyUIModernization:has([action="https://consent.youtube.com/save"] .saveButtonUIModernization[value][aria-label])'
const lista = [
  '! Title: prueba',
  'www.google.*##+js(trusted-click-element, button#W0wltc, , 500)',
  GOOGLE_CLIC,
  '! https://github.com/DandelionSprout/adfilt/discussions/932#discussioncomment-8260397',
  GOOGLE_OCULTA,
  YT_CLIC,
  YT_OCULTA,
  'consent.google.*##+js(trusted-click-element, form[action] button[jsname="tWT92d"]), , 1500)',
  // Sin clic «trusted»: se quedan.
  'example.com##.cookie-banner',
  'example.com##+js(set-cookie, consent, true)',
  '##.cc-window',
  'consent.google.*#@#.algo',
  '||consent.google.com/js/tracker.js$script',
  '@@||consent.google.com^$generichide',
  'consent.google.*##^script:has-text(x)',
  'google.*##.no-es-el-mismo-host',
  // Varios hosts: se quita solo el que tiene clic.
  'consent.youtube.com,otro.example##.aviso',
  // Solo quedaría un host negado: la regla pasaría a ser genérica, así que sale entera.
  'consent.youtube.com,~www.consent.youtube.com##.otro',
  // Procedural (#?#), también oculta.
  'consent.google.*#?#div:has(> button[jsname="tWT92d"])',
  // Negado en el clic: no cuenta.
  '~negado.example##+js(trusted-click-element, button)',
  'negado.example##.se-queda',
  // Comodines y subdominios: el clic de consent.google.* también corre en consent.google.com y .co.uk,
  // y el de consent.youtube.com en www.consent.youtube.com. Al revés no.
  'consent.google.com##.concreto',
  'consent.google.co.uk##.concreto-uk',
  'www.consent.youtube.com##.sub',
  'youtube.com##.padre-se-queda',
  'ai.example.com##+js(trusted-click-element, button)',
  'example.*##.comodin-se-queda',
  'CONSENT.GOOGLE.COM##.mayusculas',
  ''
]
const r = quitarCosmeticasSinClic(lista)
const sale = new Set(r.lineas)
ok('no sale la ocultación de consent.google.* (la de la Web Store)', !sale.has(GOOGLE_OCULTA))
ok('no sale la procedural (#?#) de consent.google.*', !r.lineas.some((l) => l.startsWith('consent.google.*#?#')))
ok('no sale la de consent.youtube.com (oculta el <body>)', !sale.has(YT_OCULTA))
ok('los +js(trusted-…) se quedan (sin recurso, el motor no hace nada)', sale.has(GOOGLE_CLIC) && sale.has(YT_CLIC))
ok('varios hosts: se recorta solo el del clic', sale.has('otro.example##.aviso') && !r.lineas.some((l) => l.includes('consent.youtube.com,otro')))
ok('solo quedaría un negado: se quita entera', !r.lineas.some((l) => l.includes('##.otro')))
ok('hosts negados en el clic no cuentan', sale.has('negado.example##.se-queda'))
ok('comodín de TLD: consent.google.* cubre consent.google.com y .co.uk', !sale.has('consent.google.com##.concreto') && !sale.has('consent.google.co.uk##.concreto-uk') && !sale.has('CONSENT.GOOGLE.COM##.mayusculas'))
ok('subdominio del host del clic: se quita', !sale.has('www.consent.youtube.com##.sub'))
ok('dominio padre del host del clic: se queda', sale.has('youtube.com##.padre-se-queda'))
ok('comodín en la ocultación y clic en un host concreto: se queda', sale.has('example.*##.comodin-se-queda'))
ok('cubre()', cubre('consent.google.*', 'consent.google.com') && cubre('consent.google.*', 'a.consent.google.co.uk') && cubre('google.*', 'consent.google.*') &&
  cubre('example.com', 'www.example.com') && !cubre('example.com', 'example.*') && !cubre('www.example.com', 'example.com') &&
  !cubre('google.*', 'google.com.evil.example') && !cubre('example.com', 'notexample.com'))
ok('cuentas', r.quitadas === 8 && r.recortadas === 1 && r.hosts === 4, JSON.stringify({ q: r.quitadas, rc: r.recortadas, h: r.hosts }))
// El resto, idéntico y en el mismo orden.
const quitadas = new Set([GOOGLE_OCULTA, YT_OCULTA, 'consent.youtube.com,~www.consent.youtube.com##.otro', 'consent.google.*#?#div:has(> button[jsname="tWT92d"])',
  'consent.google.com##.concreto', 'consent.google.co.uk##.concreto-uk', 'www.consent.youtube.com##.sub', 'CONSENT.GOOGLE.COM##.mayusculas'])
const esperado = lista.filter((l) => !quitadas.has(l)).map((l) => l === 'consent.youtube.com,otro.example##.aviso' ? 'otro.example##.aviso' : l)
ok('el resto de la lista no cambia (mismas líneas, mismo orden)', JSON.stringify(r.lineas) === JSON.stringify(esperado))
const sinClic = lista.filter((l) => !l.includes('+js(trusted-'))
ok('una lista sin clics «trusted» sale idéntica', JSON.stringify(quitarCosmeticasSinClic(sinClic).lineas) === JSON.stringify(sinClic))
// Ningún +js entra ni cambia, y todo lo que sale ya estaba (o es una cosmética recortada).
const jsAntes = lista.filter((l) => l.includes('+js(')); const jsDespues = r.lineas.filter((l) => l.includes('+js('))
ok('los +js salen exactamente igual (ni nuevos ni cambiados)', JSON.stringify(jsAntes) === JSON.stringify(jsDespues))
ok('nada nuevo: cada línea de salida está en la entrada salvo las recortadas', r.lineas.every((l) => lista.includes(l) || l === 'otro.example##.aviso'))
ok('solo se aplica a la lista de avisos de cookies', LISTAS_CON_CLIC.size === 1 && LISTAS_CON_CLIC.has('AC023D22-AE88-4060-A978-4FEEEC4221693'))

if (process.argv[2]) {
  const real = fs.readFileSync(process.argv[2], 'utf8').split('\n')
  const rr = quitarCosmeticasSinClic(real)
  console.log(`${process.argv[2]}: ${real.length} líneas, ${rr.quitadas} quitadas, ${rr.recortadas} recortadas, ${rr.hosts} hosts con clic «trusted»`)
  console.log(`hosts que pierden ocultaciones (${rr.hostsQuitados.size}): ${[...rr.hostsQuitados].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])).map(([h, n]) => `${h} (${n})`).join(', ')}`)
  const js = (ls) => ls.filter((l) => l.includes('+js(')).join('\n')
  ok('lista real: los +js salen exactamente igual', js(real) === js(rr.lineas))
  ok('lista real: no sale la ocultación de consent.google.*', !rr.lineas.includes(GOOGLE_OCULTA))
  ok('lista real: no sale la de consent.youtube.com', !rr.lineas.includes(YT_OCULTA))
}

if (fallos) { console.error(`${fallos} fallo(s)`); process.exit(1) }
console.log('todo bien')
