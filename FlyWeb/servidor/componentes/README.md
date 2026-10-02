# Componentes propios de Shields (plan B)

El almacén de Brave no se puede listar (CloudFront 403, `FlyWeb/docs/componentes.md` §4), así que no se puede copiar.
FlyWeb empaqueta sus propios componentes de Shields desde el **origen público** de las listas, firmados con claves
nuestras. Base: [`brave/brave-core-crx-packager`](https://github.com/brave/brave-core-crx-packager) (MPL-2.0).

## Qué espera FlyWeb 1.57 (comprobado en brave-core)

| Componente | Fichero dentro del CRX | Origen |
|---|---|---|
| Lista por defecto y cada lista regional | `list.txt` (**texto plano**; el motor lo interpreta al cargar) | `components/brave_shields/browser/ad_block_component_filters_provider.cc:18` |
| Recursos (scriptlets y redirecciones) | `resources.json` | `ad_block_default_resource_provider.cc:15` |
| Catálogo de listas regionales | `regional_catalog.json` (con el ID y la clave de cada lista) | `ad_block_filter_list_catalog_provider.cc:14` |

El motor de FlyWeb es **adblock-rust 0.7.9** (`components/adblock_rust_ffi/Cargo.toml`). Al ser texto plano no hay un
formato binario versionado, pero hay dos diferencias con el Brave actual.

## Compatibilidad (probado en NUBE, 02-10-2026, con `adblock-rs` 0.7.17 = motor 0.7.x)

**Listas: compatibles.**
- EasyList actual (78.615 reglas): el motor se crea en ~100 ms y bloquea `securepubads.g.doubleclick.net/…/gpt.js`.
- Con EasyList y las listas de uBlock Origin juntas, oculta 452 elementos en El País y 458 en la BBC, e inyecta 99 KB
  de scriptlets en YouTube, con sintaxis válida.
- El empaquetador actual ya genera `list.txt` y `regional_catalog.json`, y quita las reglas que no entiende adblock-rust
  0.8.6. Las que tampoco entienda la 0.7.9 se ignoran una a una: se bloquea algo menos, pero nada se rompe.

**Recursos: el `resources.json` actual NO sirve tal cual.**
- Los scriptlets actuales de uBlock Origin son funciones con argumentos, dependencias y un objeto global
  `scriptletGlobals`.
- La 0.7.9 usa plantillas `{{1}}`…`{{9}}`: los cargaría, pero no harían nada.

**Solución: `recursos-157.mjs`.**
- **Conversión.** Hace lo mismo que el empaquetador de Brave de agosto de 2023 (`c74d7d2`, la época de la 1.57): mete
  las dependencias dentro de cada scriptlet y lo envuelve en el formato de plantillas. Además añade
  `const scriptletGlobals = {}`; sin eso fallan todos, como se vio en la prueba (`ReferenceError`).
- **Excluye** los scriptlets *trusted*, como hacía Brave entonces.
- **Resultados de las pruebas:**
  - 65 scriptlets y 111 recursos en total;
  - ninguno da `ReferenceError` ni `SyntaxError` al cargarlo en Chromium (`pruebas/barrido-scriptlets.mjs`);
  - en Chromium real, `set-constant` y `abort-on-property-read` se aplican de verdad;
  - las redirecciones (`redirect=noopjs`) funcionan (`pruebas/prueba-motor-07.mjs`).

**Firma: compatible** (`pruebas/firma-crx-157.mjs`, claves desechables).
- La 1.57 exige `CRX3_WITH_PUBLISHER_PROOF` a todos los componentes
  (`chromium_src/components/component_updater/component_updater_service.cc`).
- **Se firma con `lib/crx.js`** del empaquetador, que es Node puro. `packageAdBlock.js` no lo usa: llama a un
  **binario de Brave** con `--pack-extension`, y eso no lo queremos en un servidor.
- **Port del verificador.** La prueba compara con un port propio de `VerifyCrx3` de Chromium 116.0.5845.188, con el
  parche de Brave:
  - con el publicador correcto da `OK_FULL`, y el ID coincide con el SHA-256 de la clave;
  - sin publicador, o con uno ajeno, rechaza;
  - con un byte cambiado, rechaza;
  - si el CRX no es del componente que espera el instalador, rechaza.
- **Límite.** Es un port leído del código y no el binario. La prueba definitiva es la de LOCAL (abajo).

## Empaquetado diario: `empaquetar.mjs`

```sh
sh generar-claves.sh <claves>          # una vez; solo muestra datos públicos (ID, claves públicas, hash del publicador)
NODE_USE_ENV_PROXY=1 ADBLOCK_RS=<adblock-rs 0.7.x> \
  node empaquetar.mjs --packager <checkout> --claves <claves> --salida /var/www/FlyWeb/components
```

| Componente | Contenido | Clave |
|---|---|---|
| Lista por defecto | `list.txt` con las fuentes de *Brave Default Adblock Filters* y *Brave Default Privacy Filters* (`defecto` de `listas.json`) | `defecto.pem` |
| Recursos | `resources.json` de `recursos-157.mjs` | `recursos.pem` |
| Catálogo | `regional_catalog.json`: las listas de `regionales`, con **nuestros** ID y claves, y solo los campos que lee la 1.57 | `catalogo.pem` |
| Cada lista regional | `list.txt` | `lista-<UUID>.pem` |

- **Adaptación a la 1.57.**
  - En el catálogo actual de Brave, las listas por defecto son entradas *ocultas* (`hidden`). La 1.57 no conoce ese
    campo: las mostraría como listas que el usuario puede activar, y EasyPrivacy quedaría desactivada. Por eso se
    juntan en la lista por defecto (como en la 1.57) y no van al catálogo.
  - Fuera: *iOS-Specific* y *First Party Adblock Filters*. La segunda bloquea recursos del propio sitio y en la
    1.57 se aplicaría siempre.
- **Selección inicial** (`listas.json`): avisos de cookies (la 1.57 la activa por defecto, `kCookieListUuid`),
  promociones de apps, español, y español y portugués. Cada lista que se añada necesita su clave: se vuelve a ejecutar
  `generar-claves.sh`, que solo crea las que faltan.
- **Origen.** El catálogo de `brave/adblock-resources` y las listas de `brave/adblock-lists-mirror`, ambos en GitHub.
  Solo hace falta salir a `raw.githubusercontent.com`. A diferencia del empaquetador de Brave, no se manda ninguna
  lista a validadores remotos.
- **Filtrado.**
  - Directivas `!#if` con los mismos valores que Brave. Hay una corrección: un `!#else` dentro de una rama descartada
    sigue descartado, y en Brave se volvía a abrir.
  - Se quitan las reglas que hacen fallar a adblock-rust anterior a la 0.8.7 (el comprobador wasm del empaquetador).
  - Las reglas `+js(brave-…)` solo se admiten en listas de Brave.
- **Comprobaciones antes de firmar, con el motor 0.7.x:**
  - la lista carga;
  - no bloquea páginas normales (FlyWeb, Wikipedia, claude.ai);
  - la lista por defecto bloquea doubleclick;
  - si un componente pierde más de la mitad de sus reglas respecto a la versión anterior, no se publica.

  Si falla una fuente, ese componente conserva la versión anterior y el script termina con código 1.
- **Versiones** `AAAA.MMDD.HHMM` (UTC). Solo se publica versión nueva si cambia el contenido. Se conservan la versión
  nueva y la anterior de cada CRX, y `catalog.json` se escribe de forma atómica.
- **Probado en NUBE (02-10), claves desechables:**
  - 7 componentes en 11 s; lista por defecto de 170.209 reglas, con 9 quitadas por incompatibles;
  - una segunda ejecución no publica nada;
  - los 7 CRX pasan el verificador;
  - `go-update` con ese `catalog.json` devuelve la URL de `/release/…` y el SHA-256 correcto, y `noupdate` para la
    versión al día.

## Pendiente

1. **Dónde se firma (HUMANO).** Ahí se ejecuta `generar-claves.sh` y viven las claves; copia de seguridad del
   directorio por su canal. Después, un temporizador diario que ejecute `empaquetar.mjs` (unidad systemd o launchd
   según el sitio).
2. **brave-core (NUBE)**, con los datos públicos que muestra `generar-claves.sh`:
   - `kAdBlockDefaultComponentId` y su clave (`components/brave_shields/browser/ad_block_service.cc:36`);
   - `kAdBlockResourceComponentId` y `kAdBlockFilterListCatalogComponentId` con sus claves
     (`ad_block_component_installer.cc:28` y `:40`);
   - el hash del publicador, **añadido** junto a `kBravePublisherKeyHash`
     (`chromium_src/components/crx_file/crx_verifier.cc`).

   Las listas regionales no tocan brave-core: su ID y su clave van en el catálogo.
3. **Recursos propios de Brave** (`brave/adblock-resources` `dist/resources.json`, scriptlets `brave-…`): no se
   incluyen todavía. Las reglas que los usan se quedan sin efecto, sin errores.
4. **Licencias:**
   - EasyList y EasyPrivacy: GPLv3 / CC BY-SA 3.0;
   - uBlock Origin (listas, scriptlets y recursos): GPLv3;
   - Brave (`adblock-lists`, `adblock-resources`, empaquetador): MPL-2.0.

   Se redistribuyen sin cambios en las reglas y con su atribución. La conversión de scriptlets es una modificación de
   código GPLv3, así que su fuente (este directorio) es pública.

## Reproducir las pruebas

```sh
git clone https://github.com/brave/brave-core-crx-packager && cd brave-core-crx-packager
git submodule update --init --depth 1 submodules/uBlock
npm install --ignore-scripts                                                                         # para lib/crx.js
mkdir -p /tmp/abr07 && (cd /tmp/abr07 && npm init -y >/dev/null && npm install adblock-rs@0.7.17)   # compila con cargo
export PACKAGER=$PWD ADBLOCK_RS=/tmp/abr07/node_modules/adblock-rs NODE_PATH_PW=$(npm root -g)      # playwright global
node <softmac>/FlyWeb/servidor/componentes/recursos-157.mjs . /tmp/resources.json
node <softmac>/FlyWeb/servidor/componentes/pruebas/barrido-scriptlets.mjs
node <softmac>/FlyWeb/servidor/componentes/pruebas/prueba-motor-07.mjs
node <softmac>/FlyWeb/servidor/componentes/pruebas/firma-crx-157.mjs
```

Comprobación definitiva (LOCAL): un FlyWeb compilado con nuestros componentes en `brave://components`, una página de
pruebas de bloqueo y YouTube.
