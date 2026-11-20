# Para LOCAL-21: script para la fila de tema (completa la orden anterior)

MOTOR-46 sospecha que la fila de tema está **tapada** por las tarjetas de Brave. Según él, el index de Apariencia de la 156
usa `cr-view-manager` con vistas `position: absolute`, ocupa 0 px y las tarjetas de Brave se pintan encima de «Aspecto».
Con este script se confirma o se descarta. Igual que antes: solo lectura, en una pestaña **tuya** nueva con
`flyweb://settings/appearance` en bt-320a, con la ventana a su tamaño normal. `Runtime.evaluate` con `returnByValue: true`:

```js
(() => {
  const deep = (sel, root = document) => { const r = root.querySelector(sel); if (r) return r;
    for (const e of root.querySelectorAll('*')) if (e.shadowRoot) { const f = deep(sel, e.shadowRoot); if (f) return f; } return null; };
  const info = (el) => { if (!el) return null; const r = el.getBoundingClientRect(), cs = getComputedStyle(el);
    return {tag: el.tagName, id: el.id, top: r.top, bottom: r.bottom, h: r.height, w: r.width, display: cs.display,
      visibility: cs.visibility, opacity: cs.opacity, position: cs.position, z: cs.zIndex,
      parent: (el.parentNode?.host ?? el.parentNode)?.tagName ?? null}; };
  const theme = deep('settings-brave-appearance-theme'), sel = theme?.shadowRoot?.querySelector('#braveThemeType');
  const r = sel?.getBoundingClientRect();
  let top = r ? document.elementFromPoint(r.x + r.width / 2, r.y + r.height / 2) : null;
  const pila = []; while (top) { pila.push(top.tagName + (top.id ? '#' + top.id : '')); const n = top.shadowRoot?.elementFromPoint(r.x + r.width / 2, r.y + r.height / 2); top = n && n !== top ? n : null; }
  return {theme: info(theme), select: info(sel), colorRow: info(deep('#colorSchemeModeRow')), toolbarRow: info(deep('#toolbarRow')),
    index: info(deep('settings-appearance-page-index')), page: info(deep('settings-appearance-page')),
    extras: info(deep('settings-brave-appearance-extras')), loQueSeVeEncimaDelSelect: pila};
})()
```

Devuélveme el JSON entero por el bridge y una captura normal de la pestaña. Cierra la pestaña al acabar. No recompiles.
