# E0 — base de los tres subdominios de FlyWeb en ns2

Ficheros de referencia para la instalación manual del HUMANO (etapa E0 de [`docs/SERVIDOR.md`](../../../docs/SERVIDOR.md)).
Se aplican a mano, en este orden, revisando cada paso. El servicio `go-update` llega en E2: hasta entonces
`/extensions` responde 503 (con clave) y ningún navegador apunta aquí.

| Fichero | Destino en ns2 | Qué es |
|---|---|---|
| `conf/flyweb.conf` | `/etc/apache2/conf-available/` | Común: formato de registro sin IP, clave de servicio, `<Directory /srv/flyweb>` cerrado |
| `apache/flyweb-http.conf` | `/etc/apache2/sites-available/` | Puerto 80 de los tres: reto de Let's Encrypt y redirección a https |
| `apache/flyweb.lamosquita.net.conf` | ídem | Página de FlyWeb (estática) |
| `apache/updates.flyweb.lamosquita.net.conf` | ídem | Appcast y `.dmg` (S2) |
| `apache/components.flyweb.lamosquita.net.conf` | ídem | Componentes (S3): proxy a `go-update`, con clave |
| `apache/flyweb-components-keys.conf.ejemplo` | `/etc/apache2/flyweb-components-keys.conf` | Modelo; el real, con las claves, **nunca en el repo** |
| `logrotate/flyweb` | `/etc/logrotate.d/` | 7 días |

## Decisiones (HUMANO, 02-10)

- **Certificado propio de FlyWeb** para los tres subdominios (`--cert-name flyweb`), aparte de los de tus sitios.
  - Si una renovación falla o hay que revocarlo, no afecta al resto, ni al revés.
  - Se obtiene con `certonly --webroot`: certbot no toca la configuración de Apache.
- **Usuario `flyweb`** dueño de `/srv/flyweb/`. Apache (`www-data`) solo lee.
  - Sin PHP no hay `open_basedir`.
  - Lo más parecido para contenido estático es lo que ya pone `conf/flyweb.conf`: `Options -FollowSymLinks`
    (no se sale por enlaces simbólicos), y sin listados, sin `.htaccess` y sin CGI.
  - El único proceso propio, `go-update`, corre aparte con `DynamicUser` (ver `../systemd/`).
- **Sin IPs y sin CrowdSec en estos vhost.**

| Dónde podría quedar la IP | Cómo se evita |
|---|---|
| Registro de accesos | Formato `flyweb_sinip`: fecha, petición, estado, bytes y tiempo; sin IP, User-Agent ni Referer |
| Registro de errores | `ErrorLogFormat` sin `[client IP]` |
| Servicio de detrás | `ProxyAddHeaders Off`: no recibe `X-Forwarded-For` |
| fail2ban y CrowdSec | Los registros están en `/var/log/flyweb/`, fuera de sus patrones (`/var/log/apache2/…`). Además no contienen IPs |

  - La seguridad viene de la superficie mínima:
    - página y actualizaciones, solo `GET`/`HEAD`;
    - componentes, solo `POST /extensions` con clave, `GET`/`HEAD /release/` y `GET`/`HEAD /_estado.json`;
    - todo lo demás, 403.
  - Los baneos globales del cortafuegos siguen protegiendo estos vhost.
- **Clave de servicio en `components.`** (F2.6).
  - Apache exige la cabecera `BraveServiceKey` (actual o anterior) **solo en `/extensions`**. Las descargas de
    `/release/` no la llevan.
  - La clave va dentro del binario de FlyWeb: evita el uso casual por otros navegadores, no es un secreto fuerte.
  - No aparece en ningún registro.
  - **Falla cerrado.** Se exige el formato de `openssl rand -hex 32`, así que no pasa nada en estos tres casos: si
    falta el fichero de claves, si se deja la clave de ejemplo sin cambiar, o si alguien manda el literal de la
    variable. Como es `IncludeOptional`, un fichero de claves ausente no impide arrancar Apache para el resto de sitios.

**Lo que no podemos prometer:** el cortafuegos procesa la IP en memoria para los baneos globales, y OVH y los
operadores de red la ven. La promesa honesta es «no guardamos tu IP».

## Probado en NUBE (02-10, contenedor Ubuntu 24.04, Apache 2.4.58)

Con los tres vhost activos y peticiones desde `127.0.0.5`:

| Petición | Respuesta |
|---|---|
| `http://` de cualquiera de los tres | 301 a `https://` (misma ruta) |
| `http://…/.well-known/acme-challenge/<token>` | 200 (reto de Let's Encrypt) |
| `https://flyweb…/` | 200 |
| `https://flyweb…/` con `POST` | 403 |
| Enlace simbólico a `/etc/passwd` dentro de `www` | 403 |
| `https://updates…/appcast.xml` | 200 |
| `https://updates…/` (sin índice) | 403 |
| `https://components…/release/a.crx` | 200 |
| `POST /extensions` sin clave | 403 |
| `POST /extensions` con clave | 503 sin servicio; 200 con `go-update` |
| `POST /extensions` con otra clave hexadecimal, con el literal `${FLYWEB_KEY_ACTUAL}`, sin el fichero de claves o con la clave de ejemplo | 403 en todos los casos |

La IP del cliente aparece **0 veces** en los ocho registros de `/var/log/flyweb/`. La clave, tampoco.

## Pasos

1. **Usuario y directorios:**
   ```sh
   sudo useradd --system --no-create-home --shell /usr/sbin/nologin flyweb
   sudo install -d -o root -g adm -m 0750 /var/log/flyweb
   sudo install -d -o flyweb -g flyweb -m 0755 /srv/flyweb /srv/flyweb/{www,updates,vacio,acme,components}
   sudo install -d -o flyweb -g flyweb -m 0755 /srv/flyweb/components/{release,estado,vacio} /srv/flyweb/acme/.well-known
   echo '{"etapa":"E0"}' | sudo -u flyweb tee /srv/flyweb/components/estado/_estado.json
   ```
   certbot escribe en `/srv/flyweb/acme/.well-known/acme-challenge/` como root.
2. **Clave de servicio:**
   ```sh
   openssl rand -hex 32    # anotarla también en el Mac de compilación: ~/proyectos/softmac/claves/flyweb-services-key
   sudo install -m 0600 -o root -g root flyweb-components-keys.conf.ejemplo /etc/apache2/flyweb-components-keys.conf
   sudo nano /etc/apache2/flyweb-components-keys.conf    # poner la clave en ACTUAL y en ANTERIOR
   ```
3. **Conf común y puerto 80** (todavía sin certificado):
   ```sh
   sudo cp conf/flyweb.conf /etc/apache2/conf-available/
   sudo cp apache/*.conf /etc/apache2/sites-available/
   sudo a2enmod ssl headers http2 proxy proxy_http rewrite
   sudo a2enconf flyweb
   sudo a2ensite flyweb-http
   sudo apache2ctl configtest && sudo systemctl reload apache2
   ```
4. **Certificado propio** (DNS ya apuntando a ns2):
   ```sh
   sudo certbot certonly --webroot -w /srv/flyweb/acme --cert-name flyweb \
     -d flyweb.lamosquita.net -d updates.flyweb.lamosquita.net -d components.flyweb.lamosquita.net
   ```
   La renovación automática de certbot reutiliza el mismo método. Si recargas Apache con un hook de renovación,
   este certificado también lo necesita.
5. **Puerto 443:**
   ```sh
   sudo a2ensite flyweb.lamosquita.net updates.flyweb.lamosquita.net components.flyweb.lamosquita.net
   sudo apache2ctl configtest && sudo systemctl reload apache2
   ```
   No se pueden activar antes del paso 4: `configtest` fallaría porque aún no existe
   `/etc/letsencrypt/live/flyweb/`.
6. **logrotate:**
   ```sh
   sudo cp logrotate/flyweb /etc/logrotate.d/
   sudo logrotate -d /etc/logrotate.d/flyweb
   ```
   `-d` es una prueba en seco: no rota nada.

## Comprobaciones

```sh
curl -sI http://flyweb.lamosquita.net/ | head -3                                  # 301 → https
curl -s  https://components.flyweb.lamosquita.net/_estado.json                    # {"etapa":"E0"}
curl -sI https://components.flyweb.lamosquita.net/ | head -1                      # 403
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://components.flyweb.lamosquita.net/extensions   # 403 (sin clave)
curl -s -o /dev/null -w '%{http_code}\n' -X POST -H "BraveServiceKey: $(sudo sed -n 's/.*ACTUAL *"\(.*\)"/\1/p' /etc/apache2/flyweb-components-keys.conf)" https://components.flyweb.lamosquita.net/extensions   # 503 hasta E2
# Ninguna IP en los registros (poner la IP desde la que hiciste las pruebas)
sudo grep -c 'TU.IP.DE.PRUEBA' /var/log/flyweb/*.log                             # 0 en todos
# fail2ban y CrowdSec no leen estos ficheros
sudo fail2ban-client get apache-scan logpath | grep -c /var/log/flyweb             # 0
sudo cscli metrics show acquisition 2>/dev/null | grep -c /var/log/flyweb          # 0
```

## Marcha atrás

```sh
sudo a2dissite components.flyweb.lamosquita.net updates.flyweb.lamosquita.net flyweb.lamosquita.net flyweb-http
sudo a2disconf flyweb && sudo systemctl reload apache2
sudo rm /etc/logrotate.d/flyweb
# Certificado (opcional): sudo certbot delete --cert-name flyweb
```

Nada de esto toca la configuración de otros sitios, sus certificados, los jails de fail2ban ni CrowdSec.
