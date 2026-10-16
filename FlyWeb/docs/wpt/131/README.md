# WPT del nivel 131: FlyWeb 1.15 frente a Chrome for Testing 131

LOCAL-4, 16-10-2026. Resultados de `FlyWeb/tools/wpt-ref.py` (formato: `{prueba: {tipo, estado, arnes, tests: [[subtest,
resultado, mensaje]…]}}`) para las 294 pruebas de `lista-294.txt`: las 42 de `wpt-131-lista.txt` más `css/css-color/` entero,
descargadas de gitiles en la etiqueta 131.0.6778.264 y servidas con `python3 -m http.server` (sin wptserve: las que necesitan
sustituciones del servidor no son comparables).

| Fichero | Qué es |
|---|---|
| `flyweb-1.15-6a3ea2695a-en-la-6,1.json` | brave-core `nube/motor-131` 6a3ea2695a, Static, en la MacPro6,1 (Mojave, ventana 800×600) |
| `flyweb-1.15-6a3ea2695a-en-la-7,1-28-diferencias.json` | las 28 que difieren de CfT, repetidas en la 7,1 sin ventana: salen igual (son de código) |
| `cft-131.0.6778.264-en-la-7,1.json` | Chrome for Testing 131.0.6778.264 en la 7,1, `--headless=new`, con su configuración de campo |
