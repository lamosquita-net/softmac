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

## Pendiente

1. **Claves** (las genera el HUMANO donde se decida firmar; nunca en el repo):
   - una por componente propio: lista por defecto, recursos y catálogo;
   - una por cada lista regional que se publique (su ID y clave van **dentro** de `regional_catalog.json`, no en
     brave-core);
   - una **clave de publicador**.
2. **brave-core (NUBE).** Solo tres pares ID/clave y un hash:
   - `kAdBlockDefaultComponentId` y su clave (`components/brave_shields/browser/ad_block_service.cc:36`);
   - `kAdBlockResourceComponentId` y `kAdBlockFilterListCatalogComponentId` con sus claves
     (`ad_block_component_installer.cc:28` y `:40`);
   - el SHA-256 de la clave pública (SPKI DER) del publicador, en lugar de `kBravePublisherKeyHash`
     (`chromium_src/components/crx_file/crx_verifier.cc`). **Se añade** junto al de Brave: si se sustituyera,
     FlyWeb dejaría de aceptar los CRX firmados por Brave (los de Google van aparte, con `kPublisherKeyHash`).
3. **Empaquetado diario y publicación** en `components.` (`/var/www/FlyWeb/components/release/…` y el catálogo de
   `go-update`).
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
