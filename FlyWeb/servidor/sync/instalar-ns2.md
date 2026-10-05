# Instalar flyweb-sync en ns2 (SV.1)

Procedimiento para el HUMANO (o LOCAL con su permiso). Lo preparó SERVIDOR el 05-10-2026; **nada de esto se ejecuta
sin el «validado» del HUMANO**. Ninguna orden muestra secretos (aquí no hay ninguno: ni clave de servicio ni de API).

## Qué se instala

| Pieza | Origen | SHA-256 |
|---|---|---|
| Binario `/opt/flyweb-sync/flyweb-sync` | Release `flyweb-sync` (CI, commit `eb7a424`) | `6b690b21467c3637b9e655a72c7888585aca974270d330c460876c3872b0007c` |
| Unidad `/etc/systemd/system/flyweb-sync.service` | `FlyWeb/servidor/systemd/flyweb-sync.service` | `e9b1b783cc6c2a7bf8f4b052ebe2c23a445231cfe38a2bd84037075963d2f417` |
| Vhost, al final de `lamosquita.conf` | `FlyWeb/servidor/e0/apache/flyweb-sync-vhost.conf` | `7991492911d5a46a14edf42a82494a87d8d63b27c6f15c817d1bbd76284798a5` |

- **Binario reproducido por SERVIDOR** (04/05-10, Go 1.26 que pide `go.mod`, mismas opciones que el CI): misma suma
  que la release. Los ficheros de `sync/` no han cambiado desde `eb7a424`.
- **Compara siempre con la suma de esta tabla**, no con `flyweb-sync.sha256` de la release: la release se reescribe
  en cada fusión (`--clobber`), así que su `.sha256` no prueba nada por sí solo.
- Si una suma no coincide: **parar** y avisar a SERVIDOR.

## 0. Antes (solo lectura, en ns2)

```sh
getent hosts sync.flyweb.lamosquita.net             # nada (el nombre aún no existe; comprobado el 04-10)
sudo ss -ltnp | grep ':8295 '                        # nada: el puerto está libre
systemctl list-unit-files flyweb-sync.service        # «0 unit files listed»
timedatectl show -p NTPSynchronized --value          # yes (go-sync rechaza tokens con más de 1 día de desfase)
ls -l /etc/apache2/sites-enabled/lamosquita.conf     # enlace a ../sites-available/lamosquita.conf
ls -ld /var/www/FlyWeb/proxy-vacio                   # existe (raíz vacía de proxy., la comparte sync.)
sudo apache2ctl -M 2>/dev/null | grep -E 'rewrite|proxy_http|ssl|http2'   # los cuatro
sudo apachectl configtest                            # Syntax OK (punto de partida)
sudo certbot certificates --cert-name flyweb.lamosquita.net | grep Domains
#   -> flyweb., updates., components. y proxy.flyweb.lamosquita.net. Si hay otros nombres, pararse y avisar.
# Que fail2ban y CrowdSec no lean /var/log/flyweb (no debe salir nada):
sudo grep -rn '/var/log/flyweb' /etc/fail2ban/ /etc/crowdsec/acquis.yaml /etc/crowdsec/acquis.d/ 2>/dev/null
```

## 1. DNS (ns1, maestro)

Igual que con `proxy.` el 03-10: copia de la zona, una línea nueva y la serie al alza.

```sh
Z=<fichero de la zona lamosquita.net en ns1>          # el mismo que el 03-10 (lamosquita.net.hosts)
sudo cp -p "$Z" "$Z.bak-20261005-sync"
# Editar: duplicar la línea de proxy.flyweb cambiando el nombre a sync.flyweb (A 51.91.19.170) y subir la serie.
sudo named-checkzone lamosquita.net "$Z"             # OK, con la serie nueva
sudo rndc reload lamosquita.net                      # o como recargues la zona habitualmente
```

Comprobar (desde cualquier sitio):
```sh
for s in ns1 ns2 ns3; do dig +short sync.flyweb.lamosquita.net @$s.lamosquita.net; done   # 51.91.19.170 tres veces
```
Deshacer: quitar la línea **y volver a subir la serie** (restaurar la copia bajaría la serie y ns2/ns3 no la cogerían).

## 2. Certificado

```sh
sudo certbot certonly --apache --cert-name flyweb.lamosquita.net --expand \
  -d flyweb.lamosquita.net -d updates.flyweb.lamosquita.net -d components.flyweb.lamosquita.net \
  -d proxy.flyweb.lamosquita.net -d sync.flyweb.lamosquita.net
sudo openssl x509 -in /etc/letsencrypt/live/flyweb.lamosquita.net/cert.pem -noout -ext subjectAltName
#   -> los cinco nombres
```
Deshacer: no hace falta (un nombre de más no afecta a los otros vhost); si se quiere, repetir sin `sync.`.

## 3. Binario

```sh
mkdir -p ~/flyweb-sync && cd ~/flyweb-sync
curl -fsSLO https://github.com/lamosquita-net/softmac/releases/download/flyweb-sync/flyweb-sync
echo "6b690b21467c3637b9e655a72c7888585aca974270d330c460876c3872b0007c  flyweb-sync" | sha256sum -c   # OK
sudo install -d -m 0755 /opt/flyweb-sync
sudo install -m 0755 flyweb-sync /opt/flyweb-sync/
```

## 4. Servicio

`C` = commit de `main` en el que se fusionó el PR de SV.1 (te lo da SERVIDOR).

```sh
C=<commit>; R=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor
curl -fsSLo flyweb-sync.service "$R/systemd/flyweb-sync.service"
echo "e9b1b783cc6c2a7bf8f4b052ebe2c23a445231cfe38a2bd84037075963d2f417  flyweb-sync.service" | sha256sum -c
sudo install -m 0644 flyweb-sync.service /etc/systemd/system/
sudo systemd-analyze verify /etc/systemd/system/flyweb-sync.service      # sin salida
sudo systemctl daemon-reload && sudo systemctl enable --now flyweb-sync
```

Comprobar:
```sh
systemctl is-active flyweb-sync                                           # active
sudo ss -ltnp | grep ':8295 '                                             # solo 127.0.0.1:8295
sudo journalctl -u flyweb-sync -n 5 --no-pager                            # «flyweb-sync arrancado», escucha 127.0.0.1:8295
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://127.0.0.1:8295/v2/command/   # 401 (sin token)
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8295/                      # 404
sudo ls -l /var/lib/private/flyweb-sync/                                  # sync.db, permisos -rw-------
systemd-analyze security flyweb-sync | tail -1                            # nivel de exposición (informativo)
```

## 5. Apache

```sh
curl -fsSLo flyweb-sync-vhost.conf "$R/e0/apache/flyweb-sync-vhost.conf"
echo "7991492911d5a46a14edf42a82494a87d8d63b27c6f15c817d1bbd76284798a5  flyweb-sync-vhost.conf" | sha256sum -c
F=/etc/apache2/sites-available/lamosquita.conf
sudo cp -p "$F" "$F.bak-20261005-sync"
sudo install -d -m 0755 /var/log/flyweb/sync
cat flyweb-sync-vhost.conf | sudo tee -a "$F" >/dev/null                  # al final, como proxy.
sudo apachectl configtest                                                 # Syntax OK, sin avisos nuevos
sudo systemctl reload apache2
```
Si `configtest` falla: `sudo cp -p "$F.bak-20261005-sync" "$F"` y **no** recargar.

## 6. Prueba desde fuera (desde un Mac, no desde ns2)

```sh
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://sync.flyweb.lamosquita.net/v2/command/   # 401
curl -s -o /dev/null -w '%{http_code}\n' https://sync.flyweb.lamosquita.net/                       # 404
curl -s -o /dev/null -w '%{http_code} %{redirect_url}\n' http://sync.flyweb.lamosquita.net/        # 301 https://sync…/
# Los demás siguen igual:
curl -s -o /dev/null -w '%{http_code}\n' https://flyweb.lamosquita.net/                            # 200
curl -s -o /dev/null -w '%{http_code}\n' https://proxy.flyweb.lamosquita.net/edgedl/chrome/dict/es-es-3-0.bdic  # 200
```
Sin `-k`: si el certificado no cubriera `sync.`, `curl` fallaría en vez de dar 401/404.

Después, en ns2, que no haya IP en los registros:
```sh
sudo grep -cE '([0-9]{1,3}\.){3}[0-9]{1,3}' /var/log/flyweb/sync/*.log     # 0 en los dos
sudo journalctl -u flyweb-sync --since -1h --no-pager | grep -cE '([0-9]{1,3}\.){3}[0-9]{1,3}'   # solo el arranque (127.0.0.1)
```

Pásale a SERVIDOR la salida de las comprobaciones (no contiene secretos): queda en `FlyWeb/servidor/CAMBIOS.md`.
Luego, la prueba con FlyWeb en los tres Mac es de LOCAL (`README.md`, «Prueba con FlyWeb»).

## Vuelta atrás (en este orden; cada paso es independiente)

```sh
# Apache
sudo cp -p /etc/apache2/sites-available/lamosquita.conf.bak-20261005-sync /etc/apache2/sites-available/lamosquita.conf
sudo apachectl configtest && sudo systemctl reload apache2
# Servicio y binario
sudo systemctl disable --now flyweb-sync
sudo rm /etc/systemd/system/flyweb-sync.service && sudo systemctl daemon-reload
sudo rm -r /opt/flyweb-sync
# Registros
sudo rm -r /var/log/flyweb/sync
# Datos: van cifrados por los navegadores. Solo si se abandona del todo (no se puede deshacer):
#   sudo rm -r /var/lib/private/flyweb-sync
```
DNS y certificado: ver los pasos 1 y 2. Sin el servidor, FlyWeb muestra un error en Sincronizar y sigue funcionando.

## Pendiente de decidir (HUMANO)

- **Copia en bak** de `/var/lib/private/flyweb-sync/` (va cifrada). Sin copia, si se pierde, basta con volver a
  sincronizar desde cualquier Mac. Si se quiere: `sqlite3 sync.db ".backup …"` con el servicio en marcha.
