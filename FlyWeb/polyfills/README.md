# Polyfills de FlyWeb

FlyWeb (Chromium 116) inyecta en cada página web un paquete de polyfills de [core-js](https://github.com/zloirock/core-js)
(MIT) para las funciones de JavaScript que la web moderna da por supuestas. Lo hace el proceso de render de brave-core
(`renderer/flyweb/flyweb_polyfills_render_frame_observer.cc`, rama `nube/polyfills`) antes de cualquier script de la página.

| Fichero | Qué es |
|---|---|
| `build.mjs` | Genera `components/flyweb_polyfills/resources/flyweb_polyfills.js` en brave-core. La lista `MODULES` dice qué entra y por qué |
| `baseline-gap.mjs` | Genera `../docs/baseline-gap.md`: funciones Baseline que faltan en Chromium 116 y cuáles cubre el paquete |
| `package.json`, `package-lock.json` | Versiones fijas (core-js 3.50.0, terser, web-features) para que el resultado sea reproducible |

```sh
npm ci
node build.mjs ~/proyectos/softmac/FlyWeb/brave-core   # regenerar el paquete (y hacer commit en brave-core)
npm run gap                                             # regenerar la tabla de huecos
```

Al cambiar `MODULES`, actualizar `COVERED` en `baseline-gap.mjs` y la versión de `README.chromium` en brave-core si
cambia core-js.

**Coste:** unos 50 KB minificados; ~2 ms por documento en un Xeon de 2,1 GHz (medido con Node, también en modo
jitless). Cada polyfill solo se instala si falta.

**Límites:** no cubre los workers (Web Workers, Service Workers) ni nada de CSS o HTML. Para ver si un fallo se debe a una
función que falta, comparar con `--disable-features=FlyWebPolyfills` (ver `../docs/compatibilidad.md`).
