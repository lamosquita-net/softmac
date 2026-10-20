# FlyWeb — servicios nuevos de Brave 1.58–1.69 (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.35, parte 1: la **clase E** de `migracion-128.md`). Sin código ni ramas. **Propone; decide
Titín.** Para cada servicio nuevo: qué hace, a qué hosts habla, cómo se apaga y qué recomiendo según la regla 20. La
tabla de §3 está pensada para que LOCAL la contraste con `scripts/network-audit.py` en la Fase 1.

**Etiquetas:** **[V]** visto en el código de brave-core (`v1.57.64`, `v1.69.168`, y `v1.70.133`/`v1.73.105` para ver
qué pasó después); **[I]** inferido; **[H]** hipótesis. Las horas son **estimación mía**.

## 1. Resumen

- **Ningún subsistema nuevo de escritorio habla con un host si no se enciende algo que en Brave va apagado** [V]:
  `psst`, `ai_rewriter`, `webcompat` (excepciones), `day_zero` y `brave_player` son *features* **apagadas por defecto**,
  y siguen apagadas en la 1.73 (salvo `brave_player`, que Brave **borró en la 1.70**). El resto es local: `onboarding`,
  `script_injector`, `brave_service_keys` (una biblioteca de firmas) y `challenge_bypass_ristretto` (criptografía de
  fichas).
- **Lo único que Leo (IA) enciende, ya lo apagamos:** `ai_rewriter` depende de `enable_ai_chat`, que `build.sh` pasa a
  `false`. Sus hosts serían `ai-chat.bsg.brave.com` y `ai-chat-premium.bsg.brave.com`.
- **Hay seis subsistemas solo de Android** (`hub`, `tab_group`, `tab_ui`, `language`, `webapps`, `mobile_subscription`):
  no entran en macOS.
- **Lo que sí exige trabajo es el *build***, no el código (§4): la 1.69 pide en Release **dos argumentos nuevos**
  (`brave_services_key_id` y `service_key_aichat`) y **ya no admite dos** de los de `build.sh` (`brave_ai_chat_endpoint`,
  `brave_zero_ex_api_key`; ver FM.34 caso 3).
- **Una decisión para Titín que no es de código:** Widevine (§3, fila 10). Sigue pendiente la de los componentes de Google.
- **Horas:** la clase E de FM.32 (10–30 h) **baja a ≈ 6–14 h** [H]: ≈ 1 h de argumentos, ≈ 2 h para comprobar cada
  *feature* en la 128 y el resto es la auditoría que ya hace LOCAL. El total de FM.32 baja unas 4–16 h.

## 2. Método y límites

- Por cada carpeta nueva de `components/` y `browser/` entre `v1.57.64` y `v1.69.168` (14 y 9 respectivamente [V]), leí
  sus constantes, *features*, `BUILD.gn` y puntos de registro; y comprobé si siguen en 1.70 y 1.73.
- **Hosts:** busqué cadenas `*.brave.com` / `*.bravesoftware.com` **añadidas o quitadas** en los 184 ficheros de
  `components/`, `browser/`, `chromium_src/` y `build/` que las cambian entre las dos versiones (§5).
- **Argumentos de GN:** comparé los `declare_args` de 112 y 118 ficheros de configuración de las dos versiones (§4).
- **Límites.**
  - Es lectura de código: no he compilado ni capturado ningún NetLog. La columna «qué debe ver `network-audit.py`» es lo
    que **espero**.
  - La búsqueda de hosts solo ve cadenas con subdominio; un host `brave.com` sin subdominio o construido por trozos
    (como `ai-chat` + `.bsg` + `.brave.com`) puede escaparse. Para AI Chat lo vi a mano.
  - No he leído línea a línea los 24 ficheros de `challenge_bypass_ristretto`: confío en que es una biblioteca (sus
    únicos dependientes en `BUILD.gn` son `brave_ads`, `brave_rewards` y `skus`).

## 3. Tabla por subsistema (macOS)

Por defecto = estado en la 1.69 (y en la 1.73 si no se dice otra cosa). «Apagar» = lo que hace falta en FlyWeb.

| # | Subsistema | Qué hace | Hosts | Por defecto en Brave | Cómo se apaga | Recomendación (regla 20) | Qué debe ver `network-audit.py` |
|---|---|---|---|---|---|---|---|
| 1 | **`ai_rewriter`** (`components/ai_rewriter`, 22 ficheros) | Reescribe texto con la IA de Leo desde el menú contextual | `ai-chat.bsg.brave.com`, `ai-chat-premium.bsg.brave.com` (a través de AI Chat) [V] | **Apagado** (`AIRewriter`) | GN: `enable_ai_rewriter = enable_ai_chat && escritorio`; con `enable_ai_chat:false` **no se compila** | **Apagado** (ya lo está). Manda el texto del usuario a un tercero | Nada. Si sale `*.bsg.brave.com`: fallo (la denylist `!*.brave.com` ya lo cubre) |
| 2 | **`brave_player`** (7 ficheros) | Reproductor «sin distracciones» de YouTube en `brave://player` | `www.youtube-nocookie.com` (un `<iframe>` con el vídeo, solo si se usa) [V] | **Apagado** (`BravePlayer`) | GN `enable_brave_player` (por defecto `true` en escritorio) → **`enable_brave_player:false`**. **Brave lo borró en la 1.70** | **Quitar con el argumento** (la página embebe un host de Google) | Nada; si saliera, sería de una página |
| 3 | **`psst`** (15 ficheros) | «Privacy Settings Selection for Sites Tool»: ejecuta *scripts* en webs de terceros (X/Twitter…) para cambiar sus ajustes de privacidad; las reglas llegan por un componente (`lhhcaamjbmbijmjbnnodjaknblkiagon`) | Solo el actualizador de componentes. Los *scripts* hablan con la web, no con Brave | **Apagado** (`BravePsst`), **también en 1.73**; el componente **ni se registra** si está apagado [V] | Es una *feature*; sin argumento de GN | **Dejarlo apagado.** Si algún día se enciende, servir el componente desde `components.flyweb…` y revisarlo antes (ejecuta JavaScript en páginas ajenas) | Nada. Si el ID `lhhc…` aparece en el registro de `go-update`: alguien lo encendió |
| 4 | **`script_injector`** (7 ficheros) | Tubería (`mojom`) para ejecutar un *script* en un mundo del renderizador. Lo usa PSST | Ninguno | — | — | **Mantener** (dependencia) | Nada |
| 5 | **`brave_service_keys`** (4 ficheros) | Firma peticiones a servicios de Brave (`Digest`, `Signature`, estilo *HTTP Signatures*). Argumento nuevo `brave_services_key_id` | Ninguno propio | — | GN: `brave_services_key_id` (en Release no puede ir vacío) | Pasar un valor inerte (§4) | Nada |
| 6 | **`challenge_bypass_ristretto`** (26 ficheros) | Fichas anónimas (BAT/Anuncios/SKUs): biblioteca de criptografía en Rust (`cxx`) | Ninguno | — | Es dependencia de `brave_ads`, `brave_rewards` y `skus` | **Mantener** (lo usa código que quitamos o desactivamos por código) | Nada |
| 7 | **`webcompat`** (excepciones; 6–7 ficheros) | Lista de **sitios donde se relajan las protecciones anti-huella** (por tipo: canvas, WebGL, fuentes, audio, `user-agent`…); llega por el componente de datos locales | Solo el actualizador de componentes (el nuestro) | **Apagado** (`BraveWebcompatExceptionsService`), también en 1.73 | *Feature*, sin argumento | **Dejarlo apagado:** relaja la protección contra la huella. Si hiciera falta, con una lista **propia**, sitio a sitio | Nada |
| 8 | **`onboarding`** (`browser/`, 5 ficheros) | Resalta el icono de Shields el primer día y durante 7 días | Ninguno | Siempre activo, local | — | **Mantener**: solo una marca visual y una preferencia local | Nada |
| 9 | **`day_zero_browser_ui_expt`** (6 ficheros) | Experimento en instalaciones nuevas (variante «a») que preconfigura preferencias (Noticias, Recompensas, cartera, imágenes patrocinadas, P3A) | Ninguno; la variante la entrega el servidor de *variations* | **Apagado** (`BraveDayZeroExperiment`); además exige un parámetro `variant=a` | Nuestra URL de *variations* es inerte: **nunca se enciende** | **Dejarlo**: sin servidor de *variations* no actúa | Nada |
| 10 | **`widevine`** (`components/widevine`, 2 ficheros) | Constante del componente del CDM de Widevine (`oimompecagnajdejgnnjijobebaeigek`): Netflix, Spotify… | Descarga desde servidores de Google (`*.gvt1.com`, `dl.google.com`) a través del actualizador | Activo en Brave (Brave lo pide a su servidor y luego a Google) | **Decisión de Titín**: `FLYWEB_NO_REDIRECT=1` en `go-update` lo corta (hoy no llega) | **Pendiente** de la decisión de componentes de Google. Sin ella, no hay vídeo con DRM | Con `NO_REDIRECT`: nada. Sin él: `*.gvt1.com` en reposo (la denylist ya lo marca) |
| 11 | **`storage_access_api`** (`browser/`, 2 ficheros) | Solo pruebas de navegador [V] | Ninguno | — | — | Nada | Nada |

**Solo Android** [V]: `browser/hub`, `browser/tab_group`, `browser/tab_ui`, `components/language`, `components/webapps`,
`components/brave_mobile_subscription`. **`brave_geolocation_permission`** solo define una interfaz *mojo*
(`SetEnableHighAccuracy`); sin red. **`browser/psst`** solo tiene pruebas. **`components/webui`** son ayudantes de la
interfaz (`about_ui`, recursos). No los he mirado más.

## 4. Argumentos de GN: lo que pide la 1.69 (para `build.sh`)

[V] Entre `v1.57.64` y `v1.69.168`:

| Argumento | Estado | Qué hacer en `build.sh` (propuesta; el código lo escribe otro) |
|---|---|---|
| `brave_services_key_id` | **Nuevo.** En Release (`is_official_build`) **no puede ir vacío** (`assert`) | Añadirlo con un valor inerte (`flyweb`); solo en Release |
| `service_key_aichat` | **Nuevo.** En Release **no puede ir vacío**, **aunque `enable_ai_chat` sea `false`** | Añadirlo con un valor inerte; solo en Release |
| `brave_ai_chat_endpoint` | **Ya no existe** | **Quitarlo** (si no, `gn gen` falla) |
| `brave_zero_ex_api_key` | **Ya no existe** (y su `assert` tampoco) | **Quitarlo** |
| `enable_updater` | Sigue en Chromium, pero Brave añade **`brave_enable_updater`** (por defecto `false`) | Pasar `brave_enable_updater:false`; **no** pasar `enable_updater` |
| `enable_brave_player` | **Nuevo** (por defecto `true` en escritorio); desaparece en la 1.70 | `enable_brave_player:false` |
| `enable_ai_rewriter` | **Nuevo**, derivado de `enable_ai_chat` | Nada (con `enable_ai_chat:false` se apaga solo) |
| `enable_brave_vpn_wireguard` | **Nuevo**, derivado de `enable_brave_vpn` | Nada (con `enable_brave_vpn:false` se apaga solo) |
| `enable_orchard`, `enable_zcash_by_default` | **Nuevos** (cartera: Zcash) | Nada: la cartera está quitada en el código (FM.34 caso 3) |
| `zebpay_*` (8 argumentos) | **Nuevos** (Recompensas) | Nada: no tienen `assert` |
| `enable_ipfs`, `enable_ipfs_internals_webui`, `enable_ipfs_local_node` | **Ya no existen** (Brave quitó IPFS) | Si estuvieran en `build.sh`, quitarlos. No están |
| `p3a_*_upload_url`, `p2a_json_upload_url`, `star_randomness_host` | **Ya no existen** | No están en `build.sh` |
| `brave_version_patch`, `tag_installdataindex` | `brave_version_patch` se quita; `tag_installdataindex` es de Windows | Nada |

`brave_p3a_enabled` sigue con su `assert` en Release («P3A must be enabled in the official build»), igual que en la
1.57: no cambia nada respecto a hoy.

## 5. Hosts nuevos en el código de Brave 1.58–1.69

Cadenas `*.brave.com`/`*.bravesoftware.com` **que aparecen solo en las líneas añadidas** [V]:

| Host | Dónde | Efecto en FlyWeb |
|---|---|---|
| ≈ 20 de la cartera (`api.0x.wallet.brave.com` y 10 redes, `jupiter.`, `lifi.`, `api-meld.`, `s.wallet.`, `wallet.`, `bitcoin-mainnet.wallet.`, `solana-mainnet.wallet.`, `simplehash.wallet-cdn.`, `multichain.ankr.wallet.`) | `brave_wallet_constants.h`, `network_manager.cc`, `simple_hash_client.cc` | **Ninguno** si la cartera sigue apagada (FM.34 caso 3) |
| `ai-chat.bsg.brave.com` | entrada del generador de la lista HSTS precargada (`transport_security_state_generator`) | Leo apagado |
| `star-randsrv.bsg.brave.com` | `brave_network_audit_allowed_lists.h` (la lista de auditoría **de Brave**) | P3A (STAR); apagado |
| `griffin.brave.com` | `variations/command_line_utils.cc` | *Variations*: nuestra URL es inerte |
| `updates.bravesoftware.com` | `chromium_src/chrome/updater/branding.gni` | Actualizador de Brave: apagado (`brave_enable_updater`) |
| `vpn.brave.com`, `leo.bravesoftware.com`, `feedback.brave.com` | texto de una página interna, icono, generador de HSTS | Sin tráfico del navegador |

**Los que desaparecen:** `brave-today-cdn.brave.com` (Brave Noticias), varios de la cartera (`mainnet-infura…`,
`mainnet-polygon…`, etc.), `ai-chat.proxy.brave.com`. La denylist `!*.brave.com` y `!*.bravesoftware.com` ya los cubre
a todos: **no hace falta añadir nada** a `audit/denylist.txt`.

## 6. Qué comprobar en la Fase 1 (LOCAL, con `network-audit.py`)

1. **Reposo:** cero hosts fuera de `allowlist.txt` (con `*.brave.com` en la denylist de «!»). Los seis dependientes de una
   *feature* apagada (filas 1, 2, 3, 7, 9) no deben aparecer.
2. **Uso:** `www.youtube-nocookie.com` solo con origen `pagina`; `*.gvt1.com` solo si se ha decidido Widevine.
3. **Servidor de componentes:** ninguna petición de los ID `lhhc…` (PSST) ni `oimompec…` (Widevine, salvo decisión).
4. **`chrome://flags`** (o `flyweb://flags`) en la 128: comprobar que `BravePsst`, `AIRewriter`,
   `BraveWebcompatExceptionsService` y `BraveDayZeroExperiment` salen **desactivadas** (≈ 2 h).
5. **`gn gen` en Release** con la lista de §4: sin avisos de «argumento sin efecto».

## 7. Qué no pude comprobar

- **Ninguna captura de red.** Todo lo de «hosts» y «qué debe ver» es lectura de código.
- **Funciones apagadas por *flag* que un servidor de *variations* de Brave podría encender**: con nuestra URL inerte no
  llegan, pero depende de que la URL siga inerte en la 128.
- **Servicios nuevos dentro de carpetas que ya existían** (por ejemplo, ficheros nuevos de `brave_news`, `brave_vpn` o
  `brave_ads`): solo vi las carpetas nuevas y los hosts. Los hosts añadidos de §5 los cubren en parte.
- **Servicios de Brave 1.70–1.73** (parte 2 de FM.35): aquí solo se comprueba que los de la 1.69 siguen igual.
- **Horas = estimación mía.**

## 8. Fuentes

- brave-core `v1.57.64`, `v1.69.168`, `v1.70.133`, `v1.73.105`: `components/{ai_rewriter,brave_player,psst,script_injector,
  brave_service_keys,challenge_bypass_ristretto,webcompat,widevine}`, `browser/{onboarding,day_zero_browser_ui_expt,
  brave_browser_features.cc,net/brave_network_audit_allowed_lists.h}`, `components/ai_chat/core/browser/engine/`, y los
  `declare_args` de `build/`, `components/*/buildflags*` y `updater/config.gni`.
- Proyecto: `migracion-128.md` (clase E), `brave-vs-flyweb.md` (FM.34 caso 3), `scripts/build.sh`,
  `scripts/network-audit.py`, `audit/allowlist.txt` y `audit/denylist.txt`, `servidor/componentes/README.md`.
