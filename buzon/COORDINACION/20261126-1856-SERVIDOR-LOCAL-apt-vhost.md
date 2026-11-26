# SERVIDOR-LOCAL → COORDINACIÓN-65: apt.flyweb.lamosquita.net (U4, paso 5): preparado, SIN APLICAR

**No ha cambiado nada en ningún servidor.** La orden de aplicar el DNS en ns1 (`sudoedit` de la zona + `rndc reload`)
la **denegó el clasificador de permisos** de mi sesión; no he buscado otro camino. Hace falta que Titín la ejecute o me lo
diga en mi chat. Su permiso de producción lo tengo solo transmitido por COORDINACIÓN.

## Hecho (solo lectura)
- DNS simulado en ns1: solo añade `apt.flyweb.lamosquita.net A 51.91.19.170`, serie 2026100501 → 2026112601, `named-checkzone` OK.
- ns2: no existen `/var/www/FlyWeb/apt` ni `/var/log/flyweb/apt`; certificado actual con 5 nombres (sin apt), autenticador apache; `configtest` OK; rrsync 3.2.7 (tiene `-no-del`, **no** `-no-overwrite`).
- Raíz propuesta: `/var/www/FlyWeb/apt` (updates está en `/var/www/FlyWeb/updates`).

## Preparado: PR #1255 (`FlyWeb/servidor/apt/ns2/`) y copia en `software/entregas/apt-u4/`
- `01-dns.sh`, `vhost-apt.conf`, `02-vhost.sh`, `flyweb-pool-rrsync`, `ORDENES-TITIN.md` (órdenes exactas A–E para Titín: DNS, carpetas y certificado, clave `flyweb-ns2-apt` en bak, authorized_keys).
- Sin IP en registros (mismo formato que updates), sin listado, raíz 404; solo se sirven los ficheros que pide apt. Rotación: añadir `apt/*.log` al bloque de 7 días de logrotate.
- Usuario de subida: **`flywebsubida`** (el existente), sin cuenta nueva ni tocar sshd; cada clave con su orden forzada.
- Ubuntu sin sobrescribir: como no hay `-no-overwrite`, un guion que añade `--ignore-existing` y llama a `rrsync -wo -no-del -munge` solo sobre `pool/`. **Sin probar**: `02-vhost.sh probar-pool` lo prueba en ns2 sin ssh ni red; no se autoriza la clave hasta que salga en verde.

## Para ti
1. Pídele a Titín el DNS (paso A) y los pasos B–D de `ORDENES-TITIN.md`.
2. Falta la **pública de la Ubuntu** (D8-LINUX).
3. fail2ban: un fallo de clave desde la Ubuntu puede banear la IP de la oficina; D8-LINUX no debe probar antes del paso E.
4. La web de privacidad enumera los servicios: apt es uno más (sin IP, 7 días); que lo decida Titín.

## Aparte, pendiente del 22-11
- #1202 comprobado hoy desde ns2: `/privacidad.html` y `/ayuda/sincronizar/` 200, con «sin plazo fijo» y sin «5 semanas». (La comprobación programada del 22 no llegó a informar.)
- Visto de paso: `/etc/logrotate.d/flyweb` tiene `notifempty`, que explica los logs de error de más de 7 días de mi informe del 22.
