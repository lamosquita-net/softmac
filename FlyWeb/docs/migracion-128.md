# FlyWeb — plan de la migración de base 116 → 128 en Mojave, con brave-core (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.31; sigue a `base-128.md`, que estimó la parte de APIs de macOS). Sin código ni ramas.
**Propone; deciden ARQUITECTURA o Titín.** Esta vez **medí** el salto de brave-core con los repositorios reales
(clonados en modo lectura, sin tocarlos), de modo que casi todas las cifras de §2 son **[V]** y reproducibles.

**Etiquetas:** **[V]** medido o visto en una fuente; **[I]** inferido; **[H]** hipótesis. Las horas son **estimación mía**
(trabajo efectivo de agente o LOCAL, **sin** esperas de compilación ni tiempo de Titín en las máquinas).

## 1. Resumen

1. **Brave que corresponde a Chromium 128:** **1.69.168** (Chromium 128.0.6613.138, 11 de septiembre de 2024) [V: [release](https://github.com/brave/brave-browser/releases/tag/v1.69.168)].
   Salto desde la 1.57.64: **30 740 ficheros cambiados** en brave-core (+2,54 M / −0,76 M líneas) [V].
2. **Lo nuestro es grande pero estructurado.** La rama `flyweb` lleva **700 commits** y **2 422 ficheros** distintos de la 1.57.64
   [V]. De ellos, **1 366 son ficheros nuevos que Brave no toca** (sobre todo 1 327 `.patch` de motor y seguridad) y **733 son
   traducciones** (`.xtb/.grd/.grdp`) [V]. El trabajo humano real es **~99 ficheros de código con conflicto** y **34 que Brave
   movió o borró** (§2).
3. **Más de la mitad del coste de brave-core es mecánico:** 614 de los 713 conflictos de una fusión «a pelo» son
   traducciones y Android; se **regeneran con el script de reemplazo** de marca, no se fusionan (§3, B).
4. **La mayor parte de los 1 372 `.patch` de motor desaparece en la 128:** los de los niveles 117–128 (≈ 577 con el nivel
   en el asunto del commit, más RubyLB y FM.17, que son del 128 [V]) **ya están en el árbol**; hay que **volver a cortar**
   los de los niveles 129–131 y los escapes posteriores (≈ 300–450 ficheros [H]).
5. **El repositorio `brave-browser` de FlyWeb no tiene cambios propios:** su `flyweb` es el tag 1.57.64 [V]; ese paso es
   trivial (2–4 h).
6. **Horas, brave-core y FlyWeb sin la parte de APIs: ≈ 230–560 h.** Con las APIs de `base-128.md` (85–220 h):
   **≈ 320–780 h, central ~550 h** [H]. Es compatible con el 330–710 h de `base-128.md`, ahora con desglose medido.
7. **Recomendación (confianza media):** el plan es viable y **tiene una puerta barata antes de comprometer horas** (Fase 0, ~1–2
   días de LOCAL y SEGURIDAD-PORTES, §6). No empezarlo sin esos dos datos: compilación limpia de la 128 para 10.14 y cuántos
   CVE de 117–128 fuera de Blink y V8 aplican a la 116.

## 2. Qué medí (reproducible)

Clonados en modo lectura `lamosquita-net/brave-core` (rama `flyweb`, cabeza `54b964da`, la 1.15.1) y los tags `v1.57.64`
(`25c5f015`) y `v1.69.168` (`6918a99a`) de `brave/brave-core`; lo mismo para `brave-browser`.

| Medida | Valor |
|---|---|
| FlyWeb contra la 1.57.64 | **2 422 ficheros**: 1 050 modificados, 1 370 nuevos, 2 borrados; +242 579 / −140 500 líneas |
| De los modificados | 733 traducciones (86 de ellas de Android), 57 iconos y **257 de código** |
| De los nuevos: `patches/` / resto | **1 327** / 43 (`components/flyweb_ntp` 15, `ui/webui` 6, `browser/flyweb` 2, `FlyWeb/v8-revision`, `script/flyweb-rebrand-strings.py`…) |
| Brave 1.57.64 → 1.69.168 | 30 740 ficheros; 20 206 nuevos, 12 556 borrados o movidos, 6 973 modificados |
| Ficheros que tocan **los dos** | 813 modificados por ambos; **116** que FlyWeb modificó y Brave borró o movió; 4 nuevos en la misma ruta |
| Fusión de texto de los 813 (`git merge-file`, sin contexto) | 100 limpios; **713 con conflicto** |
| De esos 713: traducciones y Android | **614** (components/strings 162, app/resources 135, android 82…) |
| De esos 713: **código u otro** | **99**: 43 `.cc`, 23 `.patch`, 9 `.h`, 11 `.ts/.tsx`, 4 `.html`, 3 `.js`, 4 `.gn/.gni`… |
| De los 116 borrados o movidos por Brave | 82 son traducciones; **34 de código y parches** (constantes de URL, cartera, anuncios, IPFS, `ad_block_service`, `sidebar`…; 2 son `.patch`) |
| `.patch` nuevos de FlyWeb por commit que los añade | nivel 117–128: 577; nivel 129–131: 166; pasos de V8: 26; seguridad: 42; el resto (551) son portes con nombre propio (RubyLB, FM.17, FM.22…) |
| `brave-browser` de FlyWeb frente a la 1.57.64 | **sin diferencias**; la 1.69.168 cambia 30 ficheros (`package.json`, flujos de GitHub…) |

**Cómo repetirlo:** `git fetch --depth 1` de los tres puntos; `git -c diff.renames=false diff --name-status 1.57.64 flyweb` y
`… 1.57.64 1.69.168`; cruzar rutas; `git merge-file` con base 1.57.64, nuestro y el de la 1.69.168. (Los scripts son de
una sola vez; si se quieren en el repositorio, es un encargo aparte.)

**Límites de la medida:** el `merge-file` de texto sobrestima los conflictos de código (no usa contexto ni detecta
movimientos) y la clasificación de parches por el asunto del commit es aproximada [I]. Cuenta como orden de magnitud.

## 3. Qué hay que hacer con cada cambio propio

| Clase | Qué es | Ficheros | Qué se hace | Horas |
|---|---|---|---|---|
| **A. De serie en la 128** | Portes de motor de los niveles 117–128, RubyLB, FM.17 (V8 12.8), parches de CVE anteriores a sept. de 2024 (CVE-2023-5217, 2023-7024, 2024-0519, 2024-4671, 2024-4761, 2024-5274…) | ≈ 900–1 000 `.patch` [H] | **Desaparecen.** Se comprueba que no queda ninguna diferencia con Chrome (`motor-N.html`, WPT) | 0 (la comprobación va en D) |
| **B. Regenerar por script** | Marca en traducciones y cadenas (pasos 5, 5b, 44; `script/flyweb-rebrand-strings.py`, `chromium-rebase-l10n.py`) | **614** conflictos de traducción + 86 de Android que se **quitan** | Volver a ejecutar el reemplazo sobre la 1.69 y revisar el diff; las cadenas nuevas de Leo y compañía hay que mirarlas a mano | **8–16** |
| **C. Rehacer a mano** | Código de Brave tocado por FlyWeb: marca de interfaz (7, 9, 23, 28), `flyweb://` (34), sin cartera (6), sin servicios (8, 10, 12, 13, 14, 22, 27, 29, 43), componentes propios (30, 32), sync propio (25, 36, 42), traducir (39), Google Web Store (40), proxies (35), NTP y bienvenida (31, 33) | **~76 ficheros** de código con conflicto + **34** movidos o borrados | Fusionar uno a uno; los 34 movidos, volver a decidir dónde viven (p. ej. `url_constants`, `webui_url_constants`, `network_constants`) | **70–180** (40–110 + 30–70) |
| **D. Volver a cortar sobre la 128** | Motor de 129–131, escapes de FM.22 posteriores a la 128, V8 13.x, seguridad de 2025–2026, ML-KEM | ≈ **300–450** `.patch` [H] + 23 con conflicto con parches de Brave | Aplicar con las herramientas de `FlyWeb/tools/port/`; cada cambio es más fácil (la 128 está más cerca que la 116). Más la revisión de **diferencias con upstream** (reglas 19 y 20) | **60–150** |
| **E. Servicios nuevos de Brave 1.58–1.69** | `ai_rewriter`, `brave_player`, `psst`, `script_injector`, `brave_service_keys`, `challenge_bypass_ristretto`, y en `browser/`: `onboarding`, `day_zero_browser_ui_expt`, `tab_group`, `storage_access_api` [V: árboles de `components/` y `browser/` en ambos tags] | — | **Auditoría de red** con `scripts/network-audit.py` y `audit/allowlist.txt`; apagar o vaciar lo que salga. Leo ya va apagado por `build.sh` (`enable_ai_chat:false`), pero su código se movió | **20–50** |
| **F. macOS y actualizador** | Sparkle (paso 45), `build/mac` (5 ficheros), firma, DMG. La 1.69.168 **sigue con `sparkle_glue.mm`** y añade `keystone_glue.*` [V: carpeta `browser/mac`] | 5 + `build.sh` | Volver a probar la actualización de una 1.15.x a la nueva; comprobar que el *keystone* no se activa | **12–24** |
| **G. Herramientas de compilación** | `brave-browser` (sin cambios nuestros), `build/commands` (2 conflictos), `build.sh` y `setup-build.sh` (argumentos GN, Node, Python, Rust), SDK 14.0 (de `base-128.md`) | ~10 | Mover a la 1.69.168, fijar `brave-core` y ajustar argumentos | **22–44** |
| **H. Servidor** | Componentes de Shields (formato de `adblock-rust`), sync (go-sync de la versión equivalente), `updates.` | — | Reconstruir y firmar componentes; actualizar go-sync; las URL y claves no cambian | **20–60** [H] |
| **I. APIs de macOS 10.15** | `base-128.md` | — | Según `base-128.md` | **85–220** |
| **J. Validación** | `motor-N.html`, WPT, CVE, Mojave en la 6,1 y la 5,1 | — | Revisión de la regla 17 sobre lo que se vuelva a cortar | **20–40** (Titín y LOCAL) |

**Total sin la clase I: ≈ 232–564 h; con ella, ≈ 317–784 h.** Lo desproporcionado es C y D: son los cambios que se rehacen a mano.

**Ya no hace falta:** el *polyfill* de core-js se quitó en la 1.14 [V: commit «Remove the core-js polyfill injection»];
`kFlyWebCacheEpoch` sigue por V8; los parches `patches/v8` (62) **se quedan**, porque V8 se fija con `FlyWeb/v8-revision`,
independiente de la base.

## 4. Riesgo por parte

| Parte | Riesgo | Por qué |
|---|---|---|
| B (marca en traducciones) | Bajo | Mecánico y repetible; riesgo: cadenas nuevas de Brave con su nombre |
| C (a mano) | **Medio-alto** | Brave movió y borró código (cartera, anuncios, IPFS, constantes); cada decisión puede abrir una fuga de privacidad |
| D (parches de motor) | Medio | Menos conflictos que sobre la 116, pero 300–450 ficheros; regla 17 sobre `LayoutNG` |
| E (servicios nuevos) | **Alto para la privacidad** | Cada subsistema nuevo es una puerta de red; una sola omisión rompe la promesa de no hablar con Brave |
| F (Sparkle, keystone) | Medio | Una actualización rota deja a los usuarios sin actualizar |
| H (servidor) | Medio [H] | Formatos de componentes y de sync pueden haber cambiado |
| I (APIs) | Medio-alto | Ver `base-128.md`: GPU y captura son lo más delicado |

## 5. Orden y puertas

**Fase 0 · Mediciones (1–2 días, antes de comprometer horas).**
1. LOCAL: Chromium 128 **limpio** con `mac_deployment_target = "10.14"` y `-Wunguarded-availability`; recuento de avisos por directorio;
   arrancar en la 6,1 (`base-128.md` §7). Checkout de 128 aparte (~100–150 GB), sin tocar `flyweb-build`.
2. SEGURIDAD-PORTES/VIGÍA: cuántos CVE altos y críticos de 117–128 **fuera de Blink y V8** aplican a la 116 y no están
   portados (`cve-triage.md`).
3. INVESTIGACIÓN-MOTOR (hecho hoy): la medida de brave-core de §2.
**Puerta 0 (ARQUITECTURA/Titín):** seguir si el punto 2 da decenas de CVE y el punto 1 da un arranque limpio y un número de avisos
razonable (<~300); si no, la alternativa de `base-128.md` §6 (subir el listón del triaje de CVE sobre la 116).

**Fase 1 · Brave 1.69.168 limpio en Mojave** (rama `nube/base-128` desde `v1.69.168`, sin nada de FlyWeb): G + I. Hito: arranca y
pinta en la 6,1 y la 5,1 con la GPU bien. **Puerta 1:** si no pasa, se para aquí con el coste ya conocido.

**Fase 2 · Capa de identidad:** B, C y E, en este orden: marca y `flyweb://` → servicios quitados y auditoría de red → componentes,
sync y actualizador (F, H). Hito: auditoría de red limpia (la de `hoja-de-ruta.md`, Fase 1).

**Fase 3 · Motor:** D (niveles 129–131 y escapes), `v8-revision` 13.1 y seguridad de 2025–2026. Hito: `motor-129…131.html` y las WPT
iguales a Chrome (regla 17 en lo que toque `LayoutNG`).

**Fase 4 · Validación y publicación:** J y una versión **menor nueva** (p. ej. 1.16 o 2.0, decide Titín): el nivel declarado
sigue siendo el 131 aunque la base sea la 128.

## 6. Convivencia con las 1.15.x mientras dura

- **Congelar el motor en el nivel 131** hasta la Puerta 1: abrir el 132 sobre la 116 y luego sobre la 128 duplica el coste.
- **Seguridad:** las correcciones urgentes siguen yendo a la 1.15.x (rama `flyweb`); las que se hagan durante la migración se
  anotan para volver a cortarlas sobre la 128 (clase D).
- **Plazo orientativo [H]:** 320–780 h son 2–5 meses de trabajo de un agente a tiempo parcial con LOCAL compilando; Fase 0 y Fase 1
  son las que dan la fecha real.

## 7. Qué falta

- Las dos mediciones de la Fase 0 (LOCAL; SEGURIDAD-PORTES).
- **Brave 1.58–1.69:** lista completa de cambios de servicios; mis datos son de árboles de carpetas, no de las notas de versión
  (la rama `master` de `CHANGELOG_DESKTOP.md` solo conserva versiones recientes).
- **Qué parte de los 551 parches «con nombre propio» es del nivel ≤128** (la clasificación por asunto de commit es aproximada).
- Qué cambió en el formato de `adblock-rust` y en el protocolo de sync entre la 1.57 y la 1.69 (clase H).
- Decidir quién ejecuta el `merge-file` completo (con contexto) en LOCAL: es la medida que cierra la clase C.

## 8. Fuentes

- Medidas propias sobre [lamosquita-net/brave-core](https://github.com/lamosquita-net/brave-core) (`flyweb` 54b964da),
  [brave/brave-core](https://github.com/brave/brave-core) (tags v1.57.64 y v1.69.168) y
  [lamosquita-net/brave-browser](https://github.com/lamosquita-net/brave-browser) [V].
- [Brave 1.69.168](https://github.com/brave/brave-browser/releases/tag/v1.69.168) (Chromium 128.0.6613.138). Árboles de
  `components/`, `browser/` y `browser/mac` en [v1.57.64](https://github.com/brave/brave-core/tree/v1.57.64) y
  [v1.69.168](https://github.com/brave/brave-core/tree/v1.69.168) (resultado de página).
- Proyecto: `integracion.md` (pasos 0–128), `base-128.md`, `cve-triage.md`, `hoja-de-ruta.md`, `scripts/build.sh`, `scripts/network-audit.py`,
  `tools/port/*`.
