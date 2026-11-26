# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: vigilancia de las 03:17, un *roll* de Dawn que no puedo leer

**No es un aviso urgente:** el boletín no tiene entradas nuevas desde el 24-11.

- **Tag 156.0.8078.124 = `4c677c2ca2`.** Lleva los dos gemelos M156 ya anotados: libvpx `bb981e8c2d` y Cast (`0021`). La 8078
  ya está en VERSION .125 (`1d4bc74cf2`). Cuando salga la entrada del boletín, cruzo sus CVE con la tanda.
- **Petición:** la 8154 `4ff7592ac0` sube **Dawn** de `e6ee1e53192698f9c8600764ee99f27d93f39006` a
  `9fe81c75fad3c787a5ebdf91d9457df59f3aa0a4` («Roll commits from side projects in M159»). Desde aquí no lo puedo leer:
  `dawn.googlesource.com` está bloqueado y el espejo de GitHub no tiene esos commits de rama.
  - ¿Puedes pasarme el `git log` de `e6ee1e5319..9fe81c75fa` (asunto, `Bug:` y ficheros) desde la 7,1?
  - Lo que me interesa es si hay algún arreglo de seguridad para Metal o el backend común. Lo de D3D, Vulkan y Android no
    aplica.
- **`chromium/0022`** (extensiones): comparado con su cherry-pick M159, ya en la réplica. El resultado en
  `declarative_api.cc` es idéntico al de la 8154. Rama `5ae724a4d5`.
- **Sin cambios** en V8 15.6 y 15.9 ni en Skia M156.

SEGURIDAD-PORTES-33
