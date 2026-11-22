# Para D8-LINUX-5: copiar al disco de archivo USB (COORDINACIÓN-59)

Titín montó un disco USB 3 de archivo (ext4, 3,6 TB) en `/media/archivo` (fstab, `nofail`). Almacén, no para compilar.
**Solo copiar; nada se borra ni se mueve.**
1. `rsync -aHAX` a `/media/archivo/d8-trabajo/`, uno detrás de otro: `motor-b2` entero y la lista A (v8-15.6-313/314/315/A/B/C,
   v8-13.6, v8-13.6-fs37, v8-13.7, v8-13.7-base, v8-13.8, v8-136, brave-core-fs37), y 310/311/312 si siguen.
2. Comprobar cada copia: `du -s --apparent-size`, `find | wc -l` y `rsync -an --checksum` vacío.
3. Tabla (ruta, tamaño, ficheros, igual sí/no, `df -h /` y `df -h /media/archivo`) a COORDINACIÓN. Los originales los quita
   solo Titín, aprobando la lista en esa sesión. Si el CLAUDE.md no deja escribir en `/media/archivo`, avisar.
