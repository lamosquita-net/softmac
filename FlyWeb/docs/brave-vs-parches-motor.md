# FlyWeb — cambios de Brave 1.58–1.73 sobre los ficheros de nuestros parches de motor (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.35, parte 3). Sin código ni ramas. **Propone; decide Titín.** Pregunta: de nuestros portes de motor
(FM.17–FM.22: niveles 117–131, escapes y seguridad), ¿qué ficheros de Chromium toca **también Brave** en 1.58–1.73, y cómo
afecta eso al **volver a cortar** los parches sobre Chromium 128 con Brave 1.69.168?

**Etiquetas:** **[V]** visto en brave-core (`v1.57.64`, `v1.69.168`, `v1.73.105`) y en nuestra rama `flyweb` (`54b964da`, 700
commits); **[I]** inferido; **[H]** hipótesis. Las horas son **estimación mía**.

> **Corrección a FM.34 (caso 3).** Allí conté **3** parches con el mismo nombre que uno de Brave. **Son 4:** me faltaba
> `platform/runtime_enabled_features.json5`, **el fichero donde se encienden las *flags* de todos los niveles**. Brave lo parchea
> desde la 1.58–1.69; nuestro parche lleva 107 *hunks* (≈ 1 745 líneas). Está corregido en `brave-vs-flyweb.md` §4.

## 1. Resumen

- **El solape es pequeño: ≈ 7 % de los ficheros** [V]. De los **1 443** ficheros de `patches/` y `chromium_src/` que hemos tocado
  desde la 1.57, **1 050** se tocaron en algún commit posterior al nivel 128, de seguridad, de V8 o sin nivel (el máximo de lo
  que se vuelve a cortar; FM.32 mide ≈ 320 reales). De esos 1 050, **20 comparten fichero de parche con Brave** (4 colisiones y
  16 parches de Brave que editamos) y **50 son ficheros que Brave sobrescribe con `chromium_src`**.
- **Lo que Brave hace con esos ficheros cambia casi siempre:** Brave modificó **los 16** parches compartidos que ya tenía en la 1.57
  (1.57 → 1.69) y **vuelve a modificar 19 de los 20** entre la 1.69 y la 1.73 (§3).
- **Seis ficheros concentran el riesgo** (§4): `runtime_enabled_features.json5`, los registros de IDL de los enlaces
  (`idl_in_modules.gni`, `generated_in_modules.gni`, `bindings/BUILD.gn`), `permissions_policy_features`, `web_contents_impl.cc` y
  `navigation_request.cc`, los de *canvas*/WebGL (el *farbling* de Brave) y los dos de V8.
- **Brave ya ha cortado los parches compartidos contra Chromium 131** (1.73): sus nuevas versiones son una **referencia gratis**
  de cómo quedan esos ficheros en la 131 [I].
- **Hay un choque con la regla 20 que no es de ficheros:** Brave 1.73 **baja `KeyboardFocusableScrollers` de `stable` a
  `experimental`** («Revert when cr132 is merged»), y nuestro nivel 130 la **enciende** (decisión de COORDINACIÓN-6, 15-10). Propuesta
  en §6.
- **Ninguna otra *feature* que Brave fuerza a apagado aparece en nuestros parches** [V]: de las 167 *features* que Brave 1.73 apaga, solo
  una cadena aparece en `patches/` (como contexto, `kDestroyProfileOnBrowserClose`, no habilitada).
- **Horas:** **≈ 5–12 h** añadidas al recorte, **dentro del rango de la clase D de FM.32 (28–70 h)**. El total no cambia.

## 2. Método y límites

- **Ficheros nuestros** = los que `flyweb` añade o modifica en `patches/` y `chromium_src/` desde `v1.57.64`: 1 443, con su historial
  (380 de los 700 commits). **Nivel de cada fichero** = el que menciona el asunto de los commits que lo tocan («Level 118…», «Engine
  level 131…», «FM.22», seguridad, V8). **Un fichero entra en «a recortar»** si lo toca algún commit posterior al 128, de FM.22, de
  seguridad, de V8 o sin nivel. **Es una cota superior:** muchos «sin nivel» son ediciones de marca que no se recortan.
- **Qué hace Brave con cada fichero:** si tiene un parche del mismo nombre o un `chromium_src` del mismo ruta en 1.57, 1.69 y 1.73, y
  si ese fichero de Brave **cambió** entre versiones.
- **Límites.**
  - Es coincidencia **de nombre de fichero**: dice dónde Brave y nosotros tocamos lo mismo, **no** si los *hunks* chocan. Para eso
    hace falta el código de Chromium 128 (la nube no llega a `chromium.googlesource.com`); el cálculo de choques lo hará MOTOR al cortar.
  - El nivel por asunto de commit es aproximado: 327 ficheros quedan «sin nivel».
  - Brave aplica sus `patches/` al código de Chromium y sus `chromium_src/` por inclusión en compilación; un `chromium_src` **no**
    choca por texto con nuestro parche, pero sí puede chocar **por significado** (macros que renombran funciones que tocamos).
  - No he buscado otros mecanismos con los que Brave apague *features* de Blink fuera de `runtime_enabled_features.json5` y de las
    entradas de `OVERRIDE_FEATURE_DEFAULT_STATES` (una búsqueda de `disable-blink-features` en `patches/` y `browser/` se cortó por
    tiempo sin resultados).

## 3. Los 20 parches que compartimos con Brave

[V] Parches de `patches/` que **Brave y FlyWeb tocan** y que seguirán en la 2.0 (hay que dejar **un solo fichero** por cada uno):

| Fichero de Chromium | Quién lo trae | Brave 1.57→1.69 | Brave 1.69→1.73 | Por qué lo tocamos nosotros |
|---|---|---|---|---|
| `platform/runtime_enabled_features.json5` | **colisión** (Brave lo añade en 1.58–1.69) | nuevo | cambió | Todas las *flags* de los niveles |
| `core/frame/local_dom_window.cc` | **colisión** | nuevo | cambió | APIs de `window` de varios niveles |
| `core/editing/commands/clipboard_commands.cc` | **colisión** | nuevo | igual | Portapapeles (FM.22) |
| `content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm` | **colisión** | nuevo | cambió | Edición de texto en macOS |
| `bindings/idl_in_modules.gni`, `bindings/generated_in_modules.gni`, `bindings/BUILD.gn` | Brave, editado por nosotros | cambió | cambió | Cada interfaz IDL nueva se registra aquí |
| `core/permissions_policy/permissions_policy_features…` | ídem | cambió | cambió | Políticas de permisos nuevas |
| `content/browser/web_contents/web_contents_impl.cc`, `…/renderer_host/navigation_request.cc` | ídem | cambió | cambió | Navegación y aislamiento (FS.15) |
| `core/frame/dom_window.h`, `core/dom/events/event_target.cc` | ídem | cambió | cambió | Eventos y APIs de `window` |
| `core/html/canvas/html_canvas_element.cc`, `modules/webgl/webgl_rendering_context_base.cc` | ídem | cambió | cambió | Canvas y WebGL (**el *farbling* de Brave**) |
| `modules/mediastream/media_devices.cc`, `components/permissions/request_type.cc` | ídem | cambió | cambió | Permisos y dispositivos |
| `platform/BUILD.gn` | ídem | cambió | cambió | Ficheros nuevos de Blink |
| `bindings/scripts/bind_gen/interface.py` | ídem | cambió | cambió | Generador de enlaces (FM.17) |
| **`v8/BUILD.gn`, `v8/src/codegen/compiler.cc`** | ídem | cambió | cambió | V8 con revisión fijada aparte (`v8-revision`) |

**Dos cosas que no son obvias:**

1. **Los dos únicos parches de V8 de Brave son justo los dos que nosotros también editamos** [V]. V8 va con su revisión fijada
   (12.8 en el nivel 128…) y no con la que lleva Brave; Brave los vuelve a cortar en 1.73 contra el V8 de Chromium 131.
2. **Brave 1.73 es una referencia para nuestro recorte:** sus versiones de estos parches ya están cortadas contra Chromium 131 [I].
   Para `runtime_enabled_features.json5`, `bindings/*.gni`, `platform/BUILD.gn` y los de V8, el contexto de líneas que usa Brave
   en la 1.73 vale como guía de cómo está ese fichero en el 131.

## 4. Los ficheros que Brave sobrescribe con `chromium_src` (50)

[V] Ficheros de Chromium **que nuestros parches tocan y que Brave envuelve** (macros y `#include "src/…"`). No chocan por texto; el
riesgo es **semántico**. Los que más pesan:

| Fichero | Qué hace Brave | Riesgo para nuestro recorte |
|---|---|---|
| `web_preferences.mojom`, `web_preferences.h/.cc`, `web_preferences_mojom_traits.h/.cc` (5 ficheros) | Añade campos a `WebPreferences` y a su serialización | **Alto:** nuestros portes de FM.22 añaden campos en los mismos sitios; el orden de los campos de un `mojom` debe ser único. Fundirlos en un solo cambio |
| `core/frame/dom_window.cc` | Redefine funciones de `DOMWindow` con macros | Medio: 9 identificadores en común con nuestro parche |
| `core/dom/document.cc`, `core/frame/local_frame.cc/.h`, `core/core_initializer.cc` | Macros de *farbling* y de Shields | Medio |
| `blink/common/features.cc`, `net/base/features.cc/.h`, `components/permissions/features.*` | Valores por defecto de *features* de Brave | Medio: mismo fichero donde damos el valor de nuestras *flags* |
| `modules/canvas/canvas2d/*_rendering_context_2d.h`, `modules/webgl/webgl_rendering_context_base.h` | *Farbling* de canvas y WebGL (Brave cambió `base_rendering_context_2d.{cc,h}` entre 1.69 y 1.73) | Medio: nuestros niveles 129–131 añaden métodos de canvas |
| El resto (≈ 35 ficheros) | Macros pequeñas | Bajo |

## 5. Lo que cambió Brave entre 1.57 y 1.73 en esos ficheros

- **1.57 → 1.69:** Brave **añadió 4** parches que ya teníamos (las colisiones), **modificó los 16** compartidos y añadió 4 `chromium_src` en
  ficheros que parcheamos (`media_session_impl.cc`, `clipboard_commands.cc`, `clipboard_promise.cc`, `render_widget_host_view_cocoa.mm`).
- **1.69 → 1.73:** Brave modificó 589 ficheros entre `patches/` y `chromium_src/` (vuelta a Chromium 131); **19 de nuestros 20 compartidos** están entre ellos.
  De `chromium_src`, cambian `base_rendering_context_2d.{cc,h}`, `blink/common/features.cc` y `browser_protocol.pdl`.
- **Nuevo en 1.73:** `chromium_src/chrome/browser/screen_ai/screen_ai_install_state.{cc,h}` (Brave quita ScreenAI; ver `brave-170-173.md`).

## 6. Regla 20: lo que Brave apaga y nosotros portamos

1. **Ninguna `base::Feature` de las 167 que Brave 1.73 fuerza a apagado se habilita en nuestros parches** [V]: la búsqueda en
   `patches/` solo devuelve una cadena de contexto (`kDestroyProfileOnBrowserClose` en `app_controller_mac.mm.patch`). No hay rastro de
   la *Privacy Sandbox* ni de Lens en los asuntos de nuestros commits ni en los nombres de *features* de los parches (Brave 1.69 apaga
   `Topics`, `Fledge`, `SharedStorage`, `FencedFrames`…) [V para los nombres; I para las *flags* de Blink].
2. **`KeyboardFocusableScrollers`: choque con la regla 20.** [V] En Chromium 130 es `stable`; **Brave 1.73 la baja a `experimental`** en su
   parche de `runtime_enabled_features.json5` con el comentario «Revert when cr132 is merged». Nuestro nivel 130 la **enciende** con el
   comportamiento final de la 130 (`d7518d129e`, por decisión de COORDINACIÓN-6, 15-10; 55 ficheros). **No encontré el motivo de Brave**
   [H: un fallo de la 131 que arregla la 132]. **Propuesta (para Titín):** seguir a Brave y dejarla `experimental` en la 2.0 hasta que
   Brave la reponga (una línea en el parche de `runtime_enabled_features.json5`, 0,5 h), y pedir a COORDINACIÓN que busque la incidencia
   de Brave por si es un fallo que también tenemos en la 1.15.1.
3. **Otras cuatro entradas de ese parche de Brave** (`FileSystemAccessAPIExperimental`, `FileSystemAccessLocal`, `MiddleClickAutoscroll`,
   `Serial`) solo ponen `base_feature: "none"`: **no cambian su estado**, las desacoplan de los servidores de *variations*. Con nuestra URL
   inerte no cambian nada.

## 7. Horas

| Parte | Horas |
|---|---|
| Fundir las 4 colisiones (ya contadas en FM.34 caso 3: 2–4 h) | — |
| Revisar los 16 parches de Brave que editamos contra su versión de la 1.69 (la mayor parte ya en la clase C: 25 parches editados) | 2–5 |
| `web_preferences` (5 ficheros) y los ≈ 10 ficheros de riesgo medio del §4, al cortar | 2–4 |
| Resto de los 50 `chromium_src` (comprobar que compila y que no se redefine nada) | 1–3 |
| **Total añadido al recorte** | **≈ 5–12 h** |

**Dentro del rango de la clase D de FM.32 (28–70 h)**, que estimó el recorte a partir del ritmo de porte (≈ 60 rechazos por hora); lo de
aquí es el sobrecoste de **dos canales de parches que se pisan**. Sube la media de la clase D, no su rango.

## 8. Qué no pude comprobar

- **Si los *hunks* chocan de verdad** (§2): necesita el código de Chromium 128 y los parches de Brave 1.69 aplicados.
- **Cuáles de los 1 050 ficheros se recortan de verdad:** el cálculo da una cota superior. FM.32 dice ≈ 320; el solape real será
  aproximadamente un 7 % de eso (≈ 20 ficheros), **si el solape se reparte igual** [H].
- **Por qué Brave baja `KeyboardFocusableScrollers`** (§6): no encontré la incidencia.
- **Otras formas de apagar *features* de Blink en Brave** (§2, último punto).
- **Horas = estimación mía.**

## 9. Fuentes

- brave-core `v1.57.64`, `v1.69.168`, `v1.73.105` (`patches/`, `chromium_src/`, `components/query_filter`, listas de interruptores) y nuestra
  rama `flyweb` (`54b964da`, 700 commits sobre `v1.57.64`; 380 tocan `patches/` o `chromium_src/`).
- Proyecto: `motor.md` (regla 20; `KeyboardFocusableScrollers`), `tools/port/nivel130-commits.tsv`, `tools/port/fm22-escapes.tsv`,
  `migracion-128.md` (clases C y D), `brave-vs-flyweb.md` (FM.34 caso 3), `brave-170-173.md` (FM.35 parte 2).
