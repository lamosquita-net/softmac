# Funciones Baseline que faltan en Chromium 116

Generado con `FlyWeb/polyfills/baseline-gap.mjs` (web-features 3.40.0). No editar a mano.

- **amplia**: Baseline "ampliamente disponible" (30 meses en todos los navegadores principales): la web la da por supuesta.
- **reciente**: Baseline "recién disponible": se empieza a usar, normalmente con alternativa.
- **Polyfill**: sí = la cubre `flyweb_polyfills.js`; vacío = no (CSS, HTML o APIs del navegador no se pueden suplir con JS razonable).

Total: 85 (17 amplias, 9 con polyfill).

| Baseline | Desde | Chrome | Función | id | Grupo | Polyfill |
|---|---|---|---|---|---|---|
| amplia | 2023-09-15 | 117 | Subgrid | `subgrid` | grid |  |
| amplia | 2023-10-13 | 118 | <search> | `search` | html-elements |  |
| amplia | 2023-11-02 | 119 | Clip path boxes | `clip-path-boxes` | clipping-shapes-masking |  |
| amplia | 2023-11-02 | 119 | :user-valid and :user-invalid | `user-pseudos` | selectors |  |
| amplia | 2023-12-05 | 119 | Storage access | `storage-access` | storage |  |
| amplia | 2023-12-07 | 120 | :dir() | `dir-pseudo` | selectors |  |
| amplia | 2023-12-07 | 120 | Exponential functions (CSS) | `exp-functions` | css |  |
| amplia | 2023-12-07 | 120 | Masks | `masks` | clipping-shapes-masking |  |
| amplia | 2023-12-07 | 120 | scripting media query | `scripting` | media-queries |  |
| amplia | 2023-12-07 | 120 | URL.canParse() | `url-canparse` |  | sí |
| amplia | 2023-12-11 | 118 | cap unit | `cap` | units |  |
| amplia | 2023-12-11 | 120 | Nesting | `nesting` | css |  |
| amplia | 2024-01-23 | 119 | rect() and xywh() | `rect-xywh` | clipping-shapes-masking |  |
| amplia | 2024-01-25 | 121 | Array.fromAsync() | `array-fromasync` | arrays | sí |
| amplia | 2024-03-05 | 117 | Array grouping | `array-group` | maps | sí |
| amplia | 2024-03-05 | 119 | Promise.withResolvers() | `promise-withresolvers` | promises | sí |
| amplia | 2024-03-22 | 123 | paint-order | `paint-order` | css |  |
| reciente | 2024-04-16 | 123 | align-content in block layouts | `align-content-block` | layout |  |
| reciente | 2024-04-16 | 118 | transform-box | `transform-box` |  |  |
| reciente | 2024-04-18 | 124 | AbortSignal.timeout() | `abortsignal-timeout` |  |  |
| reciente | 2024-04-18 | 124 | Vertical form controls | `vertical-form-controls` | css |  |
| reciente | 2024-05-13 | 123 | light-dark() | `light-dark` | css |  |
| reciente | 2024-05-17 | 125 | round(), mod(), and rem() | `round-mod-rem` | css |  |
| reciente | 2024-05-17 | 125 | :state() | `state` | custom-elements |  |
| reciente | 2024-06-11 | 122 | Set methods | `set-methods` | sets | sí |
| reciente | 2024-07-25 | 127 | font-size-adjust | `font-size-adjust` | fonts |  |
| reciente | 2024-08-06 | 117 | @starting-style | `starting-style` | css |  |
| reciente | 2024-08-06 | 117 | transition-behavior | `transition-behavior` | transitions |  |
| reciente | 2024-09-03 | 120 | Mutually exclusive <details> elements | `details-name` | html-elements |  |
| reciente | 2024-09-16 | 125 | getHTML() | `gethtml` | dom |  |
| reciente | 2024-09-16 | 125 | Relative colors | `relative-color` | css |  |
| reciente | 2024-09-16 | 119 | Typed function references (WebAssembly) | `wasm-typed-fun-refs` | webassembly |  |
| reciente | 2024-10-17 | 130 | text-wrap | `text-wrap` | text-wrap |  |
| reciente | 2024-12-11 | 128 | ruby-align | `ruby-align` | ruby |  |
| reciente | 2024-12-11 | 121 | scrollbar-width | `scrollbar-width` | scrolling |  |
| reciente | 2024-12-11 | 119 | Garbage collection (WebAssembly) | `wasm-garbage-collection` | webassembly |  |
| reciente | 2025-01-07 | 128 | Promise.try() | `promise-try` | promises | sí |
| reciente | 2025-03-04 | 129 | Intl.DurationFormat | `intl-duration-format` | intl |  |
| reciente | 2025-03-31 | 121 | ClipboardItem.supports() | `clipboard-supports` | clipboard |  |
| reciente | 2025-03-31 | 122 | Iterator methods | `iterator-methods` | iterators | sí |
| reciente | 2025-04-01 | 133 | Atomics.pause() | `atomics-pause` | javascript |  |
| reciente | 2025-04-04 | 135 | Float16Array | `float16array` | typed-arrays |  |
| reciente | 2025-04-29 | 123 | JSON import attributes | `json-modules` | json |  |
| reciente | 2025-05-01 | 136 | print-color-adjust | `print-color-adjust` | print |  |
| reciente | 2025-05-01 | 136 | RegExp.escape() | `regexp-escape` | regexps | sí |
| reciente | 2025-05-27 | 134 | dialog.requestClose() | `requestclose` | html-elements |  |
| reciente | 2025-05-29 | 137 | Exception references with exnref (WebAssembly) | `wasm-exnref-exceptions` | webassembly |  |
| reciente | 2025-06-26 | 138 | abs() and sign() | `abs-sign` | css |  |
| reciente | 2025-08-19 | 137 | Selection composed ranges | `composed-ranges` | selection, web-components |  |
| reciente | 2025-09-05 | 140 | Uint8Array base64 and hex conversion | `uint8array-base64-hex` | typed-arrays | sí |
| reciente | 2025-09-15 | 124 | Unsanitized HTML parsing | `parse-html-unsafe` |  |  |
| reciente | 2025-09-16 | 131 | ::details-content | `details-content` | selectors |  |
| reciente | 2025-10-03 | 141 | WebRTC encoded transform | `webrtc-encoded-transform` | webrtc |  |
| reciente | 2025-10-14 | 125 | view-transition-class | `view-transition-class` | view-transitions |  |
| reciente | 2025-12-12 | 128 | document.caretPositionFromPoint() | `document-caretpositionfrompoint` |  |  |
| reciente | 2025-12-12 | 135 | Invoker commands | `invoker-commands` |  |  |
| reciente | 2025-12-12 | 121 | scrollbar-color | `scrollbar-color` | scrolling |  |
| reciente | 2025-12-12 | 121 | Spelling and grammar text decorations | `text-decoration-spelling-grammar` |  |  |
| reciente | 2026-01-13 | 125 | Active view transition | `active-view-transition` | view-transitions, selectors |  |
| reciente | 2026-01-13 | 118 | rcap unit | `rcap` | units |  |
| reciente | 2026-02-11 | 123 | Zstandard compression | `zstd` |  |  |
| reciente | 2026-02-14 | 145 | Map getOrInsert() | `getorinsert` | maps |  |
| reciente | 2026-02-24 | 135 | shape() | `shape-function` | clipping-shapes-masking |  |
| reciente | 2026-02-24 | 137 | Branch hinting (WebAssembly) | `wasm-branch-hinting` | webassembly |  |
| reciente | 2026-03-13 | 146 | text-indent: each-line | `text-indent-each-line` | text |  |
| reciente | 2026-03-13 | 146 | text-indent: hanging | `text-indent-hanging` | text |  |
| reciente | 2026-03-24 | 146 | Iterator.concat() | `iterator-concat` | iterators |  |
| reciente | 2026-03-24 | 143 | @scope | `scope` | css |  |
| reciente | 2026-04-10 | 147 | contrast-color() | `contrast-color` | color-types |  |
| reciente | 2026-04-10 | 147 | Math.sumPrecise() | `math-sum-precise` | javascript |  |
| reciente | 2026-05-07 | 148 | Name-only container queries | `container-name-queries` | container-queries |  |
| reciente | 2026-05-07 | 148 | crisp-edges | `crisp-edges` | image-scaling |  |
| reciente | 2026-05-07 | 148 | text-decoration-skip-ink: all | `text-decoration-skip-ink-all` |  |  |
| reciente | 2026-05-11 | 133 | :open | `open-pseudo` | selectors |  |
| reciente | 2026-05-11 | 140 | ToggleEvent source | `toggleevent-source` | html |  |
| reciente | 2026-06-16 | 123 | field-sizing | `field-sizing` | css |  |
| reciente | 2026-07-21 | 130 | Intl.Locale info | `intl-locale-info` | intl |  |
| reciente | 2026-08-18 | 138 | sibling-count() and sibling-index() | `sibling-count` | css |  |
| reciente | 2026-09-01 | 138 | progress() | `progress-function` | css |  |
| reciente | 2026-09-11 | 153 | autocorrect | `autocorrect` |  |  |
| reciente | 2026-09-14 | 151 | alpha() | `alpha` | color-types |  |
| reciente | 2026-09-14 | 141 | ariaNotify() | `arianotify` |  |  |
| reciente | 2026-09-14 | 124 | Asynchronously iterable streams | `async-iterable-streams` | streams |  |
| reciente | 2026-09-14 | 150 | light-dark() image values | `light-dark-image` |  |  |
| reciente | 2026-09-14 | 137 | JavaScript promise integration (WebAssembly) | `wasm-jspi` | webassembly |  |
