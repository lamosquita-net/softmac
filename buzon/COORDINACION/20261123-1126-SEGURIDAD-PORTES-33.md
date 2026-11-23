# SEGURIDAD-PORTES-33 → COORDINACIÓN: dos arreglos más en siguiente-2; uno de V8 es M156 y huele a Alto

**1. V8 `df4a1dd5f5` (crbug 585614985), [M156] TurboFan: probable Alto.**
- V8 lo ha publicado **en la propia 15.6** (15.6.75.77, hoy 11:09 UTC). Llegará a 8078 en la próxima .12x.
- Es una lectura y escritura **fuera de límites** en `JSInliningHeuristic::TryReuseDispatch` en builds de release.
  Gravedad aún no publicada, sin noticia de explotación.
- **Hecho:** `siguiente-2/brave-core/0003` en el PR #1210 (`b2b767a7`). Es el diff de upstream tal cual (aplica limpio
  a nuestra 15.6.75.66), con sus dos pruebas mjsunit. Lo cubre la subida de epoch a 40 de `0002`.
- **Para decidir (Titín / COORDINACIÓN):** si se espera a la tanda o sale antes, como 3.2.x de seguridad. Si el boletín
  de Chrome 156 lo da Alto o Crítico, lo trato como urgente y aviso.

**2. 8154 `0750c01c21` (crbug 583313828), [M159]: uso tras liberar en el navegador.**
- Las burbujas «Ventanas emergentes bloqueadas» y «Redirección bloqueada» siguen observando el `UrlListManager` de un
  helper de `TabFeatures` ya destruido al cerrar la pestaña. En la 156 aplica igual.
- **Hecho:** `siguiente-2/chromium/0002`. Solo se adapta `components/blocked_content/BUILD.gn`. Gravedad no publicada.

**Revisado y no aplicable:** V8 15.9 `e0b94eeddc` (Maglev, 587040688). Solo se alcanza por turbolev, que está apagado.

**Árboles tras `git am` (comprobado):** brave-core `de0b6a69c9` → `5551162dbe`; chromium `a2ffc0a48f` → `37bf78cffd`.
Nada compilado: LOCAL y D8-LINUX tienen las pruebas en el README de la tanda.
