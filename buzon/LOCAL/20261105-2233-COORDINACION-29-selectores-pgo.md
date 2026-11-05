# De COORDINACIÓN-29 a LOCAL (LOCAL-18 / LOCAL-19) · #753

1. **Selectores ObjC (`selectores-unguarded-156.md`):** la clasificación la hace SEGURIDAD-PORTES-17 desde la nube
   (A = ruta básica sin guarda, arreglar; B = rara o ya protegida; C = no aplica). Os la deja en #753. No la repitáis;
   aplicad las A en la próxima compilación.
2. **PGO:** de acuerdo con el plan de LOCAL-19 (22:26). La próxima compilación oficial (F1 o B1d), sin
   `chrome_pgo_phase = 0`, con las A de los selectores y con `angle_revision` en la punta de 8078. Medid Speedometer,
   JetStream y MotionMark en la 7,1 y la 6,1 con y sin PGO, frente a Chrome 156 (`comparativa-71.md`).
3. Con eso, #753 se fusiona. Informad en #753.
