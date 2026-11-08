# FlyWeb 3.x: cómo avanzar después de la 3.0.0

**Borrador en curso (ARQUITECTURA, 08-11-2026).** Encargo de COORDINACIÓN-34 (buzón `20261107-2220`), por orden de Titín.
Marco: directiva «Versiones desde la 3.0.0» (Titín, 07-11; `docs/DIRECTIVAS.md`): el segundo dígito (3.1, 3.2…) son
nuestros avances, el primero rendimiento; el tercero (3.0.1, 3.0.2…), tandas de seguridad al ritmo de Chrome estable
más arreglos. claude.ai es el criterio de aceptación de cada versión. Sin horas: hitos y criterios. Decide Titín.

## Plan de trabajo del estudio

1. **Lecturas** (cuatro en paralelo, ya en marcha): rendimiento (B1d, B6, FM.56, `pruebas-gpu.md`, medidas de
   Speedometer, JetStream, MotionMark y claude.ai por máquina); seguridad (`seguridad-3.0.1.md`, `cve-triage.md`,
   histórico de arreglos limpios y con conflicto, lo que pasó con la 128); riesgos (Sparkle 1.24.3, CFBundleVersion
   198.63.N, pendientes de MOTOR para la 3.0.x); base (coste del salto 128 → 156, requisitos de Xcode y macOS,
   divergencia con Chrome, estado del fork propio y portes futuros).
2. **Datos que faltan y a quién se piden** (por COORDINACIÓN): a SEGURIDAD-PORTES-19, la definición operativa de
   «arreglo que entra limpio» y la cifra de la primera tanda (3.0.1); a MOTOR, si la 3.0.0 salió con Maglev
   encendido o apagado (B6) y con ANGLE Metal (B1d), y la lista cerrada de lo pendiente para la 3.0.x; a LOCAL, qué
   medidas de la batería de GPU y de claude.ai hay ya de la 3.0.0 en la 6,1 y en la 5,1.
3. **Redacción** en este mismo documento, con las secciones de abajo; un PR, revisión de COORDINACIÓN, decisión de Titín.

## Secciones previstas

1. Conclusión y recomendación.
2. Contenido y orden de la 3.1, 3.2…: por avance, qué se gana (medido o con fuente), coste, riesgo, máquina de medida
   y criterio de aceptación (claude.ai y el benchmark que toque).
3. Convivencia con la seguridad: capas, ramas, cadencia, quién compila qué; la medida mensual de «cuántos entran limpios».
4. Cuándo hace falta otra base: datos y umbral.
5. Riesgos conocidos: Sparkle, CFBundleVersion, pendientes de la 3.0.x.
6. Qué cambia para cada agente y qué decide Titín.
