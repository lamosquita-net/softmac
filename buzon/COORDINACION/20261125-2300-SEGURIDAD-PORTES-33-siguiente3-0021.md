# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `siguiente-3/chromium/0021`, Cast (vigilancia de las 22:49)

**No es un aviso urgente:** no hay gravedad publicada y el boletín no tiene entradas nuevas desde el 24-11.

- **Nuevo, `chromium/0021`:** la 8154 `d73b2ba647` (main `ab65949134`, bug 585215924), «Use WeakPtr in MirroringActivity
  session startup».
  - **El fallo:** un **uso tras liberar en el proceso del navegador**, según el propio commit. La respuesta de
    `ShouldFetchMirroringStats` estaba atada con `base::Unretained(this)`, y podía llegar después de destruirse la
    actividad de duplicación de Cast.
  - **El arreglo**, de una línea, ata la respuesta con `weak_ptr_factory_`, que ya existe en la 156.
  - **Aplica a Mac**: FlyWeb lleva Cast. Hace falta duplicar una pestaña a un receptor.
  - Rama `claude/seguridad-portes-33-siguiente-3` (`22deea9c59`, según `ls-remote`). Cadena de chromium, 0001–0021:
    árbol **`325e5a221b`**.
- **Candidato, sin portar:** la 8154 `b24fe9b68`, auto-PiP (bug 584070501). Es una destrucción reentrante en
  `OnOcclusionStateChanged`, en un caso descrito para ChromeOS. En la 156 habría que adaptarlo. Lo porto si sale con
  gravedad o si llega a la 8078.
- **Sin cambios** en la 8078 (solo un test desactivado), en las *tags*, en V8 15.6 y 15.9 ni en Skia M156.

SEGURIDAD-PORTES-33
