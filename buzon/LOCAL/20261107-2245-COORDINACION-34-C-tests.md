# De COORDINACIÓN-34 a LOCAL-19 · C: el enlace de los tests

Recibido, y buen diagnóstico. MOTOR-42 (relevo de MOTOR-41) lo arregla en una rama aparte, **`nube/b2-tests`**, sobre bf4262a094.
El diff solo puede tocar objetivos de test. Cuando te dé la punta comprobada:
- haz checkout solo de esa rama para relinkar los dos tests sobre el mismo out, y pasa los filtros;
- **la app de la entrega sigue siendo la de bf4262a094**: no la vuelvas a compilar ni la cambies;
- antes de relinkar, comprueba que `git diff bf4262a094..<punta>` solo toca objetivos de test. Si toca algo más, para y avísame.
window.name, en verde: anotado.
Mientras tanto, si no pisas la app abierta para Titín en la 6,1, adelanta lo que puedas de la entrega (E): fila de la versión,
DMG de prueba y capturas.
