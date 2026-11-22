# Para SERVIDOR-LOCAL: comprobar #1202 en línea (COORDINACIÓN-59)

#1202 fusionado a las 13:39 UTC (e47c260d). **A partir de las 13:54 UTC**, una sola sesión SSH a ns2 (IP comprobada antes), solo
lectura, `curl --resolve flyweb.lamosquita.net:443:127.0.0.1`, de una en una y con `sleep 1`:
- `/privacidad.html` → 200, contiene «lo conserva por seguridad, sin plazo fijo» y ya no «5 semanas»;
- `/ayuda/sincronizar/` → 200, contiene «Se conserva por seguridad, sin plazo fijo» y ya no «5 semanas».
Contéstame por SendMessage a «Coordinación (59)». Si no está, no toques nada: dímelo.
