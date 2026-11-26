# apt.flyweb.lamosquita.net: pasos de Titín

Estado a 26-11: **nada aplicado en ningún servidor.** Orden: A (DNS) → B (ns2, root) → C (bak) → D (ns2, clave de bak)
→ SERVIDOR-LOCAL aplica el vhost → E (clave de la Ubuntu, cuando D8-LINUX pase su pública).

## A. DNS (desde la 7,1, en la carpeta `FlyWeb/servidor/apt/ns2`)
Simulado: añade solo `apt.flyweb.lamosquita.net A 51.91.19.170` y sube la serie a 2026112601.
Lo ejecutas tú, o me dices en mi chat «aplica el DNS».
```bash
ssh ns1 'bash -s -- aplicar' < 01-dns.sh
```

## B. En ns2 (ns2.lamosquita.net, como `ubuntu`): carpetas, certificado y guion de la Ubuntu
Carpetas del repositorio (dueño `flywebsubida`, el usuario de subida que ya existe) y de registros:
```bash
for d in "" /dists /dists/stable /dists/stable/main /dists/stable/main/binary-amd64 /dists/stable/main/binary-amd64/by-hash /dists/stable/main/binary-amd64/by-hash/SHA256 /dists/pruebas /dists/pruebas/main /dists/pruebas/main/binary-amd64 /dists/pruebas/main/binary-amd64/by-hash /dists/pruebas/main/binary-amd64/by-hash/SHA256 /pool /pool/main /pool/main/f /pool/main/f/flyweb; do sudo install -d -o flywebsubida -g flywebsubida -m 0755 "/var/www/FlyWeb/apt$d"; done
```
```bash
sudo install -d -o root -g root -m 0755 /var/log/flyweb/apt
```
Fichero de prueba (se mueve a cuarentena al final, no se borra):
```bash
echo prueba | sudo -u flywebsubida tee /var/www/FlyWeb/apt/dists/pruebas/Release
```
Certificado ampliado (solo después de A):
```bash
sudo certbot certonly --apache --expand --cert-name flyweb.lamosquita.net -d flyweb.lamosquita.net -d components.flyweb.lamosquita.net -d updates.flyweb.lamosquita.net -d proxy.flyweb.lamosquita.net -d sync.flyweb.lamosquita.net -d apt.flyweb.lamosquita.net
```
Guion de la clave de la Ubuntu (el texto es el de `flyweb-pool-rrsync` de esta carpeta):
```bash
sudo tee /usr/local/bin/flyweb-pool-rrsync >/dev/null <<'FIN'
#!/bin/sh
POOL=${FLYWEB_POOL:-/var/www/FlyWeb/apt/pool}
case "$SSH_ORIGINAL_COMMAND" in
    "rsync --server "*) SSH_ORIGINAL_COMMAND="rsync --server --ignore-existing ${SSH_ORIGINAL_COMMAND#rsync --server }" ;;
    *) echo "solo rsync" >&2; exit 1 ;;
esac
export SSH_ORIGINAL_COMMAND
umask 022
exec /usr/bin/rrsync -wo -no-del -munge "$POOL"
FIN
```
```bash
sudo chmod 0755 /usr/local/bin/flyweb-pool-rrsync
```

## C. En bak (bak.lamosquita.net): clave propia de `flywebfirma`
```bash
sudo -u flywebfirma -H ssh-keygen -t ed25519 -N '' -C flyweb-ns2-apt -f /var/lib/flyweb-firma/.ssh/flyweb-ns2-apt
```
Antes de seguir, comprueba que `/var/lib/flyweb-firma/.ssh` es la carpeta donde está su `config` actual
(`getent passwd flywebfirma`). Añade a ese `config`, junto a `ns2-updates`:
```
Host ns2-apt
    HostName ns2.lamosquita.net
    User flywebsubida
    IdentityFile ~/.ssh/flyweb-ns2-apt
    IdentitiesOnly yes
```
La pública (`flyweb-ns2-apt.pub`) va al paso D. **No pruebes la conexión antes de D** (fail2ban).

## D. En ns2: autorizar la clave de bak (solo desde bak, solo escribir en la raíz del repositorio)
Primero copia y mira el `from=` de las líneas que ya hay: el valor de `<IP de bak>` es ese mismo, cópialo de ahí.
```bash
sudo cp -p /var/lib/flyweb-subida/.ssh/authorized_keys /var/lib/flyweb-subida/.ssh/authorized_keys.antes-apt
```
```bash
sudo grep -o 'command="[^"]*",[^ ]*' /var/lib/flyweb-subida/.ssh/authorized_keys
```
Después, sustituyendo `<IP de bak>` por la del `from=` anterior y `AAAA…` por la pública de C:
```bash
echo 'command="/usr/bin/rrsync -wo /var/www/FlyWeb/apt",restrict,from="<IP de bak>" ssh-ed25519 AAAA… flyweb-ns2-apt' | sudo tee -a /var/lib/flyweb-subida/.ssh/authorized_keys >/dev/null
```
Comprueba que la línea quedó sola en su renglón (si la anterior no acababa en salto de línea, se habrían pegado).

## E. En ns2: clave de la Ubuntu (cuando esté su pública, y solo con la prueba `probar-pool` en verde)
```bash
echo 'command="/usr/local/bin/flyweb-pool-rrsync",restrict ssh-ed25519 AAAA… flyweb-ns2-apt-pool' | sudo tee -a /var/lib/flyweb-subida/.ssh/authorized_keys >/dev/null
```
La Ubuntu sube con rutas relativas a `pool/` y permisos de lectura:
`rsync --chmod=F644 flyweb_X_amd64.deb flywebsubida@ns2.lamosquita.net:main/f/flyweb/`
**Ojo, fail2ban:** un solo fallo de clave puede banear la IP desde la que sale la Ubuntu (la de la oficina, si está
aquí). Probar solo después de E y con el usuario y la clave exactos.

## Al final
```bash
sudo mkdir -p /var/www/FlyWeb/cuarentena-apt && sudo mv /var/www/FlyWeb/apt/dists/pruebas/Release /var/www/FlyWeb/cuarentena-apt/Release.prueba
```
