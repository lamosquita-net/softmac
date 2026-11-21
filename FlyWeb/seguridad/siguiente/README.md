# Seguridad: tanda siguiente (después de la 3.2.0)

Desde el 20-11 a las 20:01 UTC (COORDINACIÓN-57, confirmado por Titín en `docs/DIRECTIVAS.md`, #1160), la tanda de la
3.2.0 está cerrada: `seguridad/pendiente/` (#1147) y `seguridad/portes-159/` (#1159). Lo que llegue después y **no**
sea Alto, Crítico o KEV se prepara aquí, para la versión que venga detrás de la 3.2.0, salvo que Titín diga otra cosa.
Lo que sí lo sea se avisa enseguida a COORDINACIÓN. Lo prepara SEGURIDAD-PORTES (desde la -33, 21-11-2026).

## Base

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`2bb85047ec`** (`pendiente/chromium/0001`–`0008` + `portes-159/chromium/0001`–`0002`) | `chromium/0001`–`0003` | **`6d4ab28029`** (tras `0001`: `faec7dc5b9`; tras `0002`: `ee335593f3`) |

## Rama 8078 después del cierre de la tanda

| Commit de la 8078 | Qué | ¿Mac? | Parche |
|---|---|---|---|
| `af12c47ccb` (20-11 23:10 UTC) | [M156] «[HLS] Intercept data: URLs in HlsDataSourceProviderImpl» (580846503, merge 586790744) | Sí (abajo) | `chromium/0002` |
| `1a63009b31` (23:19 UTC) | Prueba desactivada en Mac | — | — |
| `2762e65042` (23:56 UTC) | [M156] «Disable VariationsService HTTP fallback by default» (588460249, merge 588518337) | Sí, pero en FlyWeb Variations apunta a una URL inerte (abajo) | `chromium/0003` |
| `f95dd51f6f` (21-11 00:09 UTC) | [M156] «Never expose pseudo-elements via Event.target; fix ::column disposal» (583179913, 584370079; merge 588203329) | Sí (abajo) | `chromium/0001` |
| `04db7fff13` (00:10 UTC) | [M156] «SchemeHostPort: Reject empty host for non-file SCHEME_WITH_HOST schemes» (586171393, merge 588196153) | Sí | Ya está: es **idéntico** (`patch-id` igual) a `portes-159/chromium/0002` (#1159) |

El tag **156.0.8078.113** (`970863f8c7`, 20-11) **no sirve de referencia**. Es un *hotfix* en la sub-rama
`branch-heads/8078_108`, hecha desde 8078@#2244 (16-11, anterior a la .111), que solo añade el cambio de Variations.
Tiene menos arreglos que la .112.

## `chromium/0001`: f95dd51f6f (bugs 583179913 y 584370079)

Mientras se ejecutan los manejadores por defecto de un evento, su `target` vuelve a ser el pseudo-elemento en bruto si
este tiene comportamiento de activación (p. ej. `::scroll-marker`). Un *script* que se ejecutara entonces (p. ej. un
`DOMActivate`) podía leer `event.target` y obtener un `PseudoElement` vivo, y con él moverlo y **corromper el árbol de
pseudo-elementos** en el *renderer*. `Event::target()` solo tenía un `DCHECK`. Ahora devuelve el elemento de origen, o
`null`. Además, desechar un `::column` no desechaba su `::scroll-marker`, y eso también se corrige. Se alcanza desde
cualquier web con *scroll markers* de CSS. Aplica a Mac.

- Mismo cambio que upstream. Los seis ficheros que no son `element.cc` quedan idénticos byte a byte a los de upstream.
  En `element.cc` el *hunk* entra con un desplazamiento de 9 líneas y con las mismas líneas añadidas y quitadas
  (`git diff` las alinea de otra forma, por eso el `patch-id` sale distinto). El resto de diferencias de ese fichero con
  upstream son portes anteriores de FlyWeb, en otras funciones.
- brave-core no toca estos ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0001`

Pruebas para LOCAL: las dos WPT nuevas de `css/css-overflow/scroll-markers/` (`*-crash.html`), con `run_web_tests`, y
`blink_unittests --gtest_filter='*Event*Target*:*PseudoElement*'`.

## `chromium/0002`: af12c47ccb (bug 580846503)

El reproductor HLS integrado (`HlsDataSourceProviderImpl`) pasaba las URL `data:` por la pila de red, y así quedaban al
alcance de los *service workers*, que podían interceptarlas. Ahora se cargan directamente (`net/base/data_url`). En
FlyWeb el *demuxer* HLS se compila (`enable_hls_demuxer = proprietary_codecs`, y Brave compila con códecs
propietarios), así que aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). Añade `+net/base/data_url.h` a `media/DEPS`. brave-core no toca estos
  ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0002`

Pruebas para LOCAL: `media_unittests --gtest_filter='HlsDataSourceProvider*'` y, en la build, un vídeo HLS (`.m3u8`)
cualquiera.

## `chromium/0003`: 2762e65042 (bug 588460249, b/554051967)

`VariationsService` reintentaba por **HTTP plano** cuando fallaba la descarga de la semilla por HTTPS. Ahora ese
reintento viene apagado por defecto. En FlyWeb, Variations apunta a una URL inerte, así que en principio no hay
petición que reintentar. Va como endurecimiento, por si un día la URL deja de ser inerte.

- Mismo diff que upstream (`patch-id` igual). brave-core no toca `variations_service.{h,cc}`.

### Veredicto (regla 17): **APTO**, `chromium/0003`

Prueba para LOCAL: `components_unittests --gtest_filter='VariationsServiceTest.*'`.
