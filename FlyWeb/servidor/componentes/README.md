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
- **Firmador.** `packageAdBlock.js` de Brave firma llamando a un **binario de Brave** con `--pack-extension`, y eso no
  lo queremos en un servidor. Primero se comprobó `lib/crx.js` del empaquetador (Node puro, `pruebas/firma-crx-157.mjs`);
  ahora firma `bak/crx3.mjs`, propio y sin dependencias, que pasa el mismo verificador.
- **Port del verificador.** La prueba compara con un port propio de `VerifyCrx3` de Chromium 116.0.5845.188, con el
  parche de Brave:
  - con el publicador correcto da `OK_FULL`, y el ID coincide con el SHA-256 de la clave;
  - sin publicador, o con uno ajeno, rechaza;
  - con un byte cambiado, rechaza;
  - si el CRX no es del componente que espera el instalador, rechaza.
- **Límite.** Es un port leído del código y no el binario. La prueba definitiva es la de LOCAL (abajo).

## Construcción y firma: GitHub Actions construye, bak firma

Detalle de bak (instalación, comprobaciones, aprobación de recursos): [`bak/README.md`](bak/README.md).

| Paso | Dónde | Qué |
|---|---|---|
| Construir | GitHub Actions, 03:17 UTC (`.github/workflows/flyweb-shields.yml`) | `empaquetar.mjs`: descarga, filtra y valida con el motor 0.7.x; un zip sin firmar por componente, con la clave **pública** en el manifest (`claves-publicas.json`). Lo sube a la release `shields` |
| Firmar | bak, 05:23 UTC (`bak/firmar.mjs`, usuario `flywebfirma`) | Comprueba cada zip, firma (CRX3 + publicador) y sube a ns2 por rsync con una clave limitada a `/var/www/FlyWeb/components` |
| Servir | ns2 (`go-update` + Apache) | `catalog.json` y `release/<id>/extension_<versión>.crx` |

**Por qué así.**
- **Construir** necesita código de terceros: las listas, uBlock Origin, el motor en Rust y npm. Lo hace GitHub, sin
  secretos y con un registro público.
- **Firmar** solo necesita Node y tres ficheros revisables (`bak/`).
- **Las claves** viven solo en bak, separadas de ns2, que es quien sirve: si alguien entra en ns2, no puede firmar.

**El JavaScript es lo que más protección lleva.** `resources.json` sale del uBlock Origin fijado en `fijado.json`:
- solo se sube a versiones con **14 días o más** desde su publicación (el CI lo comprueba);
- bak solo lo firma si el HUMANO ha aprobado su hash.

Lo que protege es el retraso. Los ataques a la cadena de suministro conocidos (xz, tj-actions, event-stream) se
descubrieron en días o semanas. Una revisión manual no los habría detectado; el retraso sí los habría evitado.

| Componente | Contenido | Clave |
|---|---|---|
| Lista por defecto | `list.txt` con las fuentes de *Brave Default Adblock Filters* y *Brave Default Privacy Filters* (`defecto` de `listas.json`) | `defecto` |
| Lista de primera parte | `list.txt` con *Brave First Party Adblock Filters* (`primera_parte`) | `primera-parte` |
| Recursos | `resources.json` de `recursos-157.mjs` y el uBlock Origin fijado | `recursos` |
| Catálogo | `regional_catalog.json`: las listas de `regionales`, con **nuestros** ID y claves, y solo los campos que lee la 1.57 | `catalogo` |
| Cada lista regional | `list.txt` | `lista-<UUID>` |

- **Adaptación a la 1.57.**
  - En el catálogo actual de Brave, las listas por defecto son entradas *ocultas* (`hidden`). La 1.57 no conoce ese
    campo: las mostraría como listas que el usuario puede activar, y EasyPrivacy quedaría desactivada. Por eso se
    juntan en la lista por defecto (como en la 1.57) y no van al catálogo.
  - *First Party Adblock Filters* va como componente propio (`primera-parte`), porque la 1.57 ya lo tenía:
    `kAdBlockExceptionComponent`, en un motor aparte que también se aplica al propio sitio. Fuera: *iOS-Specific*.
- **Selección inicial** (`listas.json`): avisos de cookies (la 1.57 la activa por defecto, `kCookieListUuid`),
  promociones de apps, español, y español y portugués. Cada lista que se añada necesita su clave: se vuelve a ejecutar
  `generar-claves.sh` en bak, que solo crea las que faltan, y se actualiza `claves-publicas.json`.
- **Origen de las listas.** El catálogo de `brave/adblock-resources` y las listas de `brave/adblock-lists-mirror`.
  A diferencia del empaquetador de Brave, no se manda ninguna lista a validadores remotos.
- **Filtrado.**
  - Directivas `!#if` con los mismos valores que Brave. Hay una corrección: un `!#else` dentro de una rama descartada
    sigue descartado, y en Brave se volvía a abrir.
  - Se quitan las reglas que hacen fallar a adblock-rust anterior a la 0.8.7 (el comprobador wasm del empaquetador,
    en el commit fijado).
  - Las reglas `+js(brave-…)` solo se admiten en listas de Brave.
- **Validación con el motor 0.7.x** (`motor-07/`, versión bloqueada):
  - la lista carga;
  - no bloquea páginas normales (FlyWeb, Wikipedia, claude.ai);
  - la lista por defecto bloquea doubleclick.

  Si falla una fuente, ese componente no sale ese día y bak conserva el anterior. Si falla una lista, tampoco sale el
  catálogo.
- **Versiones** `AAAA.MMDD.HHMM` (UTC). bak solo firma si cambia el contenido y la versión es posterior.
- **Probado en NUBE (03-10), con claves desechables:**
  - construcción completa con uBlock Origin 1.75.0: 7 componentes;
  - firma en bak: los 7 CRX pasan el verificador de la 1.57;
  - `pruebas/firma-bak.mjs` comprueba los rechazos: recursos sin aprobar, clave ajena, fichero de más, zip
    cambiado, vuelta atrás, lista recortada y catálogo con una lista ajena;
  - subida por `rrsync -wo`: escribe donde debe, borra los CRX viejos y rechaza `..` y las lecturas;
  - el firmador propio (`bak/crx3.mjs`) sustituye a `lib/crx.js`; los dos pasan el mismo verificador.

## Pendiente

1. **Instalación en bak y ns2 (HUMANO):** pasos en `bak/README.md`. `generar-claves.sh` muestra el contenido de
   `claves-publicas.json`, que hay que pasar a NUBE.
2. **NUBE, con esos datos públicos:**
   - `claves-publicas.json`; con eso el CI empieza a publicar;
   - brave-core: `kAdBlockDefaultComponentId` y `kAdBlockExceptionComponentId` con sus claves
     (`components/brave_shields/browser/ad_block_service.cc`),
     `kAdBlockResourceComponentId` y `kAdBlockFilterListCatalogComponentId` con sus claves
     (`ad_block_component_installer.cc:28` y `:40`), y el hash del publicador **añadido** junto a
     `kBravePublisherKeyHash` (`chromium_src/components/crx_file/crx_verifier.cc`). Las listas regionales no tocan
     brave-core.
3. **`go-update` en ns2** (E2): binario del CI y `systemd/flyweb-components.service`.
4. **Recursos propios de Brave** (scriptlets `brave-…`): no se incluyen. Las reglas que los usan no hacen nada.
5. **Licencias:**
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
node <softmac>/FlyWeb/servidor/componentes/pruebas/firma-bak.mjs        # sin red ni empaquetador
```

Comprobación definitiva (LOCAL): un FlyWeb compilado con nuestros componentes en `brave://components`, una página de
pruebas de bloqueo y YouTube.
