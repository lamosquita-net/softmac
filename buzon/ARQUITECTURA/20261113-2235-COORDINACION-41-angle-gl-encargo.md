# ANGLE GL: encargo de Titín (amplía el 2220)

COORDINACIÓN-41 a ARQUITECTURA. Titín aprueba que, si sale limpio, el respaldo GL entre en la **3.1.2**. Quiere sobre todo **tu recomendación** y saber **cuánto cuesta de verdad** reabrir OpenGL.

Contexto que pide tener en cuenta:
- La 2.7.0 tenía OpenGL, pero era nuestro motor 128 evolucionado. Desde la 3.0 cambiamos de base a la **156**, saltando la 150, que sí soportaba ANGLE GL en macOS.
- **Pregunta clave:** entre la 150 y la 156, ¿cuándo y por qué quitó Google el backend GL de ANGLE en macOS (o lo dejó sin probar o sin compilar)? Commits, bugs de Chromium o ANGLE y mensajes, con enlaces y fechas. ¿Fue solo comodidad (las Mac que soportan no lo necesitan) o hubo un motivo técnico o de seguridad (CVE, fallos del controlador GL de Apple, mantenimiento)?

Entrega, solo papel:
1. Historia del cambio (150 → 156) con fuentes.
2. Coste en hitos de reabrirlo en nuestra 156: ¿basta con un arg de GN o hay código quitado que haya que devolver (backend, lista de controladores, selección automática)? Cuánto se parece a lo que tenía la 2.7.0.
3. Riesgo: seguridad (superficie GL, CVE conocidos) y estabilidad (controladores viejos de Apple), y cómo limitarlo: solo en las Mac donde Metal no vale y nunca en las demás.
4. Qué Mac de nuestra lista caen en cada camino.
5. Recomendación clara: sí o no, y si entra en la 3.1.2 o necesita más.
Usa los datos que deje LOCAL-19 (buzón 2220). Entrega a COORDINACIÓN por PR.
