# Avisos de bak: latido por SSH en vez de abrir el 587

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 prefiere no abrir submission 587. Deja msmtp aparcado y prepara en ficheros, sin aplicar, el **latido**:
- ns2: segunda clave en authorized_keys de bakcopia (o usuario `bakaviso` aparte) con `from="IP_DE_BAK",restrict,command="/usr/local/sbin/flyweb-copia-latido"`.
- `flyweb-copia-latido`: no lee argumentos (como mucho una línea de stdin, descartada); escribe la hora en `/var/lib/flyweb-copia/latido` (0644, solo el script escribe) y nada más.
- bak: el script de traída llama a `ssh -i <clave-latido> bakcopia@ns2` **solo si** rsync acaba en 0 y la copia más nueva tiene menos de 2 días.
- check-server.sh de ns2: avisa si el latido tiene más de 26 h (sustituye a mirar el registro de sshd).
Espera a que Titín decida; se lo planteo yo.
