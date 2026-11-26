# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `siguiente-3/chromium/0022`, extensiones (vigilancia de las 01:01)

**No es un aviso urgente:** no hay gravedad publicada y el boletín no tiene entradas nuevas desde el 24-11.

- **Nuevo, `chromium/0022`:** la 8154 `5bba75d662` (main `50bbedecb3`, bug 574789262), «[Extensions] Validate context and
  target event in events.*Rules».
  - **El fallo:** `events.addRules`, `getRules` y `removeRules` se podían llamar desde content scripts o desde un renderer
    comprometido. El evento se reconocía por prefijo, y el nombre de los `<webview>` solo lo paraba un `DCHECK`.
  - **El arreglo:** solo contextos privilegiados, una lista exacta de los tres eventos con reglas, comprobación de
    disponibilidad y `BadMessage()` para lo que no cuadra.
  - **Aplica a Mac**: FlyWeb lleva extensiones.
  - **Adaptado a la 156** a partir del diff de main, porque la réplica aún no tenía el cherry-pick. Hay tres retoques
    pequeños, detallados en el README; las API que usa existen en la 156 y Brave no choca.
  - Lleva un `unit_test` nuevo y pruebas de navegador (lista para LOCAL en el README).
  - Rama `7775fd8210` (según `ls-remote`). Cadena de chromium, 0001–0022: árbol **`3608da3c2f`**.
- **Gemelo M156 de `0021`** (Cast): la 8078 `4c677c2ca2`, idéntico. Nada que cambiar.
- **Sin cambios** en las *tags*, en V8 15.6 y 15.9 ni en Skia M156. La 8154 `0fae9fe201` (USB) es solo de Windows.

SEGURIDAD-PORTES-33
