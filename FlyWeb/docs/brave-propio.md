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
   - `components/os_crypt/sync/keychain_password_mac.mm` (**llavero «FlyWeb Safe Storage» / cuenta «FlyWeb»**, identidad fija de `CLAUDE.md`): Brave lo movió a `os_crypt/common` ([cr143]) y Chromium borró `os_crypt/sync` entero en la 149 (commit b8aa9d78b de Brave, «Remove sync backend» en Chromium). Además **`kUseAsyncOsCryptInLoginDatabase`, que FlyWeb enciende en FS.25 para las contraseñas `fw1`, ya no aparece en `password_features.cc` de 156** [V]; ha podido pasar a otro fichero o borrarse [N]. Hay que repasar el camino `fw1` (parches de `login_database.cc`, `password_store_built_in_backend.cc` y cookies, más `os_crypt/async/common/encryptor.cc`) **antes de B3**: un error aquí es pérdida de contraseñas del usuario [I].
   - `components/captive_portal/.../captive_portal_service.cc`: FlyWeb apaga siempre la detección (Brave la fuerza y llama a su host). Brave lo pasó a plaster (b287783cd, 2026-08-06, «[plaster] `//components/captive_portal`»): rehacer como commit `privacy`.
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

### 11.8 Estado y relevo

- **Hecho:** v1 (#706), P0 (#707), §10, **esto**: §11.1–11.7 (clasificación de los 556 ausentes con el commit de Brave que los quitó; medida de papel de los 579 parches; plan de poda medido; receta de B2).
- **Falta:** (1) `gn desc` con LOCAL (qué se compila de verdad); (2) la compilación de B2 y B1 (LOCAL/MOTOR); (3) leer los diffs de los commits de §11.4 (b, c) y las 8 filas FlyWeb de §11.4(a); (4) leer el código de los cambios de §10.2 que se decidan traer; (5) la puerta de Titín (A/B/C) y su sí a la poda; (6) los envoltorios se midieron por nombre y por `#define`, no por «aplica» [N].
- **Trampas de método (nuevas):** (i) `git fetch <oid>` en un repo parcial de Chromium va de uno en uno (~20 s por blob): usar `curl` a `raw.githubusercontent.com/chromium/chromium/<etiqueta>/<ruta>` (0,4 s); (ii) `git log -M` en un repo sin blobs se queda calculando: usar `--no-renames` y comparar hashes de blob entre árboles; (iii) `git log --diff-filter=D --no-renames` con árboles funciona (1,6 s sobre 18 905 commits); (iv) el `master` del fork es 1.98.37 (28-09), no 1.98.63; (v) `pkill -f` con un patrón que aparece en la propia orden mata la shell.
