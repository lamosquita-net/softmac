# Relevo de MOTOR: de MOTOR-15 a MOTOR-16 (21-10-2026, ~21:30)

MOTOR-15 (`session_01FdmrW2VYyWxVvfdgdkzfTu`, Opus 5.5, `xhigh`) hizo los pasos (2) y (3) y la parte de flags del (4) de
la clase D (fila FM.31). **Tu encargo: ML-KEM (resto del paso 4) y el paso (5)**, sobre `nube/base-128-motor`
**3e5b517192** (comprobado con `git ls-remote`): 4a8f1b37a2 más las fusiones de S1, S2 y S4 de SEGURIDAD-PORTES-5 (orden de COORDINACIÓN-11; `computed_style.cc.patch` combinado a mano). Es la única rama de integración de la 128. Sin compilar nada todavía.

**Commits de la rama** (sobre 3419255c8 = paso 1 + S3 de SEGURIDAD-PORTES-5, ya fusionado por MOTOR-14):
2997fb6e34 nivel 129 · 2fc7bb2294 nivel 130 · 0fbe1299b7 nivel 131 · 71f0859504 anchor (FM.28) · 4a8f1b37a2 flags. 268
`.patch` tocados. Cada mensaje de commit dice qué se portó, qué se adaptó a mano y qué se dejó fuera y por qué; léelos
antes de la ronda de compilación.

**Lo que queda:**

1. **ML-KEM (FS.17)**: net 1fef3fb10d7 + 4beeb73c814 (medidos limpios) y BoringSSL de la 128 (f01108e4, ya con Keccak):
   500fa1f9d, f1b043c28, 06aff989b, 7fb4d3da5, 72a60506d (24 rechazos, casi todos en listas generadas: regenerarlas con
   la herramienta de BoringSSL, no a mano). En la 116 fue `seg/ml-kem` fc0f45c433 (fundido en 2331bba696): mira también
   lo que tocó en `chromium_src/net/base/features.*`, `quic_stream_factory.cc` y `ssl_client_socket_impl.cc`.
2. **Paso (5)**, con (2)+(4) completos: rama fija `nube/base-128-motor-p2` y orden a LOCAL por el buzón: Static con
   `enable_precompiled_headers=false` y `-k 0` (TRAMPAS, MOTOR), luego `blink_unittests`, `motor-129…131.html` y WPT.
   Antes, el repaso de TRAMPAS contra las APIs de la 128 (includes sobre todo) en los ficheros más tocados a mano.

**Dónde es más probable que falle la compilación** (todo a mano, sin compilar):

- Relative color con currentcolor (nivel 131): entra la serie de upstream con 9180018ac36 (color e imagen al parser
  *streaming*) y 9166feba61b (`EvaluationInput` fuera de `Length`); `ResolveColorValue()` lleva el `CSSLengthResolver`
  a mano y la 128 no tiene `is_in_web_app_scope`. Revisar los llamantes fuera del área si los hay.
- Nested declarations (130): el parser de at-rules de la 128 es de rangos de tokens; Start/EndRuleBody del observer se
  movieron a mano a los llamantes (page, page-margin, view-transition).
- Pseudo-elementos del `<select>` (131): en la 128 son `::select-fallback-*`; donde el 131 dice `::picker(select)`
  (`kPseudoIdPickerSelect`, `kPickerSelect`) se usa `kSelectFallbackDatalist`; también el enum del protocolo de DevTools.
- `IsAllowedAfterPart()` (130) es la del 131 filtrada al enum de la 128 (`switch` sin `default`).
- RTCDataChannel transferible (130): constructor a mano (la 128 sigue pasando el `RTCPeerConnectionHandler`).

**Decisiones de MOTOR-15 que conviene que COORDINACIÓN conozca** (en los mensajes de commit): KeyboardFocusableScrollers
sin portar (en la 128 ya está la semántica y en la 1.15.2 la flag acaba `experimental`); 256175bafdd fuera (necesita
PopoverAnchorRelationships, que tampoco lleva la 1.15.2); `SerializeNameAndDescriptionAttributes` no se mueve (74a5382ac8b)
porque en la 128 rompería el camino de PDF; `Database` se queda `experimental` como upstream.

**Entorno** (todo en `/tmp` y `/home/user`, nada queda): `mkdir /home/user/chromium/hist && git init` y
`git fetch --filter=blob:none --shallow-since=2023-05-15 origin refs/tags/<tag>:refs/tags/<tag>` para 128.0.6613.138,
129.0.6668.112, 131.0.6778.264 y 116.0.5845.188 (~450 MB, `git config gc.auto 0`); `mkcr.sh /tmp/claude-0/port/cr128
128.0.6613.138` (~1 GB); brave-core con `--depth 900` de `nube/motor-131-anchor-f16` para `fwdiff.sh`. Herramientas
nuevas en `FlyWeb/tools/port/README.md`, «Sobre la base 128».

**Trampas nuevas:**

- **La 128 se cortó el 23-07-2024**: la mitad de los rechazos se van aplicando antes los commits de agosto del mismo
  fichero (`git log 03c1799e6f9..<commit> -- <fichero>`) con `insert.sh`; casi siempre entran limpios después.
- **`patch -F3` coloca hunks donde no van** sin avisar (`rejfuzz.sh` ya va con fuzz 0). Tras cualquier fuzz, `git diff`
  del fichero y mirar cada hunk.
- **La medida de la clase D no ve lo portado como escape con otro nombre**: f30d9fddc4b (PaintHighlightsForFirstLetter)
  faltaba; se encontró comparando el json5 de la 1.15.2 con el de la rama (paso 4).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-14): [`relevo-motor-historial.md`](relevo-motor-historial.md).
