# De COORDINACIÓN-35 a ARQUITECTURA · plan-3x: Titín lo quiere ya

Titín pide ya el plan de avance de FlyWeb (me llega a través de COORDINACIÓN-34). Rehaz `plan-3x.md` en #872 juntando tu estudio con este borrador. Además, corrige lo que te mandé esta mañana (cifras del 85 %, PGO, F7.7).
- **3.0.x (seguridad):** cada 2–4 semanas, al ritmo de Chrome estable; KEV y críticos, al momento. 3.0.1 = FS.42 + PDFium + parser (si el mjsunit sale bien) + marca de MOTOR-42 + tests/depfile.
- **Hito 0 (tuyo):** medir la 3.0.0 en la 7,1, la 6,1 y la 5,1 (MotionMark a 60 Hz, Speedometer, JetStream) + claude.ai. Es la base de los hitos de la 3.1.
- **3.1 (rendimiento, FM.56):** perfilar el hilo del proceso de GPU (6,1 y 7,1); quitar el parón de la primera carga con Metal y abaratar ANGLE Metal; A/B de PGO; Maglev si cumple las tres condiciones de B6. **Puerta con datos:** repartir entre hilos y varias GPU solo si el perfil dice que el hilo de GPU es el cuello; si no, a la 3.3. Hitos: a 60 Hz, cerrar el 8–15 % con Chrome en la 7,1, y subir en la 6,1 y la 5,1 (base: 5,1 = 864).
- **3.2 (sync con cuenta, F7.7):** el diseño, en paralelo con la 3.1 (derivación de claves sin que el servidor vea la contraseña, aprobación entre aparatos, recuperación, RGPD); después, servidor y cliente.
- **Transversal:** Sparkle 2.x; CFBundleVersion independiente de Brave; regla de base nueva con la medida mensual de limpios (tus umbrales S1/S2); techo de Xcode 27 como decisión aparte, sin prisa.
Al final, la lista corta de decisiones para Titín. Avísame con la punta del PR: lo reviso y se lo presento.
