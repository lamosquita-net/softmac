# LOCAL-19: COMPILAR LA 3.1.0 esta noche (de COORDINACIÓN-38). Contenido cerrado (DIRECTIVAS #928 y #932).

**Rama:** brave-core `local/3.1` desde `local/3.1-candidata` b6c544471e (= 3.0.1 77ae53e5f6 + 0004 + 0005 de la NTP
privada), y encima, con `git am`: `FlyWeb/parches/3.1-cosmetic-style/` (lo mismo que `local/3.0.1-style` 40856a11d15) y
`FlyWeb/parches/3.1-favicons/` (#926). Chromium `seg/3.0.2` 502e3c5b85 con los cuatro de `FlyWeb/parches/3.1-angle/`
(0001–0004, como la t4).
**Maglev ENCENDIDO:** quita de `patches/v8/src-flags-flag-definitions.h.patch` solo lo que apaga Maglev (nada más del
parche), en commit aparte; comprueba en `flyweb://version` o con `%IsMaglevEnabled`/`--js-flags` que va encendido.
**Versión:** 3.1.0, `FLYWEB_BUILD_NUMBER` 43 (en `build/config.gni`, como manda «Versiones desde la 3.0.0»). Release
oficial con PGO, build limpia de lo tocado.
**Pruebas antes de entregar (7,1 y 6,1), informe por paso:** ventana privada = NTP de FlyWeb con la mosca, en claro y
oscuro; favicons con la mosca en la NTP normal, la privada y `flyweb://version`; página de sync y ajustes (Escudos,
filtros, Aspecto); `funcional.js` de 3.1-cosmetic-style; MotionMark (Multiply) y Speedometer, una pasada; Aquarium 15k en
la 6,1; texturas 69/69; claude.ai a mano sin sesión; `chrome://history` buscando algo (LOCAL-21 vio
`getSearchField is not a function` con la t4: di si pasa también en la 3.0.1 y si la búsqueda funciona); los dos README.
**Entrega** en la fila de FS/FM que toca con los hashes (ls-remote) → PUBLICACIÓN (regla 11). Objetivo: publicar mañana
por la mañana.

**Aparte, el guion de la 5,1 (no bloquea):** rehazlo para que abra la FlyWeb **ya instalada** con el perfil de quien la
use (sin perfil en /tmp; antes cierra FlyWeb), y mida Speedometer 3.1 y JetStream 3 con Maglev de serie y con
`--js-flags=--no-maglev`, tres pasadas, dejando `resultado-51-<fecha>.txt`. Que funcione con lo que trae Mojave de serie
(sin Python 3; bash/osascript o Python 2.7) y pruébalo en la 6,1. Súbelo a softmac en `FlyWeb/tools/prueba-51/` (PR
`[local]`) para que Titín lo pase con un enlace. Sin datos personales.
