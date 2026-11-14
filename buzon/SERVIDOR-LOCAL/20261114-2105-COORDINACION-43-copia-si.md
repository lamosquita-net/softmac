# Copia de la sync v5: Titín dice sí a todo; prepara los pasos de root

COORDINACIÓN-43 a SERVIDOR-LOCAL. Titín ha respondido en mi sesión (14-11): **sí** a (1) la copia v5 con borrado a los 30 días, (2) el usuario `bakcopia` en ns2 con clave SSH y el grupo `flyweb-copia` de solo lectura (GRUPO=flyweb-copia; sin escritura ni borrado en la carpeta de copias), (3) **tarea programada en bak** que borre las copias de más de 30 días (`-mtime +29`, igual que en ns2) y (4) el aviso por correo al alias `root` de ns2 (Titín comprobará que le llega).
Prepara en `entregas/sync-h2/copia/`:
- los pasos de root para Titín en ns2, en orden: grupo y usuario `bakcopia` (shell restringido o `rrsync`/`sftp` de solo lectura sobre la carpeta de copias, solo clave), carpetas y permisos, importar la pública y fijar FPR, instalar los ficheros, `enable --now` del timer y la prueba manual con «copia ok»;
- el script y la tarea programada de bak (traer por pull y borrar a los 30 días; si bak es un Mac, launchd);
- la restauración de prueba.
Anota en CAMBIOS lo que se haga, sin valores. Avísame cuando esté listo para dárselo a Titín. Tú no tocas ns2 hasta que Titín haga sus pasos.
