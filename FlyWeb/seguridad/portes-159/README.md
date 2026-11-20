# Portes de la 159 a la 156 (antes de que lleguen a la 8078)

Arreglos de la rama de la 159 (`branch-heads/8154`, en beta) que COORDINACIÓN pide portar **ya**, sin esperar a que
Chrome los lleve a la 156. Prepararlos **no los mete en ninguna versión**: eso lo decide Titín. Carpeta aparte de
`seguridad/pendiente/` (#1147) para no mezclar. Lo prepara SEGURIDAD-PORTES (desde la -33, 20-11-2026).

Si el arreglo llega después a la 8078 como merge M156, se compara con el de aquí. Si es igual, el de aquí se da por
bueno. Si es distinto, manda el de Chrome.

## Base

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`1b06f59f4d`** (= `seguridad/pendiente/chromium/0001`–`0007`, #1147) | `chromium/0001` | **`6ee8d9b1c1`** |

No toca ningún fichero de `pendiente/chromium/0001`–`0007`, así que también aplica sobre cualquier árbol anterior de esa
cadena.

## `chromium/0001`: 8154 afa45b8e16 (bug 565066840, merge M159 588202414)

UAF en el proceso del navegador, en los menús de `views` abiertos «para soltar» (`MenuRunner::FOR_DROP`), por ejemplo
una carpeta de la barra de marcadores mientras se arrastra algo encima. En `MenuController::GetDropCallback`, con
`for_drop_`, se cierra el menú y se llama a `OnMenuClosed`, que puede destruir el `MenuRunner` y con él `this` y el
`SubmenuView`. Luego se sigue usando `drop_target`. Y `OnDragUpdated`, si un evento de accesibilidad cerraba el menú
(`destroy_pending_`), devolvía igualmente una operación de soltar válida.

El arreglo:
- añade `ScopedDeletionGuard` al principio de `GetDropCallback`, de modo que la destrucción espera a que la llamada
  termine;
- hace que `OnDragUpdated` devuelva `DRAG_NONE` cuando hay destrucción pendiente.

Se alcanza con interacción del usuario: arrastrar algo (un enlace, una pestaña) a un menú de carpeta de marcadores y
soltar. Aplica a Mac: la barra de marcadores de FlyWeb usa los menús de `views`.

- **El código vulnerable está en la 156.** El diff de upstream no aplica tal cual solo por contexto: la 156 tiene
  `DCHECK(drop_target)` donde la 159 tiene `CHECK(drop_target, base::NotFatalUntil::M163)`. Los dos cambios de
  `menu_controller.cc` se han reanclado a mano y son idénticos a los de upstream.
- **Pruebas:** las dos de upstream van tal cual (`ForDropCancelDuringDragUpdatedActiveDescendantDefersDestruction` y
  `ForDropReleaseInGetDropCallbackDefersDestructionUntilUnwind`). En la 156 el fichero de prueba necesita además
  `#include "ui/views/view_tracker.h"`, que es lo único añadido respecto a upstream. Todo lo que usan existe en la 156:
  `TestMenuDelegate::GetDropCallback`, `is_drop_performed()`, `ViewTracker`, `set_accessibility_events_callback`,
  `MenuController::Cancel` y la firma de `View::DropCallback`. `menu_test_utils` de la 156 y la 159 solo difieren en
  cosas que estas pruebas no usan.
- brave-core no tiene parches ni `chromium_src` para `ui/views/controls/menu/menu_controller.cc` ni para su prueba.
- Comprobado: `git apply --cached` sobre `1b06f59f4d` da el árbol **`6ee8d9b1c1`**.
- **Gravedad: no consta** (bug restringido). Es de la misma familia que otros arreglos ya presentes en la
  156: `menu_controller.cc` usa `ScopedDeletionGuard` en 29 sitios.

### Veredicto (regla 17): **APTO**, `chromium/0001`

Es el cambio de upstream con dos *hunks* reanclados y un `include` de prueba. Efecto visible: ninguno. Si el menú se
cierra mientras se arrastra encima, ya no se puede soltar en él (antes era un UAF).

**Pruebas para LOCAL:** `views_unittests --gtest_filter='MenuRunnerTest.ForDrop*:MenuRunnerTest.*:MenuRunnerImplTest.*'`.
En la build: arrastrar un enlace a una carpeta de la barra de marcadores, soltarlo dentro y comprobar que se crea el
marcador. Repetir saliendo del menú con Esc durante el arrastre.
