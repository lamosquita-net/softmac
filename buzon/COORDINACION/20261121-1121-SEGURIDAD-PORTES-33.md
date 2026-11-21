# SEGURIDAD-PORTES-33 → COORDINACIÓN-58: ROJO de portes-159/0001 (menús FOR_DROP). Causa y arreglo

Respondo a `NUBE-SEGURIDAD-PORTES/20261121-1300-COORDINACION-58-menus-rojo.md`.

## Diagnóstico: el porte estaba incompleto. No es cosa de Mac ni de la prueba
- **No es Mac.** Los menús hechos con `MenuItemView` usan `MenuRunnerImpl` en todas las plataformas. Cocoa
  (`MenuRunnerImplCocoa`/`MenuControllerCocoa`) solo entra con `MenuModel`, y estas pruebas no lo usan. En Linux fallaría
  igual.
- **No es la prueba.** Comprueba justo el caso que arregla el 0001, y en la 156 ese caso sigue siendo un UAF.
- **Causa.** En la 156, `MenuRunnerImpl::OnMenuClosed` hace `controller_ = nullptr`. En el camino FOR_DROP,
  `GetDropCallback` llama a `OnMenuClosed` y después a `GetDropCallback` del delegado. Si el delegado suelta ahí el
  `MenuRunner` (como hace el de marcadores), `Release()` ya no ve controlador y hace `delete this` en el acto, en vez de
  `DeferMenuRunnerDestruction`. El `ScopedDeletionGuard` del 0001 aplaza el `MenuController`, pero no el árbol
  `MenuItemView`/`SubmenuView`. Eso explica:
  - el submenú ya destruido en la línea 1534;
  - en la prueba de `Cancel` (línea 1577), el `nullptr` y después el SEGV.
- **Lo arregla un prerrequisito: main `041491e936`** («Defer MenuRunnerImpl destruction when released in OnMenuClosed»,
  **bug 574516887**, otro UAF; main@{#1722585}, 20-10). Mantiene `controller_` y aplaza la destrucción.
  - Es posterior a la rama 8078: la 159 lo tiene por haber nacido después y la 156 no.
  - **No está en 8078 ni en 8078_108** (comprobado hoy).
  - Lo encontré bisecando `menu_runner_impl.cc` entre las bases de 8078 y 8154. El historial por ruta de gitiles está
    cerrado.

## Arreglo: PR **#1175** (borrador, encima de #1159; rama `claude/seguridad-portes-33-menu-drop-uaf-0000`)
- **`chromium/0000` nuevo** = `041491e936`:
  - mismo `patch-id` que upstream;
  - aplica solo con desplazamientos de línea;
  - trae su prueba (`ReleaseInOnMenuClosedDuringSetSelectedDefersDestruction`) y el `include` de `view_tracker.h`.
- **`chromium/0001`:** mismo código. Ya no añade el `include`, así que sus pruebas quedan idénticas a upstream.
- **`chromium/0002`:** sin cambios.
- **No porto main `72bc9fdbbe`** (mismo bug): solo refactoriza.
- **Árboles** (`git am` sobre `90418ba4fd`, sin ficheros borrados):

  | Tras | Árbol |
  |---|---|
  | `0000` | `b333a62aa3` |
  | `0001` | `1170ab9daf` |
  | `0002` | **`9ed7d45ae0`** (antes, `2bb85047ec`) |
  | `siguiente/chromium` (3.2.1) encima, aplica limpia | `a2ffc0a48f` (antes, `861699b126`) |

- **Sobre el árbol de LOCAL** (`317e849352`): ningún otro parche ni brave-core toca `menu_runner_impl.cc` ni esta
  prueba. Basta con aplicar `0000` antes del `0001` corregido.
- **No lo he probado compilando.** Aquí no hay checkout para `views_unittests`. Mi análisis del código dice que las dos
  pruebas pasan con `0000`, pero lo tiene que confirmar LOCAL.

## Qué probar (LOCAL)
- Ejecutar `views_unittests --gtest_filter='MenuRunnerTest.*:MenuRunnerImplTest.*:MenuControllerTest.*:MenuItemViewTest.*:SubmenuViewTest.*'`:
  - deben pasar las 3 nuevas (la del 0000 y las 2 `ForDrop*`);
  - el resto debe quedar igual que sin `0000`–`0001`. El `0000` cambia cuándo se borra `MenuRunnerImpl` en todos los
    menús, así que conviene el mismo filtro sin los parches como referencia.
- En la build:
  1. Arrastrar un enlace a una carpeta de la barra de marcadores y soltarlo: se crea el marcador.
  2. Repetir con Esc durante el arrastre.
  3. Abrir y cerrar menús normales (contextual, el de la app) para comprobar que no hay regresiones.

## Decisión para Titín
- El `0001` solo vale junto con el `0000`: van los dos o ninguno.
- El `0000` es **contenido nuevo**: otro arreglo de seguridad, bug 574516887.
- Hay dos caminos:
  - **A:** `0000` + `0001` corregido en la 3.2.0, si LOCAL da verde.
  - **B:** según su regla, el `0001` sale de la 3.2.0 y los dos van juntos adonde él diga.
- No he tocado #1159. Si elige A, paso #1175 a #1159.
- El `0002` sigue en verde y ya es idéntico al merge oficial `04db7fff13` de la 8078.
