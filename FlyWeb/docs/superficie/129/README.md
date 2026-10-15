# Superficie web y huella: FlyWeb 1.13 frente a Chrome for Testing 129

Primera pasada de `FlyWeb/tools/superficie.html` (LOCAL-4, 15-10-2026, MacPro7,1, macOS 15.8.1), con perfil temporal
limpio y desde `http://127.0.0.1:8125` (contexto seguro). FlyWeb 1.13 publicada (build 22, brave-core 325686916c)
frente a CfT 129.0.6668.100, **con y sin la configuración de campo de pruebas** (`--disable-field-trial-config`).
CfT trae de serie `fieldtrial_testing_config` (los experimentos de Finch en curso); Brave la quita
(`disable_fieldtrial_testing_config`). Por eso «CfT sin config» es el valor por defecto del código de Chrome 129, y
«CfT con config» se acerca a lo que Chrome reparte por Finch (no es lo mismo que Chrome estable: la config de pruebas
enciende también experimentos que no llegan a estable).

| Fichero | Qué es |
|---|---|
| `flyweb-1.13.txt` | volcado de la 1.13 (10 024 líneas) |
| `cft129-sin-config-de-campo.txt` / `cft129-con-config-de-campo.txt` | volcados de CfT 129 (10 400 / 10 391) |
| `diff-cft129-sin-config_flyweb-1.13.diff` | `<` solo en CfT 129 (404), `>` solo en la 1.13 (28) |
| `diff-cft129-con-config_flyweb-1.13.diff` | lo mismo con la config de campo (412 / 45) |
| `diff-cft129-sin_con-config.diff` | lo que cambia la config de campo en CfT 129 |
| `huella/` | `herramientas/huella-tls.sh` (tls.peet.ws) de la 1.13 y de CfT 129 con y sin config |
| `superficie.sh`, `evalua.py`, `apagados.sh`, `dom-*.html` | guiones (rutas de la 7,1) |

## Lo que cambia la config de campo en CfT 129 (Finch)

Quita `MutationEvent` (y los eventos dejan de saltar) y `Element/ShadowRoot.prototype.getInnerHTML`; enciende
`::details-content`, `fetchLater`/`FetchLaterResult` y `CookieDeprecationLabel`. En la huella: **ALPS con el código
nuevo (17613)** y un ajuste GREASE de más en el SETTINGS de HTTP/2; sin la config, JA4, akamai y peetprint de CfT 129
son **idénticos** a los de la 1.13 (17513, el antiguo).

## Solo en la 1.13 (frente a CfT 129 sin config)

- Apagados que se escaparon (ya en FM.20): `openDatabase`, pantalla completa prefijada de `<video>` (`webkitEnterFullscreen`,
  `webkitEnterFullScreen`, `webkitExitFull[sS]creen`, `webkitSupportsFullscreen`, `webkitDisplayingFullscreen`),
  `:--x`, `DOMParser` con `includeShadowRoots`.
- Nuevos: **`<template shadowroot>`** (atributo antiguo) crea la sombra; **`Sanitizer` y `Element.prototype.setHTML`**;
  `GPUCommandEncoder.prototype.writeTimestamp`; `HTMLTemplateElement.prototype.shadowRoot`; CSS `-webkit-highlight`;
  selector `:open` `true`; **`window.originAgentCluster` `false`** y `document.domain` relaja el mismo origen
  (`dom-padre.html`: la 1.13 lee el marco de `b.web.localhost` tras `document.domain = 'web.localhost'`; CfT 129, con y
  sin config, `originAgentCluster` `true`, el setter no hace nada y el acceso queda bloqueado).
- **Polyfills de FlyWeb (core-js 3.50.0, `components/flyweb_polyfills`)**: el global **`__core-js_shared__`** (cargado
  dos veces en la misma ventana) y funciones que Chrome 129 no tiene: `RegExp.escape`, `Uint8Array.fromBase64`/`fromHex`
  y `.prototype.toBase64`/`toHex`/`setFromBase64`/`setFromHex`. Con el motor en el 129 añaden superficie y huella.
- De Brave, a propósito: `Navigator.prototype.globalPrivacyControl` (y la cabecera `sec-gpc: 1`).

## Solo en CfT 129 (404 líneas): para clasificar

- Apagado por Brave en `chromium_src` (`content_features.cc`, `blink/common/features.cc`): Privacy Sandbox (FLEDGE /
  Protected Audience, Fenced Frames, Shared Storage, Topics, Attribution Reporting `attributionSrc`, Private State Tokens),
  FedCM (`IdentityCredential`, `IdentityProvider`, `navigator.login`), `IdleDetector`, Compute Pressure
  (`PressureObserver`), WebOTP (`OTPCredential`), fragmentos de texto (`FragmentDirective`).
- Probablemente de Brave, sin confirmar: `navigator.connection`, `navigator.share`/`canShare`, Storage Access
  (`requestStorageAccess`, `hasStorageAccess`…), `speechSynthesis`, Web Serial, File System Access
  (`show*Picker`), `ReportingObserver`, `HTMLAnchorElement.hrefTranslate`.
- Funciones de niveles 117–129 que no están: anclaje CSS (`anchor-name`, `position-*`, `inset-area`,
  `CSSPositionTry*`), `CSSScopeRule`, transiciones de vista entre documentos (`CSSViewTransitionRule`, `PageRevealEvent`,
  `PageSwapEvent`, `onpagereveal`/`onpageswap`), `CloseWatcher`, `EditContext` (y `TextFormat`, `TextUpdateEvent`…),
  LoAF (`PerformanceLongAnimationFrameTiming`, `PerformanceScriptTiming`), `NotRestoredReasons`, Storage Buckets,
  `MediaStreamTrack` stats, `ChapterInformation`, `SnapEvent` y `onscrollsnapchange*`, `WebSocketStream`,
  `Scheduler.prototype.yield`, `HTMLSelectElement.prototype.showPicker`, `CustomElementRegistry.prototype.getName`,
  `interpolate-size`, `text-spacing-trim`, `WebGL drawingBufferStorage`/`drawingBufferFormat`, `GPUAdapter.prototype.info`,
  `PointerEvent.persistentDeviceId`, `PerformanceResourceTiming.deliveryType`, `Request.targetAddressSpace`, entre otras
  (lista completa en el diff).

## Huella (cabeceras)

Además de ALPS: la 1.13 manda `sec-gpc: 1` y `accept-language: es-ES,es;q=0.6` (Brave); CfT 129, sin `sec-gpc` y
`q=0.9`. JA4 sin config de campo igual: `t13d1516h2_8daaf6152771_02713d6af862`.
