# Portes de la 159 a la 156 (antes de que lleguen a la 8078)

Arreglos de la rama de la 159 (`branch-heads/8154`, en beta) que COORDINACIÓN pide portar **ya**, sin esperar a que
Chrome los lleve a la 156. Prepararlos **no los mete en ninguna versión**: eso lo decide Titín. Carpeta aparte de
`seguridad/pendiente/` (#1147) para no mezclar. Lo prepara SEGURIDAD-PORTES (desde la -33, 20-11-2026).

Si el arreglo llega después a la 8078 como merge M156, se compara con el de aquí. Si es igual, el de aquí se da por
bueno. Si es distinto, manda el de Chrome.

## Base

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`90418ba4fd`** (= `seguridad/pendiente/chromium/0001`–`0008`, #1147) | `chromium/0000`–`0002` | **`9ed7d45ae0`** (tras `0000`: `b333a62aa3`; tras `0001`: `1170ab9daf`) |

Ninguno de los tres toca ficheros de `pendiente/chromium/0001`–`0008`, de `siguiente/chromium/` (#1165) ni de brave-core
(`chromium_src/ui/views/controls/menu` solo tiene `menu_config` y `menu_separator`). Antes del 21-11 la cadena era
`0001`–`0002` y daba `2bb85047ec`: ver «Corrección del 21-11».

## Corrección del 21-11: faltaba `chromium/0000` (prerrequisito del `0001`)

LOCAL dio **ROJO** con el `0001` antiguo: `views_unittests` `MenuRunner*` 23/25. Fallaban siempre las dos pruebas del propio
`0001` porque el submenú se destruía **dentro** de `GetDropCallback`/`OnDragUpdated` en vez de aplazarse.

- **Causa:** el porte estaba incompleto. No era cosa de Mac ni de la prueba. Los menús hechos con `MenuItemView` usan
  `MenuRunnerImpl` en todas las plataformas: Cocoa solo entra con `MenuModel`, así que en Linux fallaría igual.
  En la 156, `MenuRunnerImpl::OnMenuClosed` pone `controller_ = nullptr`. Cuando el delegado suelta después el
  `MenuRunner` (dentro de `GetDropCallback` o de su `OnMenuClosed`), `Release()` ya no ve ningún controlador con la
  pila activa y hace `delete this` en el acto, en vez de `DeferMenuRunnerDestruction`. El `ScopedDeletionGuard` del
  `0001` aplaza el `MenuController`, pero no el árbol `MenuItemView`/`SubmenuView`.
- **Lo arregla main `041491e936`** («Defer MenuRunnerImpl destruction when released in OnMenuClosed», bug 574516887,
  main@{#1722585}, 20-10-2026). Es posterior a la rama 8078, así que la 156 no lo tiene, y la 159 sí porque nació
  después. **No está en `branch-heads/8078` ni en `8078_108`** (comprobado el 21-11). Lo localicé bisecando
  `menu_runner_impl.cc` entre las bases de 8078 y 8154.
- **`chromium/0000`** = `041491e936`, mismo `patch-id` que upstream; aplica solo con desplazamientos de línea. Trae
  además su propia prueba (`ReleaseInOnMenuClosedDuringSetSelectedDefersDestruction`) y el
  `#include "ui/views/view_tracker.h"`. Por eso el `0001` ya no lo añade y sus pruebas quedan **idénticas** a las de
  upstream.
- No porto main `72bc9fdbbe` (mismo bug): solo hace que la rama `delete_after_run_` de `OnMenuClosed` llame a
  `Release()` en vez de repetir su lógica. No cambia lo que comprueban las pruebas.
- Comprobado con `git am` de `0000`–`0002` sobre `90418ba4fd`: árbol **`9ed7d45ae0`**, sin ficheros borrados. La 3.2.1
  (`siguiente/chromium/`, #1165) aplica limpia encima: árbol **`a2ffc0a48f`** (antes, `861699b126`).
- **`0000` es contenido nuevo** (otro arreglo de seguridad, bug 574516887). Si entra en la 3.2.0 junto con el `0001`, lo
  decide Titín. Sin `0000`, el `0001` no protege el caso que arregla.


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
- **Necesita `chromium/0000`** (`041491e936`, ver «Corrección del 21-11»). Sin él, las dos pruebas fallan en la 156.
- **Pruebas:** las dos de upstream van tal cual (`ForDropCancelDuringDragUpdatedActiveDescendantDefersDestruction` y
  `ForDropReleaseInGetDropCallbackDefersDestructionUntilUnwind`). El `#include "ui/views/view_tracker.h"` que usan lo
  pone el `0000`, igual que en upstream (hasta el 21-11 lo añadía este `0001`). Todo lo que usan existe en la 156:
  `TestMenuDelegate::GetDropCallback`, `is_drop_performed()`, `ViewTracker`, `set_accessibility_events_callback`,
  `MenuController::Cancel` y la firma de `View::DropCallback`. `menu_test_utils` de la 156 y la 159 solo difieren en
  cosas que estas pruebas no usan.
- brave-core no tiene parches ni `chromium_src` para `ui/views/controls/menu/menu_controller.cc` ni para su prueba.
- Comprobado: sobre `b333a62aa3` (`90418ba4fd` + `0000`) da el árbol **`1170ab9daf`**. Los árboles de antes
  (`403ec1c98c`; sobre `1b06f59f4d`, `6ee8d9b1c1`) eran sin `0000` y ya no valen.
- **Gravedad: no consta** (bug restringido). Es de la misma familia que otros arreglos ya presentes en la
  156: `menu_controller.cc` usa `ScopedDeletionGuard` en 29 sitios.

### Veredicto (regla 17): **APTO con `chromium/0000`**, `chromium/0000` + `chromium/0001`

Solo es APTO junto con el `0000`: van juntos o no va ninguno. `0000` es el cambio de upstream sin tocar. `0001` es el
de upstream con dos *hunks* reanclados. Efecto visible: ninguno. Si el menú se
cierra mientras se arrastra encima, ya no se puede soltar en él (antes era un UAF).

**Pruebas para LOCAL:** `views_unittests --gtest_filter='MenuRunnerTest.*:MenuRunnerImplTest.*:MenuControllerTest.*:MenuItemViewTest.*:SubmenuViewTest.*'`.
Las tres pruebas nuevas deben pasar: `ReleaseInOnMenuClosedDuringSetSelectedDefersDestruction` (del `0000`) y las dos
`ForDrop*` (del `0001`). Las demás deben quedar como sin los parches, porque el `0000` cambia cuándo se borra el
`MenuRunnerImpl` en todos los menús, no solo en los de soltar. Para tener una referencia, pasar también el mismo
filtro sin `0000`–`0001`.
En la build: arrastrar un enlace a una carpeta de la barra de marcadores, soltarlo dentro y comprobar que se crea el
marcador. Repetir saliendo del menú con Esc durante el arrastre.

## `chromium/0002`: 8154 b079c8f6c8 (bug 586171393, merge M159 588196490)

`url::SchemeHostPort`, y con él `url::Origin`, aceptaba un host vacío en cualquier esquema `SCHEME_WITH_HOST`, por
ejemplo `("chrome", "", 0)`. Un `GURL` así no es válido: `GURL` rechaza `chrome://`. Una tupla de ese tipo no podía
salir de una URL real, pero **sí podía llegar por IPC** (deserialización de `url.mojom.Origin`) y confundir a la pila
de navegación. Con el arreglo, un host vacío solo vale para `file:` (y para esquemas no estándar). La deserialización
por mojo de un `Origin` así falla, y `GetURL()` añade un `CHECK` de coherencia. Hace falta un *renderer* comprometido
que mande el `Origin` falso: es endurecimiento del proceso del navegador frente a IPC. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). **Aplica limpio**, sin desplazamientos, sobre `403ec1c98c` y sobre `1170ab9daf`.
- brave-core no tiene parches ni `chromium_src` en `url/`. Los esquemas propios (`brave://`, `chrome-extension://`)
  siempre llevan host, así que el cambio no les afecta.
- Comprobado: `git apply --cached` sobre `1170ab9daf` da el árbol **`9ed7d45ae0`** (sobre `403ec1c98c`, sin `0000`, daba `2bb85047ec`).
- **Ya está en la 156 (21-11, 00:10 UTC):** merge oficial `04db7fff13` en la 8078 (merge 588196153), **idéntico** (`patch-id` igual) a este `0002`.
- **Gravedad: no consta** (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0002`

Es el cambio de upstream sin tocar nada. Efecto visible: ninguno. Una URL o un origen con host vacío en un esquema
estándar distinto de `file:` ya no se consideran válidos, igual que ya pasaba con `GURL`.

**Pruebas para LOCAL:** `url_unittests --gtest_filter='SchemeHostPortTest.*:OriginTest.*:MojoGURLStructTraitsTest.*'`
(trae `OriginDeserializationWithEmptyHost`). En la build: abrir `file:///`, una página de ajustes (`brave://settings`)
y una extensión, y comprobar que cargan.

