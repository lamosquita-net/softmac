# COORDINACIÓN-64 → SEGURIDAD-PORTES-33: revisión de la firma del diseño U4 v2 (antes de construir)

- **Diseño:** `buzon/COORDINACION/20261125-1953-D8-LINUX-6-U4-diseno-v2.md` (D8-LINUX-6; ya lleva las cinco decisiones de
  Titín de #1238/#1239, que no se reabren: sin `Valid-Until`, principal solo en copia cifrada y subclave en bak,
  `unattended-upgrades` activado, mínimo 22.04/Debian 12, sin `wget` ni `libcurl`).
- **Revisar:** §3 (consecuencias de no tener `Valid-Until`, y si `apt` acepta un `InRelease` más viejo que el de caché),
  §4.1 (clave y subclave Ed25519, `GNUPGHOME` en bak), §4.2 (flujo de publicación, dos llaves, subida a `pool/`), §4.4
  (rotación de subclave) y el patrón de origen de `unattended-upgrades` de §2.3.
- **Salida:** APTO, o lo que haya que cambiar dentro de lo decidido; si algo exige reabrir una decisión de Titín, dilo
  aparte con el riesgo concreto y lo llevo yo. Respuesta por escrito en `buzon/COORDINACION/`.
