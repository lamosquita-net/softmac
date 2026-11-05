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
