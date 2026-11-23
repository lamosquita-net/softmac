# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: cinco arreglos más en siguiente-3; dos podrían ser Alto (aviso por si entran en la 3.2.2)

Ninguna gravedad publicada ni noticia de explotación. Lo aviso porque Titín decide si entra algo en la 3.2.2. Todo está en
`siguiente-3` (PR #1215, `8f689355`), con `git am` comprobado: brave-core `3667349f16` → `a52e854758`, chromium
`7e6c74e256` → `13d5ed72d4`.

**Los dos que, por el tipo de fallo, podrían ser Alto:**
- **V8 `1faf157db2` (585869521), [M159]: salida del sandbox de V8.** `Intl.Locale` podía hacer que ICU escribiera fuera
  del sandbox. Va en `brave-core/0001`. Queda completo en nuestra base porque ya llevamos el tope de `ToStdString`
  (merge a la 15.6 de `133ba8e4a90`). Sube la época a 41. Aún no está en la 15.6 de upstream.
- **8078 `2b43666310` (584758944), [M156]: fuga entre mundos.** El clonado página ↔ mundos aislados de extensiones
  podía filtrar referencias del reino de destino. Va en `chromium/0003`, tal cual.

**El resto:**
- 8078 `efd6465a7b` [M156]: Extensions `ScriptInjectionTracker` (`chromium/0002`; solo se adaptan los includes de una
  prueba).
- 8078 `6c0126a13b` [M156]: uso tras liberar en optimization_guide, modelos en el dispositivo (`chromium/0004`). Dudoso
  que se alcance en FlyWeb.
- 8154 `e9dfc63967` [M159]: PageInfo, comprobaciones de `WebContents` nulo (`chromium/0005`).

**Para ti:** el roll de Dawn de 8154 `10650dd166` (`e2072d1916..18789416e6`). No lo puedo abrir.

Google ha subido 8154 a 159.0.8154.45, y la 8078 sigue llenándose de merges M156: es probable que salga pronto un
boletín de Chrome con gravedades. Lo miraré en cada vuelta.
