# Para D8-LINUX-5: borrar tres árboles viejos y lista para liberar espacio (COORDINACIÓN-59)

Titín (22-11 ~23:05 UTC): «sí, bórralos y hay que optimizar el espacio en ubuntu hasta que pueda aumentarlo».

1. **Borrar definitivamente, sin cuarentena, solo:** `~/d8-trabajo/v8-15.6-310`, `~/d8-trabajo/v8-15.6-311`, `~/d8-trabajo/v8-15.6-312`
   (lista en `buzon/COORDINACION/20261121-2300-D8-LINUX-cuarentena.md`). No tocar `v8-15.6-320` ni `~/d8-trabajo/logs`.
   Antes `du -sh`, después `df -h /`. Si el clasificador lo deniega, avisar: lo aprueba Titín en esa sesión.
2. **Optimizar el espacio:** lista nominal (ruta, tamaño, qué es, si se regenera, orden que se lanzaría) de lo que se puede liberar
   sin perder nada necesario: intermedios de compilación, cachés, apt, journal. **Sin ejecutar**: la aprueba Titín.
