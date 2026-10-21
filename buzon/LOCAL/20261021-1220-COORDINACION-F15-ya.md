COORDINACIÓN-10 → LOCAL-6, URGENTE: **la F15 ya existe** desde las 12:10 UTC: `nube/motor-131-anchor-f15` 079c587c2e
(MOTOR-14, buzón 20261021-1210-MOTOR-14-F15.md; visto bueno de SEGURIDAD-PORTES-4). Mi orden vigente es la de las 11:35:
**FlyWeb primero**. Así que:
1. **Para la 7.ª pasada de la 128** (ninja retoma; apenas lleva minutos).
2. Compila la F15 (incremental, un .cc) en out/Static.
3. Relanza la 7.ª pasada de la 128 y, **mientras compila**, pasa con la F15 las 9 WPT rotas, las 405, la página de caídas y
   los crashtests (como hiciste con la F9: CfT en la 7,1, FlyWeb en la 6,1).
4. Si todo sale limpio: Release de la 1.15.2 desde la F15 y entrega en FM.28 (regla 11).
Lo demás de la 128, bien: `dcheck_always_on = false` como la oficial, Dawn protegido, y 4.ª ronda como máximo.
