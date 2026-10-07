// FlyWeb — la mosca de la portada. Sale del logo, vuela por la página siguiendo la ruta del boceto del HUMANO
// (06-10-2026), se posa al azar en sus paradas y, de vez en cuando, vuelve al círculo. Es el vuelo de la pestaña nueva
// (brave-core components/brave_new_tab_ui/components/default/flyweb/mosca.tsx) sin React. Solo cambia `transform`.
// Sin `will-change` (línea parpadeante en la MacPro6,1 con pantalla escalada). Con «reducir movimiento», no despega.
'use strict'
;(() => {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return
  const logo = document.querySelector('.logo')
  const fin = document.getElementById('fin-vuelo')
  if (!logo || !fin || !window.fetch || !window.DOMParser) return

  const AJUSTES = {
    velocidad: 120, // px/s a 1280 px de ancho (escala con la ventana)
    variacion: 0.2, // cada tramo, hasta un 20 % más lenta o más rápida
    ondulacion: 10, // px arriba y abajo durante el vuelo
    temblor: 2.5, // temblor rápido en vuelo
    posado: [2.5, 7], // segundos en cada parada (al azar entre los dos)
    enCasa: [8, 16], // segundos en el círculo del logo
    saltarse: 0.3, // probabilidad de pasar de largo por una parada
    giroPosado: [35, 150], // al posarse gira estos grados, a un lado u otro
    rumbo: -40, // hacia dónde mira el dibujo (0 = derecha); la cabeza, arriba a la derecha
    salida: [2.5, 5] // segundos en el logo antes del primer vuelo
  }
  // Ruta cerrada del boceto (px de un lienzo de 1281 de ancho; el alto se reparte hasta el final de las notas).
  // `casa`: el círculo del logo; `posa`: una de las moscas dibujadas en el boceto.
  const ANCHO = 1281
  const ALTO = 900
  const RUTA = [
    { casa: true }, { x: 560, y: 50 }, { x: 740, y: 40 }, { x: 905, y: 62, posa: true }, { x: 1080, y: 120 },
    { x: 1190, y: 220 }, { x: 1215, y: 330 }, { x: 1130, y: 430 }, { x: 960, y: 485 }, { x: 765, y: 515, posa: true },
    { x: 560, y: 560 }, { x: 330, y: 640 }, { x: 130, y: 720 }, { x: 72, y: 770, posa: true }, { x: 150, y: 830 },
    { x: 420, y: 835 }, { x: 760, y: 815 }, { x: 1000, y: 780 }, { x: 1178, y: 722, posa: true }, { x: 1225, y: 600 },
    { x: 1170, y: 500 }, { x: 960, y: 470 }, { x: 765, y: 522 }, { x: 520, y: 552 }, { x: 260, y: 550 },
    { x: 80, y: 470 }, { x: 30, y: 340 }, { x: 100, y: 225, posa: true }, { x: 250, y: 130 }
  ]

  const mosca = document.createElement('div')
  mosca.className = 'mosca-vuelo en-casa'
  mosca.setAttribute('aria-hidden', 'true')

  function punto (p0, p1, p2, p3, t) { // Catmull-Rom
    const t2 = t * t; const t3 = t2 * t
    const c = (a, b, c_, d) => 0.5 * (2 * b + (-a + c_) * t + (2 * a - 5 * b + 4 * c_ - d) * t2 + (-a + 3 * b - 3 * c_ + d) * t3)
    return { x: c(p0.x, p1.x, p2.x, p3.x), y: c(p0.y, p1.y, p2.y, p3.y) }
  }

  let tabla = []; let largo = 0; let paradas = []; let casa = { x: 0, y: 0 }; let tam = 70

  function medir () {
    const W = document.documentElement.clientWidth
    const r = logo.getBoundingClientRect()
    const H = fin.getBoundingClientRect().bottom + scrollY
    tam = mosca.offsetWidth || 70
    casa = { x: r.left + scrollX + r.width / 2, y: r.top + scrollY + r.height / 2 }
    const P = RUTA.map(p => p.casa ? casa : { x: p.x / ANCHO * W, y: p.y / ALTO * H })
    const n = P.length; const PASOS = 50
    tabla = []; paradas = []; largo = 0
    let prev = null
    for (let i = 0; i < n; i++) {
      if (RUTA[i].casa || RUTA[i].posa) paradas.push({ d: largo, casa: !!RUTA[i].casa })
      for (let k = 0; k < PASOS; k++) {
        const q = punto(P[(i - 1 + n) % n], P[i], P[(i + 1) % n], P[(i + 2) % n], k / PASOS)
        if (prev) largo += Math.hypot(q.x - prev.x, q.y - prev.y)
        tabla.push({ d: largo, x: q.x, y: q.y }); prev = q
      }
    }
    largo += Math.hypot(tabla[0].x - prev.x, tabla[0].y - prev.y)
  }
  function en (d) {
    d = ((d % largo) + largo) % largo
    let lo = 0; let hi = tabla.length - 1
    while (lo < hi) { const m = (lo + hi + 1) >> 1; if (tabla[m].d <= d) lo = m; else hi = m - 1 }
    const a = tabla[lo]; const b = tabla[(lo + 1) % tabla.length]
    const tramo = (b.d > a.d ? b.d : largo) - a.d
    const f = tramo ? (d - a.d) / tramo : 0
    return { x: a.x + (b.x - a.x) * f, y: a.y + (b.y - a.y) * f }
  }
  const azar = (r) => r[0] + Math.random() * (r[1] - r[0])

  let d = 0; let desde = 0; let destino = 0; let inicio = 0; let duracion = 1; let hasta = 0
  let volando = false; let enCasa = true; let angulo = AJUSTES.rumbo; let giroFin = 0; let girando = 0; let endereza = -9
  let parada = null

  function siguiente () { // la próxima parada por delante; a veces se salta una
    const orden = paradas.map(p => {
      const x = p.d - (d % largo)
      return { p, x: x <= 1 ? x + largo : x }
    }).sort((a, b) => a.x - b.x)
    let i = 0
    while (i < orden.length - 1 && !orden[i].p.casa && Math.random() < AJUSTES.saltarse) i++
    return orden[i]
  }
  function despegar (t) {
    const s = siguiente()
    const vel = AJUSTES.velocidad * (innerWidth / 1280) * (1 + (Math.random() * 2 - 1) * AJUSTES.variacion)
    angulo += giroFin; giroFin = 0; endereza = t
    desde = d; destino = d + s.x; parada = s.p
    inicio = t; duracion = s.x / Math.max(vel, 40)
    volando = true; enCasa = false
    logo.classList.add('sin-mosca'); mosca.classList.remove('en-casa'); mosca.classList.add('vuela')
  }
  function posar (t) {
    volando = false; d = destino; girando = t
    if (parada && parada.casa) { // en el círculo, con la postura del logo
      enCasa = true; giroFin = 0; angulo = AJUSTES.rumbo; hasta = t + azar(AJUSTES.enCasa)
      logo.classList.remove('sin-mosca'); mosca.classList.add('en-casa')
    } else {
      const g = AJUSTES.giroPosado
      giroFin = (Math.random() < 0.5 ? -1 : 1) * azar(g); hasta = t + azar(AJUSTES.posado)
    }
    mosca.classList.remove('vuela')
  }

  let arranque = null; let previa = 0
  function volar (marca) {
    if (arranque === null) { arranque = previa = marca; hasta = azar(AJUSTES.salida); parada = paradas[0] }
    const hueco = marca - previa
    if (hueco > 800) arranque += hueco - 16 // pestaña oculta: sin saltos
    previa = marca
    const t = (marca - arranque) / 1000
    let x; let y; let giro
    if (volando) {
      const f = Math.min(1, (t - inicio) / duracion)
      const s = f * f * (3 - 2 * f)
      d = desde + (destino - desde) * s
      const p = en(d); const q = en(d + 30)
      x = p.x + Math.sin(t * 23) * AJUSTES.temblor
      y = p.y + Math.sin(f * Math.PI) * Math.sin(t * 2.1) * AJUSTES.ondulacion + Math.cos(t * 19) * AJUSTES.temblor
      const rumbo = Math.atan2(q.y - p.y, q.x - p.x) * 180 / Math.PI
      const fe = Math.min(1, (t - endereza) / 0.4)
      const dif = ((rumbo - angulo + 540) % 360) - 180
      angulo = fe < 1 ? angulo + dif * fe : rumbo
      // al llegar a casa, recupera la postura del logo en el último tramo
      const fc = parada && parada.casa ? Math.max(0, (f - 0.85) / 0.15) : 0
      giro = (angulo - AJUSTES.rumbo) * (1 - fc)
      if (f >= 1) posar(t)
    } else {
      const p = enCasa ? casa : en(d)
      x = p.x; y = p.y
      const eg = 1 - Math.pow(1 - Math.min(1, (t - girando) / 0.6), 3)
      giro = enCasa ? 0 : angulo - AJUSTES.rumbo + giroFin * eg + Math.sin(t * 1.3) * 6 + (Math.sin(t * 7) > 0.97 ? 4 : 0)
      if (t > hasta) despegar(t)
    }
    mosca.style.transform = `translate(${x - tam / 2}px, ${y - tam / 2}px) rotate(${giro}deg)`
    requestAnimationFrame(volar)
  }

  fetch(document.querySelector('.logo .mosca-logo').getAttribute('src'))
    .then(r => r.ok ? r.text() : Promise.reject(r.status))
    .then(texto => {
      const svg = new DOMParser().parseFromString(texto, 'image/svg+xml').documentElement
      if (svg.nodeName !== 'svg') return
      mosca.appendChild(document.importNode(svg, true))
      document.body.appendChild(mosca)
      medir()
      let espera = 0
      const remedir = () => { clearTimeout(espera); espera = setTimeout(medir, 150) }
      addEventListener('resize', remedir)
      if (window.ResizeObserver) new ResizeObserver(remedir).observe(document.body)
      requestAnimationFrame(volar)
    })
    .catch(() => {})
})()
