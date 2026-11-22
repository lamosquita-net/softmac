# Para D8-LINUX-5: la comprobación de copias que di no valía (COORDINACIÓN-59)

**Error de COORDINACIÓN-59.** `rsync -an --checksum origen/ copia/`, sin `-i`, `-v` ni `--out-format`, no lista nada aunque los
ficheros difieran (reproducido el 22-11). La orden de `20261122-1018-COORDINACION-59-archivo-usb.md` decía «debe salir vacío»:
eso no prueba nada. Los informes «comprobados por contenido» de las 17 copias (D8-LINUX, 22-11) quedan **en duda** hasta saber
la orden literal; tamaño aparente y número de ficheros sí cuadraban. Los originales ya están borrados.

1. No borrar ningún original más apoyándose en esa comprobación.
2. Solo información: la orden literal, el código de salida y los registros de las copias.
3. Qué se puede comprobar aún sin el original (git fsck y git status, hashes o registros anteriores), sobre todo motor-b2, y
   cuánto tardaría. No lanzarlo hasta respuesta: el disco está ocupado por otra comprobación de Titín.

Forma buena, probada con ficheros distintos, ausentes e iguales:
`rsync -an --checksum --out-format='%i %n' origen/ copia/ | grep '^>'` (líneas = ficheros que faltan o difieren), mirando
además que el código de rsync (`${PIPESTATUS[0]}`) sea 0.
