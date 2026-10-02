# E0 — base de `components.flyweb.lamosquita.net` en ns2

Ficheros de referencia para la instalación manual del HUMANO (etapa E0 de [`docs/SERVIDOR.md`](../../../docs/SERVIDOR.md)).
Se aplican a mano, en este orden, revisando cada paso. Todavía no incluyen el servicio `go-update` (llega en E2):
hasta entonces `/extensions` responde 503 y ningún navegador apunta aquí.

| Fichero | Destino en ns2 |
|---|---|
| `apache/components.flyweb.lamosquita.net.conf` | `/etc/apache2/sites-available/` |
| `logrotate/flyweb-components` | `/etc/logrotate.d/` |
| `apache/flyweb-components-keys.conf.ejemplo` | `/etc/apache2/flyweb-components-keys.conf` (con las claves reales; **nunca en el repo**) |

**Clave de servicio (F2.6, decisión del HUMANO).**
- Solo los navegadores FlyWeb pueden consultar `/extensions`: Apache exige la cabecera `BraveServiceKey` con la clave
  actual o la anterior (para rotarla sin cortar a nadie). Sin ella, 403 antes de llegar al servicio.
- Las descargas de `/release/` no llevan esa cabecera, así que siguen abiertas: son ficheros firmados por Brave o
  Google y públicos en origen.
- La clave va dentro del binario de FlyWeb, así que evita el uso casual, no es un secreto fuerte.
- No aparece en ningún registro.

## Decisión: sin IPs y sin CrowdSec en este vhost (HUMANO, 02-10)

**Privacidad: ninguna IP se guarda en disco.**

| Dónde podría quedar la IP | Cómo se evita |
|---|---|
| Registro de accesos | Formato propio `flyweb_sinip`: fecha, petición, estado, bytes y tiempo. Sin IP, sin User-Agent y sin Referer |
| Registro de errores | Apache escribe `[client IP]` por defecto; aquí `ErrorLogFormat` lo quita |
| Servicio de detrás (`go-update`) | `ProxyAddHeaders Off`: no recibe `X-Forwarded-For` y solo ve `127.0.0.1` |
| fail2ban y CrowdSec | Los registros están en `/var/log/flyweb-components/`, fuera de lo que leen (`/var/log/apache2/…`). Además, no contienen IPs |

Retención: 7 días (logrotate).

**Seguridad sin baneos propios.** En este vhost no hay nada que vigilar para banear, porque casi no hay superficie:

| Ruta | Métodos permitidos | Qué hay detrás |
|---|---|---|
| `/extensions` | Solo `POST` | Servicio en `127.0.0.1` |
| `/release/…` | Solo `GET` y `HEAD` | Ficheros estáticos |
| `/_estado.json` | Solo `GET` y `HEAD` | Fichero estático |
| Cualquier otra ruta o método | — | `403`. La raíz es un directorio vacío; sin PHP ni CGI |

- Cuerpo de las peticiones: 64 KB como máximo.
- Los **baneos globales siguen protegiéndolo**: el bouncer de CrowdSec bloquea en el cortafuegos las IP que atacan
  otros sitios de ns2, también para este.
- Lo que se pierde: detectar a quien ataque *solo* este vhost. Riesgo aceptado, porque lo único alcanzable es el propio
  Apache, que mantiene Ubuntu.
- **Límite que conviene conocer:** una inundación de `POST /extensions` no la frena nada específico. El servicio
  responde en memoria y es barato.

**Lo que no podemos prometer:** el cortafuegos procesa la IP en memoria para aplicar los baneos globales, y OVH y los
operadores de red la ven. La promesa honesta es «no guardamos tu IP».

## Probado en NUBE (02-10, contenedor Ubuntu 24.04, Apache 2.4.58)

Peticiones desde `127.0.0.5` (para distinguir la IP del cliente de la del servicio):

| Petición | Respuesta |
|---|---|
| `GET /_estado.json` y `GET /release/a.crx` | 200 (`application/x-chrome-extension`) |
| `GET /release/nope.crx` | 404 |
| `POST /extensions` | 403 sin clave o con `flyweb`; con la clave actual o la anterior, 503 sin servicio y 200 con el servicio (`go-update`) |
| `POST /_estado.json`, `DELETE /release/a.crx`, `GET`/`PUT /extensions`, `/`, `/wp-login.php`, `/extensionsX`, `GET /release/` | 403 |
| `/release/../../etc/passwd` | 400 |

- La IP del cliente (`127.0.0.5`) aparece **0 veces** en `access.log` y en `error.log`.
- El servicio de prueba en `127.0.0.1:8192` recibió la petición desde `127.0.0.1` y sin ninguna cabecera
  `X-Forwarded-*`.

## Pasos

1. **Directorios:**
   ```sh
   sudo install -d -o root -g adm -m 0750 /var/log/flyweb-components
   sudo install -d -m 0755 /srv/flyweb-components /srv/flyweb-components/{release,estado,vacio}
   echo '{"etapa":"E0"}' | sudo tee /srv/flyweb-components/estado/_estado.json
   ```
2. **DNS y certificado.** Hace falta el registro A `components.flyweb.lamosquita.net` → 51.91.19.170 (ya añadido).
   AAAA todavía no (ver `docs/SERVIDOR.md` §6). Certificado propio (certbot) o el comodín. Ajustar las dos líneas
   `SSLCertificate*` del vhost.
3. **Clave de servicio:**
   ```sh
   openssl rand -hex 32    # anotarla también en el Mac de compilación: ~/proyectos/softmac/claves/flyweb-services-key
   sudo install -m 0600 -o root -g root flyweb-components-keys.conf.ejemplo /etc/apache2/flyweb-components-keys.conf
   sudo nano /etc/apache2/flyweb-components-keys.conf    # poner la clave en ACTUAL y en ANTERIOR
   ```
4. **Apache:**
   ```sh
   sudo a2enmod ssl headers http2 proxy proxy_http
   sudo cp components.flyweb.lamosquita.net.conf /etc/apache2/sites-available/
   sudo apache2ctl configtest
   sudo a2ensite components.flyweb.lamosquita.net
   sudo systemctl reload apache2
   ```
5. **logrotate:**
   ```sh
   sudo cp flyweb-components /etc/logrotate.d/
   sudo logrotate -d /etc/logrotate.d/flyweb-components
   ```
   `-d` es una prueba en seco: no rota nada.

## Comprobaciones

```sh
curl -s  https://components.flyweb.lamosquita.net/_estado.json        # {"etapa":"E0"}
curl -sI https://components.flyweb.lamosquita.net/                    # 403
curl -sI -X POST https://components.flyweb.lamosquita.net/release/x   # 403
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://components.flyweb.lamosquita.net/extensions   # 403 (sin clave)
curl -s -o /dev/null -w '%{http_code}\n' -X POST -H "BraveServiceKey: $(sudo sed -n 's/.*ACTUAL *"\(.*\)"/\1/p' /etc/apache2/flyweb-components-keys.conf)" https://components.flyweb.lamosquita.net/extensions   # 503 hasta E2 (llega al servicio)
# Ninguna IP en los registros (sustituir por la IP desde la que has hecho las pruebas)
sudo grep -c 'TU.IP.DE.PRUEBA' /var/log/flyweb-components/*.log       # 0 en ambos
# fail2ban y CrowdSec no leen estos ficheros
sudo fail2ban-client get apache-scan logpath | grep -c flyweb-components   # 0
sudo cscli metrics show acquisition 2>/dev/null | grep -c flyweb-components # 0
```

## Marcha atrás

```sh
sudo a2dissite components.flyweb.lamosquita.net && sudo systemctl reload apache2
sudo rm /etc/logrotate.d/flyweb-components
```

Nada de esto toca la configuración de otros sitios, los jails de fail2ban ni CrowdSec.
