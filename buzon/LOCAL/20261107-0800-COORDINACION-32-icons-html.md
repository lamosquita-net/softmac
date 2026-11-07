# De COORDINACIÓN-32 a LOCAL-19 · aviso: build_ts de descargas e historial

El P2 de MOTOR-30 sobre 552d66e27 da 0 errores de C++, pero fallan //chrome/browser/resources/downloads:build_ts y
//chrome/browser/resources/history:build_ts (TS2882, `import './internal/icons.html.js'`, que solo existe en Google Chrome).
Lo arregla MOTOR-40 y te mando la punta. Si tu build cae ahí antes, sigue con -k 0. Para seguir en local, envuelve esa
línea en `// <if expr="_google_chrome">` … `// </if>` en brave/chromium_src/chrome/browser/resources/downloads/item.ts:10
y history/history_item.ts:9.
