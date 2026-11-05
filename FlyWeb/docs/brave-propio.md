# ¿Llevar brave-core 1.69 entero a Chromium 156, o absorber solo lo que usamos?

INVESTIGACIÓN-MOTOR-7, 03-11-2026, encargo de COORDINACIÓN-24 (con la pregunta de Titín). **Solo papel** (no se ha compilado nada). La v1 (#706) salió de los documentos del repo; la **v2** (este cambio) añade P0: lectura de `lamosquita-net/brave-core`
(`flyweb` ac280a17df, `add_repo` en lectura por orden de COORDINACIÓN) y las medidas del §2.4. Marcas: **[V]** leído en documento del repo o en fuente
citada; **[I]** inferencia mía; **[N]** el repo no lo dice o no se ha medido. Sin horas nuevas: las que salen son de documentos previos.
Complementa `base-siguiente.md` (riesgo 1, B2, decisión 3) y `fork-propio.md` (§5.1, F4).

## 1. Conclusión (revisada con las medidas de P0, 03-11)

**v1** (#706) recomendó la opción C sin cifras. **P0 está hecha** (lectura de `lamosquita-net/brave-core`, rama `flyweb` ac280a17df, 2.6.1; §2.4) y
**mantiene C, pero cambia el porqué**:

1. **La poda es barata, y no es lo que más pesa.** El 56 % de los ficheros de código y pruebas de Brave (7 010 de 12 549; 1,03 M de 1,91 M de líneas sin
   traducciones) es de funciones apagadas y vive en directorios propios. Solo 19 de los 1 957 parches (1 %) y 116 de los 1 555 `chromium_src` (7 %)
   mencionan esas funciones, y 223 ficheros vivos de escritorio las incluyen: son ~360 ediciones en las costuras y el resto es borrar carpetas.
   Pero **no reduce la superficie de parches**: los parches y `chromium_src` que hay que rebasar son casi todos de lo vivo (1 790 parches y 1 258 `chromium_src` en «núcleo/UI/otros»).
   La poda quita **superficie de compilación** (≈4 800 ficheros de código apagados que se siguen compilando, [I]), no de rebase.
2. **Los 1 555 `chromium_src` son menos temibles de lo que `base-siguiente.md` suponía.** 1 300 son envoltorios finos (`#include` del mismo fichero de Chromium;
   mediana de 22 líneas; 11 pasan de 300). Se rompen cuando cambia un identificador que sobrescriben, y se corrigen uno a uno.
   El riesgo 1 de `base-siguiente.md` (brave-core contra la 156) está en el **código de Brave que llama a APIs de Chromium**, no en el recuento de `chromium_src`.
3. **Dónde se gana de verdad:** el 61 % de los parches (1 209 de 1 957: Blink 956 y V8 ~250) son motor de FlyWeb y desaparecen como capa de nivel con la base nueva
   (`base-siguiente.md`). Quedan unos 750, de los que ~590 son de Brave. **Absorberlos en commits del fork (P3) y no mantener `patches/`** es el ahorro de verdad, sea cual sea la opción.
4. **Por tanto:** C sigue siendo la recomendación (podar → medir contra 156 → absorber), con la poda como paso **de bajo riesgo y alta higiene**, no como la gran palanca.
   B (disolver `brave-core`) sigue sin justificarse ahora: quedan unos 850 ficheros vivos de Shields, sync y updater, 1 463 de núcleo/UI y 1 258 `chromium_src`, además del sistema de build, l10n e identidad.
5. **Lo que decide la puerta:** el número de ficheros rotos al compilar el `brave-core` podado contra el árbol 156 (P2). Esa cifra sigue sin existir.
6. **Cuidado con el nombre «Leo»**: es el asistente de IA (se quita) y también el sistema de diseño `@brave/leo` (MIT [V]), del que cuelgan los WebUI que sí usamos.
7. **v3 (03-11, B2 en papel, §11):** (a) los 556 ausentes de 1.98 se clasifican con el commit de Brave que los quitó: 28+67 se caen, 46+96 ya no hacen falta, 30+232 se adaptan, 34+19 se reescriben, 4 a mano; (b) **el donante de 1.98 incluye 767 plasters** que §10.3 no contaba; (c) de 579 parches de Brave, **198 aplican tal cual sobre 156, 323 con una línea menos de contexto**, y los 441 que tienen donante en 1.98 aplican todos; (d) **tres cambios propios de FlyWeb no se portan solos** (clave del Secure Enclave, llavero `fw1`/«FlyWeb Safe Storage», captive portal): §11.4; (e) receta de B2 en §11.7.

## 2. Inventario: lo que FlyWeb usa de Brave

Resumen de los tres informes de lectura. Rutas de 1.57 o 1.69 según el documento; los tamaños solo cuando algún documento los da.

### 2.1 Se usa (con ajustes)

| Función | Dónde (brave-core) | Estado en FlyWeb | Tamaño / coste [V si lo da un doc] | Fuente |
|---|---|---|---|---|
| Motor de bloqueo (adblock-rust) | 1.57 `components/adblock_rust_ffi`; 1.69 `components/brave_shields/adblock/rs`, crate `adblock` en `third_party/rust` | Usa: 0.7.9 (1.x) y 0.8.11 (2.0) | versiones [V]; tamaño [N] | `brave-sync-shields` §3 |
| Listas de Shields (componentes) | `brave_shields/browser/ad_block_service.cc`, `ad_block_component_installer.cc` (1.57); `core/common/brave_shield_constants.h`, `local_data_files_service.h` (1.69) | Ajusta: ID y claves propios, firmados en bak, servidos desde `components.flyweb.lamosquita.net` | 5 pares ID/clave (1.57), 3 (1.69); reubicar ≈ 1–2 h; servidor ≈ 8–17 h [V] | `brave-sync-shields`, `componentes` |
| Cosmético, scriptlets | dentro de adblock-rust y del componente de recursos | Usa; recursos propios `recursos-157`/`recursos-20` | [N] | `brave-sync-shields` §3.3 |
| Farbling / antihuella | **parches de Blink** (`document.cc`, `local_frame.cc`, canvas2d, `webgl_rendering_context_base`…), no `brave-core` | Usa; vive en los 590 parches, no en el código de Brave | 20 ficheros compartidos con parches nuestros, 4 colisiones [V] | `brave-vs-parches-motor` |
| Filtrado de parámetros (`query_filter`) | `components/query_filter/utils.cc` | Usa y ajusta | 39 → 57 cadenas; 3 por añadir [V] | `brave-170-173` §5 |
| Debouncing | `components/debounce` | Usa; reglas por el componente «Datos locales» con ID propio | [N] | `componentes` §2 |
| HTTPS por defecto | feature `kBraveHttpsByDefault` | Ajusta (encendida, con excepciones de Datos locales) | [N] | `integracion` paso 32 |
| Políticas | `browser/policy/brave_simple_policy_map.h` | Ajusta (`.mobileconfig`) | 111 líneas [V] | `rebranding` §4, §6 |
| Sync | `components/brave_sync`, `components/sync`, `chromium_src/components/sync` | Usa y ajusta (servidor propio `servidor/sync`) | 57 modificados, 5 nuevos, 8 borrados (1.57 → 1.69) [V] | `brave-sync-shields` §2 |
| Component Updater | `components/update_client`, `chromium_src/components/component_updater`, `brave_component_updater` | Ajusta (serializador recortado, lista de bloqueo) | cliente 4–8 h [V] | `componentes` §2, §7 |
| Identidad y rebranding | `app/theme/brave/BRANDING`, `build/commands/lib/*`, `grd_string_replacements.py`, constantes de URL | Ajusta mucho | 2 422 ficheros propios sobre 1.57: 733 traducciones, 57 iconos, 257 código, 1 327 parches [V] | `brave-vs-flyweb`, `rebranding` |
| Safe Browsing y proxy | `components/constants/network_constants` (1.57) → `.h` (1.69) | Ajusta (5 constantes; regresión silenciosa si la fusión toma el valor de Brave) | 1,5–3 h [V] | `brave-vs-flyweb` §3.1 |
| Sparkle / Keystone | `keystone_glue.mm` (1.69, siempre compilado) | Ajusta | 739 líneas nuevas [V] | `brave-169-macos` |
| NTP, bienvenida | `components/flyweb_ntp` (propio) | Propio (React) | 15 ficheros nuevos + 6 de `ui/webui` + 2 de `browser/flyweb` [V] | `migracion-128` |
| Gestor de contraseñas | **no es de Brave**: es el de Chromium | Usa | — | `contrasenas` |

**De-AMP:** ningún documento lo trata. Existe en Brave (`components/de_amp`, de memoria [I]) y la web de FlyWeb lo cita como tema; hay que
comprobar si compila y si está encendido [N].

### 2.2 Se apaga o se quita

| Qué | Cómo se apaga hoy | Notas |
|---|---|---|
| Leo / AI Chat / AI Rewriter | `enable_ai_chat:false` (el Rewriter cae solo) | Tras -p13 se corrigieron dos fallos de UI/tests por apagarlo (MOTOR-18); `brave_service_keys` aún exige claves no vacías en Release |
| VPN (+ WireGuard) | `enable_brave_vpn:false`, `enable_brave_vpn_panel:false` | — |
| P3A, stats, variations, updater de Brave | `brave_p3a_enabled:false`, URLs `flyweb.invalid`, `enable_updater:false` | `build.sh` ~255–272 [V] |
| Wallet | **sin flag de gn**; `nube/no-wallet`: `IsAllowed()` = `false` en `common_util(s).cc`; sin componente de datos; Web3 oculto en Ajustes | 1.69 añade Bitcoin y Zcash: comprobar que `IsAllowed()` también los apaga |
| Rewards, Ads, SKUs | Rewards: sin flag; política `BraveRewardsDisabled`; `brave_ads` queda compilado | `challenge_bypass_ristretto` (26 ficheros, Rust) se mantiene solo porque lo usan Ads, Rewards y SKUs |
| News, Talk, referidos, imágenes patrocinadas | parches de comportamiento (`integracion` pasos 10, 25, 33) | — |
| IPFS | Brave lo quitó de escritorio en la 1.69 | `components/ipfs`: 78 → 10 ficheros [V] |
| Player, PSST, WebCompat, DayZero | `enable_brave_player:false` y features apagadas por defecto | Player borrado por Brave en la 1.70 |
| Tor, Speedreader, Playlist, Sidebar | **sin decisión documentada**; `build.sh` no pasa sus flags | Tor se descarga solo al abrir ventana Tor [N] si va compilado |
| Safe Browsing | no se puede quitar al compilar en 1.57; política + proxy propio | — |

### 2.3 Dependencias ocultas (lo vivo que cuelga de lo muerto)

Estas son las que impiden «borrar y ya» [V salvo indicación]:
- `brave_services_key`: la misma clave sirve a sync, a los componentes y a Leo (`x-brave-key`). Si se compilara Leo con ella, viajaría a `ai-chat.bsg.brave.com`. Comprobar con `strings` que el binario no contiene ese host [N: sin hacer].
- `challenge_bypass_ristretto` y `script_injector` solo existen por Ads/Rewards/SKUs y PSST: caen con ellos.
- Cadenas: `brave_components_strings.grd` (112 entradas) y sus `.grdp` de Rewards, Wallet, VPN, News, Tor siguen presentes y traducidas
  (510 apariciones de «Brave» en `brave_strings.grd`, 648 `.xtb`). Podar cadenas exige `chromium-rebase-l10n.py` (no editar `.grd`/`.xtb` a mano, CLAUDE.md).
- Constantes que pasan a cabeceras en la 1.69 (`flyweb://`, proxies de Safe Browsing, monedero apagado) y un `UpgradeDetector` sin la guarda de Keystone:
  regresiones silenciosas (TRAMPAS 26-10). Un rebase a 156 repite el riesgo.
- Mojom y recursos WebUI compartidos con lo apagado: ahora medido en parte (§2.4: 223 ficheros vivos de escritorio incluyen código apagado, 25 de ellos en `browser/ui/webui`); la lista fichero a fichero sale de `p0.py`.
- Pruebas: `brave/test/BUILD.gn` y los *browsertests* de lo apagado siguen compilándose [N: sin lista].
- Los parches no se deshacen solos: `apply_patches` no revierte los que crean ficheros (TRAMPAS).

### 2.4 Medidas de P0 (sobre `flyweb` ac280a17df)

Clasificación **por ruta con expresiones regulares** (heurística, §9); guion reproducible en `FlyWeb/tools/brave-inventario/`. 34 181 ficheros: `third_party` 12 742 (374 MB; 12 119 de crates de Rust),
código 10 282 (2,71 M de líneas), iOS 3 713, pruebas 2 267, parches 1 957 (21,7 MB; coincide con `fork-propio.md` §2), Android 1 665, `chromium_src` 1 555 (58 634 líneas).
Las cifras de parches y `chromium_src` **coinciden con las de `fork-propio.md`** [V].

| Función | Estado | Código: ficheros / líneas | Pruebas: ficheros | `chromium_src` | Parches | iOS | Android |
|---|---|---|---|---|---|---|---|
| Rewards, Ads, SKUs, CBR, referidos, Greaselion | apagada, **se compila** | 2 783 / 202 735 | 675 | 0 | 0 | 117 | 121 |
| Wallet (+ Web3, IPFS-DNS, Filecoin) | apagada, **se compila** | 1 876 / 251 108 | 192 | 4 | 2 | 440 | 186 |
| VPN | apagada (flag) | 282 / 24 452 | 17 | 0 | 0 | 62 | 56 |
| Leo / AI Rewriter | apagada (flag) | 198 / 21 166 | 36 | 0 | 0 | 104 | 13 |
| P3A, stats, métricas | apagada (flag) | 194 / 18 099 | 43 | 0 | 0 | 26 | 19 |
| News | apagada, se compila | 132 / 14 135 | 461 (238 600 líneas, datos) | 0 | 0 | 0 | 23 |
| Player, PSST, WebCompat, DayZero | apagada | 85 / 4 441 | 13 | 0 | 0 | 1 | 1 |
| IPFS, Talk | apagada | 15 / 614 | 8 | 0 | 0 | 6 | 0 |
| **Total apagado** | | **5 565 / 536 750** | **1 445 (488 587 líneas)** | **4** | **2** | 756 | 419 |
| Tor | **sin decisión** | 93 / 8 898 | 50 (375 593 líneas, datos) | 0 | 0 | 0 | 0 |
| Speedreader | sin decisión | 127 / 14 002 | 132 | 0 | 0 | 1 | 2 |
| Playlist | sin decisión | 139 / 16 567 | 19 | 0 | 0 | 226 | 12 |
| Sidebar | sin decisión | 65 / 7 437 | 4 | 0 | 2 | 0 | 0 |
| WebTorrent, Wayback, Brave Search, Commander, Request-OTR | sin decisión | 234 / 14 117 | 22 | 0 | 0 | 0 | 1 |
| NTP y bienvenida de Brave | sustituidas | 330 / 28 203 | 25 | 8 | 1 | 192 | 69 |
| Shields y privacidad | viva | 506 / 43 641 | 100 | 107 | 31 | 67 | 15 |
| Sync | viva | 89 / 7 858 | 12 | 68 | 3 | 59 | 27 |
| Updater, componentes, claves, constantes | viva | 99 / 4 571 | 10 | 65 | 20 | 10 | 5 |
| Identidad, l10n, recursos | viva | 1 572 / 1 789 396 (traducciones) | 39 | 45 | 108 | 459 | 93 |
| Núcleo, UI y otros | viva/resto | 1 463 / 234 604 | 409 | **1 258** | **1 790** | 1 943 | 1 022 |

Notas: (a) «Se compila» significa que `build.sh` no pasa ningún flag que lo excluya [V: `build.sh` ~255–272 según los informes]; no lo he comprobado con `gn desc` [N].
(b) En «Wallet», 1 213 de los 1 876 ficheros son `brave_wallet_ui` (React/TS, webpack); en «Rewards/Ads», 2 152 son `brave_ads`. (c) Las pruebas de News y Tor son sobre todo datos de prueba.
(d) La fila «Total apagado» es la suma de las filas apagadas: **7 010 ficheros de código y pruebas, 1 025 337 líneas**.

**Cuánto de lo vivo toca lo apagado** [V, por inclusión y dependencias de GN/DEPS]:
- Parches con alguna mención a funciones apagadas: **19 de 1 957** (Wallet 12, Playlist 4, Rewards 2, Sidebar 2, VPN 1, Leo 1).
- `chromium_src` con alguna mención: **116 de 1 555** (Wallet 56, Leo 27, Rewards 20, VPN 20, Tor 18, Speedreader 17, P3A 9, Playlist 9, Sidebar 7, News 6, IPFS 5).
- Ficheros vivos de escritorio (sin Android/iOS) que incluyen o dependen de código apagado: **223** (Rewards/Ads 92, Wallet 66, Leo 66, P3A 63, VPN 56, News 24, Player/PSST/… 18, IPFS 3; con solapes).
  Concentrados en `browser/ui/webui` (25), `browser/ui/views` (18), `browser/ui/toolbar` (6), `components/brave_shields/content` (6, métricas P3A en `ad_block_service.h`),
  barra lateral (8), `request_otr` (4) y `omnibox` (3). Más los `BUILD.gn`/`sources.gni`/`DEPS` de `browser/ui`, `chromium_src/chrome/browser`, `build/`.
- En `third_party/rust` hay crates de funciones apagadas: `zcash*`, `orchard`, `libsecp256k1*`, `ed25519_dalek_bip32`, `adss`, `challenge_bypass_ristretto*` [V: nombres]. Caen con Wallet y Rewards; `curve25519_dalek` y `ed25519` pueden tener otros usos [N].

**Dónde está el acoplamiento real con Chromium** (superficie de rebase):
- Parches por área [V]: Blink 956, V8 ~250 (motor de FlyWeb, capa de nivel), `chrome/` 282 (201 de `chrome/browser`), `components/` 137, `content/` 47, `net/` 38, `tools/` 29, `ui/` 28, `services/` 19, BoringSSL 16, `build/` 15, `base/` 14.
- Interfaz: **74 parches `chrome/browser/ui` + 323 ficheros `chromium_src/chrome/browser/ui` = ~400 puntos de contacto**. Mayores clientes en `browser/ui` de Brave: `views/frame` 40, `views/tabs` 39 + `tabs` 29,
  `views/toolbar` 30 + `toolbar` 21, `views/sidebar` 25 + `sidebar` 14, `views/side_panel` 22, `commander` 29, `webui/settings` 50, `color` 13, `views/omnibox` 12.
- `chromium_src`: 1 300 de 1 555 son envoltorios finos (mediana 22 líneas).

## 3. Opciones

| | **A. brave-core 1.69 tal cual contra 156** | **B. Absorber lo útil en el fork y dejar brave-core** | **C. Poda + absorción gradual (recomendada)** |
|---|---|---|---|
| Qué es | Rebase de todo: 590 parches, 1 555 `chromium_src`, código de Brave muerto y vivo | Todo lo vivo (Shields, sync, updater, políticas, identidad, Sparkle, l10n, build) como commits en `chromium/src`; se abandona `brave-core` | Borrar lo muerto en `brave-core` (128); portar a 156 lo que queda; mover a commits del fork lo que sea envoltorio de Chromium; `brave-core` queda pequeño |
| Coste de rebase | El mayor: paga la deriva de 28 hitos también en el código de funciones apagadas | Desaparece el rebase de `brave-core`, pero se paga una vez la absorción de todo, incluido el sistema de build | Rebase de lo vivo únicamente; poda previa y barata de revertir (git) |
| Riesgo | Alto y creciente; precedente: el rebase de Brave fue la partida mayor de la 116 → 128 (150–300 h de 330–710) [V] | Muy alto de golpe: el *build*, el empaquetado, la l10n y la identidad hoy salen de `brave-core`/`brave-browser` | Medio; se divide en pasos medibles y reversibles |
| Qué se pierde | Nada, a cambio de coste | La estructura `chromium_src` (que evita tocar ficheros de Chromium) y la posibilidad de traer un diff de Brave tal cual | Casi nada: los mismos 590 parches se quedan hasta F4 |
| Encaja con directivas | Contradice la propia salida de «apagar, no borrar» (se borra con fork propio) | Contradice «Brave no se sigue por número» solo parcialmente; sí encaja con fork propio | Encaja con las dos |
| Reversible | Sí | Difícil | Cada paso sí |

Por qué no B ahora: con un fork de `chromium/src` y `v8` por delante, convertir también el *sistema de build* de Brave en commits suma
una segunda transformación grande al mismo tiempo que se cambia de base. B es un destino posible, no el primer paso [I].
Por qué no A: es pagar el coste por mantener compilando código que no se ejecuta y que la propia directiva dice que se borra con el fork.

## 4. Licencia

- **MPL-2.0 es por fichero** [V: `LICENSE` de brave-core, `package.json` `"license": "MPL-2.0"`; `FlyWeb/README.md`]. Un fichero de Brave que
  se absorbe **sigue siendo MPL**: se conserva su cabecera, se publica su fuente si se distribuye el binario y se marca como tal.
- Mezclarlo con código BSD de Chromium es posible: MPL §3.3 permite una «obra mayor» bajo otros términos si se cumple la MPL para el
  *Covered Software* [V: texto de la licencia]. **No es asesoría legal**: lo comprueba quien firme la publicación.
- **Hoy** se cumple con forks públicos (`lamosquita-net/brave-core`, `brave-browser`) y la página «Código y licencias» (W4, `web-flyweb.md`), más
  `about:credits` (`hoja-de-ruta.md`). Si `brave-core` desaparece o se recorta, la obligación pasa a un inventario de **qué ficheros de Brave
  quedan en el fork**, con su cabecera, y a un enlace público al fork.
- **Cambia con la poda:** `about:credits` deja de listar lo borrado. Lo que se queda (D-DIN OFL, EasyList/EasyPrivacy GPLv3/CC BY-SA, uBlock Origin GPLv3, Chromium Legacy BSD-3,
  `go-sync` MPL-2.0) se mantiene [V: `hoja-de-ruta`, `llavero`, `disenos`].
- **Dependencias de Brave que se quedan:** `adblock` (adblock-rust) es MPL-2.0 en su rama principal (`Cargo.toml`, 0.13.5) [V]; **no he comprobado la 0.8.11** que
  usamos [N]. `@brave/leo`: MIT (rama principal) [V]. El resto (`challenge_bypass_ristretto` si se queda, etc.): [N], sin inventario.
- **Marca:** «Brave» y su logo no están cubiertos por la MPL; ya se cambian (`marca-pendiente.md`). Los avisos legales de Brave se quedan en los ficheros que se conserven.

## 5. Interfaz más parecida a Chrome: qué sobra de la de Brave

La documentación fija esto [V]: NTP y bienvenida son propias; Rewards, News, Talk, Leo y cartera salieron de la barra, la NTP y la barra lateral; el icono y el
león están sustituidos; los menús y ajustes están traducidos; la fuente de las páginas internas es D-DIN; el panel de Shields y el menú **no tienen diseño propio**
(`disenos.md`); las pestañas planas de D8 (Titín, 27-10) son lo único que pide alejarse del aspecto actual, «sin prioridad». **Ningún documento pide
«parecerse a Chrome» como tal** [N]: es la dirección que Titín ha dado hoy.

Lo que sigue es propuesta mía. Los tamaños son **medidos** [V] (§2.4); la valoración de cada pieza, inferencia [I]. Puntos de contacto con la UI de Chromium: 74 parches `chrome/browser/ui` + 323 `chromium_src/chrome/browser/ui`.

| Parte de la UI | Propuesta | Razón |
|---|---|---|
| Botón y panel de Shields, contadores | **Se queda** (WebUI, poco acoplado a las vistas de Chromium) | Es la razón de ser de FlyWeb |
| NTP, bienvenida, `flyweb://` | **Propios** | Ya lo son |
| Barra lateral de Brave (Sidebar: `views/sidebar` 25 + `sidebar` 14 + componente 65 ficheros) | **Sobra**: usar el panel lateral de Chromium (`views/side_panel`) si hace falta | Solo se parchea para quitar Talk; es una superficie de parches que cambia cada hito [I] |
| Botones de barra de Rewards, Wallet, VPN, Leo | **Borrar** con su código | Muertos |
| Pestañas (`views/tabs` 39 + `tabs` 29 + 12 parches de `chrome/browser/ui/tabs`): verticales, tarjetas, estilo | **Sobra**, salvo D8 si Titín lo mantiene | Se pinta sobre `TabStyle` de Chromium, que cambia con cada rediseño [I] |
| Menú de aplicación y menú contextual de Brave | **Sobra**: el de Chromium + las entradas de Shields | [I] |
| Ajustes extra de Brave | **Podar** (Rewards, Web3, Leo, VPN, Sidebar…) | Muertos o prescindibles |
| Temas y colores de Brave (`@brave/leo`) | **Se queda** `@brave/leo` en los WebUI; el tema de la ventana, a Chromium | `@brave/leo` es dependencia de los WebUI que usamos |
| Omnibox con sugerencias de Brave Search | **Sobra** | DuckDuckGo es el buscador por defecto |

Regla para decidir cada elemento (P5): se queda si da algo que Chrome no da y no choca con el rediseño de Chromium del hito; si no, se usa el de Chromium.
La razón principal es el coste: cada vista de Brave que sustituye a otra de Chromium es un conflicto en cada rebase.

## 6. Fases e hitos (sin horas)

| Fase | Qué | Hito (se cumple cuando) | Quién |
|---|---|---|---|
| **P0 Medir** — **hecha** (03-11) | Clasificar cada fichero por función y tamaño sobre `flyweb` ac280a17df | Tabla del §2.4 y guion reproducible en `FlyWeb/tools/brave-inventario/`. `local/270-arreglos` a78df81efd (2.7.0) difiere de `flyweb` en 335 ficheros: 330 de `patches/` (+150, −28; V8 y pruebas), 2 de `chromium_src` (mixed content), `build/config.gni` y 2 revisiones; **no cambia el reparto por funciones**. Pendiente: `gn desc` para saber qué se compila de verdad | INVESTIGACIÓN-MOTOR |
| **P1 Poda en sitio** (≈360 ediciones en costuras + borrado de directorios; orden de hojas a acopladas) (rama de `brave-core`, base 128, **después** de publicar la 2.7.0) | Borrar por orden: hojas (Leo, VPN, News, Talk, Player, PSST, WebCompat, DayZero, IPFS; ya excluidas por flag salvo News, IPFS y Talk), luego las acopladas (Wallet, Rewards/Ads/SKUs/CBR y P3A, que tocan `browser/ui` y Shields) | Compila y arranca igual que antes; `network-audit.py` sin cambios; `strings` sin `bsg.brave.com`; tabla antes/después de ficheros y parches | MOTOR, LOCAL |
| **P2 B2 revisado** | Compilar el `brave-core` podado contra el árbol 156 de B1 y contar ficheros rotos | Número de ficheros rotos frente a los de la opción A (sobre `brave-core` sin podar, para comparar) | MOTOR |
| **Puerta (Titín)** | Elegir A / C / B con P0 y P2 | Decisión anotada en `DIRECTIVAS.md` | Titín, ARQUITECTURA |
| **P3 Absorción gradual** (= F4 de `fork-propio.md`) | Los parches vivos y los `chromium_src` que sean envoltorio de un fichero de Chromium pasan a commits `Flynk-Class`; los 49 de `third_party/` a forks o `DEPS` | `patches/` a cero; `chromium_src` reducido a lo que no es un envoltorio simple | MOTOR |
| **P4 Licencias** | Inventario de ficheros de Brave que quedan, con cabecera MPL; `about:credits` regenerado; enlace a los forks | Inventario publicado y revisado por quien firme | PUBLICACIÓN, CONTENIDOS-WEB |
| **P5 Interfaz** | Elemento por elemento de la tabla del §5 | Cada elemento marcado «Brave» o «Chromium» con su razón | Titín decide el aspecto; MOTOR |

## 7. Encaje con los otros documentos

- **`fork-propio.md`:** la capa permanente ya prevé los 590 parches de Brave como primer commit y los 49 de `third_party/` en F4. Esta propuesta
  añade **antes** una poda del código muerto y **después** el paso de `chromium_src` a commits. No contradice nada aprobado; amplía F4.
- **`base-siguiente.md`:** B2 pasa a medir el `brave-core` **podado** (P2) y a compararlo con el sin podar. La decisión 3 de Titín se toma tras P0 y P2.
- **Orden de trabajo:** 2.7.0 publicada → conversión a git (F0–F1) → P0 → P1 → B1/B2 → puerta. La poda **no** se hace antes de publicar la 2.7.0.

## 8. Qué decide Titín

1. **A, B o C** (recomendada C), tras P0 y P2.
2. **Borrar** el código muerto (revoca «apagar, no borrar» para lo ya apagado; la propia directiva lo preveía con el fork). Con las medidas de P0 delante.
3. **Qué interfaz de Brave se conserva** (§5): Sidebar, pestañas verticales/estilo de pestaña (D8), menú y temas.
4. **Tor, Speedreader, Playlist**: ¿se compilan? Sin decisión documentada.
5. **Widevine** (pendiente desde antes) y el widget de búsqueda de la NTP: afectan a qué se conserva.

## 9. Debilidades

(i) P0 clasifica por **ruta con expresiones regulares**: las filas son órdenes de magnitud (p. ej. «Shields» incluye `permissions` y `content_settings`, «Identidad» incluye todo `resources`; la regla de Tor dio falsos positivos que corregí). Los fallos son revisables en el guion. (ii) «Se compila» no está comprobado con `gn desc` [N].
(iii) No distingo qué parches son de Brave (539–590) y cuáles de FlyWeb; lo da `fork-propio.md` (1 267 nuestros). (iv) Medido sobre `flyweb` ac280a17df (2.6.1); `local/270-arreglos` a78df81efd solo añade parches de V8/pruebas. (v) De-AMP (`components/de_amp`, 14 ficheros) existe en el árbol; si está encendido, [N]. Tor, Speedreader y Playlist siguen sin decisión.
(vi) La lectura de licencias no es asesoría legal. (vii) Las horas citadas son de documentos anteriores y suelen salir pesimistas.
**Fuentes:** `fork-propio`, `base-siguiente`, `brave-vs-flyweb`, `brave-vs-parches-motor`, `brave-sync-shields`, `brave-servicios-nuevos`, `brave-169-macos`, `brave-170-173`,
`integracion`, `identidad-128`, `rebranding`, `componentes`, `disenos`, `marca-pendiente`, `migracion-128`, `web-flyweb`, `hoja-de-ruta`, `TRAMPAS.md`, `DIRECTIVAS.md`;
`brave/brave-core` v1.69.168 (`LICENSE`, `package.json`, `BUILD.gn`); `brave/adblock-rust` `Cargo.toml` (rama principal); `brave/leo` `package.json` (rama principal).

## 10. Brave 1.98.63 frente a 1.69.168 (ampliación de Titín, 03-11)

Solo lo que FlyWeb usa; fuera, por orden: publicidad y sponsored images, Rewards, Wallet, Leo, VPN, News, Talk, P3A, stats, Brave Search. Método: dos etiquetas de `brave/brave-core`
traídas con `git fetch --filter=blob:none` (árboles) y los mensajes de commit de 2024-09-02 a 2026-10-30 (sin árboles, así que **ningún cambio se ha leído como código fuente**:
las conclusiones salen de listas de ficheros, `diff --stat`, indicadores y mensajes de commit). Cuatro subagentes de lectura, uno por área.

### 10.1 Datos [V salvo marca]

- **1.98.63 = Chromium 156.0.8078.80** (`package.json`, `projects.chrome.tag`). 1.69.168 = Chromium 128.
- Tamaño: 32 764 → **63 639 ficheros**; `patches/` 590 → **1 242**; `chromium_src/` 1 549 → **2 071**; `third_party/rust` 12 119 → 6 633. Diferencia: 43 676 añadidos, 12 801 borrados, 9 618 modificados.
  Crecimiento atribuido a Brave Origin (417 ficheros) y Brave Account (211) [I]; nada de eso lo usamos.
- Herramientas de build: Node >= 24.16 y pnpm >= 11.11 (antes Node 20–21 y npm 10), guiones `.js` → `.ts`, desaparece `scripts/sync.js`; los endpoints del updater, Safe Browsing, variations y stats **ya no se reenvían desde el build** (son valores por defecto de GN desde 2026-07, #37324/#37752); `brave_services_key_id`, `service_key_*`, `sparkle_eddsa_*` y `is_brave_origin_branded` son argumentos nuevos.

### 10.2 Qué cambió y qué merece traerse

| Área | Qué cambió | ¿Mejora real? | Coste de traerlo | Depende de lo apagado / de Chromium ≥ 129 | Veredicto |
|---|---|---|---|---|---|
| **Filtro de parámetros** (`query_filter`) | Brave **borra la lista compilada** (55 simples + 4 condicionales + 3 con ámbito) y la sirve por un componente nuevo (`cemdlagocoimleflkfkjoihojfainiho`, flag ON). **Sin componente no filtra nada** (no hay lista de respaldo) | Actualizable sin release, pero **pierde autonomía** | Portar la lista: trivial. Traer el componente: instalador + esquema + updater | Servicio de componentes de Brave | **No traer el componente.** Conservar la lista estática de 1.69 + `srsltid`, `_bhlid` y la excepción `urldefense.com` (ya previstos en `brave-170-173`). Si se quiere actualizar sin release, publicar un componente **propio** con ID propio, como ya hacemos con Shields |
| **Debounce** | Acción `regex-path-template`, rechazo de destinos sin eTLD+1 válido, arreglos de URLs sin ruta; 18 → 23 ficheros | Robustez modesta | Bajo: 0 parches y 0 `chromium_src` lo mencionan | No | **Traer** (aislado) |
| **De-AMP** | Solo refactor de `de_amp_body_handler.cc` y política de empresa | No | — | No | Nada |
| **HTTPS por defecto** | Brave migra de su mecanismo al HTTPS-upgrade de Chromium (flag 2026-09-09, migración de ajustes 2026-09-16) | Mejora a largo plazo (usar upstream) | Alto en Brave; **con la base 156 es nativo** | Chromium ≥ 150 [I] | **No portar lo de Brave.** Con base 156, el de Chromium + nuestra lista de excepciones (Datos locales) |
| **Avisos de cookies** | La lista «Cookie» ya era ON por defecto en 1.69; se borra el diálogo opt-in | Producto | — | — | Nada |
| **adblock-rust** | **0.8.11 → 0.13.3**; movido a `core/common/adblock`; servicio rehecho (`ad_block_service.cc` 619 líneas, `ad_block_engine_wrapper` +471), caché DAT, recursos compartidos, procedural, `removeparam`/CSP | Rendimiento y memoria, arreglos de hilos y de comprobación 3p en CSP [I por commits] | **Muy alto y acoplado**: no hay parche pequeño; 224 ficheros en `brave_shields` (+13 269/−4 259); 13 parches de 1.98 mencionan Shields (1 en 1.69) | **P3A dentro de `ad_block_service.cc`** (`AdBlockListP3A`): hay que recortarlo; crates Rust de Chromium ≥ 150 [I] | **No como parche suelto**; entra dentro del porte a 156 (P3), recortando P3A. Las listas ya se filtran para motores < 0,8,7 |
| **Farbling** | Token **por perfil** (2026-07, #37897) y **por contenedor** (2026-05, #36474); `BraveFarblingService` eliminado (su lógica pasa a `BraveShieldsSettingsService`); WebGL (extensiones, `debug_renderer_info`, flag); pantalla activada por defecto en escritorio (2026-02); WebGPU | **Real** (evita correlar perfiles) | Alto: refactor de servicio y parches nuevos de Blink (22 añadidos en `patches/third_party-blink-*`) | Los contenedores necesitan la infraestructura de «Containers», **ausente en la 128** | **Después de la base 156**, de forma selectiva (WebGL y pantalla, luego token por perfil) |
| **Almacenamiento** | `EphemeralStorage` deja de ser feature (permanente); cookies localhost/127.0.0.1 particionadas (2026-08); particionado de Blob URL | Real en parte | Medio-alto (`cookie_monster`, `cookie_settings`, `blob_url_store_impl`) | `PartitionKey`/CHIPS (cr143/145), `BlobURLStoreImpl` (cr140) | **Con la base 156** |
| **Local Network Access** | Brave **borra** sus parches de permiso de localhost y usa el LNA de Chromium | Real (seguridad) | Con base 156, gratis | LNA de Chromium, no está en la 128 | **Adoptar el de Chromium**; quitar nuestro parche de Brave |
| **Políticas** | `brave_simple_policy_map.h` 63 → 180 líneas (+32 constantes); 5 manejadores nuevos; la mayoría para Brave Origin | Producto/administración | Medio | — | Solo si interesa gestionarlas por MDM: `BraveSyncUrl`/`CustomSyncServiceUrl`, `TrackingQueryParametersFiltering`, `Debouncing`, `DeAmp`, `ReduceLanguage`, `GlobalPrivacyControl` |
| **Sync** | 101 ficheros cambiados (casi todo adaptación a Chromium: `ModelType` → `DataType`, Nigori cr150/152); ajuste «Custom sync URL» (2024-11) | Sync propio **más cómodo** | Bajo (ajuste + política) | No | **Traer opcional** (encaja con nuestro `servidor/sync`) |
| **Component updater** | Adaptación a Chromium 152 (clave CUP propia), sin cambio de protocolo | No | — | — | Nada |
| **Actualizador de macOS** | **Omaha 4** sustituye a Sparkle/Keystone como principal; Sparkle 1.24.4 de reserva | No para FlyWeb | Alto (servidor Omaha, firma) | `enable_updater` | **No traer**: tenemos Sparkle propio |
| **Políticas de privacidad que ya no están** | Se **revierten** las protecciones de `blob://` (2026-09-26) y se quita el bloqueo del modo oscuro (2026-09-01) | Retrocesos | — | — | **No copiar** |

**Hosts nuevos** (ámbito limitado a constantes y red; no es un `git grep` global): `usage-ping.brave.com`, `search.brave.software`, `support.brave.app`, y `*.ads.brave.com`/`*.ads.bravesoftware.com`.
**`brave.software` y `brave.app` no los cubre la lista de bloqueo `!*.brave.com`**: si alguna vez entra código de 1.98, añadirlos a `network-audit.py`. Desaparecen `laptop-updates.brave.com`, `p3a*.brave.com` y `support.brave.com`.

### 10.3 Brave 1.98 como donante del porte a Chromium 156 (medido)

Nombres de ficheros comparados entre `flyweb` (HEAD), v1.69.168 y v1.98.63 (hash de blobs; sin descargar contenido):

| | De Brave 1.69 que siguen en FlyWeb | También en 1.98 | Cambiados por Brave entre 1.69 y 1.98 | Ya no existen en 1.98 |
|---|---|---|---|---|
| `patches/` | 590 | **452** | 440 | 138 |
| `chromium_src/` | 1 549 | **1 131** | 1 026 | 418 |

Lectura: Brave **ya adaptó a Chromium 156** (y a sus propias funciones nuevas) el 77 % de nuestros parches de Brave y el 73 % de los envoltorios. Para cada uno,
`git diff v1.69.168 v1.98.63 -- patches/<fichero>` enseña cómo lo hizo. Los 138 parches y 418 envoltorios desaparecidos son código movido, obsoleto o de otras plataformas:
hay que revisarlos uno a uno (ejemplos: parches de Windows, Android, `build/rust`). Límite: «mismo nombre, contenido distinto» mezcla la adaptación a 156 con funciones nuevas de Brave,
y 25 de los parches y 35 de los envoltorios que FlyWeb modificó chocarán con la versión de 1.98.

### 10.4 Efecto sobre A, B y C

1. **Seguir Brave 1.98 como base: no.** Árbol ×1,9, parches ×2,1 (+652), herramientas nuevas (pnpm, TypeScript, Omaha 4) y casi todo lo nuevo es lo que apagamos. Confirma «Brave no se sigue por número».
2. **Pero 1.98 abarata el porte de 1.69 a 156 (A, B y C por igual):** el 77 % de los parches y el 73 % de los envoltorios tienen un donante ya adaptado (§10.3). Eso **reduce el riesgo 1 de `base-siguiente.md`**, aunque no lo cuantifica: P2 puede medirlo (ficheros rotos *con y sin* donante).
3. **No cambia la elección: sigue siendo C** (podar → medir → absorber). Lo que cambia es que la medida de P2 debe usar los donantes, y que B (disolver `brave-core`) pierde un argumento
   (el miedo al rebase de Brave es menor del que se pensaba), mientras que A sigue pagando el código muerto.
4. **Lo que de Brave 1.98 merece traerse, por orden:**
   - (ya posible en la 128) los 3 parámetros de `query_filter` y el ID de ScreenAI, previstos en `brave-170-173`; la política `BraveSyncUrl` si se quiere.
   - (con la base 156, casi gratis) HTTPS-upgrade y Local Network Access **de Chromium**; quitar nuestro parche de localhost de Brave; debounce nuevo (aislado).
   - (después, selectivo) farbling: WebGL y pantalla; luego token por perfil y por contenedor; particionado localhost y Blob URL.
   - (dentro del porte a 156) adblock-rust 0.13 con su servicio, recortando P3A. No antes, no suelto.
   - No traer: Omaha 4, Origin, Account, modo «solo adblock», componente de `query_filter`, retrocesos de `blob://`, pnpm/TypeScript.
5. **Riesgo nuevo:** si se sigue usando `brave-browser` 1.69 con Chromium 156, su `npm run sync` y sus argumentos de GN quedan lejos de lo que 1.98 espera (los endpoints ya no se reenvían). `build.sh` ya es nuestro; hay que
   comprobar en B1/B2 qué argumentos declara `brave-core` 1.69 y cuáles Chromium 156.

**Límites de este apartado:** [N] no se ha leído código de los cambios (solo listas y mensajes); [N] qué listas concretas añadió o quitó el catálogo remoto de Shields (viene de un componente); [N] versiones mínimas de macOS, SDK y Rust de 1.98; [N] el emisor de `usage-ping.brave.com`;
[I] todas las valoraciones de «mejora real» que salen solo de mensajes de commit.

## 11. B2 en papel: ausentes de 1.98, poda y receta (INVESTIGACIÓN-MOTOR-8, 03-11)

Cierra los pendientes (3) del relevo anterior y prepara (2). **Solo papel**: no se ha compilado nada. Sobre `flyweb` 5fdeb23d6 (2.7.0; P0 se midió sobre ac280a17df). Marcas: **[V]** medido o leído en fuente citada; **[I]** inferencia mía; **[N]** no se ha comprobado.
Datos y guiones reproducibles en `FlyWeb/tools/brave-inventario/` (README: tabla de guiones; resultados en `datos/`).

### 11.1 Método y límites

1. Se reprodujeron las cifras de §10.3 [V]: de los 590 parches y 1 549 envoltorios de 1.69 que siguen en `flyweb`, **138 y 418 no existen en 1.98.63** (los 556 de `datos/b2-ausentes.tsv`).
2. Por cada uno: (a) si el fichero de Chromium que parchea existe en **128 y en 156** (árboles de `github.com/chromium/chromium`, etiquetas 128.0.6613.138 y 156.0.8078.80) [V]; (b) si el parche aplica sobre el fichero de 156 (`git apply --check`; control en 128: los 80 aplican) [V]; (c) **el commit de Brave que lo borró**, con fecha y asunto (historial de 18 905 commits de 2024-09-02 a 1.98.63, con árboles y sin blobs; solo 3 de 556 sin commit: el borrado es anterior a 2024-09-02) [V]; (d) si Brave lo reexpresa como **plaster** (`rewrite/<ruta>.yaml` en 1.98.63) [V]; (e) si sus identificadores `BRAVE_*` siguen en 1.98.37 (`master` del fork, 28-09; no es la etiqueta 1.98.63) [V].
3. La clase sale de reglas por asunto del commit y por ruta (`b2-clasifica.py`), con 35 revisiones a mano. **Es heurística**: el asunto dice *por qué lo quitó Brave*, no *si FlyWeb lo sigue necesitando*. No se ha leído el diff de cada commit [N]. Una muestra aleatoria de 24 filas leída contra el asunto: 22 coherentes y 2 dudosas (`content-browser-browser_main_runner_impl`, `chrome/browser/themes/theme_service_factory.h`) [I].
4. Clases: **se cae** (otra plataforma, función apagada/podable o interfaz de Brave que P5 sustituye por la de Chromium); **ya no hace falta** (Chromium borró el fichero o Brave adoptó lo de Chromium); **se adapta** (el cambio existe, en otro fichero, con otra forma o con *plaster*; el donante de 1.98 lo enseña); **se reescribe** (el objetivo cambió y no hay donante utilizable, o el parche ya no aplica).

### 11.2 Los 138 parches

| Clase | Parches | De los cuales | Qué hacer |
|---|---|---|---|
| Se cae | 28 | 22 de otras plataformas (Android 12, Windows 5, Linux 5), 3 de funciones apagadas, 3 otros | Nada; salen con la poda y con «solo macOS» |
| Ya no hace falta | 46 | 17 de `third_party/rust`, `tools` y `build` (crates que Chromium ya no necesita o parcheo redundante, [cr134–cr153]); 13 de WebUI (Brave quitó overrides redundantes o Chromium borró el fichero); resto sueltos | Nada; **comprobar** los de FlyWeb (§11.4) |
| Se adapta | 30 | Chromium movió o renombró lo parcheado ([cr133] IDL de canvas, [cr143] `os_crypt`, [cr145] `TabStripRegionView`…); 3 con plaster | Tomar el donante de 1.98 (el nuevo nombre) |
| Se reescribe | 34 | **20 son WebUI** (`chrome/browser/resources/{bookmarks,downloads,extensions,history,password_manager,side_panel}`): Brave cambió a un mecanismo nuevo de *overrides* de WebUI (#26881 y otros) y el parche de 1.69 no aplica; 4 de Rust | **Decisión de P5**: si la interfaz va hacia Chromium, no se reescriben; si se quiere el estilo de Brave, hay que adoptar el mecanismo nuevo |

De los 138, **80 tienen el fichero en 156** y **58 no** (renombrado o borrado). De los 80: aplican sin tocar 21, con una línea menos de contexto otros 22, no aplican 37 [V].

### 11.3 Los 418 envoltorios (`chromium_src`)

| Clase | Envoltorios | Detalle |
|---|---|---|
| Se adapta | 232 | **143 los lleva Brave ahora como plaster**: 120 con `rewrite/<ruta>.yaml` en 1.98.63 [V] (migraciones `OVERRIDE_FEATURE_DEFAULT_STATES` I–V, `make_virtual` pt.1–4, `ECDSA_SHA384`, …); el resto, movidos o renombrados por Chromium ([cr140] 27, [cr142] 16, [cr143] 14…) o con el override rehecho |
| Ya no hace falta | 96 | Chromium borró el fichero (141 de los 418 ya no existen en 156 con ese nombre; p. ej. [cr149] `os_crypt/sync`, [cr152] `attribution_reporting`) o Brave quitó/simplificó el override |
| Se cae | 67 | 34 de Android/iOS/Windows; **19 de interfaz de Brave** (pestañas verticales, panel lateral, `tab_search`, `tab_drag`: P5 los sustituye por los de Chromium); 10 de funciones apagadas; 4 otros |
| Se reescribe | 19 | 8 cuyos identificadores `#define` ya no existen en el fichero de 156 [V]; 6 de «Only use brave:// scheme for display» (§11.4b); `component_updater_utils` (2, sin commit en el historial: Brave lo quitó antes de 2024-09-02); 3 más |
| A mano | 4 | `host_content_settings_map.h` (sin pistas) y los 3 de §11.4(c) |

**Hallazgo que corrige §10.3 [V]:** el donante de 1.98 **no es solo `patches/` y `chromium_src/`**: Brave tiene **767 plasters** (`rewrite/*.yaml`, herramienta `tools/cr/plaster.py`, `docs/plaster.md`: una regex por fichero que *genera* el parche; ninguno existía en 1.69). Los 120 envoltorios de arriba solo se ven mirando `rewrite/`. Si se usa 1.98 como donante, o se **adopta plaster** (otra herramienta de build que mantener) o se **convierte el resultado en un commit** del fork; para el fork propio es lo segundo.
Sobre el cruce con FlyWeb: de los 556 solo **8 los modificó FlyWeb** (4 parches y 4 envoltorios); con el donante de 1.98 hay además **28 parches y 37 envoltorios** que FlyWeb modificó y Brave también cambió y que chocan (`b2-donante.py`; §10.3 daba 25 y 35 sobre ac280a17df). 989 envoltorios y 412 parches son **sustituibles** por el de 1.98 sin pisar nada de FlyWeb.

### 11.4 Lo que hay que mirar a mano (por riesgo)

a. **Lo de FlyWeb que Brave ya no tiene, y que no se debe perder** [V salvo marca]:
   - `crypto/unexportable_key_metrics.cc` (FM.42 d2): FlyWeb apagó `kTpmLatencyMetrics` porque creaba, usaba y borraba una clave del Secure Enclave en cada arranque de un Mac con T2. Brave borró su parche ([cr155]). **En el fichero de 156, `MaybeMeasureTpmOperations` ya no tiene el feature y lanza la medición sin condición** [V, leído en el fichero de 156]: el cambio de FlyWeb **no se puede portar tal cual y hay que rehacerlo** (quién llama a esa función: [N]).
   - `components/os_crypt/sync/keychain_password_mac.mm` (**llavero «FlyWeb Safe Storage» / cuenta «FlyWeb»**, identidad fija de `CLAUDE.md`): Brave lo movió a `os_crypt/common` ([cr143]) y Chromium borró `os_crypt/sync` entero en la 149 (commit b8aa9d78b de Brave, «Remove sync backend» en Chromium). Además **`kUseAsyncOsCryptInLoginDatabase`, que FlyWeb enciende en FS.25 para las contraseñas `fw1`, ya no aparece en `password_features.cc` de 156** [V]; ha podido pasar a otro fichero o borrarse [N]. Detalle y plan de port en §11.8. Hay que repasar el camino `fw1` (parches de `login_database.cc`, `password_store_built_in_backend.cc` y cookies, más `os_crypt/async/common/encryptor.cc`) **antes de B3**: un error aquí es pérdida de contraseñas del usuario [I].
   - `components/captive_portal/.../captive_portal_service.cc`: FlyWeb apaga siempre la detección (Brave la fuerza y llama a su host). Brave lo pasó a plaster (b287783cd, 2026-08-06): **no hace falta rehacerlo**, el envoltorio de FlyWeb vale tal cual en 156 (§11.8.3).
   - `ui/base/cocoa/permissions_utils.mm` (compat <10.15, FM.42 c2): **ya no hace falta**: el fichero de 156 devuelve `false` si `macos_version < 14'00'00` [V].
   - IDL de canvas (`lang` con `RuntimeEnabled=CanvasTextLang`, nivel de motor): [cr133] Chromium fusionó los IDL; con la base 156 el atributo ya viene de upstream [I].
   - `tab_hover_card_bubble_view.cc` («flyweb://» en la tarjeta): [cr148] la movió de sitio; re-anclar.
b. **«Only use brave:// scheme for display» (#34610, 2026-03-20)**: Brave convierte `brave://` a `chrome://` lo antes posible y solo muestra `brave://`. Quitó 9 ficheros por ello (3 parches y 6 envoltorios) (`extension_tab_util`, `web_ui_impl`, `render_thread_impl`, `history_utils`, `profile_io_data`…). Afecta a cómo FlyWeb muestra `flyweb://`; **no se puede decidir en papel**: leer el diff de ese commit.
c. **Reversiones de Brave que reabren funciones de Chromium** (regla 20, privacidad): «Revert "Disables Tracking Protection Onboarding"» y «Revert "Explicitly disable search engine choice flag check"»: los envoltorios que lo apagaban ya no existen en 1.98. Si FlyWeb quiere esas funciones apagadas, el cambio es **nuestro** y hay que decidir si se mantiene.
d. **WebUI (34 parches «se reescribe»)**: depende de P5 (§5), no del coste técnico.
e. **Sync**: [sync] `ModelType` → `DataType` renombra tipos en `components/sync/engine` (2 envoltorios, 1 parche) y en el código de `brave_sync` (101 ficheros, §10.2) [V]; **entra en el porte, no es opcional**.

### 11.5 Medida de papel de P2: ¿aplican los parches de Brave sobre 156?

`git apply --check` de cada parche **de Brave** (579 de los 590; no se probaron los 11 de subrepositorios: v8 2, `third_party/catapult` 8, `devtools-frontend` 1) sobre el fichero de Chromium 156, sin los demás parches [V, `datos/b2-aplica-579.tsv`]:

| | Parches |
|---|---|
| El fichero de Chromium que parchean **existe en 156** | 521 de 579 (los otros 58: renombrado o borrado) |
| El parche de 1.69 aplica **tal cual** | 198 (38 % de los 521) |
| Aplica con una línea menos de contexto (`-C1`; incluye los 198) | 323 (62 %) |
| No aplica ni así | 198 (38 %) |
| Con donante en 1.98 y objetivo en 156 | 441; el parche de 1.98 **aplica en los 441** (control: valida el método) |

Esto es una **cota de papel** («el hueco existe»), no «compila»: un parche que aplica puede no compilar y uno que no aplica puede arreglarse con un retoque. Aun así da orden de magnitud: **sin donante, ~200 parches de Brave habría que rehacer; con donante, el trabajo se reduce a los que FlyWeb tocó** (28 chocan) **y a los que Brave quitó** (§11.2). Los envoltorios no se midieron igual [N] (no hay equivalente barato de «aplica»).

### 11.6 Poda (P1) preparada y medida (P2)

Plan mecánico sobre `flyweb` 5fdeb23d6, solo escritorio (`b2-poda.py`; `datos/poda-*.tsv`; clasificación por ruta, heurística como P0): **74 directorios** que son ≥ 90 % de una función muerta (6 004 ficheros de código y pruebas), **217 costuras** (ficheros vivos que incluyen o dependen de código muerto; P0 daba 223 sobre ac280a17df) y **582 líneas de `BUILD.gn`/`.gni`/`DEPS`** que enlazan con directorios muertos.

| Función | Directorios | Ficheros | Costuras | Líneas GN/DEPS (ficheros) |
|---|---|---|---|---|
| IPFS | 1 | 10 | 3 | 2 (2) |
| Player, PSST, WebCompat, DayZero | 8 | 84 | 18 | 28 (8) |
| News | 3 | 147 | 25 | 15 (8) |
| Leo / AI Rewriter | 8 | 209 | 76 | 83 (21) |
| P3A, stats, métricas | 10 | 194 | 65 | 62 (18) |
| VPN | 4 | 254 | 60 | 74 (23) |
| Wallet (+ Web3, IPFS-DNS, Filecoin) | 14 | 1 689 | 67 | 146 (22) |
| Rewards, Ads, SKUs, CBR, referidos, Greaselion | 26 | 3 417 | 82 | 172 (24) |
| **Total** (con solapes en costuras) | **74** | **6 004** | **217** | **582** |

Orden propuesto (hojas → acopladas, un commit por función, cada uno revertible): IPFS → Player/PSST/WebCompat → News → Leo → P3A/stats → VPN → Wallet → Rewards/Ads/SKUs. **Puerta de cada paso** (en 128, LOCAL): `gn gen --check` sin errores nuevos; `ninja brave` compila; la app arranca igual; `network-audit.py` sin cambios; `strings` sin `bsg.brave.com`; tabla antes/después de ficheros y parches. Lo que **no** se puede decidir en papel: Tor, Speedreader, Playlist y Sidebar (sin decisión de Titín: 11 de los 19 envoltorios de interfaz de §11.3 son del panel lateral); cadenas de `.grd`/`.xtb` (se podan con `chromium-rebase-l10n.py`, no a mano); el `third_party/rust` de las funciones muertas (`zcash*`, `orchard`, `challenge_bypass_ristretto*`…); y los *mojom* y recursos WebUI compartidos.
Nota de «apagar, no borrar» (Titín, 03-11): la poda **revoca** esa regla para lo ya apagado y **requiere su sí** (§8 punto 2).

### 11.7 Receta de la medida B2 (para MOTOR o LOCAL, cuando LOCAL tenga el 156 limpio de B1)

**Variantes.** (A) `flyweb` 5fdeb23d6 sin podar; (C) A + poda §11.6 en la rama `b2/podado`; cada una **sin donante** (S) y **con donante** (D: sustituibles de `b2-donante.py`). La puerta necesita **A-S y C-S** (§6); **C-D** mide lo que ahorra 1.98 (§10.4.3).
**Insumos fijos:** Chromium **156.0.8078.80** (`fb096c0011f9d50f0a264a9376420cdea9c421e3`) limpio de B1, **en una copia** (`cp -c`, APFS) para no tocar B1; `flyweb` 5fdeb23d6; `v1.98.63` de `brave/brave-core` (donante, solo lectura). Una sola compilación a la vez en la 7,1; con `nohup` y registro.
1. **Rama de medida.** `git clone --shared` de brave-core en `src/brave` de la copia; rama `b2/<A|C>-<S|D>`. Dejar en `patches/` **solo los parches de Brave**: `comm -12 <(git ls-tree -r --name-only v1.69.168 patches) <(git ls-tree -r --name-only origin/flyweb patches)` (590; los 1 267 de motor Blink/V8 son de otra capa y no se miden aquí). Para D: copiar de 1.98 los `sustituible` y anotar los `choque`.
2. **Parches.** `npm run apply_patches` (`build/commands/scripts/commands.js`; no `gclient sync`). **Medida 1** = parches que fallan (esperado según §11.5: ~198 de 521 más los 58 sin objetivo, **para A-S**). Los fallidos se quedan fuera y se anotan; no se arreglan.
3. **GN.** `gn gen out/B2` con los argumentos de `FlyWeb/scripts/build.sh` más `is_component_build=true symbol_level=0 blink_symbol_level=0 treat_warnings_as_errors=false mac_deployment_target="10.14"` y el SDK de B1; luego `gn gen --check`. GN se detiene en errores: **cada fichero GN que hay que tocar se cuenta (Medida 2) y se arregla con el cambio mínimo** (comentar la línea), un commit por fichero en `b2/…`. Esperados: `third_party/rust/*/BUILD.gn` de 128 que en 156 cambiaron ([cr134], [cr136], [cr137], [cr153]; §11.2) y los argumentos que Brave 1.98 ya no reenvía (§10.4.5).
4. **Compilar sin parar.** `autoninja -C out/B2 -k 0 brave 2>&1 | tee b2-<variante>.log`; hito: ninja termina (todo compilado o fallado). Un error en una cabecera tumba muchas unidades: por eso la medida es **por fichero**, no por error.
5. **Contar.** `python3 -I b2-cuenta.py b2-<variante>.log lista-parcheados.txt > b2-<variante>.tsv` (la lista = los ficheros de Chromium que tocan los parches que sí aplicaron: `git -C src diff --name-only`). Da, una vez por fichero roto: `gn`, `brave_falta` (cabecera de `brave/` inexistente: poda incompleta o donante incompatible), `brave`, `envoltorio`, `parcheado`, `chromium_via_brave` y el recuento de símbolos sin enlazar. Probado con un registro sintético (cada categoría sale una vez) [V]; **no probado contra un registro real** [N].
6. **Reglas de lectura.** El número de la puerta es **ficheros rotos de `brave/` + envoltorios + parcheados + `gn`** (A-S frente a C-S). Los `brave_falta` se informan **aparte**: en C son costuras que faltan por podar (no rompe 156); en D, donante que usa código de 1.98. Si un fichero de `chromium_via_brave` apunta a una cabecera de Chromium cambiada, anotar cuál (suele cubrir 20–40 ficheros).
7. **Entrega.** Tabla variante × categoría en `brave-propio.md` §11 y los `.tsv` en `datos/`; **no se arregla ningún fichero fuera de GN**: B2 mide, B4/B5 arreglan.
Criterio de validez: `apply_patches` de A-S sobre una copia limpia da **el mismo número de fallos que §11.5** (si no, el árbol de B1 no es 156.0.8078.80 limpio).

### 11.8 Los tres cambios propios de FlyWeb: qué hacen en la 128, qué cambió en Chromium y cómo se portan a la 156

Encargo de COORDINACIÓN-25 (03-11, tras #722). **Papel**: nada compilado ni ejecutado. Fuentes: ficheros de Chromium 128.0.6613.138 y 156.0.8078.80 (`raw.githubusercontent.com/chromium/chromium`), historial de Chromium desde 2024-08-01 (sin árboles; **solo búsqueda por mensaje de commit**: los hashes citados son [V], pero qué líneas tocó cada uno es [I] salvo que se diga), `FlyWeb/docs/fw1-migracion.md` y los ficheros de `flyweb` 5fdeb23d6. Pruebas de aplicación: `git apply --check` de cada parche de FlyWeb sobre el fichero de 156 (control en 128: todos aplican).

#### 11.8.1 Clave del Secure Enclave (FM.42 d2)

| | |
|---|---|
| **Hoy (128)** | `crypto/unexportable_key_metrics.cc`: `MaybeMeasureTpmOperations` estaba tras `kTpmLatencyMetrics` (encendida por defecto); el parche de FlyWeb la deja **apagada**. Se llama desde `chrome_browser_main_extra_parts_metrics.cc:862` al arrancar (Win y Mac). Con la medición activa se crea, usa y borra una clave en el Secure Enclave de los Mac con T2 en cada arranque |
| **Upstream** | e6909845c3 (2025-02-06) «[Code Health] Remove stale feature flag kTpmLatencyMetrics»: la función **lanza siempre** la medición [V: fichero de 156, líneas 410–416]. La llamada sigue en `chrome_browser_main_extra_parts_metrics.cc:946` con `unexportable_keys::GetDefaultConfig()` [V]. `MeasureVirtualTpmOperations` crea y borra la clave (`DeleteKey()`) [V]. Brave quitó su parche por esto mismo ([cr155] «ECDSA_SHA384 patches not needed anymore»); **nuestro cambio sobrevive solo en `flyweb` y no lo cubre ningún donante** |
| **Port a 156** | El parche actual **no aplica** (el feature no existe). Propuesta: **envoltorio en `chromium_src/crypto/unexportable_key_metrics.cc`** que renombra la función de Chromium (`#define MaybeMeasureTpmOperations MaybeMeasureTpmOperations_ChromiumImpl`) y define después una `MaybeMeasureTpmOperations` vacía; cero parches, un solo fichero estable (en el fork propio: un commit `Flynk-Class: privacy`). Alternativa peor: quitar la llamada de `chrome_browser_main_extra_parts_metrics.cc`, fichero que cambia casi cada hito |
| **Riesgo de migración de perfiles** | **Ninguno**: no hay datos guardados; es un comportamiento. Si se olvida el port, el efecto es el de antes del 2.5: una clave del Secure Enclave por arranque y, en Mac sin T2, nada [I] |
| **Aparte** [N] | 156 también tiene **Device Bound Session Credentials** (`dbsc`, p. ej. 60f88a6c38 «Use application tag for key deletion», 2025-11-12), que usan claves no exportables si una web las pide. Falta decidir si FlyWeb las apaga (regla 20, huella y llavero) |

#### 11.8.2 Llavero `fw1` y «FlyWeb Safe Storage» (FS.25; contraseñas y cookies cifradas desde la 2.5.0)

**Lo que hay hoy (128, `flyweb`)**, de `fw1-migracion.md` y del código: (1) proveedor `Fw1KeyProvider` (`components/flyweb_os_crypt/`: clave AES-256-GCM aleatoria en el llavero, servicio «FlyWeb Safe Storage», cuenta **«FlyWeb fw1»**, etiqueta `fw1`, precedencia 20) sobre `crypto::AppleKeychain`; (2) registro en `browser_process_impl.cc` (envoltorio + parche de 1 línea); (3) guarda en `Encryptor::DecryptData` para que un dato `fw1` sin clave falle en vez de caer a OSCrypt síncrono; (4) `kUseAsyncOsCryptInLoginDatabase` encendida (contraseñas por el `Encryptor`); (5) `built_in_backend.cc` con `Encryptor::Option::kNone`; (6) `DeleteUndecryptableLogins` no borra filas `fw1`; (7) cookies: borrado **por fila** de las `fw1` ilegibles (parche de 116 líneas en `sqlite_persistent_cookie_store.cc`) en vez de todo el eTLD+1; (8) la clave **`v10`** (la de Chromium) vive en «FlyWeb Safe Storage» / cuenta «FlyWeb», por el envoltorio de `os_crypt/sync/keychain_password_mac.mm`.

**Qué cambió en Chromium entre la 128 y la 156** [V salvo marca; hashes y fechas de commits de Chromium]:
- **OSCrypt síncrono, borrado:** db4074165b (2026-04-13) «Remove os_crypt/async -> os_crypt/sync fallback»; 21b80f4fd6 y a4cab4afb4 (2026-04-17) «Remove usage of legacy sync backend» / «Remove sync backend»; antes, 1d6ef28c92 (2025-10-08) «Remove os_crypt/sync usage from components/password_manager». En 156 `login_database.cc` usa **solo** `os_crypt_async::Encryptor` y `Encryptor::DecryptData` **ya no tiene el *fallback***: lo que no casa con una etiqueta devuelve `nullopt`; con la etiqueta y la clave presente pero fallo → `nullopt` permanente; con la clave ausente → `nullopt` y `flags->temporarily_unavailable = true`.
- **API de proveedores:** `KeyProvider::KeyCallback` ahora lleva `base::expected<Key, KeyError>` (`kPermanentlyUnavailable` / `kTemporarilyUnavailable`; el comentario de upstream avisa de que «permanente» puede hacer que el llamante **borre** datos); desaparece `IsCompatibleWithOsCryptSync()` (1ac3e6cc97, 2025-02-03, y siguientes); `Encryptor` es `RefCounted` (`scoped_refptr`), no se mueve; `Encryptor::Option::kEncryptSyncCompat` eliminada (a741396bc8 2026-02-05; 83a7d11c36 2026-06-16).
- **Reescritura activa disponible:** `DecryptFlags::should_reencrypt = (proveedor del dato != proveedor de cifrado)`: upstream ya marca los `v10` para pasarlos a `fw1`.
- **Llavero:** `crypto::AppleKeychain` **ya no existe** en 156 (solo `crypto/apple/keychain_v2.*`): 158a2d2a54 (2026-02-06) «Unify MacOS Keychains» pasa OSCrypt, `KeychainPassword` y `KeychainKeyProvider` a `crypto::apple::KeychainV2` y **dice expresamente que el almacenamiento no cambia: «todos los datos siguen en el llavero tradicional basado en fichero»**; antes, 614a8ffdbf (2026-01-13) mueve `FindGenericPassword`/`AddGenericPassword` a `KeychainV2`, y e338af7ea7 (2026-02-12) «Cleanup Keychain V1».
- **Proveedor de la clave `v10` en Mac:** `KeychainKeyProvider` (etiqueta `v10`, precedencia 10), registrado en `browser_process_impl.cc` solo si `features::kUseKeychainKeyProvider` (**encendida por defecto**, `chrome_features.cc:59`). El nombre del ítem sale de `KeychainPassword::GetServiceName()/GetAccountName()` en **`components/os_crypt/common/keychain_password_mac.mm`** (ya no en `os_crypt/sync/`); los dos ganchos `BRAVE_GET_SERVICE_NAME` / `BRAVE_GET_ACCOUNT_NAME` de Brave 1.98 están en el mismo sitio de la función [V: parche de 1.98].
- **Contraseñas:** `kUseAsyncOsCryptInLoginDatabase` **no aparece** en `password_features.cc` de 156 (el cifrado asíncrono es el único). `DeleteUndecryptableLogins` sale si `!encryptor_->IsEncryptionAvailable()`, y esto ahora es «existe el proveedor de cifrado por defecto y tiene clave» [V]: con `fw1` como proveedor por defecto, **si la clave `fw1` no carga no se borra nada**.
- **Cookies:** la rama de descifrado de `sqlite_persistent_cookie_store.cc` sigue igual en lo esencial (fallo de `DecryptString` → `ok = false` → se pierde el grupo; línea 1046) [V]. Cómo recibe el servicio de red el `Encryptor` en 156: [N].

**Propuesta de port, pieza a pieza** (aplicación de los parches de FlyWeb sobre 156: encryptor ✗, built_in_backend ✗, cookies ✗, browser_process_impl ✗, login_database ✓) [V]:

| Pieza de FlyWeb | Acción en 156 | Por qué |
|---|---|---|
| Guarda en `encryptor.cc` (envoltorio + parche) | **Eliminar** | El *fallback* a OSCrypt ya no existe; un dato `fw1` sin clave devuelve `nullopt` por defecto [V] |
| `built_in_backend.cc` (`Option::kNone`) | **Eliminar** | La opción ya no existe [V] |
| `password_features.cc` (flag) | **Eliminar** | El flag ya no existe [V] |
| Guarda `fw1` en `DeleteUndecryptableLogins` | **Eliminar tras la prueba (5) de la puerta de abajo**; el parche aplica | Cubierto por `IsEncryptionAvailable()` si `fw1` es el proveedor por defecto [I: falta la prueba con la clave `v10` ausente y `fw1` presente] |
| Registro en `browser_process_impl.cc` | **Reanclar**: la macro va justo después del bloque `kUseKeychainKeyProvider` (línea ~1651 de 156), con `kPrecedence = 20` (> 10, para que `fw1` sea el de cifrado) | El parche no aplica por desplazamiento de contexto |
| `Fw1KeyProvider` | **Reescribir** sobre `crypto::apple::KeychainV2` (`FindGenericPassword`/`AddGenericPassword`), con el `KeyCallback` nuevo, sin `IsCompatibleWithOsCryptSync`. **Mismo servicio, misma cuenta «FlyWeb fw1», mismo formato** (256 bits en Base64, AES-256-GCM, etiqueta `fw1`). Ante denegación o llavero bloqueado: **`kTemporarilyUnavailable`**, nunca `Permanently`. Pruebas con `FakeKeychainV2` | `AppleKeychain` ya no existe [V]; el almacenamiento es el mismo [V: 158a2d2a54] |
| Envoltorio `os_crypt/sync/keychain_password_mac.mm` (nombre `v10`, importadores) | **Mover** a `chromium_src/components/os_crypt/common/keychain_password_mac.mm`; el `#include` pasa a `components/os_crypt/common/keychain_password_mac.h`; mantiene «FlyWeb Safe Storage» / «FlyWeb» y las ramas `--import-*` | Es **la pieza más delicada**: ver M1 |
| Parche de cookies por fila | **Reanclar a mano** (mismo propósito) | Sin él, una cookie `fw1` ilegible tira todas las del eTLD+1, también las `v10` legibles |

**Riesgos de migración de perfiles existentes** (ordenados por gravedad; «nadie puede perder contraseñas ni cookies»):

| # | Riesgo | Efecto si falla | Mitigación / prueba |
|---|---|---|---|
| M1 | El envoltorio del nombre `v10` no engancha en el fichero nuevo (o engancha con otro nombre): `KeychainPassword` usa «Chromium Safe Storage» y **crea una clave aleatoria nueva** [I: así lo hace el código de upstream si no encuentra el ítem] | Todo lo `v10` queda ilegible: cookies (se descarta el eTLD+1), contraseñas `v10` (se borran al limpiar las indescifrables) y todo lo no migrado de Web Data. **Es el peor caso: pérdida real** | (a) Prueba unitaria que lea `KeychainPassword::GetServiceName()/GetAccountName()` y compare con las constantes; (b) tras abrir un perfil envejecido con la 156, `security find-generic-password -s "Chromium Safe Storage"` **no debe existir** (y tampoco «Chrome Safe Storage»); (c) el número de ítems «FlyWeb Safe Storage» no cambia |
| M2 | `kUseKeychainKeyProvider` apagada (Finch, `variations` mal puesto, o un `--disable-features` heredado) | `KeychainKeyProvider` no se registra: lo `v10` no se puede leer | Probar con `chrome://flags`/histogramas que el proveedor `v10` carga; **no tocar el feature** (encendido por defecto [V]) |
| M3 | `Fw1KeyProvider` reescrito devuelve otra clave (otra cuenta, otro formato Base64 o longitud) | Cookies y contraseñas `fw1` (todas las escritas desde la 2.5.0) ilegibles | Prueba «golden»: un perfil **real de la 2.7.0** (copia, en local; no va al repo) abierto con la 156: contar `v10`/`fw1` con `FlyWeb/tools/fw1-perfil.sh` antes y después y comprobar que las sesiones de claude.ai y GitHub siguen y las contraseñas se autorrellenan |
| M4 | El ítem lo creó la API `SecKeychain` (2.5.0–2.7.0) y ahora se lee por `SecItem` | Diálogo de llavero al actualizar (no pérdida); si lo deniega, `fw1` no carga | Probar con la **Release firmada** (los binarios de prueba crean ítems con otra lista de acceso, `fw1-migracion.md` §3.9); en 10.14 y en 11+ |
| M5 | `KeyError::kPermanentlyUnavailable` donde debía ser temporal | El llamante puede **borrar** datos | Solo `Temporarily` salvo certeza; prueba con ítem borrado y con llavero denegado |
| M6 | Parche de cookies por fila no reanclado | Una cookie `fw1` ilegible tira todo su eTLD+1 (sesiones, no contraseñas) | Prueba 5 de `fw1-migracion.md` §3 (ítem corrupto) |
| M7 | Activar `should_reencrypt` (reescritura activa) a la vez que se cambia de base | Duplica el riesgo de la migración | **No activarlo en el mismo salto**; después, si se quiere |
| M8 | Vuelta atrás 156 → 2.7.0 | La 2.7.0 lee `fw1` y `v10` como hoy | Sin cambio de formato [V: `EncryptData` sigue anteponiendo la etiqueta] |

**Puerta propuesta** (hito, sin horas): perfil real de la 2.7.0, **copiado**, abierto con un build de 156 en la 6,1 y la 7,1: (1) `fw1-perfil.sh` da los mismos recuentos antes y después de un primer arranque, (2) sin diálogo de llavero nuevo, (3) no aparece ningún ítem «Chromium/Chrome Safe Storage», (4) sesiones y contraseñas intactas, (5) con el ítem `fw1` borrado a mano: no cae, no se borra ninguna contraseña. Si falla (1) o (3), **bloqueante** (pérdida de datos). Es la prueba 1–5 de `fw1-migracion.md` §3, aplicada a la 156.

#### 11.8.3 Captive portal siempre apagado

| | |
|---|---|
| **Hoy (128)** | `chromium_src/components/captive_portal/content/captive_portal_service.cc`: `#define DISABLED_FOR_TESTING DISABLED_FOR_TESTING && false`, de modo que `enabled_ = testing_state_ != DISABLED_FOR_TESTING && … && <pref>` es siempre `false`. Brave la fuerza encendida y la apunta a su host (`detectportal.brave-http-only.com`) |
| **Upstream** | La línea de `UpdateEnabledState()` es **idéntica en 156** (línea 241: `enabled_ = testing_state_ != DISABLED_FOR_TESTING && resolve_errors_with_web_service_.GetValue();`) y `DISABLED_FOR_TESTING` solo aparece ahí en el `.cc` [V]. Brave 1.98 lo reexpresa como *plaster* (`rewrite/components/captive_portal/content/captive_portal_service.cc.yaml`, b287783cd, 2026-08-06) para dejarla **siempre encendida**: es lo contrario de lo que queremos y no se toma |
| **Port a 156** | **Ninguno**: el envoltorio vale tal cual. En el fork propio pasa a ser un commit `privacy` sobre ese fichero. Añadir una prueba unitaria que compruebe `CaptivePortalService::enabled() == false` (si una subida futura reescribe la expresión, el envoltorio dejaría de apagarla **sin avisar**) |
| **Riesgo de migración** | **Ninguno**: sin datos guardados |

#### 11.8.4 Lo que sigue y lo que no sé

- **Hecho en papel:** los tres cambios entendidos con fuente, port propuesto y riesgos de migración. **No** hay nada compilado ni probado: el diseño de `Fw1KeyProvider` sobre `KeychainV2` es una propuesta [I] y la compatibilidad de `KeychainV2` con macOS 10.14 está sin comprobar [N] (en B1, vigilar `-Wunguarded-availability` en `crypto/apple/keychain_v2.mm`).
- **Falta [N]:** cómo recibe el servicio de red el `Encryptor` en 156 (cookies); si `KeychainKeyProvider` de 156 lee el ítem exactamente por servicio+cuenta de `KeychainPassword` (el `.mm` de 156 no se ha leído entero); el diff de e6909845c3 y de 158a2d2a54 (solo se leyeron los mensajes); qué hace `Encryptor` con datos `fw1` si el proveedor `fw1` devuelve `kTemporarilyUnavailable` y luego carga (el orden de arranque).
- **Quién:** MOTOR para el port (es motor y llavero, no Brave); SEGURIDAD-PORTES para la revisión de la regla 17 de `Fw1KeyProvider`; LOCAL para la puerta con el perfil real (Titín o LOCAL aportan la copia del perfil; **no** va a GitHub).

### 11.9 Estado y relevo

- **Hecho:** v1 (#706), P0 (#707), §10, **esto**: §11.1–11.7 (clasificación de los 556 ausentes con el commit de Brave que los quitó; medida de papel de los 579 parches; plan de poda medido; receta de B2) y §11.8 (los tres cambios propios de FlyWeb: Secure Enclave, llavero `fw1`, captive portal; encargo de COORDINACIÓN-25).
- **Falta:** (1) `gn desc` con LOCAL (qué se compila de verdad); (2) la compilación de B2 y B1 (LOCAL/MOTOR); (3) leer los diffs de los commits de §11.4 (b, c) y las 8 filas FlyWeb de §11.4(a); (4) leer el código de los cambios de §10.2 que se decidan traer; (5) la puerta de Titín (A/B/C) y su sí a la poda; (6) los envoltorios se midieron por nombre y por `#define`, no por «aplica» [N].
- **Trampas de método (nuevas):** (i) `git fetch <oid>` en un repo parcial de Chromium va de uno en uno (~20 s por blob): usar `curl` a `raw.githubusercontent.com/chromium/chromium/<etiqueta>/<ruta>` (0,4 s); (ii) `git log -M` en un repo sin blobs se queda calculando: usar `--no-renames` y comparar hashes de blob entre árboles; (iii) `git log --diff-filter=D --no-renames` con árboles funciona (1,6 s sobre 18 905 commits); (iv) el `master` del fork es 1.98.37 (28-09), no 1.98.63; (v) `pkill -f` con un patrón que aparece en la propia orden mata la shell.

## 12. Medida P2 (MOTOR-30, 05-11)

Medida real de B2 (receta §11.7) en Ubuntu por MOTOR-30, redactada por MOTOR-31. Datos en `FlyWeb/tools/brave-inventario/datos/p2/`
(`B2-entrega.txt` es el informe original). Marcas como en el resto: **[V]** medido; **[I]** inferencia; **[N]** sin medir.

### 12.1 Condiciones

- **Chromium 156.0.8078.90** (23b0e24adf), Linux x64. La receta pedía .80: los 10 parches que aplican en papel (§11.5) y no en real se achacan a esa diferencia [I].
  GN: `is_debug=false is_component_build=true symbol_level=0 blink_symbol_level=0 use_remoteexec=false treat_warnings_as_errors=false`, más los args de Brave de `config.js` y los de `build.sh` válidos en Linux (en la poda, sin los que ya no se declaran).
- **Base** `flyweb` 5fdeb23d6f (2.7.0); **poda** `nube/b2-poda` 742e13ff (70 dirs + Tor + corte `.onion`). Ambas desde la misma 156 limpia y en el mismo orden: parches como `apply_patches`, `chromium-rebase-l10n`, `updateBranding`, los mismos arreglos de medida (lista 3) y `gn gen`.
- **Objetivos:** todo C++ y Rust de `brave/` y las unidades de Chromium con envoltorio o parche; no se compila `chrome` entero. `autoninja -k 0` con un `cc_wrapper` de medida que anota el fallo y deja seguir (Chromium se recompila sin envoltorio; Brave deja un objeto vacío). Lo bloqueado tras acciones de webui o Rust se compila desde `compdb`.
- **Recuento:** un fichero roto cuenta **una vez**, en la clase del fichero donde cae su primer error. Sin medir: crates Rust bloqueados (65 base, 17 poda).

### 12.2 Resultado [V]

| Ficheros rotos por clase | Base | Poda | Cambio |
|---|---|---|---|
| **Total** | **1 682** | **936** | **−746** |
| `brave` (código de Brave contra API de Chromium cambiada) | 1 281 | 584 | −697 |
| `chromium_src` (envoltorio o el original que incluye) | 253 | 251 | −2 |
| `brave_rust` | 77 | 43 | −34 |
| `generado_falta` (cabecera generada bloqueada) | 26 | 18 | −8 |
| `rust_chromium` (crate de Chromium que solo usa Brave) | 23 | 23 | 0 |
| `chromium_via_brave` | 20 | 16 | −4 |
| `otro` | 2 | 1 | −1 |

| | Base | Poda |
|---|---|---|
| Unidades C++ que fallan / objetivos | 2 713 / 3 834 | 1 319 / 1 811 |
| … con fuente en `brave/` | 2 187 / 3 069 | 799 / 1 054 |
| Parches de Brave (1.69) aplican / no aplican / sin objetivo | 196 / 336 / 58 (de 590) | 195 / 330 / 58 (de 583) |

De los 336 que no aplican en la base, 197 fallan del todo y 125 solo aplicarían con `-C1` (`apply_patches` no usa *fuzz*). Los 58 sin objetivo cuadran exactos con §11.5. **70 de los que no aplican son de GN**, entre ellos los que enganchan `brave/browser`, `brave/common` y `brave/renderer` a `chrome/`: sin ellos el grueso de Brave ni entra en el grafo.

**Lectura:** la poda quita el **44 %** de los ficheros rotos (754 desaparecen: 711 borrados y 43 que ya no fallan) y casi no toca `chromium_src` (−2): confirma §1.1, la poda reduce **compilación**, no **rebase**. La superficie real del porte es la **lista 1 (928)**, la **lista 3 (255)** y los ~330 parches.

### 12.3 Las tres listas

**Lista 2: rotos por la poda: 2** [V], ya arreglados en `nube/b2-poda` (4127545c):
- `browser/ntp_background/view_counter_service_factory.cc:82`: `sizeof` de tipo incompleto `NTPP3AHelper` (la cabecera llegaba por `ntp_p3a_helper_impl.h`, borrado con P3A). Arreglo: incluir `ntp_p3a_helper.h` (68828d14).
- `components/common/typescript.gni:25`: listaba `definitions/rewardsInternals.d.ts`, borrado con Rewards. Arreglo: quitar la línea (4e7a0118).

Ninguna unidad compila en la base y falla en la poda, ni hay `#include` de cabeceras borradas. Los 8 ficheros que salen rotos solo en la poda son de la 156: en la base su unidad caía antes por una cabecera de Ads o de la cartera [V].

**Lista 1: rotos por la 156 (en las dos variantes): 928** (`B2-lista1-rotos-por-la-156.tsv`). Clasificación por el primer error (MOTOR-31, regex sobre el texto; aproximada [I]):

| Causa | Ficheros | Ejemplos |
|---|---|---|
| Cabecera de Chromium quitada o movida | 241 | `base/containers/contains.h` 49, `base/ranges/algorithm.h` 35, `chrome/browser/ui/browser_finder.h` 18, `brave_components_resources.h` 14 (grit), `wtf/text/text_stream.h` 8, `scoped_testing_local_state.h` 6, `browser_list.h` 5 |
| Firma cambiada (argumentos, conversiones, definición fuera de línea) | 120 | `no viable conversion`, `FrameTreeNodeId`, `does not match any declaration` |
| Identificador o tipo desconocido | 117 | `String`/`WTF`/`AtomicString` de Blink 29, `Browser` 11, `ModelTypeSet` 4 |
| `base::Value::Dict`/`List` (la 156 quitó esa forma) | 80 | |
| `no member named` | 77 | `BrowserWindowInterface::profile` 19, `v8::Context::GetIsolate` 6, `GURL::host_piece` 5 |
| `override` sobre método que ya no es virtual (`KeyedServiceFactory`…) | 63 | 40 «hides virtual», 22 «only virtual» |
| `Browser` → `BrowserWindowInterface` | 37 | |
| `NOTREACHED_IN_MIGRATION` | 15 | |
| Rust (`custom attribute panicked`, `unsafe` traits) | 23 | crates de `chromium_crates_io` |
| Tipo incompleto, miembro privado, clase abstracta | 24 | |
| Otros | 101 | |

Por zona: `brave/browser/ui` 147, `chromium_src/chrome` 68, `chromium_src/components` 67, `third_party/rust` 43, `third_party/blink` 38, Shields (`components/brave_shields` 24 + `browser/brave_shields` 15), `browser/net` 23, `browser/extensions` 21, `ntp_background_images` 16, **Playlist 25** (`components` 16 + `browser` 9), `ephemeral_storage` 14, `omnibox` 14.

**Donante** (comparando los ficheros de la lista 1 con `master` del fork = **1.98.37**, no .63 [I: aproximación]): de los 825 de `brave/`, **633 tienen otra versión en 1.98** (Brave ya los adaptó), **188 no existen en 1.98** (Brave los movió o quitó: 43 crates de `chromium_crates_io`, 20 de `chromium_src/chrome/browser`, 13 de `browser/ui/views`, 16 de Playlist…) y **4 son iguales** (el donante no ayuda). 103 están fuera de `brave/` (Chromium o crates).
**Repetida con .63 (MOTOR-32, T0) [V]:** 632 distintos, 189 ausentes (además, `components/assist_ranker/ranker_model_loader_impl_unittest.cc`) y 4 iguales: las cifras casi no cambian. Pero de los 636 que están en las dos, **116 cambian de contenido entre .37 y .63** (sobre todo pruebas; también `about_flags.cc`, `brave_content_browser_client.h`, `brave_proxying_url_loader_factory`, omnibox, `ntp_background_images`, commander y playlist). En el árbol entero hay 2 698 distintos, 319 solo en .63 y 78 solo en .37. **El donante es .63**, no el `master` del fork.

**Lista 3: herramientas, generación y arreglos de medida: 255**, todas «arreglo de medida, **rehacer en el porte**» (`B2-lista3-arreglos-de-medida.tsv`). Lo que se repite: 64 parches GN puestos a mano, 44 líneas de Brave comentadas, 28 crates de Brave duplicados en la 156 (pasan a reenviar al de Chromium), 35 dependencias Rust sin resolver (`quote`, `proc_macro`), 7 visibilidades, 6 fuentes de Chromium desaparecidas, 4 crates `testonly`. Lo que **bloquea todo el árbol**:
- `redirect_cc` (la herramienta de `chromium_src`) no compila en la 156 (`base::Contains`, `StringPieceType`, `make_span`, `Environment::GetVar`).
- `mojom_parser.py` de `chromium_src` (firma de `_ParseAstHelper`); la 156 valida atributos de mojom: `[BraveAdd]`/`[BraveExtend]` y `[Native]` de `brave.mojom` (tumbaba `network_service.mojom`).
- grit de la 156: `chromeos_ash` → `is_chromeos` (22 grd/grdp), `output_all_resource_defines` desaparece (12 grd y `gen-webpack-grd.js`), variantes de género, `resource_ids.spec`, 80 `.xtb` de locales nuevos.
- `updateBranding` pega sobre la 156 los `.grd` de la 128: hay que pasar `chromium-rebase-l10n` en cada rebase.
- `function_registration` exige `<ns>/<ns>_api.h` (7 cabeceras de reenvío).
- Envoltorios de `base` que bloquean `libbase.so`: `json_reader.h` y `feature_list.cc` (la macro de `default_state` hay que rehacerla).
- Webui: `cr_elements/BUILD.gn` y `aggregate_vector_icons.py` (parches que no aplican); sin resolver: `build_ts` de settings, password_manager y bookmarks, `brave_new_tab`, `brave_welcome`, web-discovery-project.
- GN: un ciclo nuevo `content → language_detection → optimization_guide → unified_consent → sync → brave_sync → content`; objetivos de Chromium desaparecidos (`os_crypt/sync`, `flags_ui`, `companion`, `privacy_budget`, `ppapi`…); la 156 ya trae `brave_search_suggestion_parser.cc`.

### 12.4 Rust: el donante resuelve Shields [V]

Los crates de Brave que fallan dependen de crates que la 156 ya no trae (`syn 1`, `rand 0.7/0.8`, `rand_core 0.5/0.6`, `base64 0.13`, `getrandom 0.1/0.2`…; tabla en `B2-rust-donante.txt`). **El adblock 0.13.3 de 1.98 (cierre de 61 crates) solo usa `syn 2.0.119` y `3.0.5`, los de la 156. Shields se porta tomando el adblock 0.13.3 de 1.98 y su cierre**, no vendorizando los viejos (adblock 0.8.11, cssparser 0.27/0.28, selectors 0.22/0.23, html5ever 0.25). En 1.98 solo siguen con `syn 1` async-trait, data-encoding-macro-internal, derive_more 0.99, ff_derive y pin-project-internal, todos de la cartera y zcash, ya podados.
Coste a vigilar [I]: adblock 0.8 → 0.13 cambia la API que usa `components/brave_shields/adblock/rs` (FFI cxx); el envoltorio de 1.98 es el donante natural.

### 12.5 `.onion` y Mac

- **`.onion` fuera del DNS** (RFC 7686): el envoltorio `chromium_src/net/dns/host_resolver_manager.cc` compila en la 156 y **pasa** con control negativo (`B2-onion-prueba.txt`): `x.onion`, `X.ONION.`, `onion` y `a.b.onion` dan `ERR_NAME_NOT_RESOLVED` **sin consulta**; con el filtro anulado, tres de ellos llegan al resolutor. No es `net_unittests` ni `tcpdump` [N]. La rama `source=MULTICAST_DNS` (`IsValidDnsName`) no pasaba por el filtro: **cortada también** en 4127545c (sin medir aún).
- **Para LOCAL:** en Linux no se compilan los **50 `.mm` de escritorio** de la poda (`B2-mac-mm-para-LOCAL.txt`): entre ellos `keystone_glue`, `sparkle_glue`, `fw1_key_provider_mac` (llavero `fw1`, §11.8), `keychain_password_mac`, los marcos de ventana y 24 envoltorios `chromium_src` de Cocoa. Su medida es de LOCAL en la 7,1.

### 12.6 Plan del porte de la lista 1 (propuesta de MOTOR-31; **no empezado**, espera aprobación)

Principio: **tandas por causa común**, no por directorio, para que cada tanda sea mecánica, revisable y **medible por MOTOR-30** con la misma receta (§12.1) y el mismo recuento. Cada tanda: rama `nube/b2-porte-tN` encima de la anterior; commits por causa; entrega = sha + cifra esperada; MOTOR-30 vuelve a compilar y da la lista 1 nueva y la lista 2 de regresiones (debe ser 0). **Donante:** donde el fichero existe distinto en 1.98, se toma el cambio de Brave de ese fichero (diff 1.69 → 1.98 acotado a la causa de la tanda), no el fichero entero, para no arrastrar funciones nuevas de 1.98; se reaplican las ediciones de FlyWeb (rebranding, `flyweb://`, constantes) y se vigilan las regresiones silenciosas de §2.3.

| Tanda | Qué | Ficheros (lista 1) | Donante | Riesgo |
|---|---|---|---|---|
| **T0** | **Lista 3 hecha bien** (no es lista 1, pero bloquea todo): `redirect_cc`, `mojom_parser.py` y atributos `[BraveAdd]`/`[BraveExtend]`/`[Native]`, grit (`is_chromeos`, `output_all_resource_defines`, géneros, `resource_ids.spec`, `.xtb` nuevos), `chromium-rebase-l10n` dentro de `updateBranding`, cabeceras `_api.h`, envoltorios de `base` (`json_reader.h`, `feature_list.cc`), los 70 parches GN rehechos como commits, Rust en GN (visibilidades, 28 duplicados → reenvío, `testonly`), ciclo `brave_sync`. Hito: `gn gen --check` limpio **sin** arreglos de medida | 255 (lista 3) | 1.98 tiene todas estas herramientas ya en 15x | alto: es la base de todo; sin ella la medida no es fiable |
| **T1** | Renombres mecánicos de `base`/URL: `base/containers/contains.h` y `base/ranges/algorithm.h` → `std::ranges`, `NOTREACHED_IN_MIGRATION` → `NOTREACHED()`, `GURL::*_piece` → `host()`/`path()`, `StringPieceType`, `cxx23_to_underlying` → `std::to_underlying`, `base::NullCallback`, `StringPrintf` | ~120 | sí (sustituciones iguales en 1.98) | bajo; con guion y revisión de diff |
| **T2** | `base::Value::Dict`/`List` → la forma de la 156 (`base::DictValue`/`base::ListValue`, clases propias en `base/values.h` de la 156 [V]) | ~80 | sí: 63 de 80 | bajo-medio: hay sobrecargas y *mojom* con `Value` |
| **T3** | Blink: `WTF::String`/`AtomicString`/`text_stream.h` (WTF absorbido en `blink`), `v8::Context::GetIsolate`, `WebString::FromUTF8` | ~45 | sí: 29 de 30 | medio: toca farbling y los parches del motor (`brave-vs-parches-motor`) |
| **T4** | `KeyedServiceFactory` y factorías: `override` sobre métodos ya no virtuales → la API nueva (`BuildServiceInstanceForBrowserContext` con `unique_ptr`, `ProfileKeyedServiceFactory`) | ~63 | sí: 52 de 63 | bajo-medio |
| **T5** | Interfaz: `Browser` → `BrowserWindowInterface` (`profile()` 19, `browser_finder.h`/`browser_list.h` 23), `BrowserFrame`, `browser_navigator*`, `read_later_side_panel_web_view`, `browser_non_client_frame_view` | ~150 (`browser/ui` 147) | sí: la mayoría | **alto**: es la «capa de interfaz» que Titín quiere rehacer; propongo portarla **mínima** (compilar y arrancar) y no traer el rediseño de 1.98 |
| **T6** | Shields y privacidad: adblock 0.13.3 de 1.98 y su cierre (§12.4), FFI de `brave_shields/adblock/rs`, `brave_shields` C++, `ephemeral_storage`, `content_settings`, `permissions`, `net` (`FirstPartySetMetadata`, `CookiesNewInfo`, `PartitionKey`), `query_filter`, `debounce`, `de_amp` | ~110 + 43 Rust | sí | **alto** en valor: es lo que FlyWeb conserva; prueba funcional de Shields después (listas propias de `components.flyweb`) |
| **T7** | Sync y cuentas: `ModelTypeSet` → `DataTypeSet`, `AccountConsistencyMethod`, `os_crypt/sync` desaparecido (cruce con §11.8: `fw1`, llavero) | ~25 | sí | alto: datos del usuario; revisar con §11.8 |
| **T8** | `chromium_src` restante (lo que no cayó en T1–T7): envoltorio a envoltorio, con el *plaster* o el envoltorio de 1.98 como donante | ~120 de 251 [I] | 1.98 (envoltorios y 767 *plasters*) | medio: cada `#define` puede dejar de aplicar **sin error** (§11.8: captive portal); añadir prueba donde el envoltorio apague algo |
| **T9** | Los 188 **ausentes en 1.98**: decidir uno a uno (Brave lo quitó → ¿lo quitamos?, lo movió → seguir el movimiento) con el commit de Brave que lo quitó (§11.1). Incluye **Playlist (25)**, `webtorrent`, `ntp_widget_utils` | 188 (43 crates en T6) | el commit de 1.98 que lo movió o quitó | depende de decisiones de Titín |

Orden: **T0 → T1 → T2 → T4 → T3 → T6 → T7 → T5 → T8 → T9**: primero lo mecánico y masivo (baja la cifra deprisa y despeja errores en cascada), después lo de más valor (Shields, sync) y al final la interfaz y lo que depende de decisiones.
**Decisiones que ahorran trabajo** (para COORDINACIÓN/Titín antes de T5/T9): Playlist (25 rotos), Speedreader, Sidebar, WebTorrent, Wayback, Commander y el NTP de Brave (sustituido por `flyweb_ntp`; 16 rotos en `ntp_background_images`). Cada «fuera» se poda como en B2 y quita sus rotos de la lista 1.
**Límites del plan:** la causa sale del **primer** error de cada fichero (puede esconder otros); el donante medido es 1.98.37, no .63; los ~330 parches de Brave y los ~1 267 del motor no están aquí (§11.5 y la capa de nivel), y Mac (50 `.mm`) lo mide LOCAL.

### 12.7 T0: lista 3 hecha bien (MOTOR-32, 05-11)

**brave-core `nube/b2-porte-t0` = 146eeddc** (48 commits sobre 4127545c; PR #9 en borrador). Sin compilar: medida pendiente de MOTOR-30 (`buzon/MOTOR`). Donante v1.98.63 (Chromium 156.0.8078.80). Los parches de Chromium que se tocan pasan `git apply --check` contra los ficheros de 156.0.8078.90 [V]. La comprobación estática (`b2-chk.py`, `py_compile`, JSON, `node --check`, llaves de GN) no da roturas nuevas respecto a la poda [V]. Hecho por seis subagentes en paralelo, uno por grupo, cada uno en su worktree.

| Grupo | Lista 3 | Estado |
|---|---|---|
| Herramientas | `redirect_cc` (a mano: 1.98 lo cambió por `-iquote`), `mojom_parser.py`, parche de `mojom_attributes_check.py` (`BraveAdd`/`BraveExtend`/`[Native]`), `json_reader`, `feature_list` (macro `default_state` rehecha para `IsCountrySpecificFeatureState`), `_api.h` por `custom_impl_schemas` (3 esquemas, no 10), `unsafe_buffers_paths.txt` como parche (arg quitado de `config.js`), `generate_blink`, iconos Leo | bien; `cr_shared_vars.css` depende de `cr_elements` (hecho) |
| grit y l10n | grd/grdp regenerados desde 156 con `chromium-rebase-l10n` (fuera `chromeos_ash` y `chromeos_lacros`); `output_all_resource_defines` quitado; `resource_ids.spec`; variantes de género sin el arg; los 81 locales cuadran sin xtb vacíos (el parche lee `components_chromium_strings`); xtb de 1.98 pasados a FlyWeb con `flyweb-rebrand-strings.py` (idempotente); `updateBranding` comprueba `app/CHROMIUM_L10N_VERSION` | bien; tamaños de `resource_ids.spec` estimados |
| Parches GN | Todos los de Brave en `chrome/`, `components/`, `base`, `build`, Blink, WebUI y `v8` aplican. Fuentes de Brave en `chrome/browser:core` (156 vacía `browser`). Lo de FlyWeb que 156 movió, en parches nuevos (eye_dropper, help). `prepopulated_engines` pasa a `third_party/search_engines_data`. Borrados como en 1.98: páginas WebUI que ahora son Lit, searchbox, `embedded_i18n`, `rust_target`, `google_update` | bien; Android parcial (Java/bytecode) |
| Rust | Crates solo de lo podado, borrados (188 directorios); 12 duplicados reenviados a Chromium; vendorizados syn 1, rand 0.8, rand_core 0.6, rand_chacha 0.3, getrandom 0.2, ppv_lite86, rustc_version, semver y base64 0.13 (este solo para adblock 0.8, hasta T6); visibilidad por `cargo_crate.gni` | bien; sin `[patch]` en `Cargo.toml` (un `gnrt gen` los pisaría) |
| GN de Brave | Deps movidas seguidas (flags_ui → `webui/flags`, searchbox → `omnibox/browser`, `native_ui_types`, `user_agent`…); ciclo `brave_sync` roto como en 1.98 (`NetworkTimeHelper` recibe el task runner); `include_polymer` como en 1.98; 156 ya trae el parser de Brave Search | bien; `os_crypt/sync` → `async` solo en GN (el C++ es de T7) |

**Fuera de T0, siguen sin aplicar:**
- Los parches GN propios de FlyWeb del motor (Blink core, `certificate_transparency`, `color`, `eye_dropper`, `dragonbox`, `fast_float`, `simdutf`, boringssl y mojom de network).
- `components-os_crypt-sync-BUILD.gn` (T7, con §11.8).
- `prepopulated_engines.json` (en 156 vive en el repo aparte `third_party/search_engines_data/resources`).

**Cifra esperada [I]:** caen unos 41 crates de Rust, unos 5 de omnibox y `json_reader.cc`; la lista 3 debería quedar sin entradas a mano.
**Avisos para la tanda de TS/C++:** los parches TS de las páginas WebUI que en 156 son Lit siguen en el árbol y romperán tsc; `components/flyweb_os_crypt` y `browser/test` siguen con `os_crypt/sync` (solo Mac: LOCAL).


### 12.8 T3: Blink/V8 y poda de Page Graph (MOTOR-33, 05-11)

brave-core `nube/b2-porte-t3` = **8b2de20e** (PR brave-core #13, borrador; 837c44f3 + T3-bis 078fe70b: `update_client` y browsertest de device memory + T3-ter: canvas, `partitioned_host_state_map`, `RandIntInclusive`), sobre T4 corregido (2dec767d: `//brave/build:compiler`
primero en `default_compiler_configs` y arreglos de `gn gen`, de MOTOR-32). 23 commits, sin compilar; `b2-chk.py` igual que en T4.
Antes van T1 (5d7b856a, #10), T2 (7a6e1577, #11) y T4 (dbc5fbd5 → 2dec767d, #12), descritas en `relevo-motor.md`.

- **Page Graph podado** (COORDINACIÓN-28, 05-11: instrumentación de investigación de Brave, ni privacidad ni interfaz). Seis
  commits revertibles: motor (`third_party/blink/renderer/core/brave_page_graph`, `components/brave_page_graph`), buildflags y args
  `enable_brave_page_graph*` de `config.js`, ganchos de `chromium_src` en Blink y en V8 (`//brave/v8` y `chromium_src/v8/src` enteros),
  pegamento de codegen (probes, bindings), 13 parches borrados y 3 recortados, comandos de DevTools. 242 ficheros, −14 700 líneas.
- **Blink/V8 de 156**: `blink::String`/`AtomicString` (WTF absorbido), `FromUtf8`, `ends_with`, `v8::Context::GetIsolate`
  (safe_builtins, brave_search, cosmetic_filters; `WebScriptController::RegisterExtension` ya no existe, como en 1.98), tipos de
  permissions policy en `network::mojom` (parche nuevo de `services/network/.../permissions_policy_features.json5`),
  `Location::ancestorOrigins`, WebSocketChannelImpl, ResourceFetcher, `IDLMemberInstaller`, mixed content `.onion`,
  `BraveSessionCache` con `crypto::hmac` (misma clave y datos: las semillas deberían salir iguales [I]).
- **Farbling conservado**: canvas 2D (`isPointInPath`/`isPointInStroke` pasan a `Canvas2DRecorderContext`, como en 1.98; se
  mantienen la excepción de Google Maps y `bytes_per_channel` de FlyWeb), plugins (lista fija de visores PDF en 156: se farblea en el
  constructor), device memory (156 limita a 2–32 GB: valores falsos en {2, 4, 8, 16, 32}), lista blanca de fuentes.

**Cifra esperada [I]:** caen unos 75 de los 80 de T3 en la lista 1 (32 de Page Graph, ~43 de Blink/V8).
**Quedan:** 4 contextos de permisos (API `PermissionDecided` de 156: T6), `ephemeral_storage_blink_memory_cache_browsertest` (T5).
- **T3-bis**: `chromium_src/components/update_client` (ancla de `IsBraveComponent()` en `Uninstall()`, porque en 156
  `GetInstalledFile` devuelve `std::optional<FilePath>`; `SequentialUpdateChecker` con la API de 156; el recorte de FlyWeb de
  `MakeProtocolRequest` sigue valiendo) y browsertest de device memory con los valores de 1.98 (mismo PRNG randen) [I].

**BLOQUEANTE de T8 (privacidad; COORDINACIÓN-28, 05-11):** se quitaron 18 overrides de `blink::features` que ya no existen en 156 (SharedStorage*, PrivateAggregation,
Fledge*, InterestGroupStorage…); 1.98 los apaga con el parche de `runtime_enabled_features.json5` (`base_feature_status: "disabled"`).
Hasta portarlo, esas APIs de Privacy Sandbox podrían quedar encendidas. T8 no se da por hecha sin ese parche y una prueba JS que
compruebe que no existen en `window`/`document` (`sharedStorage`, `fence`, `runAdAuction`/`joinAdInterestGroup`,
`browsingTopics`, `privateAggregation`, `attributionReporting`…).
- **T3-ter** (lo que afloró en la medida de 2dec767d): farbling de canvas `toDataURL`/`toBlob` con los parches de 1.98 (sin los
  backports de motor de FlyWeb, que la 156 ya trae; envoltorio de `image_data_buffer.h` para `pixmap_multable()`; los bytes por
  canal del F16 salen ahora del pixmap del propio búfer), `partitioned_host_state_map` sin `base::make_span`,
  `RandIntInclusive`. `websocket_channel_impl`: nada que cambiar (fallaba porque no aplicaba el parche del `.h`).

### 12.9 T6: Shields y privacidad (MOTOR-33, 05-11)

brave-core `nube/b2-porte-t6` = **820772ce** (PR brave-core #14, borrador, base T3). 23 commits, sin compilar; `b2-chk.py` igual.

- **Rust**: adblock 0.13.3 y su cierre de crates de 1.98; fuera los que solo usaba adblock 0.8 (base64 0.13, cssparser 0.28,
  selectors 0.23, itertools 0.10, seahash 3, rmp…); shims url 2/idna 1 de 1.98 sobre `//url`; `[patch]` en `Cargo.toml` hacia
  los 69 crates de 156; parches de aho-corasick y bitflags. La interfaz cxx no cambia; `cargo check` del FFI, limpio.
  Comportamiento: `:style`/`:remove*` se devuelven a los campos que lee el renderer (igual que antes); las procedurales y
  `$method` se parsean pero no se aplican (antes no se parseaban); el `.dat` serializado cambia de formato (FlyWeb carga
  `list.txt`).
- **C++**: permisos (`PermissionDecided`, `ContentSettingPermissionContextBase`; fuera las peticiones agrupadas de Wallet),
  content settings (`PermissionSettingsRegistry`), ephemeral storage y cookies en el network service, HSTS particionado,
  `URLRequestHttpJob`, envoltorios de `net`, HTTPS-Upgrades, throttles con `NavigationThrottleRegistry`, semillas de farbling
  con `crypto::hmac`, `BraveContentBrowserClient` con las firmas de 156, Web Bluetooth con `BraveBluetoothDelegate` (1.98).
  Se conservan los extras de FlyWeb (herencia de permisos en incógnito, tope de 7 días a las cookies de script, partición por
  NIK, fallback HTTPS con ≥400, HTTPS estricto en incógnito). Más estricto: `BraveIsAllowedThirdParty` con
  `SameDomainOrHost`. Se pierde (como en 1.98): la excepción de scripts chrome:// y de extensiones en `AllowScriptFromSource`.
- **Seguridad de 1.98**: el proxy de URLLoader de Brave rechaza `FollowRedirect` no pedidos (crbug 497494634) y destinos
  inseguros; las redirecciones propias usan `SetBypassRedirectChecksForNextRedirect` (parche nuevo de `navigation_handle.h`).
- **Pins HSTS de Brave**: inertes ya en la 128 y en la 156 (`PinsListTimestamp` de 09-2024, más de 70 días); todos de hosts
  de Brave. Propuesta: quitarlos en T9; pins propios, aparte.

**Cifra esperada [I]:** ~50 de Rust, ~95 de los 184 de Shields/privacidad. **Quedan:** `browser/ui` y `BrowserWindowInterface`
(T5), recursos grit, `temporal_capi` (sin causa clara), `ahash 0.7` (Speedreader, T9), `RegisterTrustedWebUIInterfaceBrokers`
y `HandleURLOverrideRewrite` (T5).

**Decisiones de COORDINACIÓN-28 sobre T6 (05-11):** pins estáticos de Brave fuera en T9; sin pins para `*.flyweb.lamosquita.net`
(un pin caducado o mal puesto deja el servicio inaccesible; bastan HSTS preload y CT). En T8, comprobar que con JavaScript
bloqueado en Shields siguen funcionando `chrome://settings`, la nueva pestaña y las extensiones (o portar la solución de 1.98).
**T6-bis (medida de T3, a28f8adf):** permisos de Wallet (ethereum/solana) quitados del todo en 7 commits (permissions policy,
`PermissionType`, `RequestType`, `ContentSettingsType`, ajustes, UMA con huecos «// Removed»); prefs `brave_ethereum`/`brave_solana`
huérfanas e inocuas. `safety_hub_handler_unittest` (macros que pisaban `PermissionName`) y `local_frame.cc` (`Snapshot` sin
`FlushReason`). Restos de Wallet para T9: Android (prompt, dapp), `wallet_strings.grdp`, allowlist `braveWallet`.

### 12.10 T7: sync, cuentas y `os_crypt` (MOTOR-33, 05-11)

brave-core `nube/b2-porte-t7` = **ff2fa26e** (PR brave-core #15, borrador, base T6 a28f8adf). 16 commits, sin compilar; `b2-chk.py` igual.

- **Sync**: `ModelType` → `DataType`, controladores de historial, `BraveDataTypeWorker` (parche nuevo), `SyncScheduler`,
  `sync_server_connection_manager` de 1.98 (la 156 rechaza el token con CRLF), device info con `SelfDeleteSupport`, prefs
  sincronizables (se mantiene `cosmeticFiltering`), signin con las promos apagadas.
- **Semilla**: misma pref (`brave_sync_v2.seed`) y base64, cifrada con el `Encryptor` de `os_crypt_async`; no se borra mientras el
  `Encryptor` no está listo (1.98). Palabras, tamaño y derivación sin cambios.
- **`os_crypt/sync` fuera**: nombres del llavero FlyWeb en `os_crypt/common/keychain_password_mac.mm` (v10: saltysalt, 1003
  iteraciones, AES-128-CBC); Linux, nombres de Brave en `FreedesktopSecretKeyProvider`.
- **Importer** → `user_data_importer`; sin contraseñas ni tarjetas de Chromium (OSCrypt síncrono; como 1.98).
- **Buscadores**: `prepopulated_engines.json` → `patches/third_party/search_engines_data/resources/` (lo aplica `util.js`);
  valores de FlyWeb (versión 29, DuckDuckGo sin `t=`); nuestro `startpage` pasa a `brave_startpage` (la 156 trae el suyo, id 113).

**Datos del usuario (para LOCAL, puerta M1–M5 de §11.8 con perfil real de la 2.x):** la guarda `fw1` de `encryptor.cc` desaparece;
falta reescribir `Fw1KeyProvider` para `os_crypt_async` (Mac). Un dato sin prefijo, o `fw1` sin proveedor, da `nullopt` (la 2.x lo
devolvía en claro). Una semilla que la 3.0 vuelva a guardar (solo al unirse a una cadena) puede no leerse en una vuelta atrás a la 2.x.
**Por decidir:** excluir `AUTOFILL_VALUABLE` del sync como 1.98, según lo que acepte go-sync.
**Cifra esperada [I]:** ~80 de 94. **Quedan para T5:** `identity_apitest`, `brave_sync_account_deleted_infobar`, `brave::ShowSync`
con `BrowserWindowInterface*`.

### 12.11 Nueva pestaña: medida previa a T5 (MOTOR-33, 05-11)

`components/flyweb_ntp` son **15 ficheros de recursos** (fuentes D-DIN, fondos 1–7 y de arranque, SVG de la mosca), sin código.
La nueva pestaña de la 2.7.0 es `components/brave_new_tab_ui` modificado (`default/flyweb/`), que importa esos recursos;
`brave_welcome_ui` también. Plan aprobado por COORDINACIÓN-28: (B) fuera en commits revertibles; (A) portado en su forma mínima.

- **(A) Se queda:** `flyweb_ntp`; núcleo de `brave_new_tab_ui` (`flyweb/`, mojom `brave_new_tab_page`); `browser/ui/webui/new_tab_page`
  (BraveNewTabUI, page handler, message handler, TopSites); de `ntp_background_images`, `view_counter_service`/`model`,
  `brave_ntp_custom_background_service`, `ntp_custom_images_source`, `url_constants`, `pref_names`; de `browser/ntp_background`, la
  fábrica, `custom_background_file_manager`, `ntp_background_prefs`, `constants`; `components/ntp_tiles`; prefs de reloj, stats,
  fondo y buscador, y sus cadenas.
- **(B) Se borra:** `ntp_widget_utils` (7); patrocinados y referidos (`component_installer`, `sponsored_images_*`,
  `ntp_background_images_source`, `ntp_p3a_helper`, `ntp_tab_helper`…; `NTPBackgroundImagesService` fuera si sale barato); en
  `brave_new_tab_ui`, ~35 muertos (exchangeWidget, popupMenu, braveTalk, brandedWallpaper, sponsoredImage(s), rewards_*,
  newTabAdsData, widgetCard, stories); ~16 de `components/img/newtab`; Android/iOS.
- **(C) Hay que tocar:** `brave_content_browser_client` (brokers, `NewTabShowsNavigationThrottle`), `brave_web_ui_controller_factory`,
  `brave_browser_process`, fábricas y tab helpers, registro y migraciones de prefs, settings `brave_new_tab_page`, BUILD y pruebas.

**Lista de comprobación visible (LOCAL, captura en B6 contra la 2.7.0):** diseño y tipografía D-DIN; fondos 1–7 rotando y fondo de
arranque en el primer inicio; mosca; sitios populares (añadir, quitar, reordenar); reloj (12/24 h); contador de Shields (anuncios,
rastreadores, HTTPS, ancho de banda); buscador si sale; fondo propio del usuario (subir, quitar, color); ajustes de la pestaña (mostrar
u ocultar cada elemento); sin rastro de patrocinados, Rewards, Talk ni News.

### 12.12 T7-bis: llavero y `os_crypt_async` (MOTOR-33 y MOTOR-34, 05-11)

brave-core `nube/b2-porte-t7` = **b02508af** (PR brave-core #15). MOTOR-33, 7b2a0a79: ff2fa26e + `AUTOFILL_VALUABLE` fuera del
sync (como 1.98; COORDINACIÓN-28) + `Fw1KeyProvider` para `os_crypt_async` + datos sin prefijo en claro. MOTOR-34, b02508af:
parches de la 128 que no aplicaban sobre 156, reanclados (cookies `fw1` por fila, ahora con el borrado por fila de cookies no
canónicas de la 156, y su prueba; `browser_process_impl.h`); guarda de `DeleteUndecryptableLogins` ampliada a `v10`; fuera el
parche de `password_store_built_in_backend.cc` y el override de `kUseAsyncOsCryptInLoginDatabase` (no existen en 156); browsertest
de nombres del llavero con «FlyWeb Safe Storage» / «FlyWeb» (M1 a). Todos pasan `git apply --check` sobre 156.0.8078.90. Sin
compilar ni ejecutar.

- **`Fw1KeyProvider`** (Mac) sobre `crypto::apple::KeychainV2` y el `KeyCallback` de 156: mismo ítem, clave Base64 de 256 bits,
  AES-256-GCM y etiqueta `fw1` que la 2.x; todo fallo da `kTemporarilyUnavailable`. Registrado en `browser_process_impl` (parche)
  con precedencia 20 (`v10`, 10). **Cifra con `fw1`** cuando su clave carga (como la 2.x); si no, `v10`.
- **Sin prefijo**: envoltorio de `Encryptor::DecryptData` (parche de una línea): en Mac y Linux, un dato sin prefijo conocido se
  devuelve en claro y marcado para recifrar, nunca `nullopt` silencioso. Pruebas: `fw1_key_provider_mac_unittest.mm`,
  `encryptor_legacy_unittest.cc`.
- **Contraseñas**: una fila `fw1` o `v10` que no se descifra **nunca se borra** (`IsEncryptionAvailable()` solo mira el proveedor
  de cifrado; con `fw1` cargada y `v10` denegada, la 156 habría borrado las `v10`).
- **Cookies**: una cookie `fw1` ilegible se borra sola (no su eTLD+1), también con el llavero denegado, como en la 2.x
  (COORDINACIÓN-28: confirmado; una sesión perdida se recupera). Una `v10` ilegible tira su eTLD+1 (upstream, como la 2.x).

**Tabla de casos para LOCAL (puerta M1–M5, perfil real de la 2.7.0)** — `DecryptString`, flags, con qué se recifra y qué pasa con
contraseñas y cookies:

| Dato | Situación | Devuelve | Flags | Recifra | Contraseña | Cookie |
|---|---|---|---|---|---|---|
| `fw1` | clave cargada | claro | — | fw1 | se lee | se lee |
| `fw1` | llavero denegado o bloqueado, ítem corrupto | error | temporalmente no disponible | v10 | no se borra | se borra esa cookie |
| `fw1` | otra clave en el ítem, o datos dañados | error | permanente | fw1 | no se borra | se borra esa cookie |
| `v10` | las dos claves cargadas | claro | recifrar (Chromium) | fw1 | se lee | se lee |
| `v10` | llavero de `v10` denegado | error | temporalmente no disponible | fw1 | no se borra | cae su eTLD+1 |
| `v10` | corrupto | error | permanente | — | no se borra | cae su eTLD+1 |
| sin prefijo (Mac/Linux) | algún proveedor registrado | **claro, tal cual** | recifrar | fw1 (o v10) | se lee | se lee |
| prefijo de proveedor no cargado (`v11`, `fw2`…) | — | error | — | — | no se borra si es `v10`/`fw1` | — |
| vacío | — | `""` | — | `""` | — | — |
| sin prefijo en Windows | — | error (como Chromium) | — | — | — | — |

**Para LOCAL, además de M1–M5:** tras el primer arranque no debe existir «Chromium Safe Storage» ni «Chrome Safe Storage»; los
recuentos de `FlyWeb/tools/fw1-perfil.sh` antes y después iguales; sesiones de claude.ai y GitHub y autorrelleno intactos; con
«FlyWeb fw1» denegado en el diálogo, ninguna contraseña desaparece.
**M7, decidido (COORDINACIÓN-28, 05-11):** se acepta que la 156 recifre a `fw1` lo que lea en `v10`; la 2.x ya escribía `fw1` y lo
lee, así que la vuelta atrás a la 2.x sigue funcionando.
**Dudoso, solo comprobable en Mac:** que `KeychainV2` (`SecItemCopyMatching`) lea sin diálogo nuevo el ítem creado con
`SecKeychain` por la 2.x, en una Release firmada en 10.14 (M4). Riesgo aceptado: un texto en claro antiguo que empiece por `vNN` o
`fwN` da error en vez de salir en claro. M2 sigue abierto (`kUseKeychainKeyProvider` apagada → sin `v10`).
**Para las notas de la 3.0.0:** volver de la 3.0 a la 2.x puede pedir otra vez las palabras de sync si la 3.0 reescribió la semilla.

### 12.13 T9: la capa de nivel de la 2.x en `patches/` (MOTOR-34, 05-11)

Encargo de COORDINACIÓN-29: los parches de nivel (funciones de Chrome ≥ 129 que la 156 ya trae) salen en T9; antes, esta lista de
los que **no** son de nivel, con su veredicto. Papel: sin compilar; la columna «156» es orientativa (líneas añadidas por el parche
que ya aparecen en el fichero de 156). La capa Mojave solo cubría 10.14 → 10.15; el 10.15 → 13 de Chromium 156 ya
está hecho y probado en `lamosquita-net/chromium` `flynk-b1d` (B1b/B1d, LOCAL), con lo que T10 solo cubre huecos.

Análisis en solo lectura de `/home/user/wt/t8` (rama `t9`, 14d0eac68), 05-11-2026. Brave = mismo nombre en `v1.69.168` o `v1.98.63`. Comprobación en 156 con `b2-cr156` (Chromium 156.0.8078.90; V8 d72e817d59): cuenta de líneas añadidas por el parche (sin comentarios) que ya aparecen literalmente en el fichero de 156; orientativa (código reestructurado da cifras bajas aunque el arreglo esté). ANGLE, Dawn y Skia son subrepositorios: no comprobados.

#### 12.13.1. Recuentos

| Grupo | Ficheros |
|---|---|
| Total en `patches/` | 2025 (2020 `.patch` + 5 `.md`) |
| Brave (nombre en 1.69 o 1.98) | 561 |
|  · de ellos, Brave + añadidos de FlyWeb (difieren de 1.69 y de 1.98 con ≥5 líneas nuevas o comentario FlyWeb, sin contar adaptaciones del porte T5/T7) | 24 |
| Propios de FlyWeb (`.patch`) | 1460 (+4 `FLYWEB-SECURITY*.md`) |
|  · (a) nivel | 1319 |
|  · (b) seguridad, backport de upstream (ya en 156) | 70 |
|  · (b) mojave | 47 |
|  · (b) función propia | 9 |
|  · (b) seguridad propia | 6 |
|  · (b) UA/versión | 3 |
|  · (b) otro | 3 |
|  · (b) dudoso (CT, Static CT API) | 2 |
|  · (b) seguridad (Maglev, va con el flag) | 1 |

De los 24 Brave+FlyWeb: 13 son de nivel, 5 seguridad upstream (`render_frame_host_impl.cc`, `navigation_request.cc`, `document.cc`, `webgl_rendering_context_base.cc`, `v8/src-codegen-compiler.cc`; ya en 156) y 6 no de nivel (en la tabla de (b), marcados [Brave+FlyWeb]). Otros 64 de Brave difieren de ambas etiquetas con <5 líneas nuevas: adaptaciones del porte (T5/T7: fuentes de `//brave`, quitar Speedreader/Leo…), no FlyWeb.

Nota de contexto: de los 561 de Brave, 299 siguen idénticos a 1.69 (aún sin portar a 1.98); 89 ya son los de 1.98 tal cual.

#### 12.13.2. (b) No son de nivel — tabla completa

Veredicto: **reportar** = hay que llevarlo a la 156; **ya está** = la 156 lo trae; **sobra** = deja de tener objeto en la 3.0.0; **dudoso** = decidir.

##### 2.1 Mojave, UA/versión, funciones propias, privacidad, otros

| Fichero (`patches/…`) | Subtipo | Qué hace | 156 | Veredicto |
|---|---|---|---|---|
| `base-mac-launch_application.mm.patch` | mojave | Abrir apps/URLs sin NSWorkspaceOpenConfiguration (10.15) y con _kLSOpenOptionBackgroundLaunchKey débil (LOCAL-6/8) | 23/49 líneas añadidas presentes en 156 | reportar |
| `base-mac-launch_services_spi.h.patch` | mojave | Declara _kLSOpenOptionBackgroundLaunchKey como weak_import (no existe en 10.14) | — (solo comentarios o borrados) | reportar |
| `base-process-launch_mac.cc.patch` | mojave | Alternativa a posix_spawn_file_actions_addchdir_np (10.15+) (LOCAL-8) | 6/9 líneas añadidas presentes en 156 | reportar |
| `base-threading-platform_thread_apple.mm.patch` | mojave | Política de hilos de tiempo real como en 116 por un fallo de 10.14 (FM.42 c1) | 0/2 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-apps-link_capturing-mac_intent_picker_helpers.mm.patch` | mojave | Sin enlaces universales (SFUniversalLink es 10.15+) (LOCAL-8) | 2/4 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-device_reauth-mac-authenticator_mac.mm.patch` | mojave (plataforma, decisión FlyWeb) | Reautenticación sin Touch ID en ningún Mac (FM.42 d4) | 0/1 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-enterprise-connectors-device_trust-key_management-core-mac-secure_enclave_client_impl.mm.patch` | mojave (plataforma, decisión FlyWeb) | kSecUseDataProtectionKeychain débil (10.15+) y nunca Secure Enclave (LOCAL-8, FM.42 d8) | 2/7 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-platform_util_mac.mm.patch` | mojave | -openURL:configuration:completionHandler: es 10.15+: vía antigua en 10.14 (LOCAL-8) | 4/12 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-ui-views-eye_dropper-BUILD.gn.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | 1/1 líneas añadidas presentes en 156 | reportar |
| `chrome-browser-ui-views-eye_dropper-eye_dropper_view_mac.mm.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | 5/16 líneas añadidas presentes en 156 | reportar |
| `components-color-BUILD.gn.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | 0/1 líneas añadidas presentes en 156 | reportar |
| `components-color-color_id.h.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | — (solo comentarios o borrados) | reportar |
| `components-color-color_mixers.cc.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | — (solo comentarios o borrados) | reportar |
| `components-eye_dropper-BUILD.gn.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | 0/4 líneas añadidas presentes en 156 | reportar |
| `components-eye_dropper-eye_dropper_view.h.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | 0/2 líneas añadidas presentes en 156 | reportar |
| `components-eye_dropper-eye_dropper_view_mac.mm.patch` | mojave | Cuentagotas genérico (de 116) en 10.14, que no tiene NSColorSampler (FM.42 b2; 8 ficheros, eye_dropper_view_mac.mm es nuevo) | no existe en 156 con ese nombre | reportar |
| `components-input-web_input_event_builders_mac.mm.patch` | mojave | Campos de tableta/puntero leídos desde 10.14; si vienen vacíos, el puntero sigue (FM.42 b6) | 0/10 líneas añadidas presentes en 156 | reportar |
| `components-metal_util-hdr_copier_layer.mm.patch` | mojave | Capa HDR sin CAEDRMetadata/preferredDevice (10.15) (LOCAL-7) | 4/7 líneas añadidas presentes en 156 | reportar |
| `components-remote_cocoa-app_shim-menu_controller_cocoa_delegate_impl.mm.patch` | mojave | Etiqueta «New» de menús: celda propia porque los menús Carbon de 10.13-10.14 ignoran flipped (FM.42 c4) | 4/12 líneas añadidas presentes en 156 | reportar |
| `content-browser-renderer_host-file_utilities_host_impl.cc.patch` | mojave (+ seguridad FS.26) | OPFS truncate()/SetLength por el navegador en 10.14, cuyo sandbox no deja ftruncate al renderer (de 116); FS.26 valida el descriptor (5 ficheros) | 0/17 líneas añadidas presentes en 156 | reportar |
| `content-browser-renderer_host-file_utilities_host_impl.h.patch` | mojave (+ seguridad FS.26) | OPFS truncate()/SetLength por el navegador en 10.14, cuyo sandbox no deja ftruncate al renderer (de 116); FS.26 valida el descriptor (5 ficheros) | 0/3 líneas añadidas presentes en 156 | reportar |
| `content-browser-renderer_host-render_widget_host_view_mac.mm.patch` | mojave | Anota que unas API funcionan desde 10.14 (aviso de disponibilidad) (FM.42 b6) | 1/1 líneas añadidas presentes en 156 | reportar |
| `content-common-font_list_mac.mm.patch` | mojave | Oculta las fuentes de sistema que 10.14 lista con nombre (FM.42 c5, de 116) | 1/5 líneas añadidas presentes en 156 | reportar |
| `crypto-features.cc.patch` | mojave (plataforma, decisión FlyWeb) | Sin claves en Secure Enclave en ningún Mac (FM.42 d1); en 156 el fichero es crypto/apple/unexportable_key_apple.mm | 0/1 líneas añadidas presentes en 156 | reportar |
| `crypto-unexportable_key_mac.mm.patch` | mojave (plataforma, decisión FlyWeb) | Sin claves en Secure Enclave en ningún Mac (FM.42 d1); en 156 el fichero es crypto/apple/unexportable_key_apple.mm | no existe en 156 con ese nombre | reportar |
| `crypto-unexportable_key_metrics.cc.patch` | mojave (plataforma, decisión FlyWeb) | Apaga la métrica que creaba y borraba una clave de Secure Enclave en cada arranque (FM.42 d2) [Brave+FlyWeb] | no comprobado | reportar |
| `device-bluetooth-bluetooth_low_energy_adapter_apple.mm.patch` | mojave | CBCentralManager.authorization es 10.15+: en 10.14 se usa el estado (LOCAL-8) | 0/10 líneas añadidas presentes en 156 | reportar |
| `device-fido-mac-touch_id_context.mm.patch` | mojave (plataforma, decisión FlyWeb) | Sin autenticador de plataforma (Touch ID) en ningún Mac (FM.42 d3/d4) | 1/1 líneas añadidas presentes en 156 | reportar |
| `device-fido-mac-util.mm.patch` | mojave (plataforma, decisión FlyWeb) | Sin autenticador de plataforma (Touch ID) en ningún Mac (FM.42 d3/d4) | 0/1 líneas añadidas presentes en 156 | reportar |
| `device-gamepad-game_controller_data_fetcher_mac.mm.patch` | mojave | productCategory es 10.15+ (selector desconocido en 10.14) (LOCAL-8) | 2/9 líneas añadidas presentes en 156 | reportar |
| `gpu-ipc-service-image_transport_surface_overlay_mac.mm.patch` | mojave (vía GL) | Dispositivo CGL con el backend OpenGL de ANGLE en 10.14 | 0/6 líneas añadidas presentes en 156 | sobra si se mantiene la vía Metal (B1d); reportar solo si se reabre la GL |
| `media-base-mac-video_capture_device_avfoundation_helpers.mm.patch` | mojave | Tipos de dispositivo y AVCaptureDeviceDiscoverySession 10.15+: enumeración antigua (LOCAL-8) | 0/2 líneas añadidas presentes en 156 | reportar |
| `media-capture-video-apple-video_capture_device_avfoundation.mm.patch` | mojave | Fotos con AVCaptureStillImageOutput en 10.14 (AVCapturePhotoOutput es 10.15+) (FM.42 a2, de 116) | 9/41 líneas añadidas presentes en 156 | reportar |
| `media-mojo-services-gpu_mojo_media_client_mac.cc.patch` | mojave | xHE-AAC por AudioToolbox solo en 10.15+ | 1/2 líneas añadidas presentes en 156 | reportar |
| `sandbox-mac-system_services.cc.patch` | mojave | _CSCheckFixDisable como weak_import (no existe en 10.14) (LOCAL-6) | 1/1 líneas añadidas presentes en 156 | reportar |
| `services-device-public-cpp-geolocation-system_geolocation_source_apple.h.patch` | mojave | Permiso de geolocalización en 10.14 arrancando las actualizaciones (requestWhenInUseAuthorization es 10.15+) (FM.42 b4) | 0/2 líneas añadidas presentes en 156 | reportar |
| `services-device-public-cpp-geolocation-system_geolocation_source_apple.mm.patch` | mojave | Permiso de geolocalización en 10.14 arrancando las actualizaciones (requestWhenInUseAuthorization es 10.15+) (FM.42 b4) | 3/16 líneas añadidas presentes en 156 | reportar |
| `third_party-blink-public-mojom-file-file_utilities.mojom.patch` | mojave (+ seguridad FS.26) | OPFS truncate()/SetLength por el navegador en 10.14, cuyo sandbox no deja ftruncate al renderer (de 116); FS.26 valida el descriptor (5 ficheros) | 0/4 líneas añadidas presentes en 156 | reportar |
| `third_party-blink-renderer-core-editing-substring_util.mm.patch` | mojave | -[NSFont fontWithSize:] es 10.15+ (LOCAL-8) | 1/4 líneas añadidas presentes en 156 | reportar |
| `third_party-blink-renderer-modules-file_system_access-file_system_access_regular_file_delegate.cc.patch` | mojave (+ seguridad FS.26) | OPFS truncate()/SetLength por el navegador en 10.14, cuyo sandbox no deja ftruncate al renderer (de 116); FS.26 valida el descriptor (5 ficheros) | 2/15 líneas añadidas presentes en 156 | reportar |
| `third_party-blink-renderer-modules-file_system_access-file_system_access_regular_file_delegate.h.patch` | mojave (+ seguridad FS.26) | OPFS truncate()/SetLength por el navegador en 10.14, cuyo sandbox no deja ftruncate al renderer (de 116); FS.26 valida el descriptor (5 ficheros) | 0/4 líneas añadidas presentes en 156 | reportar |
| `third_party-blink-renderer-platform-fonts-mac-font_matcher_mac.mm.patch` | mojave | CTFontCopyVariationAxesInternal débil y fuente que el renderer sí puede dibujar en 10.14 (LOCAL-6, FM.47) | 32/82 líneas añadidas presentes en 156 | reportar |
| `third_party/angle/src-libANGLE-renderer-metal-BUILD.gn.patch` | mojave (compilación) | flyweb_metal_bin_path: ruta a metal/metallib de Xcode para el backend Metal de ANGLE (FM.31) | no comprobado (subrepositorio) | dudoso: depende de cómo compile LOCAL la 156 con Xcode 26 |
| `third_party/dawn/src-dawn-common-AlignedAlloc.cpp.patch` | mojave | aligned_alloc es 10.15: posix_memalign en 10.14 (LOCAL-7) | no comprobado (subrepositorio) | reportar (si WebGPU/Dawn se compila para 10.14) |
| `third_party/dawn/src-dawn-native-metal-PhysicalDeviceMTL.mm.patch` | mojave | supportsFamily:/hasUnifiedMemory son 10.15: MTLFeatureSet/isLowPower en 10.14 (LOCAL-6/7) | no comprobado (subrepositorio) | reportar (si WebGPU/Dawn se compila para 10.14) |
| `ui-base-cocoa-permissions_utils.mm.patch` | mojave | Sin permiso de grabación de pantalla antes de 10.15: no se calienta ni se deniega getDisplayMedia (FM.42 c2) [Brave+FlyWeb] | no comprobado | reportar |
| `ui-display-mac-screen_mac.mm.patch` | mojave | Nombres de pantalla y HDR en 10.14 por la vía de 116 (FM.42 b3, LOCAL-6) | 4/64 líneas añadidas presentes en 156 | reportar |
| `ui-gfx-mac-color_space_util.mm.patch` | mojave | kCMFormatDescriptionTransferFunction_sRGB es 10.15 (LOCAL-7) | 4/5 líneas añadidas presentes en 156 | reportar |
| `ui-gl-init-gl_display_initializer.cc.patch` | mojave (vía GL) | Backend OpenGL de ANGLE por defecto en 10.14, Metal desde 10.15 (FM.31) | 0/2 líneas añadidas presentes en 156 | sobra: contradice la vía Metal decidida para la 3.0.0 (B1d) |
| `chrome-browser-extensions-chrome_extensions_browser_client.cc.patch` | UA/versión | Actualización de extensiones con la versión declarada [Brave+FlyWeb] | no comprobado | sobra mientras el nivel declarado sea 156 (= real); reportar si la 3.x declara más que el motor real (ver §4) |
| `chrome-common-extensions-manifest_handlers-minimum_chrome_version_checker.cc.patch` | UA/versión | minimum_chrome_version de las extensiones contra la versión declarada (kFlyWebEngineFullVersion), no la real | 0/1 líneas añadidas presentes en 156 | sobra mientras el nivel declarado sea 156 (= real); reportar si la 3.x declara más que el motor real (ver §4) |
| `components-update_client-update_query_params.cc.patch` | UA/versión | Las peticiones de extensiones (prod=CRX) llevan la versión declarada | 0/7 líneas añadidas presentes en 156 | sobra mientras el nivel declarado sea 156 (= real); reportar si la 3.x declara más que el motor real (ver §4) |
| `components-update_client-update_query_params.h.patch` | UA/versión | Las peticiones de extensiones (prod=CRX) llevan la versión declarada | 0/1 líneas añadidas presentes en 156 | sobra mientras el nivel declarado sea 156 (= real); reportar si la 3.x declara más que el motor real (ver §4) |
| `chrome-browser-component_updater-pki_metadata_component_installer.cc.patch` | seguridad propia (PKI Metadata) | Tipo de log CT desconocido → kUnspecified en vez de NOTREACHED (no tumba el navegador) | no comprobado | dudoso: mismo motivo; comprobar si la 156 aún hace NOTREACHED |
| `components-password_manager-core-browser-password_store-login_database.cc.patch` | seguridad propia (FS.25) / fw1 | No borra contraseñas fw1/v10 que no se descifran (otro proveedor sin clave) | 3/5 líneas añadidas presentes en 156 | reportar (con la capa fw1 de components/flyweb_os_crypt) |
| `net-cert-cert_verify_proc_builtin.cc.patch` | seguridad propia (CRS) | Restricciones de versión del Chrome Root Store contra una versión fija 153.0.8010.0 (desconfianzas hasta Chrome 153) | 18/19 líneas añadidas presentes en 156 | sobra (la 156 usa su propia versión); reponer si se quieren desconfianzas de Chrome > 156 |
| `net-cert-internal-trust_store_chrome.cc.patch` | seguridad propia (PKI Metadata) | Un ConstraintSet con campos desconocidos (de un Chrome más nuevo) no casa nunca, en vez de ensancharse | 9/22 líneas añadidas presentes en 156 | dudoso: conviene reportarlo, FlyWeb se queda en 156 y recibirá PKI Metadata de Chrome más nuevos |
| `third_party-blink-renderer-modules-webaudio-audio_param_handler.h.patch` | seguridad propia | IsAudioRate() lee la tasa bajo rate_lock_ (completa Chromium 8669b50ce1c; carrera entre hilos) | 0/1 líneas añadidas presentes en 156 | reportar: la 156 sigue leyendo automation_rate_ sin el cerrojo |
| `v8/test-mjsunit-wasm-regress-flyweb-jspi-return.js.patch` | seguridad propia (prueba FS.38) | Prueba propia de retorno de pilas JSPI en V8 13.8 | no existe en 156 con ese nombre | sobra |
| `chrome-browser-ui-tabs-pinned_tab_codec.cc.patch` | función propia (pestañas fijadas compartidas) | No guarda las pestañas fijadas «ficticias» de otras ventanas ni lee las vacías de perfiles 2.0.x [Brave+FlyWeb] | no comprobado | reportar |
| `components-os_crypt-async-common-encryptor.cc.patch` | función propia (fw1) | Gancho BRAVE_ENCRYPTOR_DECRYPT_DATA para la capa fw1 | 0/1 líneas añadidas presentes en 156 | ya portado (T7, 48cb3cdf3) |
| `components-password_manager-core-browser-password_store-login_database_async_helper.cc.patch` | función propia (fw1/OSCryptAsync) | Crea el puente de sync de contraseñas antes de que llegue la clave de OSCryptAsync (BD abierta después) (4 ficheros, sin comentario en 3) | 5/12 líneas añadidas presentes en 156 | dudoso: la 156 inicializa el almacén con OSCryptAsync de otra forma; revisar al portar fw1 |
| `components-password_manager-core-browser-password_store-login_database_async_helper.h.patch` | función propia (fw1/OSCryptAsync) | Crea el puente de sync de contraseñas antes de que llegue la clave de OSCryptAsync (BD abierta después) (4 ficheros, sin comentario en 3) | 1/1 líneas añadidas presentes en 156 | dudoso: la 156 inicializa el almacén con OSCryptAsync de otra forma; revisar al portar fw1 |
| `components-password_manager-core-browser-sync-password_sync_bridge.cc.patch` | función propia (fw1/OSCryptAsync) | Crea el puente de sync de contraseñas antes de que llegue la clave de OSCryptAsync (BD abierta después) (4 ficheros, sin comentario en 3) | 10/15 líneas añadidas presentes en 156 | dudoso: la 156 inicializa el almacén con OSCryptAsync de otra forma; revisar al portar fw1 |
| `components-password_manager-core-browser-sync-password_sync_bridge.h.patch` | función propia (fw1/OSCryptAsync) | Crea el puente de sync de contraseñas antes de que llegue la clave de OSCryptAsync (BD abierta después) (4 ficheros, sin comentario en 3) | 5/7 líneas añadidas presentes en 156 | dudoso: la 156 inicializa el almacén con OSCryptAsync de otra forma; revisar al portar fw1 |
| `net-extras-sqlite-sqlite_persistent_cookie_store.cc.patch` | función propia (fw1) | Una cookie fw1 ilegible borra solo su fila, no todo el eTLD+1 (y su prueba) | 9/10 líneas añadidas presentes en 156 | reportar |
| `net-extras-sqlite-sqlite_persistent_cookie_store_unittest.cc.patch` | función propia (fw1) | Una cookie fw1 ilegible borra solo su fila, no todo el eTLD+1 (y su prueba) | 13/33 líneas añadidas presentes en 156 | reportar |
| `v8/src-flags-flag-definitions.h.patch` | función propia / seguridad | Maglev apagado (decisión HUMANO 05-10) y maglev_untagged_phis apagado (CVE-2026-3910) | 0/2 líneas añadidas presentes en 156 | no reportar como parche: Maglev se decide en B6 (DIRECTIVAS 05-11); untagged_phis sobra (la 156 lo arregla) |
| `v8/src-utils-version.h.patch` | función propia (V8) | kFlyWebCacheEpoch en el hash de versión: invalida cachés de código al cambiar parches V8 propios | 0/1 líneas añadidas presentes en 156 | sobra mientras la 3.0.0 no lleve parches V8 propios; reponer con el primero |
| `third_party-blink-renderer-platform-runtime_enabled_features.json5.patch` | privacidad | Privacy Sandbox, Fledge, etc. apagados por defecto [Brave+FlyWeb] | no comprobado | ya portado (T8, f91290620) |
| `components-certificate_transparency-chrome_ct_policy_enforcer.h.patch` | dudoso (nivel CT) | Tipos de log (Static CT API, M144) y lista embebida sin tiled_logs en la 128 | 2/7 líneas añadidas presentes en 156 | sobra (la 156 ya lo trae) |
| `components-certificate_transparency-tools-make_ct_known_logs_list.py.patch` | dudoso (nivel CT) | Tipos de log (Static CT API, M144) y lista embebida sin tiled_logs en la 128 | no comprobado | sobra (la 156 ya lo trae) |
| `build-config-unsafe_buffers_paths.txt.patch` | otro (compilación) | Exime brave/ y rutas con prefijo src/ de -Wunsafe-buffer-usage [Brave+FlyWeb] | no comprobado | dudoso: comprobar con la compilación de la 156; Brave 1.98 trae su propia lista |
| `third_party-blink-renderer-core-loader-base_fetch_context_test.cc.patch` | otro (pruebas) | Adaptan pruebas de Chromium a los chromium_src de Brave 1.69 | 0/1 líneas añadidas presentes en 156 | sobra (rehacer contra Brave 1.98 si fallan) |
| `third_party-blink-renderer-core-timing-time_clamper_test.cc.patch` | otro (pruebas) | Adaptan pruebas de Chromium a los chromium_src de Brave 1.69 | 0/11 líneas añadidas presentes en 156 | sobra (rehacer contra Brave 1.98 si fallan) |
| `third_party-blink-renderer-modules-websockets-websocket_channel_impl_test.cc.patch` | otro (pruebas) | Adaptan pruebas de Chromium a los chromium_src de Brave 1.69 | 0/5 líneas añadidas presentes en 156 | sobra (rehacer contra Brave 1.98 si fallan) |
| `v8/src-maglev-maglev-post-hoc-optimizations-processors.h.patch` | seguridad (acompaña a untagged_phis off) | Barre almacenes muertos de contexto cuando el selector de representación no corre | — (solo comentarios o borrados) | sobra |

##### 2.2 Seguridad: backports de arreglos de Chromium/V8/ANGLE/Skia/Brotli (FS.17–FS.39)

Todos son commits de upstream fusionados como muy tarde en M151 o en `main` antes de la rama 156 (registro en `patches/FLYWEB-SECURITY*.md`). Muestreados a mano en 156: `integrity_policy_parser.cc` (d71f062d656, solo main), `source-text-module.cc` (137e7f93d7), `css_font_feature_values_map.cc` (CVE-2026-2441), `builtins-wasm-gen.cc` (CVE-2026-87491), `baseline-batch-compiler.cc` (ebf970d8a3), Brotli `decode.c` (CVE-2026-111497): todos presentes. Veredicto común: **ya está → borrar**. Los mixtos (p. ej. `element.cc`, `css_math_expression_node.cc`, `integrity_policy_parser.cc`) llevan además código de nivel: también se borran enteros.

| Fichero | Arreglo | 156 |
|---|---|---|
| `content-browser-bad_message.h.patch` | upstream 9971d3de459 | 0/1 líneas añadidas presentes en 156 |
| `content-browser-renderer_host-ipc_utils.cc.patch` | upstream eb3896190a2 | 9/10 líneas añadidas presentes en 156 |
| `content-browser-renderer_host-navigation_request.h.patch` | // is transferred to the committing RenderFrameHost. FlyWeb (FS.39): a | 8/8 líneas añadidas presentes en 156 |
| `content-browser-service_worker-service_worker_version.cc.patch` | upstream 405dcf07fd1 | 26/30 líneas añadidas presentes en 156 |
| `content-browser-service_worker-service_worker_version.h.patch` | upstream 405dcf07fd1 | 3/3 líneas añadidas presentes en 156 |
| `content-public-browser-disallow_activation_reason.h.patch` | upstream 0dcb0580163 | 1/1 líneas añadidas presentes en 156 |
| `gpu-command_buffer-service-shared_image-iosurface_image_backing.mm.patch` | 25210ac50d, crbug 40254930 | 5/7 líneas añadidas presentes en 156 |
| `gpu-ipc-service-shared_image_stub.cc.patch` | f35ac32d66 / 6345b520b1, crbug 488270257 | 7/9 líneas añadidas presentes en 156 |
| `media-gpu-mac-vt_video_encode_accelerator_mac.mm.patch` | upstream cdf876cf92ec; crbug 416294710 | 2/2 líneas añadidas presentes en 156 |
| `services-network-public-cpp-integrity_policy_parser.cc.patch` | // FlyWeb (FS.39): GetString() on an integer, decimal or boolean item is // FlyWeb (level  | 40/67 líneas añadidas presentes en 156 |
| `third_party-blink-common-page_state-page_state_serialization.cc.patch` | upstream cf3b685c0d5 | 16/24 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-animation-css_default_interpolation_type.cc.patch` | upstream 70c9c1f16b; crbug 433196586 | 2/2 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-animation-css_interpolation_type.cc.patch` | upstream 70c9c1f16b; crbug 433196586 | 2/2 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-animation-css_var_cycle_interpolation_type.cc.patch` | upstream 70c9c1f16b; crbug 433196586 | 2/5 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-css-css_font_feature_values_map.cc.patch` | CVE-2026-2441; crbug 483569511 | 2/5 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-css-css_math_expression_node.cc.patch` | // FlyWeb (FS.39): std::clamp() with NaN is unspecified (upstream // FlyWeb (nivel 138, FM | 113/128 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-dom-element.cc.patch` | upstream 155b785d0e, 3f4d114155; crbug 496280532, 410437529 | 159/189 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-editing-commands-replace_node_with_span_command.cc.patch` | upstream 155b785d0e; crbug 496280532 | 2/6 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-editing-frame_selection.cc.patch` | upstream 9fb841bf28; crbug 523292588 | 23/27 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-frame-local_frame_view.cc.patch` | upstream c215f8e6f0; crbug 491994185 | 13/13 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-html-forms-range_input_type.cc.patch` | upstream 926d3d2597 | 20/39 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-layout-layout_object.h.patch` | upstream 0e454ce616; crbug 543070692 | 6/7 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-core-loader-preload_helper.cc.patch` | CVE-2025-4664; crbug 415810136 | 13/14 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-modules-accessibility-ax_node_object.cc.patch` | upstream a16cd5c0ad | 10/13 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-modules-webcodecs-background_readback.cc.patch` | upstream 9cad4244e46 | 2/4 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-modules-webcodecs-video_encoder.cc.patch` | // FlyWeb (FS.39): cross-thread handles, the callback may be destroyed | 4/7 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-modules-webcodecs-video_frame.cc.patch` | // FlyWeb (FS.39): the callback may be destroyed off the main thread | 36/51 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-modules-webgl-webgl_context_group.cc.patch` | upstream c1433740f3ea; crbug 485935305 | no existe en 156 con ese nombre |
| `third_party-blink-renderer-platform-geometry-calculation_expression_node.cc.patch` | upstream f27c40425db | 59/66 líneas añadidas presentes en 156 |
| `third_party-blink-renderer-platform-widget-widget_base.cc.patch` | upstream 9fb841bf28; crbug 523292588 | 3/3 líneas añadidas presentes en 156 |
| `third_party-brotli-dec-decode.c.patch` | CVE-2026-111497, brotli 0ed4268a (FS.39) | 49/51 líneas añadidas presentes en 156 |
| `third_party-brotli-include-brotli-decode.h.patch` | CVE-2026-111497, brotli 0ed4268a (FS.39) | 1/1 líneas añadidas presentes en 156 |
| `third_party/angle/src-compiler-translator-Compiler.cpp.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-compiler-translator-ValidateOutputs.cpp.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-libANGLE-TransformFeedback.cpp.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-libANGLE-TransformFeedback.h.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-libANGLE-renderer-metal-BufferMtl.mm.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-libANGLE-renderer-metal-TextureMtl.mm.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/angle/src-libANGLE-validationES2.cpp.patch` | ANGLE (FS.39 GPU: aa51faff/4664989d, 4e2ac155, e1dc0a7a) | no comprobado (subrepositorio) |
| `third_party/skia/src-gpu-ganesh-text-GrAtlasManager.cpp.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-gpu-graphite-text-TextAtlasManager.cpp.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-Glyph.h.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-GlyphVector.cpp.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-GlyphVector.h.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-StrikeCache.cpp.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-StrikeCache.h.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `third_party/skia/src-text-gpu-SubRunContainer.cpp.patch` | Skia, crbug 491421267 (clave de átlas con formato) | no comprobado (subrepositorio) |
| `ui-accessibility-ax_tree_serializer.h.patch` | upstream a16cd5c0ad; crbug 442619489 | 6/7 líneas añadidas presentes en 156 |
| `v8/include-cppgc-visitor.h.patch` | upstream 5a113ffdf2 | 6/6 líneas añadidas presentes en 156 |
| `v8/src-baseline-baseline-batch-compiler.cc.patch` | upstream ebf970d8a3 | 0/4 líneas añadidas presentes en 156 |
| `v8/src-baseline-baseline-compiler.cc.patch` | upstream ebf970d8a3; crbug 515431687 | 4/7 líneas añadidas presentes en 156 |
| `v8/src-builtins-builtins-definitions.h.patch` | CVE-2026-87491; upstream 36079c36 | 0/1 líneas añadidas presentes en 156 |
| `v8/src-builtins-builtins-internal-gen.cc.patch` | upstream c82024befb | 0/2 líneas añadidas presentes en 156 |
| `v8/src-builtins-builtins-wasm-gen.cc.patch` | CVE-2026-87491; upstream 36079c36; crbug 543557673 | 33/38 líneas añadidas presentes en 156 |
| `v8/src-builtins-x64-builtins-x64.cc.patch` | upstream 3137a74400, 49a1dbeb1b; crbug 561655173 | 5/7 líneas añadidas presentes en 156 |
| `v8/src-compiler-js-native-context-specialization.cc.patch` | upstream 9b5250b9 | 25/36 líneas añadidas presentes en 156 |
| `v8/src-compiler-turboshaft-pipelines.cc.patch` | // unchecked stack pointer jump of arbitrary size (FlyWeb: port of v8 | 6/6 líneas añadidas presentes en 156 |
| `v8/src-execution-frame-constants.h.patch` | upstream 3137a74400 | 1/1 líneas añadidas presentes en 156 |
| `v8/src-execution-isolate.cc.patch` | upstream 13c7629466; crbug 501147587 | 3/10 líneas añadidas presentes en 156 |
| `v8/src-maglev-maglev-graph-builder.cc.patch` | upstream a068030f51, 811ebc89d5; crbug 495751197, 523884658 | 14/18 líneas añadidas presentes en 156 |
| `v8/src-maglev-maglev-graph-builder.h.patch` | upstream dd7e9b5ef6 | 4/4 líneas añadidas presentes en 156 |
| `v8/src-objects-elements.cc.patch` | upstream 0197c35257 | 35/54 líneas añadidas presentes en 156 |
| `v8/src-objects-map-updater.cc.patch` | upstream 5a4d7a78db | 6/11 líneas añadidas presentes en 156 |
| `v8/src-objects-shared-function-info.h.patch` | upstream 7fd662da8a | 2/2 líneas añadidas presentes en 156 |
| `v8/src-objects-source-text-module.cc.patch` | upstream 137e7f93d7, d87667efce; crbug 574038247, 559893859 | 17/20 líneas añadidas presentes en 156 |
| `v8/src-parsing-rewriter.cc.patch` | comprobación de desbordamiento de pila, como upstream | 12/12 líneas añadidas presentes en 156 |
| `v8/src-wasm-module-compiler.cc.patch` | upstream 00250c2d2c | 3/3 líneas añadidas presentes en 156 |
| `v8/src-wasm-wasm-external-refs.cc.patch` | upstream 54cf5fa964; crbug 485784597 | 2/7 líneas añadidas presentes en 156 |
| `v8/test-mjsunit-regress-regress-559893859.mjs.patch` | // FlyWeb: upstream regress-559893859.js rewritten for V8 13.6, which has no | no existe en 156 con ese nombre |
| `v8/test-mjsunit-regress-regress-574038247.mjs.patch` | // FlyWeb: upstream regress-574038247.js rewritten for V8 13.8, which has no | no existe en 156 con ese nombre |

#### 12.13.3. (a) Nivel — recuentos y ejemplos

| Directorio | Parches |
|---|---|
| third_party/blink/renderer/core | 715 |
| v8/ | 211 |
| third_party/blink/renderer/modules | 109 |
| third_party/blink/renderer/platform | 81 |
| third_party/blink/renderer/bindings | 32 |
| content | 28 |
| components | 24 |
| third_party/boringssl/src/ | 23 |
| third_party/blink (public, common) | 21 |
| net | 17 |
| services | 16 |
| third_party (otros) | 13 |
| gin | 7 |
| chrome | 5 |
| ash | 4 |
| cc | 4 |
| ui | 3 |
| media | 2 |
| base | 1 |
| extensions | 1 |
| net/third_party/quiche/src/ | 1 |
| third_party/emoji-segmenter/src/ | 1 |
| **Total** | **1319** |

1239 de ellos no llevan ningún comentario «FlyWeb» (código de upstream copiado); los 80 restantes dicen «FlyWeb (level NNN)», «as Chrome NNN», «the 128 has…» o citan el commit de upstream.

Ejemplos:

- `third_party-blink-renderer-core-css-css_selector.cc.patch` (231 líneas): // FlyWeb (level 131): ca1fb13815a; the 128's ::select-fallback-datalist takes
- `third_party-blink-renderer-core-css-parser-css_if_parser.cc.patch` (199 líneas): // FlyWeb: the 128's media and container query parsers work on ranges, not on
- `third_party-blink-renderer-core-layout-layout_box.cc.patch` (53 líneas): // FlyWeb (level 132, sideways 0b24096ebe): logical caret rect, which also
- `third_party-blink-renderer-modules-clipboard-clipboard_item.cc.patch` (73 líneas): // FlyWeb level 133 (d72d71316f2): getType() always gives a Blob, but the
- `third_party-blink-renderer-core-scheduler-dom_timer.cc.patch` (51 líneas): // FlyWeb: setInterval(..., 0) without the 1ms clamp, as Chrome 135
- `net-base-data_url.cc.patch` (12 líneas): // Strip whitespace for non-text MIME types. FlyWeb (level 130): only
- `gin-v8_initializer.cc.patch` (6 líneas): // FlyWeb (engine level 136): the JS features Chromium 135/136 ship from
- `third_party-simdutf-simdutf.cpp.patch` (67616 líneas): (sin comentario)
- `third_party/boringssl/src/crypto-mlkem-mlkem.cc.patch` (1097 líneas): (sin comentario)
- `ui-gl-gl_switches.cc.patch` (1 líneas): (sin comentario)

Notas sobre (a): `gin-v8_initializer.cc` (flags JS de 135/136) se cuenta como nivel: en la 156 esas funciones van por defecto. ML-KEM de BoringSSL (FS.17, función de Chrome 131) y `ui-gl-gl_switches.cc` (Metal por defecto en Intel) también: la 156 los trae (en 156 `kDefaultANGLEMetal` ya no existe).


#### 12.13.4. Versión declarada, nivel y número de versión (brave-core, fuera de `patches/`)

##### Qué hay hoy (t9 = lo de la 2.7.0)

| Dónde | Qué hace |
|---|---|
| `build/config.gni` | `flyweb_version = "2.7.0"`, `flyweb_engine_level = 138`, `flyweb_engine_full_version = "138.0.7204.185"`, `flyweb_min_macos_version = "11.7.10"`; argumento `flyweb_build_number` (0 por defecto; lo pasa `build.sh` con `FLYWEB_BUILD_NUMBER`). Comentarios con la tabla 1.N/2.N = nivel |
| `components/version_info/BUILD.gn` + `version_info_values.h.version` | Genera `kFlyWebEngineLevel`, `kFlyWebEngineFullVersion`, `kFlyWebMinMacOSVersion` y `kBraveVersionNumberForDisplay = "2.7.0 (motor 138)"`; `GetFlyWebVersion()` lo usan `sparkle_glue.mm` y Ajustes/Acerca de |
| `BUILD.gn` + `build/mac/tweak_info_plist.py` | `CFBundleShortVersionString = flyweb_version`; `CFBundleVersion = <brave minor+100·major>.<build>.<flyweb_build_number>`; hoy `package.json` sigue en 1.69.168 → `169.168.N` (lo que compara Sparkle) |
| `browser/flyweb/declared_version.{h,cc}` + `BraveContentBrowserClient::GetUserAgent()` | Cambia `Chrome/<mayor real>.` por `Chrome/<nivel>.` en el User-Agent (salvo `--user-agent`) |
| `chromium_src/components/embedder_support/user_agent_utils.cc` | Client Hints: sin marca propia (solo «Chromium» + GREASE), `Sec-CH-UA`/`fullVersionList`/`uaFullVersion` con el nivel y `flyweb_engine_full_version`; `platformVersion` nunca por debajo de `flyweb_min_macos_version` (privacidad: 10.14.6 identifica) |
| `chromium_src/components/safe_browsing/core/browser/db/v4_protocol_manager_util.cc` | El cliente de Safe Browsing (al proxy propio) declara la versión completa declarada |
| `patches/` (3 parches, tabla 2.1) | Extensiones: `minimum_chrome_version`, `prod=CRX` de update_client y la actualización de instaladas, con la versión declarada |

##### Qué hay que decidir para la 3.0.0 (motor 156 nativo)

DIRECTIVAS (05-11) ya fija `flyweb_engine_level = 156` y `flyweb_version = 3.0.0` (salto de base; 3.0.x después). Queda:

1. **`flyweb_engine_full_version`**: una versión real de Chrome 156 para Mac. Propuesta: la de la base, `156.0.8078.90`; así declarada = real y el UA reducido de Chromium ya dice `Chrome/156.0.0.0`.
2. **¿Se conserva el mecanismo de versión declarada?** Con nivel = motor real es un no-op (`DeclareUserAgent`, los 3 parches de extensiones, Safe Browsing). Pero DIRECTIVAS (05-11 noche) dice que tras la 3.0.0 FlyWeb porta funciones a su ritmo «a la par» con Chrome: si algún día declara > 156, hace falta otra vez. Opciones: (a) conservar `declared_version` y el override de Client Hints (baratos, en `chromium_src`) y borrar los 3 parches de extensiones hasta que hagan falta; (b) quitarlo todo y declarar siempre el real. Recomiendo (a).
3. **El override de Client Hints no compila tal cual en 156**: en 156 `GetUserAgentBrandList(major, full, type, additional_brand_version)` ya no recibe el GREASE por política, `GetUserAgentMetadata` solo tiene la sobrecarga `(bool)` y la política `kUserAgentClientHintsGREASEUpdateEnabled` ya no se lee ahí. Además `patches/components-embedder_support-user_agent_utils.cc.patch` sigue siendo el de Brave 1.69 (los macros `BRAVE_GET_USER_AGENT_BRAND_LIST`/`BRAVE_BRAND_VERSION_OVERRIDE_*` hay que reportarlos con el de 1.98). Hay que reescribirlo aunque el nivel sea el real, porque lo de «sin marca Brave» y `platformVersion` mínimo sigue haciendo falta.
4. **`flyweb_min_macos_version`**: Chrome 156 exige macOS 13 (subidas: 11 en 129, 12 en 139, 13 en 151; `base-siguiente.md`). El comentario de `config.gni` se queda en «139+ 12.7.6»: para 156 tocaría un 13.7.x real (comprobar el último Ventura publicado). Lo decide Titín (fue decisión suya, F4.8, por privacidad). El UA sigue diciendo `Intel Mac OS X 10_15_7` (congelado por Chromium).
5. **Número visible**: `kBraveVersionNumberForDisplay` daría «3.0.0 (motor 156)»; decidir si se mantiene «(motor N)» ahora que motor = base.
6. **`CFBundleVersion`/Sparkle**: decidir qué versión de Brave queda en `package.json` (si pasa a 1.98.63 → `198.63.N`, mayor que `169.168.N`: Sparkle actualiza bien; si sigue 1.69.168, `FLYWEB_BUILD_NUMBER` debe superar el de la 2.7.x). En cualquier caso `FLYWEB_BUILD_NUMBER` sube.
7. **Comentarios desfasados** (`declared_version.h` habla de «real 116», `config.gni` de la tabla 1.N/2.N, `version_info_values.h.version` de «2.0.2 (motor 131)»): actualizarlos con la regla nueva (3.0.0 = 156; 3.0.x = seguridad y arreglos).
8. **`v8/src-utils-version.h.patch` (`kFlyWebCacheEpoch`)**: sin parches V8 propios en la 3.0.0 sobra; el cambio de versión de V8 ya invalida las cachés de la 2.x. Reponerlo con el primer parche propio de V8 de la 3.0.x.

##### Decisiones de COORDINACIÓN-29 (05-11, 23:39 UTC)

- **T9** borra (a) los 1319 de nivel y los 70 backports de seguridad de upstream. **T10** (aceptada) lleva los ~55 «reportar»,
  con una condición previa: cruzar cada parche Mojave con `lamosquita-net/chromium` rama `flynk-b1d` (LOCAL ya hizo la capa 10.14
  de Chromium 156 en B1b/B1d, incluido 10.15 → 13; oficial-6 pasa la batería en la 6,1). Lo que esté allí no se reporta en
  brave-core; solo lo que falte o sea de código de Brave. Primero en T10: `audio_param_handler.h` (carrera real),
  `trust_store_chrome.cc` y `pki_metadata_component_installer.cc`.
- (1) `flyweb_engine_full_version` = la última Stable normal de la 156 para Mac (regla de `motor-niveles.md`, nivel 129):
  **156.0.8078.82** según versionhistory (consultado 05-11 23:40 UTC: .82, .81, .80, .79, .76). La base es .90, no publicada como
  Stable de Mac.
- (2) Se conservan `declared_version` y el override de Client Hints, **reescritos para la 156** (FlyWeb seguirá portando por su
  cuenta tras la 3.0.0, #772); los 3 parches de extensiones sobran mientras declarada = real.
- (3) `flyweb_min_macos_version` = la mínima del Chrome declarado (principio 13 de Titín, 12-10): con 156, el último 13.x publicado.
  **13.7.8** (build 22H730): confirmado por LOCAL-19 el 06-11 con `softwareupdate --list-full-installers` en la 7,1, único 13.x
  publicado.
- (4) Se mantiene «(motor N)». (5) `package.json` en la base de 1.98 → `CFBundleVersion` = `198.63.N` (> `169.168.N`: Sparkle lo
  ve como subida); `FLYWEB_BUILD_NUMBER` sube igual.

#### 12.13.5. Observaciones para quien borre la capa

- La capa Mojave de la 2.x (47 parches propios + 2 Brave+FlyWeb) solo cubre 10.14 → 10.15 sobre la 128. La 156 exige macOS 13: además de reportar estos, falta la traducción 10.15 → 11 → 12 → 13 (`base-siguiente.md` §3.2). Tres de los 47 dependen de la vía GPU: con la vía Metal decidida (B1d) sobran `ui-gl-init-gl_display_initializer.cc` y `gpu-ipc-service-image_transport_surface_overlay_mac.mm`; el `BUILD.gn` de Metal de ANGLE depende de cómo compile LOCAL.
- Las decisiones de plataforma (sin Touch ID, sin Secure Enclave, sin autenticador de plataforma: FM.42 d1–d8, 7 parches) no son de Mojave sino de FlyWeb (27-10-2026): se reportan aunque la 156 tenga las API.
- Funciones propias que hay que reportar: pestañas fijadas compartidas (`pinned_tab_codec.cc`), la capa `fw1` en cookies y contraseñas (`sqlite_persistent_cookie_store.cc`, `login_database.cc`; el puente de sync de contraseñas, dudoso), y el arreglo de carrera de `audio_param_handler.h` (la 156 aún lee `automation_rate_` sin cerrojo; candidato a mandarlo a upstream).
- Ningún parche de `patches/` toca formularios verticales: es función de Blink de nivel (Chrome 119/12x) y ya está en 156.
- Maglev: el parche lo apaga; DIRECTIVAS (05-11) lo pone a prueba en B6 con la V8 de la 156. Si B6 falla, se apaga con un flag (`--no-maglev` en gin o un parche de una línea), no con este parche.
- El commit b70c6d590 (T8) ya quitó dos parches de nivel que aún aplicaban; f91290620 ya regeneró `runtime_enabled_features.json5` para 156.

### 12.14 T5, T8 y T9 (MOTOR-34, 05-11)

Sin compilar; `b2-chk.py` no añade nada en ninguna tanda. Ramas y sha en `relevo-motor.md` (MOTOR-34 → MOTOR-35).

- **T5, poda** (un commit por función, revertibles): Playlist, Speedreader (con lol_html 0.3, ahash 0.7 y 65 crates de Cargo.lock
  que solo colgaban de él), WebTorrent, Wayback Machine, Commander y la Sidebar de Brave (el panel lateral de Chromium se queda;
  sin botón en la barra ni Cmd+B). Prefs que puede haber en perfiles de la 2.7.0: obsoletas y limpiadas con `ClearPref`
  (`browser/flyweb/pruned_feature_prefs`).
- **T5, NTP** (§12.11): fuera `ntp_widget_utils`, patrocinados y referidos (con `NTPBackgroundImagesService`), partes muertas de la
  WebUI (Rewards, Talk, pila de tarjetas, widgets), imágenes sin uso y métricas. La clave `new-tab-data` de localStorage solo
  guardaba Rewards y Talk: se borra al cargar. **Única diferencia visible con la 2.7.0:** desaparece la pestaña «Tarjetas» de los
  ajustes de la página (su interruptor ya no controlaba nada).
  **Lista para LOCAL (captura contra la 2.7.0; rutas bajo `components/brave_new_tab_ui`):** fondo (fotos 1–7 al azar, color o
  degradado, foto propia) — `components/default/page/index.tsx`, datos en `components/default/flyweb/recursos.ts` y
  `data/backgrounds.ts`; tipografía D-DIN — `components/default/flyweb/estilos.ts`; mosca — `components/default/flyweb/mosca.tsx`;
  contador de Shields — `containers/newTab/stats.tsx`; reloj 12/24 h — `components/default/clock/index.tsx`; sitios populares
  (añadir, quitar, reordenar) — `containers/newTab/gridSites.tsx`, `gridTile.tsx`, `addSiteTile.tsx`,
  `components/default/editTopSite/index.tsx`; pie (crédito y Personalizar) — `components/default/footer/footer.tsx`; buscador —
  `components/search/SearchPlaceholder.tsx`; ajustes — `containers/newTab/settings.tsx` (fondo, Shields, sitios, reloj,
  buscador). El fondo de arranque del primer inicio es de `brave_welcome_ui`, sin tocar.
- **T5, interfaz mínima** (donante 1.98, sin su rediseño): búsquedas de ventanas con `BrowserWindowInterface`, `navigator/`,
  delegados de BraveBrowser en `BrowserWindowFeatures`, cierre en `UnloadController`, pestañas fijadas compartidas, marco de Mac
  (`BrowserWidget`/`BrowserFrameView`), restos de T4. Parches de `chrome/browser/ui`: 43 de los 45 que no aplicaban, aplican.
  Fuera los paneles de lectura y marcadores propios de Brave (1.98 también; revertible). **Para las notas de la 3.0.0** (aceptado por COORDINACIÓN-29; la 156 quitó
  el gancho): `brave://` ya no sale en la burbuja de estado, la pestaña de la nueva pestaña vuelve a tener favicon y desaparece
  «quitar de la lista» del menú de descargas.
  **Falta (T5-bis):** vistas de pestañas, pestañas verticales, menú de perfil, maquetación del panel lateral, infobars.
- **T8:** Privacy Sandbox apagado (`runtime_enabled_features.json5` desde 1.98, sin Tor; Private State Tokens a experimental) con
  la prueba de navegador `flyweb_privacy_sandbox_apis_browsertest` y su gemela `FlyWeb/tools/privacy-sandbox.html`; con JS
  bloqueado en Shields, `chrome://settings`, la nueva pestaña y `chrome://extensions` siguen (la 156 decide el JS en el navegador
  con la lista de esquemas exentos; prueba `flyweb_script_block_internal_pages_browsertest`).
- **T9:** pins estáticos de Brave fuera; la capa de nivel (1319) y los 70 backports de seguridad, fuera (§12.13); fuera
  `FlyWeb/{v8,dragonbox,fast_float}-revision`; restos de Wallet fuera (cadenas, ajustes, constantes y URLs, allowlists, Android
  en C++, 15 dependencias npm, `third_party/{argon2,bitcoin-core,ethash}`, `crypto_wallets`; prefs `brave.wallet` limpiadas).
- **T9-ver:** 3.0.0, nivel 156, 156.0.8078.82, mínimo macOS 13.7.8, `package.json` 1.98.63 (CFBundleVersion 198.63.N), Client
  Hints reescritos para la 156; `declared_version` se conserva.

