# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: menús FOR_DROP; la M156 revirtió algo que llevamos desde la 3.2.1

No es Alto, Crítico ni KEV publicado. Lo aviso porque toca lo que ya llevan la 3.2.1 y la 3.2.2.

## Qué ha pasado
- La 8078 ha recibido **`66ed8d17e9`** (23-11 23:47 UTC): «[M156] views: Fix FOR_DROP menu drag and drop teardown UAF»
  (565066840). Es el arreglo que nosotros ya portamos en la M159 como `siguiente/chromium/0010` (`afa45b8e16`).
- Su texto dice que la M156 **revirtió** crrev 8613791. Ese cambio lo llevamos desde la 3.2.1: es
  `siguiente/chromium/0009`, merge M159 `041491e936`, «Defer MenuRunnerImpl destruction… in OnMenuClosed».
  - La reversión es `b0cd918806` (22-10, 8078@{#1449}). El motivo, **b/576555601**, es un bug interno sin detalle
    público.
  - Por eso el merge de la M156 conserva `controller_` **solo en los menús FOR_DROP**, para no tocar los demás (cita el
    AppMenu).
- **Riesgo en la 3.2.1/3.2.2:** podemos tener la regresión que llevó a revertirlo en la M156. No sé qué es ni si se da
  en Mac.
- **Lo que no cambia:** el UAF de FOR_DROP está arreglado en las dos versiones, la nuestra y la de la M156.

## Qué he hecho
`siguiente-3/chromium/0006` (rama `claude/seguridad-portes-33-siguiente-3`, `9595c3f9`, PR #1215) deja
`ui/views/controls/menu` como la 8078.
- **Comprobado** fichero a fichero contra la 8078: `menu_runner_impl.cc`/`.h`, `menu_controller.h` y la prueba quedan
  iguales.
- `menu_controller.cc` no cambia: el nuestro ya tiene el arreglo, y además guardas extra.
- **Cambio neto:** los menús que no son FOR_DROP vuelven a borrar `controller_` en `OnMenuClosed`, como en la M156.
- **Lo que se pierde:** en esos menús vuelve a quedar sin cubrir el UAF de 574516887, igual que en Chrome 156.
- **Árbol:** `13d5ed72d4` → **`5c5893384f`** (`git am`; `--diff-filter=D` vacío).
- **Sin compilar ni probar aquí.**

## Para decidir (Titín)
Recomiendo **seguir a Chrome M156** (este parche) en la próxima versión que salga con la siguiente-3. Las razones:
- es lo que Google ha probado en su rama de la 156;
- nosotros no podemos ver b/576555601.

Si alguien vio en la 3.2.1/3.2.2 cierres raros o cuelgues con el menú de la app o los menús contextuales, eso le daría
prisa. Si no, no veo motivo para una 3.2.3 solo por esto.

**Para LOCAL:**
- `views_unittests --gtest_filter='MenuRunner*:MenuController*'`;
- a mano, en la 7,1 y la 5,1: menú de la app, menús contextuales y de marcadores, y arrastrar un marcador a la barra y a
  una carpeta abierta.

Cierro con esto el pendiente «afa45b8e16/041491e936 frente a siguiente/0010 y 0009».

SEGURIDAD-PORTES-33
