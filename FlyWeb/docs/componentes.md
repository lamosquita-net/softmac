# FlyWeb — Componentes y servidor propio (Fase 2)

Inventario de lo que el navegador descarga por el actualizador de componentes y plan para servirlo desde
`components.flyweb.lamosquita.net` (encargo S3 de [`disenos.md`](disenos.md)). Sacado del código de brave-core 1.57.64
(rama `flyweb` + `nube/*` hasta el paso 26) el 02-10-2026. Rutas relativas a brave-core.

## 1. Conclusión

**Para dejar de hablar con Brave no hace falta volver a firmar nada.** El navegador comprueba dos firmas en cada CRX:
la del propio componente (su ID es el hash de esa clave) y la "prueba de publicador" (Google o Brave). Ambas
viajan dentro del fichero. Si nuestro servidor sirve **los mismos CRX de Brave sin tocarlos**, copiados a diario
desde el almacén de Brave, las dos siguen siendo válidas. En el navegador solo cambia una URL:

```sh
FLYWEB_UPDATER_URL=https://components.flyweb.lamosquita.net/extensions FlyWeb/scripts/build.sh
```

Es la misma estrategia que la hoja de ruta ya preveía para CRLSet ("espejo sin modificar"), extendida a todo. Volver a
firmar con una clave nuestra solo hace falta si un día queremos **listas distintas** de las de Brave (§5).

Lo que sí cambia: quien habla con Brave es el servidor (una vez al día), no cada navegador cada pocas horas.

## 2. Componentes de Brave

| # | Componente | ID | Clave en brave-core | Cuándo se registra | En FlyWeb |
|---|---|---|---|---|---|
| 1 | Shields: lista por defecto | `iodkpdagapdfkphljnddpjlldadblomo` | `components/brave_shields/browser/ad_block_service.cc:36` | Siempre (al arrancar) | Activo |
| 2 | Shields: excepciones (primera parte) | `adcocjohghhfpidemphmcmlmhnfgikei` | `ad_block_service.cc:49` | Siempre | Activo |
| 3 | Shields: recursos (scriptlets) | `mfddibmblmbccpadfndgakiopmmhebop` | `ad_block_component_installer.cc:29` | Siempre | Activo |
| 4 | Shields: catálogo de listas | `gkboaolpopklhgplhaaiboijnklogmbc` | `ad_block_component_installer.cc:42` | Siempre | Activo |
| 5 | Shields: listas regionales y opcionales (una por lista) | Las da el catálogo (`regional_catalog.json`, campo `list_text_component`) | No está en el código | La del idioma, una vez; las demás si el usuario las activa | Activo |
| 6 | HTTPS Everywhere | `oofiananboodjbbmdelgdommihjbkfag` | `browser/brave_shields/https_everywhere_component_installer.cc:33` | Siempre | Activo |
| 7 | Datos locales (debounce, limpieza de URL, Greaselion y otras listas) | `afalakplffnnnlkncjhbmahjfjhmlkal` | `components/brave_component_updater/browser/local_data_files_service.h:22` | Siempre | Activo |
| 8 | Fondos de la nueva pestaña (fotos) | `aoojcmojmmcbpfgoecoadbdpnagfchel` | `components/ntp_background_images/browser/ntp_background_images_component_installer.cc:28` | Al abrir la nueva pestaña | Activo; desaparece con la NTP propia (F7.2) |
| 9 | Cliente de Tor y transportes | 4 + 3 ID por plataforma | `components/tor/brave_tor_client_updater.cc`, `…pluggable_transport_updater.cc` | Solo al abrir una ventana Tor | Sin tocar |
| 10 | Nodo IPFS (kubo) | 5 ID por plataforma | `components/ipfs/brave_ipfs_client_updater.h` | Solo si se arranca el nodo local | Sin tocar (sección oculta en el paso 25) |
| 11 | Detector de Playlist | `jccpmjhflblpphnhgemhlllckflnipjn` | `components/playlist/browser/media_detector_component_installer.cc:68` | Función `Playlist` (apagada) | No se descarga |
| — | Imágenes patrocinadas, Super Referral | ~730 ID | `sponsored_images_component_data.cc` | — | **Quitado** (paso 8) |
| — | Datos del monedero | `bbckkcdiepaecefgfnibemejliemjnio` | `wallet_data_files_installer.cc:48` | — | **Quitado** (paso 6) |
| — | Recursos de anuncios de Brave | ~430 ID | `components/brave_ads/browser/component_updater/component_util.cc` | Solo con Rewards | No se descarga (Rewards quitado) |

En uso normal se descargan los números 1–8, más las listas regionales activas. Es lo que vio F1.6: unas 73 peticiones
a `go-updater.brave.com` en 30 minutos, porque Brave pregunta **componente a componente**
(`chromium_src/components/update_client/update_checker.cc`).

## 3. Componentes de Google

| Componente | ID | Qué hace Brave | Estrategia |
|---|---|---|---|
| CRLSet (certificados revocados) | `hfnkpimlhhgieaddgfemjhofmfblmnib` | Lo registra y fuerza una actualización al arrancar (`chromium_src/chrome/browser/component_updater/crl_set_component_installer.cc:26`) | Espejo sin modificar. Clave y publicador de Google |
| File Type Policies | `khaoiebndkojlmppeemjhbpbandiljpe` | Fuerza una actualización | Espejo sin modificar |
| Widevine (DRM) | `oimompecagnajdejgnnjijobebaeigek` | Solo si el usuario lo acepta | Redirigir a Google (como hace `go-update`) o no servirlo |
| Resto de componentes de Chromium 116 que Brave no bloquea | — | Lista de bloqueo en `chromium_src/components/component_updater/component_installer.cc:32` (Origin Trials, Subresource Filter, phishing del lado del cliente, FLoC…) | **Por comprobar en el checkout de Chromium** (LOCAL): cuáles quedan registrados y si salen en la auditoría |

## 4. Lo que tiene que hacer el servidor (SERVIDOR, S3)

Base: **`brave/go-update`** (comprobado el 02-10-2026: existe, MPL-2.0, Go 1.26, último commit 23-07-2026).
- Responde al protocolo Omaha en `POST /extensions` (y `GET`). Sirve los componentes que conoce y **redirige a Google**
  lo que no conoce. También sirve de filtro: bloquea componentes antes de redirigir.
- Dependencias de Brave, todas configurables:
  - El catálogo se lee de **DynamoDB** (`controller/controller.go:49`), con `DYNAMODB_ENDPOINT` para otro servidor.
    Opciones: DynamoDB Local en la misma máquina, o un cambio pequeño para leer un JSON.
  - Las URL de descarga apuntan a `S3_EXTENSIONS_BUCKET_HOST` (por defecto `brave-core-ext.s3.brave.com`,
    `extension/utils.go:49`) → poner el nuestro.
  - Sentry (`SENTRY_DSN`): dejarlo vacío.

Tarea diaria:
1. Pedir a `go-updater.brave.com` la versión vigente de cada componente de §2 y de cada lista del catálogo.
2. Descargar los CRX nuevos de `brave-core-ext.s3.brave.com` y publicarlos en nuestro almacén.
3. Actualizar el catálogo (ID, versión, SHA-256).
4. Hacer lo mismo con CRLSet y File Type Policies desde Google.

Sin claves privadas, sin firmar nada. Licencias: el servidor redistribuye las listas sin cambios, con su atribución
(EasyList y EasyPrivacy GPLv3 / CC BY-SA 3.0, uBlock Origin GPLv3).

## 5. Si algún día queremos listas propias

Entonces sí hace falta firmar:
- **Clave por componente.** Cada componente modificado necesita una clave nueva, porque el ID es el hash de la clave.
  Hay que cambiar en brave-core las constantes de §2 (filas 1–4) y meter las claves de las listas regionales en
  nuestro `regional_catalog.json`.
- **Prueba de publicador.** El navegador exige la de Google o la de Brave (`EnforceCRX3PublisherProof`, activada por
  defecto: `chromium_src/components/component_updater/component_updater_service.cc:9`). Habría que añadir el hash de
  nuestra clave de publicador junto a `kBravePublisherKeyHash` (`chromium_src/components/crx_file/crx_verifier.cc:15`).
- **Claves privadas fuera del repo** (regla 5 de `TAREAS.md`).

No hay ningún motivo para hacerlo ahora.

## 6. Detalles del lado del navegador

- **URL.** Se fija al compilar con `updater_prod_endpoint` / `updater_dev_endpoint` (`build.sh`). Brave la añade como
  `--component-updater=url-source=…` (`app/brave_main_delegate.cc:155`). Las actualizaciones de extensiones usan la misma
  URL (`common/extensions/brave_extensions_client.cc:20`).
- **Cabecera.** Cada consulta lleva la cabecera `BraveServiceKey: flyweb` (`brave_services_key`). `go-update` no la
  comprueba.
- **HSTS.** `go-updater.brave.com` tiene HSTS y fijado de clave. Nuestro dominio no, ni lo necesita.
- **Prueba sin compilar.** En principio vale `--component-updater=url-source=https://components…/extensions`, pero Brave
  añade también la suya y no está comprobado cuál gana. Mejor con una compilación con `FLYWEB_UPDATER_URL`.
- **Comprobación final.** En `brave://components`, "Buscar actualizaciones" en cada componente. La auditoría
  (`network-audit.py --mode reposo` y `--mode uso`) no debe mostrar ningún destino de Brave.
- **Fallo conocido de Brave, que no nos afecta.** En `build/commands/lib/config.js:940`, `updater_prod_endpoint` se
  asigna a la variable del entorno de desarrollo. FlyWeb pasa las URL directamente con `--gn`.

## 7. Qué envía FlyWeb en cada consulta de componentes

Sacado del código: Chromium 116 `components/update_client/protocol_serializer*.cc`, la configuración de Brave
(`browser/component_updater/brave_component_updater_configurator.cc`) y el recorte de FlyWeb
(`nube/componentes-minimos` 10f9114d = paso 27 de `integracion.md`). Es una petición POST con JSON, una por componente.

| Dato | Chromium | Brave 1.57 | **FlyWeb** |
|---|---|---|---|
| ID y versión del componente (`appid`, `version`), y si está activado | Sí | Sí | **Sí** (necesario) |
| Versión del navegador (`prodversion`, `updaterversion`) | Sí | Sí | **Sí** |
| Sistema y arquitectura (`@os`=`mac`, `arch`=`x64`, `os.platform`=`Mac OS X`, `os.arch`) | Sí | Sí | **Sí** (para servir el binario correcto en Tor o IPFS) |
| Canal (`stable`) | Sí | Sí, fijo | **Sí, fijo** |
| Identificadores de la sesión y de la petición (`sessionid`, `requestid`) | Aleatorios en cada consulta | Igual | **Igual**. No persisten: no sirven para seguir a nadie |
| Cabeceras `X-Goog-Update-AppId`, `-Updater`, `-Interactivity` | Sí | Sí | **Sí** (repiten el ID, el producto vacío y si la consulta la pidió el usuario) |
| Cabecera `BraveServiceKey` | — | Sí | **Sí, `flyweb`**, igual para todos |
| Idioma de la interfaz (`lang`), producto, preferencia de descarga | Sí | Vacíos | Vacíos |
| **Memoria instalada y CPU** (`hw.physmemory`, `sse`…`avx`) | Sí | Sí | **No** (ceros para todos) |
| **Versión exacta del sistema** (`os.version`, p. ej. 10.14.6) | Sí | Sí | **No** |
| **Día de instalación de cada componente** (`installdate`) | Sí | Sí | **No** |
| **Contadores de actividad** (`ping`: último día activo, *roll call*, `ping_freshness`) | Sí | Sí | **No** |
| **Avisos posteriores** de instalación y actualización (tiempos de descarga, códigos de error) | Sí | Sí, al mismo servidor | **No** (sin URL de aviso) |
| Cohorte (`cohort`) | Si el servidor la asigna | Igual | Igual. Nuestro servidor no asigna |

Por qué se quitan: la memoria, los indicadores de CPU (una 5,1 sin AVX con 48 GB es casi única) y la versión exacta del
sistema, juntos, distinguen equipos. La fecha de instalación es estable por equipo. Los contadores de actividad son el
mecanismo de Google para contar usuarios únicos por día. Ninguno hace falta para responder qué versión hay de cada
componente.

En el servidor (`FlyWeb/servidor/e0/`) no se guarda la IP ni el User-Agent. Lo único que queda en el registro es la
fecha, la ruta, el estado y el tamaño de cada petición, durante 7 días.

Pendiente de comprobar en una compilación (LOCAL): capturar una consulta real (NetLog o `chrome://net-export`) y
confirmar que el JSON coincide con la columna FlyWeb.
