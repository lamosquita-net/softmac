# Extensiones: API de Chrome 117–131 frente a FlyWeb (FM.24, MOTOR-11, 16-10-2026)

Medida pedida por COORDINACIÓN-7 (con aprobación de Titín) antes de decidir. Sin código.

## El problema

uBlock Origin Lite no se instala desde la Web Store: «requiere Chrome 122». La tienda trata a FlyWeb como el Chrome que
declara (130 en la 1.14; 131 en la 1.15) y ofrece la versión más reciente. Pero al instalar, el navegador compara
`minimum_chrome_version` con su versión real de Chromium, que es la 116
(`chrome/common/extensions/manifest_handlers/minimum_chrome_version_checker.cc`, `version_info::GetVersion()`).

Además, aunque pasara esa comprobación, la 116 valida el manifiesto con sus propios límites. uBO Lite trae **56
conjuntos de reglas** de `declarativeNetRequest`, y la 116 admite como mucho **50** (`dnr_manifest_handler.cc`): no se
instalaría igualmente.

## 1. Qué cambió en las API de extensiones entre la 116.0.5845.188 y la 131.0.6778.265

**Método.** Comparé `_api_features.json`, `_permission_features.json` y `_manifest_features.json` de
`chrome/common/extensions/api` y de `extensions/common/api`, más los esquemas (`.json` e `.idl`) de las API públicas. Me
quedo solo con lo visible para una extensión normal en el canal estable: sin listas de permitidas, sin ChromeOS, sin API
privadas ni de empresa. El resto de lo que cambió (201 entradas) es un cambio de formato (`contexts`), sin efecto.

| Qué | Chrome | En la 116 | Quién lo pide (de la muestra) | Coste de porte (MOTOR) |
|---|---|---|---|---|
| Límites de `declarativeNetRequest`: conjuntos estáticos 50 → **100**, activos a la vez 10 → **50**, reglas dinámicas 5000 → **30000** «seguras» (+5000 «no seguras»), sesión 5000 aparte | 120–121 | límites viejos; un manifiesto con más de 50 conjuntos **no se instala** | uBO Lite (56 conjuntos), Ghostery, AdGuard | 2–4 h (constantes y la clasificación de reglas seguras y no seguras) |
| `declarativeNetRequest`: condiciones `responseHeaders`/`excludedResponseHeaders` y `regexSubstitution` en `modifyHeaders` | 128 | no existen | bloqueadores avanzados | 4–6 h (casar reglas en la fase de respuesta) |
| `chrome.userScripts` (permiso y API; en la 131 solo con el modo de desarrollador encendido) | 120 | no existe (la 116 tenía piezas internas, sin API) | uBO Lite y Ghostery lo piden | 6–10 h + revisión de SEGURIDAD-PORTES (inyecta código) |
| `chrome.readingList` | 120 | no existe | ninguna de la muestra | 2–3 h |
| Pequeñas: `storage.getKeys()` (130), `tabs.Tab.lastAccessed` (121), `offscreen` con `BATTERY_STATUS`/`MATCH_MEDIA`, `tts.onVoicesChanged` (124), `contentSettings.clipboard` (131), `privacy.websites.relatedWebsiteSetsEnabled` (sustituye a `privacySandboxEnabled`) | 121–131 | no existen | por medir | 2–4 h en total |
| `action.openPopup()` en estable (127) y `action.onUserSettingsChanged` (130) | 127–130 | `openPopup` solo en el canal dev | por medir | 1–2 h |
| `cookies`: `partitionKey` (CHIPS) | 119–130 | no existe en la API (CHIPS sí está en la red) | por medir | 3–4 h |
| `debugger`: `DebuggerSession` (objetivos hijos) | 125 | no existe (la marca `developer_mode_only` de `debugger` en la 116 no hace efecto: `RestrictDeveloperModeAPIs` está apagada) | por medir | 2–3 h |
| Manifiesto: `trial_tokens` (pruebas de origen para extensiones) | 125+ | no existe | ninguna | no hace falta |

Sin cambios que importen: `runtime` (`getContexts()` ya estaba encendido en la 116), `scripting`, `sidePanel` (`open()`
ya estaba encendido en la 116), `tabs` salvo lo de arriba, `windows` y `webRequest`.

**Total para cerrar el hueco entero:** 22–36 h de MOTOR, más la compilación de LOCAL y la revisión de SEGURIDAD-PORTES
de `userScripts` y de las reglas de DNR.

## 2. Extensiones medidas

Manifiestos de la rama principal de cada proyecto en GitHub, a 16-10. La versión publicada en la Web Store puede ir un
poco por detrás.

| Extensión | MV | `minimum_chrome_version` | ¿Se instala hoy (116)? | Con la versión declarada (131) | Qué le falta |
|---|---|---|---|---|---|
| uBlock Origin Lite | 3 | 122.0 | no | **no**: 56 conjuntos de DNR > 50 | límites de DNR (120–121); pide `userScripts` |
| Ghostery | 3 | 122 | no | sí (6 conjuntos) | pide `userScripts`; qué deja de funcionar sin él, por medir |
| KeePassXC-Browser | 3 | 124 | no | sí | todos sus permisos existen en la 116; por qué pide la 124, por medir |
| Bitwarden | 3 | **134** | no | **no** (134 > 131) | ni con la 131 |
| Dark Reader | 3 | 106 | sí | sí | — |
| Proton Pass | 3 | 102 | sí | sí | — |
| React DevTools | 3 | 114 | sí | sí | — |
| Zotero Connector | 3 | 88 | sí | sí | — |
| Return YouTube Dislike | 3 | — | sí | sí | — |
| SponsorBlock | (base) | — | sí | sí | — |
| Privacy Badger, Violentmonkey, ClearURLs, Stylus | 2 en su rama | 61 / 86 / — / — | MV2: la versión de la Web Store puede ser otra | — | por medir |

**No se ha podido medir desde la nube:**
- La Web Store y su servidor de actualizaciones (`chromewebstore.google.com`, `clients2.google.com`): el proxy de la nube
  los bloquea. Por eso no sé qué versión exacta sirve la tienda a un navegador 130/131.
- Las extensiones de código cerrado: Google Translate, Grammarly, 1Password, LastPass, Honey, Tampermonkey, AdBlock,
  Dashlane… Adblock Plus está en GitLab y no lo he mirado.
- Vue DevTools y Consent-O-Matic: no encontré la ruta del manifiesto.

Lo cerrado y la versión real de la tienda solo se pueden medir instalando desde FlyWeb (LOCAL, en la 6,1).

## 3. Recomendación

| Opción | Coste | De las 4 bloqueadas en la muestra… | Riesgo |
|---|---|---|---|
| **A.** Comparar `minimum_chrome_version` con la versión declarada (`flyweb_engine_full_version`) y no con la 116 | ~0,5 h (un parche) + Static | pasan 2 (Ghostery, KeePassXC); uBO Lite sigue fuera (DNR) y Bitwarden también (134) | una extensión que use API de 117–131 se instala y falla a medias, sin avisar |
| **B.** Portar las API por niveles, como el motor | 22–36 h de MOTOR + LOCAL + SEGURIDAD | pasan 3 (no Bitwarden) y funcionan enteras | coste; `userScripts` y DNR tocan seguridad |
| **C.** Aviso claro y lista de extensiones comprobadas | 1–2 h, más las pruebas de LOCAL | ninguna | no arregla nada; sí evita sorpresas |

**Recomiendo A + una parte de B + C, en este orden:**
1. **A**, en la siguiente versión. Lo coherente con el principio 13 (lo que se declara, se cumple) es comprobar contra la
   versión que FlyWeb declara, porque la tienda ya trata a FlyWeb como esa versión.
2. **B mínimo con A (5–9 h):** límites de DNR (2–4 h), las API pequeñas (2–4 h) y `action.openPopup` (1 h). Con eso
   entran uBO Lite y Ghostery, salvo lo que dependa de `userScripts`.
3. **El resto de B, por niveles (15–25 h):** `userScripts` (con SEGURIDAD-PORTES), `responseHeaders` de DNR, CHIPS en
   `cookies`, `debugger` y `readingList`. Encaja en la auditoría de FM.22 o en una fila propia.
4. **C:** que LOCAL instale desde la Web Store, en la 6,1, las 20 extensiones más usadas. Así se mide lo que la nube no
   alcanza (cerradas y versiones reales), y la lista va a «Para la web» de cada versión.

**Lo que esto no arregla:** las extensiones que exigen una versión por encima de la declarada (Bitwarden pide 134). Eso
solo se resuelve subiendo de nivel.
