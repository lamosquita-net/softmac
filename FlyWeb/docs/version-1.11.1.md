# FlyWeb 1.11.1 — huella de red de Chrome 127 (LOCAL-2, 13-10-2026)

**Estado:** Release **157.64.17** compilado y probado de brave-core `local/huella-127` **44c1d6e4** (= la 1.11,
`seg/v8-12.7` 94914682, + F4.8). Entregado a PUBLICACIÓN en la fila F4.8 del tablero (regla 11). Detalle técnico y
mediciones: `compatibilidad.md` §5; plan de ARQUITECTURA y revisiones en la fila F4.8.

| Dato | Valor |
|---|---|
| Versión visible / `CFBundleVersion` | 1.11.1 / 157.64.17 (`FLYWEB_BUILD_NUMBER=17`) |
| Motor | nivel 127, V8 12.7.224.20 con la seguridad de la 1.11 (sin cambios) |
| Cambios | Client Hints de UA encendidas y coherentes con Chrome 127; Kyber y ECH en TLS; HTTP/2 sin `MAX_CONCURRENT_STREAMS`; `platformVersion` como mínimo 10.15.7 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Menos bloqueos y comprobaciones de «¿eres un robot?».** Algunas webs protegidas contra bots (por ejemplo tiendas o
  servicios que usan Akamai o Cloudflare) bloqueaban FlyWeb o le hacían esperar en una pantalla de comprobación, porque la
  forma en que se presentaba no encajaba con la de un Chrome normal. Ahora FlyWeb se presenta igual que Chrome 127, y esas
  webs se abren directamente.
- **Conexiones cifradas más modernas.** FlyWeb usa el intercambio de claves resistente a ordenadores cuánticos y prepara
  el cifrado del nombre de la web que se visita (ECH), como Chrome.
- **Más privacidad en Macs antiguos.** A las webs que preguntan la versión de macOS, FlyWeb les dice la mínima compatible
  con Chrome 127 (10.15.7) en lugar de la real cuando es más antigua. Un Mojave era un dato tan raro que ayudaba a
  identificar al usuario.

Nada cambia en los ajustes ni en los datos del usuario.
