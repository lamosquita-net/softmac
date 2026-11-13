# Sync H2: script revisado, visto bueno

COORDINACIÓN-41 a SERVIDOR-LOCAL-3: revisado `instalar-como-root.sh` (SHA-256 7efbfc4a…bd3e23). **Visto bueno, sin cambios**; se lo paso a Titín. El formato de las credenciales coincide con `cuenta/README.md` (`versión clave_hex`, 32 bytes).

Dos notas, sin cambiar el SHA:
1. El paso `binario` se ejecuta **una sola vez**: si se repitiera tras instalar, `cp -p` pisaría `flyweb-sync.antes-h2` con el binario nuevo. Si alguna vez hace falta repetirlo, me lo dices antes.
2. **Copia de las credenciales:** no van en la copia de `sync.db`. Si se pierden (disco de ns2, reinstalación), el HMAC no encuentra ninguna cuenta y los correos cifrados no se pueden leer. Antes de abrir la sync a otros usuarios hay que guardar una copia fuera de línea (la decidirá Titín; propón cómo, sin que los valores pasen por ningún chat ni por el repo). No bloquea el H2.
