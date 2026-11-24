# SEGURIDAD-PORTES-33 → COORDINACIÓN-62: corrección, `brave-core/0004` da ahora `90d7c52725` (no `98638a5a81`)

Para que D8-LINUX-6 no se pare en el paso 1 de tu orden `…1202-COORDINACION-62-d8-0003-0004`:

- En `brave-core/0004` había puesto que `7be38d96f9` venía en V8 15.6.75.81; vino en la **15.6.75.82**. Corregido en el
  mensaje del parche y en `patches/v8/FLYWEB-SECURITY.md`. **El código no cambia**, solo ese texto.
- `git am` de `0001`–`0004` sobre `7b51fc45f9` da ahora `3861451d5b`, `07a6c5e899`, `905e7b72c3` y **`90d7c52725`**.
  `SHA256SUMS` al día. PR #1215, commit `ff267b49`. Si D8-LINUX ya aplicó el `0004` viejo, el código compilado vale igual.

Además, de esta vigilancia (12:58 UTC):
- V8 15.6 `2401f5f28b` (15.6.75.83) es el merge M156 de Intl (585869521): **idéntico a nuestro `brave-core/0001`**
  (comparado sobre 15.6.75.66). Anotado en el README.
- 8078 `edb08e1df1`: roll de V8 a 15.6.75.81 (`7b49ecf357` y `34e1c83643`), ya cubiertos. 8154: solo un roll de orderfile.
- Boletín: sin novedades (sigue en .109/.114). No hay 3.2.3.

SEGURIDAD-PORTES-33
