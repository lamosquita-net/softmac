# De COORDINACIÓN-36 a «Motor ubuntu» · mjsunit de la V8 de la 3.0.2 (con y sin parser)

Para la sesión del PC Ubuntu abierta por Titín el 09-11 (`session_01MwmK2kVVMhxRUscaawz4rP`). Yo soy COORDINACIÓN-36
(`session_01MwmK2gmWuLtoTHjfCXLggq`). Sustituye a los encargos de mjsunit de COORDINACIÓN-34 (07-11) de esta carpeta.

Directiva fija: aquí solo se compila d8 y se pasa mjsunit; nada de `chrome` ni Blink, sin push, sin llaves ni datos de
Titín; paquetes solo con `sudo apt-instalar` (nunca `apt-get`). Si hay un checkout de V8 con build en `~/d8-trabajo` o
`~/motor-trabajo`, reutilízalo.

Hashes (git ls-remote, 09-11 17:15 UTC; repos públicos `lamosquita-net/brave-core` y `lamosquita-net/chromium`):
- V8 de la 3.0.2: **182f13107b** (15.6.75.51; gitlink de V8 en chromium `seg/3.0.2` = 502e3c5b85).
- V8 de la 3.0.1: **6500240d22** (15.6.75.50).
- brave-core `seg/3.0.1` = **6415661d24**; `seg/3.0.2` = **0d6a771f23**; `seg/3.0.1-parser` = **bee89ad8a6** (encima de
  6415661d24: 21 commits del parser de V8 de main, CVE-2026-121082, más 21 tests nuevos de mjsunit).

Tres d8, release x64:
- **A** = 6500240d22 + `patches/v8` de `seg/3.0.1` (referencia: la 3.0.1).
- **B** = 182f13107b + `patches/v8` de `seg/3.0.2` (3.0.2 sin parser).
- **C** = B + los parches del parser que añade bee89ad8a6 sobre 6415661d24, con sus tests.
Si un parche no aplica limpio, para y pregúntame antes de improvisar.

Pruebas: mjsunit con y sin Maglev en las tres.
Quiero: total y fallos de cada una; los que fallan solo en B o solo en C respecto a A; y si C tiene caídas propias
(crash/CHECK/DCHECK). **Lo que decide:** sin caídas propias, el parser entra en la 3.0.2.

Respuesta a COORDINACIÓN-36 por SendMessage/send_message; si no llega, en `buzon/` no puedes escribir: díselo a Titín.
Primero un acuse corto con la carpeta y la build que vas a usar.
