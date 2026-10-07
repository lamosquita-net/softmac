// Cifras de FlyWeb: lee cifras.csv (fecha,tipo,dmg,descargas) y rellena la tabla. Sin dependencias ni nada externo.
'use strict'
document.addEventListener('DOMContentLoaded', async () => {
  const enUso = document.getElementById('en-uso')
  const tabla = document.getElementById('tabla')
  try {
    const r = await fetch('cifras.csv', { cache: 'no-cache' })
    if (!r.ok) throw new Error(r.status)
    const filas = (await r.text()).trim().split('\n').slice(1).map((l) => l.split(','))
    const hace30 = new Date(Date.now() - 30 * 864e5).toISOString().slice(0, 10)
    const v = {}
    for (const [fecha, tipo, dmg, n] of filas) {
      if (tipo !== 'web' && tipo !== 'act') continue
      const x = (v[dmg] ??= { web: 0, act: 0, web30: 0, act30: 0 })
      x[tipo] += Number(n)
      if (fecha >= hace30) x[tipo + '30'] += Number(n)
    }
    const num = (s) => s.replace(/^FlyWeb-|\.dmg$/g, '').split('.').map(Number)
    const orden = Object.keys(v).sort((a, b) => {
      const x = num(a); const y = num(b)
      for (let i = 0; i < Math.max(x.length, y.length); i++) if ((x[i] ?? 0) !== (y[i] ?? 0)) return (y[i] ?? 0) - (x[i] ?? 0)
      return 0
    })
    for (const dmg of orden) {
      const tr = tabla.insertRow()
      for (const c of [dmg.replace(/^FlyWeb-|\.dmg$/g, ''), v[dmg].web30, v[dmg].web, v[dmg].act30, v[dmg].act]) tr.insertCell().textContent = c
    }
    const ultima = orden[0]
    const fechas = filas.map((f) => f[0]).sort()
    const desde = fechas[0]
    const hasta = fechas[fechas.length - 1]
    enUso.textContent = ultima
      ? `FlyWeb ${ultima.replace(/^FlyWeb-|\.dmg$/g, '')} en uso (aprox.): ${v[ultima].web + v[ultima].act}. Contado del ${desde} al ${hasta}; se cuenta cada mañana hasta el día anterior.`
      : 'Todavía no hay descargas contadas.'
  } catch (e) {
    enUso.textContent = 'No se han podido cargar las cifras.'
  }
})
