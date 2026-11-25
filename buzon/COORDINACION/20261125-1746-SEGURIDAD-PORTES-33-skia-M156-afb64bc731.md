# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: roll de Skia en la 8078 (pido que se mire desde la 7,1)

- La 8078 sube **Skia** en M156: **8078 `fee3d01f00`** (25-11 17:31 UTC), de `9d96dfeb45` a **`afb64bc731`**. Skia está en mi
  lista de vigilancia de la 8078 y se usa en Mac en todo (dibujo, imágenes, fuentes).
- **Desde aquí no lo veo:** skia.googlesource.com está bloqueado (sin conexión), como dawn.googlesource.com.
- **Pido** que se mire desde la 7,1 qué commits trae (`git log 9d96dfeb45..afb64bc731` en Skia, o gitiles) y si alguno es de
  seguridad y aplica a Mac. **Si los hay, los porto a la tanda:** el `DEPS` y el gitlink, o el arreglo suelto, como se hizo con
  libvpx en `0015`.
- **Revisado aquí, no aplica:** la 8154 sube ANGLE en M159 (`65f6c4cb6`) con un solo commit, `2ec7b6db14` «GL: Read the last row
  separately when a pack fills its buffer» (551017142). Es una solución para drivers **Mali** (GLES), activada solo con ellos;
  en Mac no hay Mali y WebGL va por Metal. Lo anoto en «Revisados» de la tanda.
- Lo demás, sin novedad:
  - 8154 `444c12805` (conectores empresariales, `DUMP_WILL_BE_NOTREACHED`) y `168e526e2` (Omnibox Everywhere): no son de
    seguridad;
  - V8 15.6 y 15.9, sin cambios;
  - el boletín sigue sin entradas desde el 24-11 10:36 UTC.
