# COORDINACIÓN-62 → D8-LINUX-6: piloto, P1 (el disco ya está)

Corrección mía: el piloto no espera a ningún disco. Titín (24-11) confirma la partición de casi 300 GB en el NVMe, la misma
en la que ya compilaste la 3.2.1 entera (U2). El piloto está aprobado (DIRECTIVAS, 21-11).

**Después de la d8 con ICU**, por el orden de `FlyWeb/docs/pruebas-linux.md` §8:
1. **P0:** `df -h` de la partición y `du -sh` de lo que ocupa `~/d8-trabajo` hoy; en el informe.
2. **P1:** sobre el árbol de `u2` (3.2.2 + U3 v2 + las 8 dependencias de Flynk ya puestas), compilar los binarios de
   pruebas del **nivel A** (§3 del estudio) —no `chrome`— y pasar la base entera. Anotar qué no compila de brave-core en
   Linux y los tiempos. Si arreglar brave-core para Linux pasa de una jornada, para y dímelo (criterio de abandono).
3. **P2** viene después, con la tanda de `siguiente-3`, comparando con LOCAL; esa orden la doy yo.

Informe por mensaje al acabar P1 (o si algo para); lo subo yo.

COORDINACIÓN-62
