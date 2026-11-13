# LOCAL-19: COMPILAR LA 3.1.1 ya (de COORDINACIÓN-40). Contenido cerrado: `FlyWeb/seguridad/3.1.1/CONTENIDO.md` (#966)

Decisión de Titín (13-11, DIRECTIVAS #965): la 3.1.1 sale ya, **sin la 158** (va a la 3.1.2) y **sin la V8 .59** (paso
opcional de CONTENIDO: NO lo apliques; D8-LINUX lo está probando para la 3.1.2). V8 = 15.6.75.58, ya probada (#961).

**Chromium:** `seg/3.0.2` 502e3c5b85, con `git am` y en este orden, comprobando el árbol tras cada paso:
1. `FlyWeb/seguridad/3.1.1/chromium/` 0001–0034 → árbol 3d9092e4e3;
2. 0035–0043 (delta de 156.0.8078.104) → d9f6c5c67e;
3. `FlyWeb/parches/3.1.1-catalina/` 0001–0004 → 38c6e1d3e3.
Comprueba `SHA256SUMS` antes. Si un árbol no cuadra, para y avísame.
**brave-core:** `local/3.1` fc9389773fe + `FlyWeb/seguridad/3.1.1/brave-core/0001` (flyweb_version 3.1.1). Build **44**,
CFBundleVersion 198.63.44, `chrome/VERSION` .104. Maglev encendido como en la 3.1.0. Release oficial con PGO; perfil de V8
con `download_profiles.py --check-v8-revision`.
**Pruebas antes de entregar:** las de CONTENIDO §«Pruebas para LOCAL», puntos 2–8:
- navegación de 0030/0031 (popup desde CSP sandbox, about:blank y srcdoc, file:// → about:blank, claude.ai entero);
- FSA con mayúsculas (`~/LIBRARY`);
- **huella de Chrome 156** (JA4, HTTP/2, orden de cabeceras, Client Hints frente a un Chrome 156 real);
- WebRTC 2–3 min colgando a mitad; canvas 2D con `ctx.filter` y filtro SVG;
- `comprobar-importes-1015.py` sobre el FlyWeb Framework (tiene que salir vacío de importes fuertes que falten en 10.15)
  y el grep de ANGLE/Dawn de `3.1.1-catalina/README.md`;
- la batería de siempre en la 7,1 y la 6,1.
La prueba en Catalina (Mac mini y MacBook Pro 2012) la hace Titín con la versión publicada: deja el DMG a mano.
**Entrega** en la fila de la versión con los hashes (ls-remote) → PUBLICACIÓN (regla 11). Sin datos personales.
