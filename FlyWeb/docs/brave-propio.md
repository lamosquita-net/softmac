# ¿Llevar brave-core 1.69 entero a Chromium 156, o absorber solo lo que usamos?

INVESTIGACIÓN-MOTOR-7, 03-11-2026, encargo de COORDINACIÓN-24 (con la pregunta de Titín). **Solo papel.** No he leído el código
de `lamosquita-net/brave-core` (no está en el alcance de esta sesión): todo sale de los documentos del repo y de ficheros sueltos de
`brave/brave-core` v1.69.168 (el listado de árbol de GitHub da 403 desde aquí). Marcas: **[V]** leído en documento del repo o en fuente
citada; **[I]** inferencia mía; **[N]** el repo no lo dice o no se ha medido. Sin horas nuevas: las que salen son de documentos previos.
Complementa `base-siguiente.md` (riesgo 1, B2, decisión 3) y `fork-propio.md` (§5.1, F4).

## 1. Conclusión

1. **Opción C, mixta y en orden: podar primero, absorber después, disolver solo si las medidas lo piden.**
   - **Poda en sitio** de `brave-core` en la base 128: borrar el código de lo que ya está apagado (Wallet, Rewards/Ads/SKUs,
     Leo/AI Rewriter, VPN, News, Talk, IPFS, Player, PSST…). Es lo que la directiva «apagar, no borrar» (DIRECTIVAS, 20-10) preveía
     para «cuando tengamos el fork propio». Se hace antes del salto a 156, para que B2 mida el árbol ya podado.
   - **Absorción gradual** en la capa permanente del fork (F4 de `fork-propio.md`): lo que siga vivo de `patches/` (590 parches de Brave)
     y los `chromium_src` que solo envuelven un fichero de Chromium pasan a commits `Flynk-Class` del fork.
   - **No disolver `brave-core` ahora.** Es el sistema de compilación, empaquetado, l10n, identidad y Shields; sacarlo a la vez que se
     cambia de base suma dos transformaciones de riesgo alto. Decidir tras B2 (§7).
2. **La premisa de Titín es cierta a medias.** Es cierto que lo añadido de la 1.57 a la 1.69 son sobre todo servicios que apagamos
   (clase E: 10 subsistemas nuevos, 0 dependencias de macOS > 10.14, casi todos apagados o solo Android; `brave-servicios-nuevos.md`).
   Pero el coste del salto a 156 no lo pone lo que Brave añadió, sino **lo que FlyWeb tiene enganchado a Chromium**: 590 parches de
   Brave, 1 555 ficheros `chromium_src`, 2 422 ficheros propios sobre la 1.57 (257 de código) y, sobre todo, la capa de interfaz.
   Que lo apagado no se deba arrastrar es correcto; que «el resto» se pueda tirar sin más no está medido.
3. **Falta el dato decisivo**: cuánto de esos 590 + 1 555 + 257 pertenece a funciones muertas. Ningún documento lo da. Se mide en
   un día de trabajo en la nube con lectura de `brave-core` (§6, P0); sin esa tabla, A, B y C son opiniones.
4. **Cuidado con el nombre «Leo»**: es el asistente de IA (se quita) y también el sistema de diseño `@brave/leo` (MIT [V]), del que cuelgan
   los WebUI que sí usamos (D-DIN se aplicó cambiando `@brave/leo`, `disenos.md` §2). Podar Leo no es borrar `@brave/leo`.

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
- Mojom y recursos WebUI compartidos con lo apagado: **[N]** ningún documento los enumera. Es lo primero que mide P0.
- Pruebas: `brave/test/BUILD.gn` y los *browsertests* de lo apagado siguen compilándose [N: sin lista].
- Los parches no se deshacen solos: `apply_patches` no revierte los que crean ficheros (TRAMPAS).

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

Lo que sigue es propuesta mía; la composición de la UI de `brave-core` 1.69 es de conocimiento general, **no verificada aquí** [I]:

| Parte de la UI | Propuesta | Razón |
|---|---|---|
| Botón y panel de Shields, contadores | **Se queda** (WebUI, poco acoplado a las vistas de Chromium) | Es la razón de ser de FlyWeb |
| NTP, bienvenida, `flyweb://` | **Propios** | Ya lo son |
| Barra lateral de Brave (Sidebar) | **Sobra**: usar el panel lateral de Chromium si hace falta | Solo se parchea para quitar Talk; es una superficie de parches que cambia cada hito [I] |
| Botones de barra de Rewards, Wallet, VPN, Leo | **Borrar** con su código | Muertos |
| Pestañas verticales, tarjetas, estilo propio de pestaña | **Sobra**, salvo D8 si Titín lo mantiene | Se pinta sobre `TabStyle` de Chromium, que cambia con cada rediseño [I] |
| Menú de aplicación y menú contextual de Brave | **Sobra**: el de Chromium + las entradas de Shields | [I] |
| Ajustes extra de Brave | **Podar** (Rewards, Web3, Leo, VPN, Sidebar…) | Muertos o prescindibles |
| Temas y colores de Brave (`@brave/leo`) | **Se queda** `@brave/leo` en los WebUI; el tema de la ventana, a Chromium | `@brave/leo` es dependencia de los WebUI que usamos |
| Omnibox con sugerencias de Brave Search | **Sobra** | DuckDuckGo es el buscador por defecto |

Regla para decidir cada elemento (P5): se queda si da algo que Chrome no da y no choca con el rediseño de Chromium del hito; si no, se usa el de Chromium.
La razón principal es el coste: cada vista de Brave que sustituye a otra de Chromium es un conflicto en cada rebase.

## 6. Fases e hitos (sin horas)

| Fase | Qué | Hito (se cumple cuando) | Quién |
|---|---|---|---|
| **P0 Medir** | Con lectura de `lamosquita-net/brave-core` (`add_repo`, que ordena COORDINACIÓN): clasificar cada fichero y parche por función (muerta, viva, UI, build) y tamaño: ficheros, líneas, `patches/`, `chromium_src`, mojom, recursos WebUI y pruebas | Tabla función × (ficheros, líneas, parches, `chromium_src`) y lista de dependencias vivas → muertas | INVESTIGACIÓN-MOTOR (nube) |
| **P1 Poda en sitio** (rama de `brave-core`, base 128, **después** de publicar la 2.7.0) | Borrar por orden: hojas sin acoplamiento (Leo/AI Rewriter, VPN, News, Talk, Player, PSST, WebCompat, DayZero, IPFS) y luego las acopladas (Wallet, Rewards/Ads/SKUs/`cbr`) | Compila y arranca igual que antes; `network-audit.py` sin cambios; `strings` sin `bsg.brave.com`; tabla antes/después de ficheros y parches | MOTOR, LOCAL |
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

(i) No he visto el código de `lamosquita-net/brave-core`; las rutas de 1.69 que cito vienen de los documentos. (ii) No hay tamaños por función ni lista de dependencias
muertas → vivas: es P0. (iii) De-AMP, Tor, Speedreader y Playlist no están documentados. (iv) La composición de la UI de Brave (§5) es de conocimiento general.
(v) La lectura de licencias no es asesoría legal. (vi) Las horas citadas son de documentos anteriores y suelen salir pesimistas.
**Fuentes:** `fork-propio`, `base-siguiente`, `brave-vs-flyweb`, `brave-vs-parches-motor`, `brave-sync-shields`, `brave-servicios-nuevos`, `brave-169-macos`, `brave-170-173`,
`integracion`, `identidad-128`, `rebranding`, `componentes`, `disenos`, `marca-pendiente`, `migracion-128`, `web-flyweb`, `hoja-de-ruta`, `TRAMPAS.md`, `DIRECTIVAS.md`;
`brave/brave-core` v1.69.168 (`LICENSE`, `package.json`, `BUILD.gn`); `brave/adblock-rust` `Cargo.toml` (rama principal); `brave/leo` `package.json` (rama principal).
