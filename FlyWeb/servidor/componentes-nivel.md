# Componentes del espejo frente al nivel del motor (FS.32)

Directiva «Servidor a la par del motor» (Titín, 28-10-2026): el servidor sirve los datos del nivel del motor (2.1.x = 132), nunca los de la base 128. Lectura de solo lectura en ns2 el 28-10-2026 ~08:40 UTC, más el código del lector en Chromium 128 (`chrome/browser/component_updater/`). Sin hosts ni IP.

## Cómo pide el espejo a Google

`bak/google.mjs` pregunta a Google por los siete componentes de abajo como **Chrome 116.0.5845.188** (`NAVEGADOR`), con SO 10.14.6. Es un anclaje al nivel 116, no al 128 ni al 132. Google devuelve la versión vigente de cada uno en formato actual (File Type Policies sale como 145.0.7584.0), así que lo anclado no es el dato sino **el lector del navegador** (128) y la versión con que se pide.

## Tabla

| Componente (ID) | En ns2 hoy | Lector (128) y problema | Propuesta |
|---|---|---|---|
| PKI Metadata (`efniojl…`) — `ct_config.pb` | 1820 (28-10), `log_list` con `compatibility_version` **4**, timestamp 17-10 | `kMaxSupportedCTCompatibilityVersion = 2` (`pki_metadata_component_installer.cc:60,237`): con 4 el lector **descarta la lista** y se queda con la integrada. CT no se actualiza desde la 2.0.0 | **Cambiar el lector** (MOTOR-27): subir el máximo al de Chrome 132 y portar el formato de `CTLogList` que la 132 entienda. Subir el servidor no basta: Google ya sirve la 4 |
| PKI Metadata — `kp_pinslist.pb` | `compatibility_version` 1 | máximo 1 (`:67,346`): entendido | Nada |
| PKI Metadata — `crs.pb` (Root Store) | 350 KB, campo 2 = 43 (sin mapear) | El Root Store integrado de la 2.1 es v17 (132); la restricción de versión se evalúa contra 139 fijo (commit `dae06d65683`) | Comprobar que el lector acepta este `crs.pb` y qué hace si es más nuevo que el integrado (MOTOR-27/SEGURIDAD-PORTES) |
| PKI Metadata — `mtc_config.pb` | 9 KB | La 128 no lo lee (no hay `mtc` en el instalador) | Nada hasta que el motor lo porte |
| CRLSet (`hfnkpim…`) | secuencia 10866 (28-10), al día | Formato estable | Nada |
| File Type Policies (`khaoieb…`) | 145.0.7584.0, `download_file_types.pb` versión 69 | Formato proto estable | Comprobar que el lector 128/132 lo parsea (campos nuevos se ignoran) |
| Certificate Error Assistant (`giekcmm…`) | versión 7 (03-10) | Estable | Nada |
| Safety Tips (`jflookg…`) | 3092 (10-10) | Estable | Nada |
| Crowd Deny (`ggkkehg…`) | 2026.10.26.79 (27-10), `preload_data_format` 1 | Formato 1 | Nada |
| MEI Preload (`laoigpb…`) | 1.1.0.3 (03-10), sin cambios de Google | Estable | Nada |
| Shields (recursos, catálogo, listas) | al día (listas 28-10; recursos-20 y catálogo 23-10) | Propios, versionados por nosotros | Nada |
| Datos locales (`fmaniol…`) | 2026.1008.1042 | Propios | Nada |

## No sirve el espejo

Origin trials, Privacy Sandbox, Safe Browsing (va por el proxy propio, no es un componente), Widevine y el resto de componentes de Chromium no pasan por el espejo (`GOOGLE` solo lista los siete anteriores). **No he verificado** en el navegador cuáles de ellos pide la 2.1.x ni a qué servidor: eso se lee en el parche de la 2.1.1, no en el servidor.

## Propuesta

1. **Lo único anclado y roto es CT** (lector, MOTOR-27). Mientras tanto no hay nada que subir en el servidor.
2. En el servidor, un cambio opcional y barato: pedir a Google como Chrome 132 (`NAVEGADOR` y `updaterversion`) para que los datos sean los del nivel. Es un cambio de `bak/google.mjs` (bak: lo aplica Titín) y solo tiene sentido junto al lector nuevo; riesgo: Google podría servir formatos que el lector 128 aún no entiende.
3. Repetir esta lectura cuando suba el nivel del motor.
