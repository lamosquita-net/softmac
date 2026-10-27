# FlyWeb — plan de la migración de base 116 → 128 en Mojave, con brave-core (INVESTIGACIÓN-MOTOR)

Estudio en papel (filas FM.31 y FM.32; sigue a `base-128.md`). Sin código ni ramas. **Propone; deciden ARQUITECTURA o Titín.**
**Revisado el 20-10-2026 (FM.32):** las horas de la primera versión (320–780 h) eran demasiado altas; con medidas sobre los repositorios
reales y los datos de los niveles ya entregados bajan a **≈ 130–330 h (central ~230 h)**. Lo medido y lo supuesto van separados
(§3 y §4).

**Etiquetas:** **[V]** medido o visto en una fuente; **[I]** inferido; **[H]** hipótesis. Las horas son **estimación mía** (trabajo efectivo de
agente o LOCAL, **sin** esperas de compilación ni tiempo de Titín en las máquinas).

## 1. Resumen

1. **Brave que corresponde a Chromium 128:** **1.69.168** (Chromium 128.0.6613.138, septiembre de 2024) [V]. Desde la 1.57.64: 30 740 ficheros
   cambiados en brave-core.
2. **Las horas bajan a ≈ 130–330 h (central ~230 h)**; la primera versión decía 320–780 h (central ~550). Cuatro causas, todas medidas:
   (a) **~1 040 de los 1 372 `.patch` de motor ya vienen de serie en la 128** y solo se vuelven a cortar **~320** (§3, clase D);
   (b) de los **257 ficheros de código** propios, **164 son fáciles** y solo **3 difíciles** (clase C);
   (c) **Chromium Legacy** ya resolvió casi todo lo de macOS 10.15: **31 de 44 ficheros se aplican idénticos** a la 128 (clase I);
   (d) los portes se hicieron a **5–9 ficheros por hora de reloj** y la estimación de los niveles 129 y 130 salió **~10 veces pesimista** (§4).
3. **Brave 1.58–1.69 casi no depende de macOS > 10.14** (clases C y E): una sola guarda nueva (`@available(macOS 11.0)` en `geolocation_utils_mac.mm`) y
   ninguna modificación del destino de despliegue [V: búsqueda en los dos tags]. Los 17 parches de Brave sobre ficheros de macOS de Chromium son el
   punto de contacto con lo de la clase I (§5).
4. **Lo que sigue sin medir** (y puede subir la cifra): los avisos del compilador sobre la 128 limpia con destino 10.14 (LOCAL), la parte de GPU
   (Dawn, ANGLE, Skia y listas de GPU, que no están en el repositorio de Legacy) y cuántos CVE de 117–128 fuera de Blink y V8 compensan el salto
   (SEGURIDAD-PORTES). Si el ritmo real fuera la mitad del medido, el techo subiría a ~450 h.
5. **Recomendación (confianza media):** con ~230 h el plan deja de ser desproporcionado frente a lo que ya se invirtió en los niveles 117–131, y la **Fase 0**
   (~1–2 días de LOCAL y SEGURIDAD-PORTES) sigue siendo la puerta antes de comprometer horas.

## 2. Qué se midió (reproducible)

Clonados en modo lectura `lamosquita-net/brave-core` (rama `flyweb`, cabeza `54b964da`, la 1.15.1) y los tags `v1.57.64` (`25c5f015`) y `v1.69.168`
(`6918a99a`) de `brave/brave-core`; `brave-browser` igual; y, para la clase I, `blueboxd/chromium-legacy` (tag `1303823`, 127.0.6494.0) y los tags
`127.0.6494.0` y `128.0.6613.138` de `chromium/chromium` (solo árboles, sin descargar el código).

| Medida | Valor |
|---|---|
| FlyWeb contra la 1.57.64 | **2 422 ficheros** (1 050 modificados, 1 370 nuevos, 2 borrados); 700 commits |
| De los modificados | 733 traducciones (86 de Android), 57 iconos y **257 de código** (25 de ellos son parches nuestros sobre parches de Brave) |
| De los nuevos | 1 327 `.patch` y 43 de otro tipo (`components/flyweb_ntp` 15, `ui/webui` 6, `browser/flyweb` 2…) |
| Brave 1.57.64 → 1.69.168 | 30 740 ficheros; 20 206 nuevos, 12 556 borrados o movidos, 6 973 modificados; 539 → 590 parches de Chromium |
| Ficheros que tocan los dos | 813 modificados por ambos, 116 que Brave borró o movió |
| Fusión de texto de los 813 | 100 limpios y 713 con conflicto; de ellos **614 son traducciones y Android** y **99 de código** |
| Los 257 de código, por dificultad (§3, clase C) | **140 fáciles** (71 fusión limpia, 53 que Brave no toca, 16 solo de marca), **78 medios**, **39 difíciles**; tras revisar una muestra (§3) quedan 164 / 65 / 3 en los 232 que no son parches |
| `.patch` primer añadidos por commit | 1 372: ≤ nivel 128 (niveles, RubyLB, FM.17), 1 040 aprox.; a volver a cortar ≈ 320; V8 (se queda, §3) 14 |
| Parches de Brave sobre ficheros de macOS de Chromium | 17 (`app_controller_mac.mm`, `permissions_utils.mm`, `render_widget_host_view_cocoa.mm`, `keychain_password_mac.mm`, instalador y firma…) |
| Argumentos de GN de `build.sh` | **35 de 37 siguen en la 1.69**; desaparecen `brave_ai_chat_endpoint` y `brave_zero_ex_api_key` |
| `brave-browser` de FlyWeb frente a la 1.57.64 | sin diferencias; la 1.69.168 cambia 30 ficheros (`package.json`, flujos de GitHub…) |

**Cómo repetirlo:** `git fetch --depth 1` de los puntos; `git -c diff.renames=false diff --name-status 1.57.64 flyweb` y `… 1.57.64 1.69.168`; cruzar rutas;
`git merge-file` con base 1.57.64; para los parches, `git log --no-merges --diff-filter=A --name-only -- patches/` y agrupar por el asunto del commit y su fecha.
Los scripts son de una sola vez; si se quieren en el repositorio, es un encargo aparte.

## 3. Tabla A–J revisada

**Medido [V]** y **supuesto [H]** van en columnas distintas. «FM.31» es la estimación anterior; «Revisado», la actual.

| Clase | Qué es | Medido [V] | Supuesto [H] | FM.31 | **Revisado** |
|---|---|---|---|---|---|
| **A. De serie en la 128** | Niveles 117–128, RubyLB, FM.17, escapes de FM.22 con flag estable ≤128, CVE anteriores a sept. de 2024 | De 1 372 `.patch`, ~1 040 son de eso (577 de niveles 117–128, 71 RubyLB, 109 FM.17, 207 de FM.22 y ~76 portes con nombre propio de niveles ≤124) | Que la 128 lleve todo lo que Chrome 128 lleva | 0 | **0** |
| **B. Regenerar por script** | Marca en traducciones y cadenas | 614 conflictos de traducción y Android (se regeneran o se quitan); el script `script/flyweb-rebrand-strings.py` existe | Hará falta revisar a mano las cadenas de Leo y compañía | 8–16 | **6–14** |
| **C. Rehacer a mano** | 232 ficheros de código no-parche (marca de interfaz, `flyweb://`, sin cartera, sin servicios, componentes, sync, traducir…) | **164 fáciles, 65 medios, 3 difíciles** tras la muestra (abajo) + 43 ficheros nuevos que se llevan | Ritmo: 0,02–0,05 h el fácil, 0,15–0,5 h el medio, 1–4 h el difícil | 70–180 | **20–60** |
| **D. Volver a cortar** | Niveles 129–131, escapes de FM.22 posteriores a la 128 (15), seguridad de 2025–2026, V8 13.x en Blink | **~320** `.patch` (166 de niveles 129–131, 15 de FM.22, 103 con otro nombre y fecha ≥ 14-10, ~35 de seguridad), más 14 de V8 que no se tocan; ritmo del primer porte: 7,5 ficheros/h (nivel 129) y 8,9 (FM.22) | Que re-cortar sobre la 128 cueste menos que portar sobre la 116 (menos rechazos) | 60–150 | **28–70** |
| **E. Servicios nuevos de Brave 1.58–1.69** | `ai_rewriter`, `brave_player`, `psst`, `script_injector`, `brave_service_keys`, `challenge_bypass_ristretto`; `browser/`: `onboarding`, `day_zero_browser_ui_expt`, `tab_group`, `storage_access_api` | 10 subsistemas nuevos (carpetas); `enable_ai_chat` y VPN siguen existiendo; **0 dependencias de macOS > 10.14** (§5) | 1–3 h por subsistema con `network-audit.py` | 20–50 | **10–30** |
| **F. macOS y actualizador** | Sparkle, `build/mac`, firma | `sparkle_glue` cambia 6–8 líneas; `build/mac/BUILD.gn` +65 líneas; `enable_sparkle` sigue; en la 1.69 aparece además `keystone_glue.*` | Que el *keystone* no se active | 12–24 | **6–14** |
| **G. Herramientas de compilación** | `brave-browser`, `build/commands`, `build.sh`, SDK 14.0 | `brave-browser` sin cambios propios; **35 de 37 argumentos** siguen; 2 desaparecen; 2 conflictos en `build/commands` | Versiones de Node, Python y Rust; claves obligatorias nuevas en Release | 22–44 | **8–20** |
| **H. Servidor** | Componentes de Shields, sync, `updates.` | Los componentes de Shields son **listas de texto** (sin DAT binario); el motor pasa de adblock-rust 0.7.9 a 0.8.11 | Cambios del protocolo de go-sync entre la 1.57 y la 1.69 | 20–60 | **8–24** |
| **I. APIs de macOS 10.15** | `base-128.md` | **Chromium Legacy (127.0.6494.0): 44 ficheros con cambios de 10.15 (≈2 500 líneas); 31 son idénticos en la 128 y su diff aplica tal cual** (§6) | Los 13 que cambian se fusionan con poco esfuerzo; la parte de GPU (Dawn, ANGLE, Skia) no está en Legacy | 85–220 | **25–55** |
| **J. Validación** | `motor-N.html`, WPT, CVE, Mojave en la 6,1 y la 5,1 | — | Tiempo de Titín y LOCAL | 20–40 | **20–40** |
| | | | **Total** | **320–780** | **≈ 130–330 (central ~230)** |

**Sin las clases I y J (lo de brave-core y FlyWeb):** ≈ 85–230 h (antes 232–564).

### Muestra de la clase C (diff leído, no fusión de texto)

- **Fáciles (164 de 232):** 71 fusionan limpios, 53 no los toca Brave, 16 son solo marca; **24 de los 32 «borrados o movidos» son `brave://` → `flyweb://` en
  comentarios o URL**, o funciones que Brave quitó (p. ej. IPFS, `brave_wallet_pin_service.cc`) y entonces **nuestro cambio desaparece con la función**.
- **Medios (65):** los que Brave movió de carpeta pero siguen siendo lo mismo (`ad_block_service.cc` → `content/browser/`, que lleva nuestros ID de componente;
  `url_constants.cc` con 185 líneas de enlaces de ayuda; `kBraveUIScheme`) y los que Brave renombró (`brave_location_bar_view.cc`: `BraveNewsLocationView`
  pasa a `BraveNewsActionIconView`, y nuestra supresión se rehace sobre el nombre nuevo).
- **Delicados por privacidad, aunque pocos en horas:** `chromium_src/components/embedder_support/user_agent_utils.cc` (Brave lo refactorizó con macros nuevas; ahí vive la regla 20:
  marca y *Client Hints*), `network_constants.cc` (proxies), `ad_block_*` (componentes propios). Revisión de SEGURIDAD-PORTES.
- **Difíciles (3):** `browser/ui/tabs/shared_pinned_tab_service.cc` (19 conflictos; **Brave 1.69 ya trae su propio `SharedPinnedTabService` con vista ficticia**, así que
  parte de lo nuestro puede quedar superado: FM.25), `brave_location_bar_model_delegate.cc` y `brave_new_tab_ui/…/page/index.tsx`.
- **Los 25 parches nuestros sobre parches de Brave** (21 medios, 4 difíciles, p. ej. `bind_gen/interface.py.patch` con 3 739 líneas) entran en la clase D: si son de un nivel ≤128, **desaparecen**.

## 4. Calibración con las horas reales de los niveles ya entregados

**Medido [V]** (filas FM.19–FM.22 y commits de `flyweb`):

| Dato | Estimación original | Real |
|---|---|---|
| Nivel 129 | «~5–6 días de MOTOR» | **~9,5 h** del paso de V8 a la entrega (FM.20); 43 `.patch` en 5,7 h de commits |
| Nivel 130 | «~8–10 días de MOTOR» | el código del nivel, **~1,6 h** (15:50–17:25); la cifra de días «usaba la unidad del inventario del 129, unas diez veces pesimista» (FM.20); en horas de reloj, 11–14 h |
| Nivel 131 | 5–7,5 h de MOTOR (2,3 veces el 130) | entregado a PUBLICACIÓN ~30 h después de su primer commit (15-10 16:12 → 16-10 ~22:00), con 114 `.patch` |
| FM.22 (1.15.1) | 21–31 h de MOTOR | **226 `.patch` en 25 h** de reloj entre el primer y el último commit |

**Ritmo medido de un porte:** 7,5 (nivel 129) y 8,9 (FM.22) ficheros de parche por hora de reloj [V: tiempos de commit]; el nivel 130, 5–6 por hora de código.
**Aplicado [H]:** a la clase D (~320 ficheros) a 5–9 ficheros/h salen 36–64 h **como primer porte**; re-cortar sobre la 128 deja menos rechazos, de modo que usé
**28–70 h** (incluye 8–16 h de revisión de diferencias con upstream, reglas 19 y 20). **A las clases C, E, F, G y H** no hay medidas directas de fusión de código de Brave:
usé el ritmo medido como suelo y mi ritmo prudente como techo. **Límites de esta calibración:** los tiempos de commit pueden infravalorar (se hacen por ráfagas) y un porte de
parches no es lo mismo que fusionar código de Brave, que exige entender el cambio; por eso el techo de cada fila sigue alto.

## 5. Brave 1.58–1.69 y macOS > 10.14 (clases C y E)

- **Medido [V]:** búsqueda de `@available`, `API_AVAILABLE`, `__builtin_available`, `IsAtLeastOS10_1x`, `mac_deployment_target`, `10.15` en brave-core: 68 coincidencias en la 1.57, 88 en la 1.69;
  **solo una línea nueva es de macOS**: `browser/ui/geolocation/geolocation_utils_mac.mm` con `@available(macOS 11.0, *)` (con guarda, así que en 10.14 sigue el otro camino).
  `text_recognition.mm` usa 10.15 y 13.0 **con guarda desde la 1.57**. Brave **no toca el destino de despliegue**. La nota de la 1.69.168 dice que deja macOS 10.14 y anteriores, por Chromium.
- **Límite:** esa búsqueda solo ve marcas explícitas; **un uso sin guarda de una API de 10.15 no deja marca**. Solo el compilador lo encuentra (Fase 0).
- **Punto de contacto [V]:** de los 17 parches de Brave sobre ficheros de macOS de Chromium, **`chrome-browser-app_controller_mac.mm.patch` y `ui-base-cocoa-permissions_utils.mm.patch`**
  tocan ficheros que también cambian los reverts de Legacy (clase I): fusión a mano de esos dos.
- **Consecuencia:** las clases C y E **no suman horas por macOS**; lo de macOS está todo en la clase I.
- **Comprobado a fondo (21-10, [`brave-169-macos.md`](brave-169-macos.md)) [V]:** índice de disponibilidad del SDK 14.5 contra todas las líneas nuevas de macOS de la 1.69.
  Hay **dos** guardas nuevas, no una: falta `default_accelerators_mac.mm`, con `@available(macos 12.0)` en minúsculas.
  Ninguna llamada sin guarda; Brave no toca GPU ni Dawn; un solo framework nuevo (CoreLocation, 10.6). Rust queda en el
  objetivo de Chromium. Conclusión igual: 0–2 h por macOS en brave-core.

## 6. Clase I: qué se aplica casi tal cual de Chromium Legacy (BSD-3)

Comparado el árbol de `blueboxd/chromium-legacy` (tag `1303823`, el 127.0.6494.0) con el `127.0.6494.0` de Chromium **[V]**:

- **226 ficheros** con cambios de versión de macOS; **54** tocan 10.15 y **172** solo 10.14 y anteriores, que no nos hacen falta (Mojave ya los tiene; Legacy llega a 10.7).
- **Mínimo decidido por Titín (20-10): Mojave 10.14.** Esta clase I (25–55 h) **no cambia**. Una marca `10.N` es una comprobación en esa frontera y solo hace falta si el mínimo es inferior a 10.N. Medido contra Chromium 128 sobre los ficheros de Legacy 124: con marca 10.15 son 53 (29 idénticos, 15 limpios, **9 a mano**); High Sierra habría añadido 37 ficheros (10 a mano, ≈ 19–42 h): ver `legacy-evolucion.md`.
- De los 54, **44** (sin `remoting/` ni el README) tienen **≈ 2 500 líneas** de cambio. **31 de esos 44 son idénticos entre Chromium 127.0.6494.0 y 128.0.6613.138** (1 555 líneas): el diff de Legacy
  se aplica **tal cual**. **13 cambian de la 127 a la 128** (934 líneas de Legacy): `app_controller_mac.mm`, `screen_mac.mm`, `bluetooth_adapter_mac.mm`,
  `menu_controller_cocoa_delegate_impl.mm`, `browser_non_client_frame_view_mac.mm`, `supported_types.cc`, `message_pump_kqueue.cc`, `mac_intent_picker_helpers.mm`,
  `chrome/browser/BUILD.gn` y `chrome_content_browser_client.cc` (con hunks pequeños de 3–7 líneas aunque el fichero cambió mucho), entre otros.
- **Cubre** casi todas las filas de `base-128.md`: AuthenticationServices, `_CSCheckFixDisable`, pantallas, `launch_application`, CTFont↔NSFont, captura de vídeo, permisos de pantalla,
  xHE-AAC, cuentagotas, truncado del sandbox, Bluetooth y mandos.
- **No cubre:** Dawn, ANGLE y Skia (repositorios aparte; Legacy los guardó en 2023–2024), las listas de GPU de `gpu/config` (parte de los 172 ficheros), y lo que Chromium 128 añadió tras la 127.
- **Hay que extraer solo los hunks de 10.15**: el diff completo de Legacy trae 5 366 líneas más de 10.7–10.14. Licencia BSD-3, compatible con la raíz MIT (cada software con su licencia).
- **Horas [H]:** aplicar los 31 idénticos, 2–4 h; fusionar los 13, 8–20 h; GPU y lo que Legacy no cubre, 6–12 h; compilar y arreglar, 4–10 h → **25–55 h** (antes 85–220).

## 7. Riesgo por parte (revisado)

| Parte | Riesgo | Por qué |
|---|---|---|
| B (marca en traducciones) | Bajo | Mecánico y repetible |
| C (a mano) | **Medio** (antes medio-alto) | Solo 3 difíciles; **delicados**: UA y *Client Hints*, proxies y componentes (privacidad) |
| D (parches de motor) | Medio | ~320 ficheros, ritmo medido; regla 17 sobre `LayoutNG` |
| E (servicios nuevos) | **Alto para la privacidad** | Una sola omisión rompe la promesa de no hablar con Brave |
| F (Sparkle, keystone) | Medio | Una actualización rota deja a los usuarios sin actualizar |
| H (servidor) | Bajo-medio | Listas de texto: poco riesgo; sync por medir |
| I (APIs) | **Medio** (antes medio-alto) | Legacy ya lo resolvió casi todo; **GPU y Metal sin cubrir** |

## 8. Orden y puertas

**Fase 0 · Mediciones (1–2 días, antes de comprometer horas).**
1. LOCAL: Chromium 128 **limpio** con `mac_deployment_target = "10.14"` y `-Wunguarded-availability`; recuento de avisos por directorio; **comparar con los 44 ficheros de la clase I**
   (lo que el compilador señale y no esté en Legacy es lo que falta). Checkout de 128 aparte (~100–150 GB), sin tocar `flyweb-build`.
2. SEGURIDAD-PORTES/VIGÍA: cuántos CVE altos y críticos de 117–128 **fuera de Blink y V8** aplican a la 116 y no están portados.
3. LOCAL: el `merge-file` con contexto de los 99 ficheros de código (cierra la clase C).
**Puerta 0 (ARQUITECTURA/Titín):** seguir si el punto 2 da decenas de CVE y el punto 1 da un arranque limpio y menos de ~300 avisos no cubiertos por Legacy.
**Fase 1 · Brave 1.69.168 limpio en Mojave** (rama `nube/base-128`, sin nada de FlyWeb): G + I. Hito: arranca y pinta en la 6,1 y la 5,1. **Puerta 1.**
**Fase 2 · Capa de identidad:** B, C y E; luego F y H. Hito: auditoría de red limpia.
**Fase 3 · Motor:** D, `v8-revision` 13.1 y seguridad de 2025–2026. Hito: `motor-129…131.html` y WPT iguales a Chrome.
**Fase 4 · Validación y publicación:** J y una versión menor nueva; el nivel declarado sigue siendo el 131.
**Convivencia:** congelar el motor en el nivel 131 hasta la Puerta 1; las correcciones urgentes siguen yendo a la 1.15.x y se anotan para volver a cortarlas sobre la 128.

## 9. Qué falta

- Fase 0 completa (LOCAL; SEGURIDAD-PORTES).
- **Brave 1.58–1.69:** lista completa de servicios nuevos (los datos son de carpetas, no de notas de versión) y las **claves obligatorias nuevas** de un Release oficial (se ven al primer intento de LOCAL).
- La clasificación de los ~103 parches «con otro nombre» posteriores al 14-10 es por fecha, no por asunto.
- Qué parte de lo de `shared_pinned_tab_service.cc` (FM.25) queda superada por el servicio propio de Brave 1.69.
- Cambios del protocolo de sync (go-sync) entre la 1.57 y la 1.69.
- GPU: Dawn, ANGLE y Skia sobre Metal en Mojave (la parte que Legacy no cubre).

## 10. Fuentes

- Medidas propias sobre [lamosquita-net/brave-core](https://github.com/lamosquita-net/brave-core) (`flyweb` 54b964da), [brave/brave-core](https://github.com/brave/brave-core) (v1.57.64 y v1.69.168),
  [lamosquita-net/brave-browser](https://github.com/lamosquita-net/brave-browser), [blueboxd/chromium-legacy](https://github.com/blueboxd/chromium-legacy) (tag 1303823) y
  [chromium/chromium](https://github.com/chromium/chromium) (127.0.6494.0 y 128.0.6613.138) [V].
- [Brave 1.69.168](https://github.com/brave/brave-browser/releases/tag/v1.69.168) (Chromium 128.0.6613.138).
- Proyecto: `integracion.md`, `base-128.md`, `cve-triage.md`, `scripts/build.sh`, `scripts/network-audit.py`, `servidor/componentes/README.md`, `docs/TAREAS.md` (FM.19–FM.22, FM.25, FM.31, FM.32), `tools/port/*`.
