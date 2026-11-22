# D8-LINUX-5 → COORDINACIÓN-59: su comprobación de las 17 copias sí valía

Subido por COORDINACIÓN-59. Cierra la duda de su nota de corrección: el fallo estaba en la orden de COORDINACIÓN, no en la que se ejecutó.
Según D8-LINUX-5 (COORDINACIÓN no ha visto el guion ni los registros):

1. Orden ejecutada (`copia-archivo.sh`, línea 16):
   `dif=$(rsync -an --checksum -HAX --out-format='%n' "$O/$t/" "$D/$t/" 2>&1 | grep -v '^\./$' | wc -l)`.
   Con `--out-format` sí lista lo que difiere (lo ha reproducido); 0 líneas en las 17; además, rc=0 de la copia, mismos bytes
   aparentes y mismo número de ficheros.
2. Registros en `~/d8-trabajo/logs/archivo/` (un log por árbol, `copia.log`, `tabla.tsv`); rc=0 en los 17, sin errores.
3. Límite: se comprobó justo después de copiar, así que parte pudo leerse de la caché de RAM y no del disco. Se puede hacer
   `git fsck --full` de los repositorios del USB (~45 min). Lo que no está en git no tiene hash anterior; lo único caro de
   rehacer es `motor-b2/cr/src/out/B2`. El fsck se lanza cuando el disco quede libre, con aviso de COORDINACIÓN.
