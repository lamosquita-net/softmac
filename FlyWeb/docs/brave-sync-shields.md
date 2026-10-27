# FlyWeb — Brave 1.57 → 1.69 en sync y Shields (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.34, caso 1). Sin código ni ramas. **Propone; decide Titín.** Complementa la clase H de
`migracion-128.md` (§3) y cierra su pendiente «cambios del protocolo de sync entre la 1.57 y la 1.69».

**Etiquetas:** **[V]** visto en el código o en el historial de los repos; **[I]** inferido; **[H]** hipótesis. Las
horas son **estimación mía**. Nada de esto se ha compilado ni probado en un navegador.

## 1. Resumen

- **Sync: casi todo vale.** El token de autenticación, el endpoint (`brave_sync_endpoint`) y el servidor no cambian
  [V]. Lo de Brave que cambia entre 1.57 y 1.69 es API de Chromium y diagnóstico. **Una sola diferencia de datos:**
  en Chromium 128 el historial se sincroniza como `HISTORY` y ya no como `TYPED_URLS` [V]; el historial no cruzará
  entre FlyWeb 1.x y 2.0 (§2.3).
- **Shields: el servidor sigue valiendo en lo esencial, pero hay que cambiar tres cosas** (§3): (1) el catálogo pasa de
  `regional_catalog.json` a `list_catalog.json`, con las listas por defecto como entradas ocultas; (2) el motor pasa
  de adblock-rust 0.7.9 a 0.8.11 y el `resources.json` de 0.8.11 sigue siendo autocontenido (ignora `dependencies`),
  así que `recursos-20.mjs` repite el formato de la 1.x salvo la política de scriptlets «trusted»; (3) los ficheros de brave-core donde fijamos los ID y las claves **se movieron de carpeta**.
- **Servidor antes que cliente, y los dos formatos a la vez.** FlyWeb 1.x y 2.0 se actualizarán contra el mismo
  servidor: `regional_catalog.json` y `list_catalog.json` pueden ir en el mismo zip, pero los recursos necesitan **un
  ID nuevo para la 2.0** (§3.4).
- **Horas:** ≈ **18–38 h** en total, repartidas entre la clase C (cliente, 8–14 h) y la H (servidor, 10–24 h) de
  `migracion-128.md`. **Esos rangos aguantan; el total no cambia.**
- **Orden:** primero lo que protege la privacidad (el serializador y los pings del actualizador), después los ID de
  componentes, después sync (§5).

## 2. Sync

### 2.1 Qué cambió en Brave (v1.57.64 → v1.69.168)

[V] En las carpetas de sync de brave-core hay 57 ficheros modificados, 5 nuevos y 8 borrados. Lo que he leído es,
sobre todo, API de Chromium:

| Cambio | Efecto en nosotros |
|---|---|
| `brave_sync_auth_manager.cc`: `Base64Encode` devuelve valor, `ToJsTime` → `InMillisecondsFSinceUnixEpoch` | Ninguno. **El token es el mismo:** `base64(hora_hex\|firma_hex\|clave_pública_hex)` más la cabecera de clave de servicio |
| `brave_sync_server_commands.cc`: `SyncerError` con `type()` | Ninguno en el protocolo |
| Borrados: `brave_syncer_device_poll.*` (sondeo forzado de dispositivos cada 15 s) y `chromium_src/.../syncer.cc` | **Menos peticiones a ns2** [I]: el cliente ya no fuerza ese sondeo |
| `BraveSyncServiceImpl`: sin la migración «Sync v1» y con «leave chain details» (diagnóstico local) | Ninguno |
| `features.cc`: quitadas `kBraveSyncHistoryDiagnostics` y `kBraveSyncSendAllHistory` | **Nuestra edición de `features.cc` desaparece** (era un comentario y `flyweb://`); `kBraveSync` sigue activa por defecto [V] |
| Nuevo `chromium_src/components/sync/base/features.cc` | Apaga `kSyncEnableBookmarksInTransportMode`; sin cuenta de Google no debería afectarnos [I] |
| `chromium_src/.../model_type.cc` y `.h` | `HISTORY` pasa a **cifrable** y ya no es de baja prioridad (el servidor solo ve datos cifrados) |

El endpoint sigue siendo el argumento de GN `brave_sync_endpoint`, con el mismo `assert` y el mismo `buildflag` en
las dos versiones [V]. `build.sh` no cambia.

### 2.2 Nuestros cambios de cliente sobre sync

[V] Son cuatro, y Brave no toca tres de ellos (tampoco el cuarto en lo que nos importa):

| Nuestro cambio | ¿Lo toca Brave 1.57→1.69? | Veredicto |
|---|---|---|
| `brave_sync_configure.ts`, `brave_sync_setup.ts`, `brave_sync_code_dialog.html` (sin QR, directo a las palabras) | **No.** Las tres cadenas de las que dependen (`syncCodeDialogType`, `choose`, `handleChooseMobile_`) siguen en la 1.69 | **Vale tal cual** |
| `brave_sync_account_deleted_infobar_delegate.cc` (`flyweb://` en un comentario) | **No** (sí la parte de `views/infobars`, que no tocamos) | Se rehace con el script de marca |
| `chromium_src/.../keychain_password_mac.mm` («FlyWeb Safe Storage») | **No.** Solo cambia de línea el parche de Brave que lo usa | **Vale tal cual**; comprobar tras compilar que el nombre del llavero no cambia (regla «no cambiar sin migración») |
| `features.cc` | Reescrito | Nada que rehacer |

Sí cambia `brave_sync_subpage.ts` en Brave (`assert_ts.js` → `assert.js`), que no tocamos.

### 2.3 Protocolo y datos

- **Cliente.** El protocolo de sync de Chromium 116 → 128 es aditivo [I]; el servidor ya lleva las definiciones de
  Chromium 124 (go-sync `e4b539e`, abr. 2024: `sessionsCommitDelaySeconds` ya no lo usa el cliente [V]).
- **Servidor.** Nuestro `go.mod` fija go-sync de **2026-09-09** [V]; desde entonces solo hay *lint*. Ya incluye el tipo
  historial (oct. 2023, `client_tag_hash` como ID, sin comprobación de versión), la caducidad del historial (14 días
  en nuestro README) y las cuotas (50 000 objetos, 30 000 de historial); `sqlite.go` lo implementa [V]. **No hay
  nada que adaptar en el servidor para un cliente 1.69.**
- **Historial.** En Chromium 116 `HISTORY` existe, pero `kSyncEnableHistoryDataType` está apagada y el historial va
  por `TYPED_URLS`. En Chromium 128 `TYPED_URLS` ya no está en la enumeración y todo va por `HISTORY` [V, ficheros de
  Chromium 116.0.5845.188 y 128.0.6613.138]. Consecuencias [I]:
  1. Un FlyWeb 2.0 no leerá el historial que subieron los 1.x, ni al revés. Marcadores, contraseñas y ajustes **sí**
     cruzan.
  2. Los `TYPED_URLS` viejos quedan en ns2 como objetos normales (sin caducidad) y **cuentan para la cuota de 50 000**.
     Hay que borrarlos al cerrar la 1.x o al migrar (una consulta en `sqlite.go`, 1–2 h).
  3. El historial de la 2.0 es **nuevo en el servidor**: cifrado, con caducidad de 14 días y su cuota. Nada que decidir,
     pero hay que decírselo al usuario.
- **Encadenar versiones.** Dos Macs en la misma cadena con 1.x y 2.0 funcionan [I], salvo el historial; conviene
  probarlo (§5).

## 3. Shields y componentes

### 3.1 Qué hay de nuestro en esta zona

[V] Nuestro cliente fija en brave-core **cinco** pares de ID y clave pública (lista por defecto, lista de primera
parte, recursos, catálogo, datos locales), la clave del publicador en `crx_verifier.cc`, un serializador que recorta
la petición al actualizador, el fin de los pings y una lista de componentes de Google permitidos. El servidor
(`servidor/componentes`) construye, firma en bak y sirve.

### 3.2 Qué cambió en Brave

| Tema | 1.57.64 | 1.69.168 | Efecto |
|---|---|---|---|
| Carpetas | `components/brave_shields/browser/` | `.../core/browser`, `.../content/browser`, `.../core/common` | Los ficheros donde fijamos los ID **se movieron** (`git diff --name-status` los marca «borrados» porque se saltó la detección de renombrados; están en la carpeta nueva) |
| Constantes de componentes | Lista por defecto, primera parte, recursos, catálogo e iOS en `ad_block_service.cc` y `ad_block_component_installer.cc` | **Solo recursos y catálogo**, en `core/common/brave_shield_constants.h`; datos locales sigue en `local_data_files_service.h` | **De cinco ID a tres** (con datos locales) |
| Listas por defecto | Componentes propios (`iodkpd…`, `adcocj…`) | **Entradas del catálogo** con `hidden` y `default_enabled`; las de primera parte, con `first_party_protections` | La lista por defecto y la de primera parte ya no necesitan constante en brave-core |
| Catálogo | `regional_catalog.json` | **`list_catalog.json`** (catálogo unificado, agosto 2023 en el empaquetador) con campos nuevos: `hidden`, `default_enabled`, `first_party_protections`, `permission_mask`, `platforms` | Hay que servir el formato nuevo |
| Formato de listas | `list.txt`; DAT en iOS | `list.txt`; **DAT retirado** (packager, 6-02-2024) | Sin cambios para nosotros |
| Recursos | `resources.json` (0.7.9: plantillas `{{1}}`) | `resources.json` de 0.8: `dependencies` y `permission` por recurso | Ver §3.3 |
| Motor | `components/adblock_rust_ffi`, adblock 0.7.9 | `components/brave_shields/adblock/rs` (cxx) y el crate `adblock 0.8.11` vendido en `third_party/rust` | El motor deja de ser nuestro punto de contacto |
| Actualizador | `BraveConfigurator` con `absl::optional` | Reescrito (`GetPersistedData`, `url_loader_factory`, `GetCrxCachePath`) y nuevo `IsBraveComponent()` | Nuestras ediciones (fin de pings) se rehacen a mano |
| Protocolo Omaha | v3.1 | **Igual** (v3.1); solo `std::optional`, `kProtocolVersion` externo y errores nuevos reconocidos | El servidor `go-update` no cambia |

### 3.3 Resultados por pieza nuestra

| Pieza | Veredicto |
|---|---|
| Claves, ID y firma CRX3 con publicador; bak; `go-update` | **Valen.** Chromium exige el publicador por sí mismo, en la 116 y en la 128 (`component_updater_service.cc`, `CRX3_WITH_PUBLISHER_PROOF`) [V]; Brave 1.69 ya no lleva su propio interruptor `kEnforceCRX3PublisherProof` y acepta su clave **además** de la de Google. Nuestro hash se reaplica en `crx_verifier.cc` (solo cambia un comentario) |
| `pruebas/verificador-157.mjs` (port propio de `VerifyCrx3` de la 116) | **Re-portar contra la 128:** el verificador de Chromium cambia 88 líneas, casi todas de estilo, más las constantes `kEocd` y `kEocd64` (fin del directorio central de zip, también zip64) [V]. Nuestros zips son pequeños y no son zip64 [I]. 1–2 h |
| `serializador` que recorta la petición (`protocol_serializer.cc`) | **Se vuelve a cortar:** la firma pasa a `std::optional`, `kProtocolVersion` va en `protocol_request::`, y `base::CPU` solo en x86. 1–2 h. **Primero de todo:** sin él se enviaría memoria, CPU y fechas |
| Fin de pings (`brave_component_updater_configurator.cc`) | A mano: la clase se reescribió. 1–3 h |
| Lista de componentes permitidos (`component_installer.cc`) | Reaplicar; Brave cambia la firma de `Register` y añade `IsBraveComponent`. 0,5 h |
| `update_query_params.{cc,h}` (parches nuestros) | Cortar de nuevo sobre Chromium 128 (no los toca Brave). 1–2 h |
| ID y claves (cinco) | Dos en `brave_shield_constants.h`, uno en `local_data_files_service.h`; los dos de listas pasan a entradas del catálogo. 1–2 h |
| `empaquetar.mjs` y `listas.json` | Generar `list_catalog.json`: las listas por defecto y la de primera parte como entradas `hidden`, con sus ID y claves **de ahora** (se reutilizan) |
| `regional_catalog.json` y la lista por defecto fusionada | **Siguen para los 1.x.** Mismo zip, los dos ficheros |
| `recursos-157.mjs` | **`recursos-20.mjs` (FM.39, PR #497)**: con adblock-rust **0.8.11** los scriptlets siguen autocontenidos (dependencias inlinadas, plantilla `{{1}}`): 0.8.11 **ignora** `dependencies` [V: doc de `Resource` en adblock-rust v0.8.11 y CI del #497; lo que decía esta fila antes [I] era falso]. Sin ningún scriptlet «trusted» (nombre `trusted-…`, alias o `requiresTrust`) |
| Validación con `motor-07` | Añadir `motor-08` (0.8.11) para la 2.0; la 0.7 sigue para los 1.x |
| Filtro de reglas que rompen adblock-rust anterior a la 0.8.7 | **Se mantiene mientras haya 1.x**: el mismo `list.txt` lo leen las dos |

### 3.4 Convivencia 1.x + 2.0 (el punto delicado)

El mismo servidor atiende a las dos versiones, y `prodversion` declara Chromium, no FlyWeb [I]: no se puede decidir por
versión del cliente.

- **Catálogo:** un solo CRX con `regional_catalog.json` y `list_catalog.json`. Hay que dejar pasar el segundo fichero
  en bak (`pruebas/firma-bak.mjs` rechaza hoy «fichero de más»).
- **Listas** (`list.txt`): sin cambios; las dos versiones leen lo mismo.
- **Recursos:** **ID nuevo y clave nueva para la 2.0** (un par más en bak). Un `resources.json` 0.8 en el ID antiguo
  haría que la 0.7.9 «los cargara, pero no hicieran nada» (README de componentes). El ID viejo queda congelado en el
  último de la 1.x.
- **Retirada:** cuando se deje de publicar la 1.x se quita `regional_catalog.json`, la lista fusionada y `motor-07`.

## 4. Horas

| Parte | Clase de `migracion-128.md` | Horas |
|---|---|---|
| Sync, cliente (UI, llavero, `features.cc`) | C | 1–3 |
| Sync, prueba con un cliente 1.69 contra ns2 (historial, cuotas, cadena mixta) y borrado de `TYPED_URLS` | H | 3–6 |
| Actualizador (serializador, pings, lista permitida, `update_query_params`, ID y claves) | C | 4–8 |
| Servidor de componentes: `list_catalog.json`, ID nuevo de recursos, conversión de recursos, `motor-08`, bak, re-port del verificador | H | 8–17 |
| Prueba de punta a punta en Mojave (Shields filtra, sync, actualizador) | C/H | 2–4 |
| **Total** | | **≈ 18–38** |

[H] El techo sube a ~50 h si la conversión de recursos del empaquetador de Brave exige más que lo visto, o si hay que
volver a escribir la parte de permisos (`permission_mask`).

## 5. Orden

1. **Fase 1 (Brave 1.69.168 limpio):** nada de esto.
2. **Identidad:**
   1. **Actualizador primero** (serializador, pings, lista permitida): sin él, la primera ejecución con red filtraría
      datos a Brave/Google. Prueba: capturar la petición (el método de `scripts/network-audit.py`).
   2. ID y claves de componentes, y la clave del publicador.
   3. Sync: UI, llavero, endpoint.
3. **Servidor, antes de publicar la 2.0.0:** catálogo con los dos ficheros, recurso con ID nuevo, bak actualizado.
4. **Prueba mixta:** una cadena con un FlyWeb 1.15.x y una compilación de la 128, y comprobar a mano que cruzan
   marcadores y contraseñas, y que el historial **no** cruza.
5. **Después de la 2.0.0:** retirar lo de la 1.x cuando proceda (§3.4).

## 6. Qué no pude comprobar

- **Nada se ha compilado.** El análisis es de código y de historial.
- **`git diff --name-status` entre los dos tags saltó la detección de renombrados** (30 740 ficheros): los «borrados»
  de `components/brave_shields` son movimientos; los he resuelto a mano para los ficheros que importan, pero otros
  pueden esconder más movimientos.
- **Qué hace `IsBraveComponent()` en la 1.69** (¿decide a qué servidor va el componente?): lo veo definido y heredado,
  no su uso. Si decide la URL o las cabeceras, es un punto de contacto más con nuestro actualizador. Pendiente de LOCAL
  al primer arranque.
- **Si la 1.69 sigue añadiendo `--disable-sync` cuando `BraveSync` está apagada** (paso 25 de `integracion.md`): no lo
  he mirado; no aplica mientras `kBraveSync` siga activa.
- **Resultado de 0.8.11 con `resources.json` actual:** inferido de las notas de versión y los commits; falta cargarlo.
- **Los componentes de Google** (Widevine, CRLSet…): fuera de este estudio.

## 7. Fuentes

- brave-core `v1.57.64`, `v1.69.168` y nuestra rama `flyweb` (54b964da), en lectura: carpetas `components/sync`,
  `components/brave_sync`, `chromium_src/components/sync`, `components/brave_shields`, `components/brave_component_updater`,
  `chromium_src/components/{component_updater,update_client,crx_file}`.
- [brave/go-sync](https://github.com/brave/go-sync): `38e0206` (protos de Chromium 116), `25cdebc` (tipo historial),
  `862e79d` (caducidad), `e4b539e` (protos de Chromium 124), `40a22d3` (cuota de historial).
- [brave/adblock-rust](https://github.com/brave/adblock-rust): etiquetas `v0.7.9` … `v0.8.11` (0.8.0: «lots of API
  cleanup», sin el formato DAT antiguo, almacén unificado de recursos con permisos y dependencias).
- [brave/brave-core-crx-packager](https://github.com/brave/brave-core-crx-packager): `b66a80a` (catálogo unificado,
  30-08-2023), `bc00baf` y `af2cab4` (recursos), `8f03bc8` (DAT retirado, 6-02-2024), `c0f0efb` (`list_catalog.json`).
- Chromium `116.0.5845.188` y `128.0.6613.138` (espejo de GitHub): `components/sync/base/{model_type.h,features.cc}`,
  `components/update_client/{protocol_serializer,protocol_definition,protocol_parser_json}.*`.
- Proyecto: `servidor/sync/README.md`, `servidor/componentes/README.md`, `migracion-128.md`, `integracion.md`.
