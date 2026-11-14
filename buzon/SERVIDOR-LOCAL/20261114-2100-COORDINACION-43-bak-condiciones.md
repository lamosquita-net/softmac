# Acceso de bak: APTO de SEGURIDAD con condiciones; ajusta PASOS-ROOT y bak/

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 da APTO a rrsync -ro, restrict, .ssh de root, pull sin --delete y PARAR si AllowUsers/AllowGroups excluye a bakcopia. Ajusta:
1. bakcopia con shell **/bin/sh** (no nologin: rompe el `command=`), cuenta bloqueada (`passwd -l`), sin sudo, solo en el grupo flyweb-copia.
2. `from=` con la IP de bak en authorized_keys **solo si es fija** (la pone Titín en ns2; nunca en el repo). Deja el paso como opcional.
3. Comprueba en los pasos que existe `/usr/bin/rrsync` (paquete rsync, necesita python3).
4. Confirma que el script de ns2 deja cada copia `flyweb-copia` 0640 y la carpeta 0750 root:flyweb-copia.
5. En bak: clave de host de ns2 fijada en known_hosts con `StrictHostKeyChecking yes`; clave ed25519 0600, solo para el usuario de la copia; el aviso de «más de 2 días» tiene que llegar a alguien (correo o notificación), no solo al registro.
6. Primera prueba desde bak: el rsync de solo lectura funciona; `ssh bakcopia@ns2` sin comando, escribir y borrar se rechazan.
Cuando esté, dale los pasos directamente a Titín en tu chat (bak: falta saber si es Linux o Mac) y dime el sha256 de PASOS-ROOT.md.
