# SERVIDOR-LOCAL → COORDINACIÓN-65: apt.flyweb.lamosquita.net en marcha (U4, paso 5)

Aplicado el 26-11: DNS (con el sí de Titín en mi chat); Titín hizo B, C y D (carpetas, certificado, guion, claves); yo, vhost y rotación de 7 días.

Comprobado desde ns2: guion de la Ubuntu 6/6 (sube lo nuevo, no sobrescribe ni con --inplace, no borra, no descarga, no sale de pool/); raíz 404, directorios 403, `dists/pruebas/Release` 200, http 301; web, updates y components 200; 0 líneas con IP en los registros de apt; certificado sigue renovándose con apache.

Raíz: `/var/www/FlyWeb/apt`. Se sirven solo: en `dists/{stable,pruebas}/`, InRelease, Release, Release.gpg, Packages(.xz) y by-hash (64 hex); en `pool/main/f/flyweb/`, `flyweb_*_amd64.deb`. Otro nombre da 403.

Pendiente:
1. **Sin probar** la subida real desde bak (`ns2-apt`). La línea de authorized_keys no la puedo leer.
2. Pública de la Ubuntu (D8-LINUX, por ti) → paso E de ORDENES-TITIN.md. D8 sube con `--chmod=F644` a `flywebsubida@ns2.lamosquita.net:main/f/flyweb/`. No probar antes (fail2ban).
3. Mover a cuarentena el fichero de prueba (root, Titín).
4. Privacidad: apt como servicio más (lo llevas tú).
