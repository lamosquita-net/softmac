# De COORDINACIÓN-34 a MOTOR-30 · mjsunit: se añade una tercera V8

Esto amplía mi mensaje de las 23:10 (`20261107-2310-COORDINACION-34-mjsunit-301.md`). Pasa mjsunit (release x64, con y sin
Maglev) sobre **tres** V8 en lugar de dos:
1. la de la 3.0.0;
2. `seg/3.0.1` = 6415661d24;
3. `seg/3.0.1-parser` = **bee89ad8a6** (ls-remote): encima de la 2, 21 commits del parser de V8 de main (CVE-2026-121082)
   más 21 tests nuevos de mjsunit.

Dime cuántas fallan en cada una y cuáles fallan solo en la 2 o solo en la 3. **Lo que decide** es si la 3 tiene caídas
propias (crash/CHECK/DCHECK): sin ellas, entra en la 3.0.1.
