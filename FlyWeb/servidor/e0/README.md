# E0 — base de `components.flyweb.lamosquita.net` en ns2

Ficheros de referencia para la instalación manual del HUMANO (etapa E0 de [`docs/SERVIDOR.md`](../../../docs/SERVIDOR.md)).
Se aplican a mano, en este orden, revisando cada paso. Todavía no incluyen el servicio `go-update` (llega en E2):
hasta entonces `/extensions` responde 503 y ningún navegador apunta aquí.

| Fichero | Destino en ns2 |
|---|---|
| `apache/components.flyweb.lamosquita.net.conf` | `/etc/apache2/sites-available/` |
| `logrotate/flyweb-components` | `/etc/logrotate.d/` |
| `crowdsec/acquis.d/flyweb-components.yaml` | `/etc/crowdsec/acquis.d/` |
| `crowdsec/parsers/s02-enrich/flyweb-components-whitelist.yaml` | `/etc/crowdsec/parsers/s02-enrich/` |

## Cómo se aísla de fail2ban y CrowdSec

Ambos leen ficheros de registro, no vhosts. En ns2 (configuración vista el 02-10):
- **fail2ban:** `/var/log/apache2/*/*access.log` y `/var/log/apache2/*/*error.log`.
- **CrowdSec:** `/var/log/apache2/*/*.log` y `/var/log/apache2/*.log`.

Este vhost escribe en **`/var/log/flyweb-components/`**, fuera de esos patrones.

| Qué | Efecto |
|---|---|
| **Reglas actuales** | Ninguna regla actual lo ve ni cambia: el resto de sitios sigue exactamente igual |
| **fail2ban** | Sin jail propio. Los suyos son de WordPress, Apache y SSH, y CrowdSec ya cubre este vhost |
| **CrowdSec** | Lee esos ficheros con su propia entrada (`acquis.d/`), con los mismos escenarios de Apache que el resto |
| **Lista blanca** | Quita solo el tráfico legítimo del navegador, y solo en ese fichero: `POST /extensions` con respuesta 200/302/307, y `GET`/`HEAD /release/…` con respuesta 200/206/304. Todo lo demás cuenta y se banea igual (otras rutas, 4xx, sondeos, intentos contra fallos conocidos) |
| **Superficie** | El vhost niega con 403 todo lo que no sea `/extensions`, `/release/` o `/_estado.json`. Limita el cuerpo de las peticiones a 64 KB |

**Decisión pendiente del HUMANO: IP en el registro.** `disenos.md` pedía registros sin IP, pero sin IP CrowdSec no puede
banear en este vhost. Propuesta: registrar la IP (formato `combined`) y guardarla solo **7 días** (logrotate).

**Límite conocido.** Un ataque que repitiera `POST /extensions` válidos no lo frenaría CrowdSec, porque está en la
lista blanca. El servicio es barato y no toca disco, y Apache limita el cuerpo. Si hiciera falta, se añade un
escenario propio solo para ese fichero, con un umbral muy por encima del uso normal. El uso normal es de unas 70
peticiones cada 30 minutos por navegador.

## Probado en NUBE (02-10, contenedor Ubuntu 24.04)

- **Apache 2.4.58:** `configtest` correcto. Respuestas:
  - 200: `/_estado.json` y `/release/a.crx` (tipo `application/x-chrome-extension`, con HSTS);
  - 403: `/`, `/release/`, `/etc/passwd` y `/extensionsX`;
  - 503: `/extensions` (sin servicio, lo esperado en E0).
- **CrowdSec 1.4.6** (paquete de Ubuntu), con `crowdsecurity/apache2-logs` del hub y esta entrada y lista blanca.
  - Con `cscli explain`, quedan **en la lista blanca** solo `POST /extensions` 200 y `GET`/`HEAD /release/…` 200.
  - **Siguen contando:** `/wp-login.php` 403, `/release/../../etc/passwd` 404, `/` 403, `/extensionsX` 403 y
    `/extensions` 503.
  - Los campos `http_verb`, `http_path` y `http_status` existen con ese analizador.
  - En ns2 puede haber otra versión de CrowdSec: el paso 0 y `cscli explain` lo confirman.

## Pasos

0. **Comprobar el analizador de CrowdSec.** La lista blanca usa campos que pone el analizador de Apache
   (`http_verb`, `http_path`, `http_status`):
   ```sh
   sudo cscli collections list | grep -i apache
   sudo cscli parsers list | grep -i -E 'apache2-logs|whitelist'
   ```
   Hace falta `crowdsecurity/apache2` (que trae `crowdsecurity/apache2-logs`).
1. **Directorios:**
   ```sh
   sudo install -d -o root -g adm -m 0750 /var/log/flyweb-components
   sudo install -d -m 0755 /srv/flyweb-components /srv/flyweb-components/release /srv/flyweb-components/estado
   echo '{"etapa":"E0"}' | sudo tee /srv/flyweb-components/estado/_estado.json
   ```
2. **DNS y certificado.** Registro A/AAAA `components.flyweb.lamosquita.net` → ns2. Certificado propio (certbot) o el
   comodín. Ajustar las dos líneas `SSLCertificate*` del vhost.
3. **Apache:**
   ```sh
   sudo a2enmod ssl headers http2 proxy proxy_http
   sudo cp components.flyweb.lamosquita.net.conf /etc/apache2/sites-available/
   sudo apache2ctl configtest
   sudo a2ensite components.flyweb.lamosquita.net
   sudo systemctl reload apache2
   ```
4. **logrotate:**
   ```sh
   sudo cp flyweb-components /etc/logrotate.d/
   sudo logrotate -d /etc/logrotate.d/flyweb-components
   ```
   `-d` es una prueba en seco: no rota nada.
5. **CrowdSec:**
   ```sh
   sudo cp flyweb-components.yaml /etc/crowdsec/acquis.d/
   sudo cp flyweb-components-whitelist.yaml /etc/crowdsec/parsers/s02-enrich/
   sudo crowdsec -t
   sudo systemctl reload crowdsec
   ```
   `crowdsec -t` comprueba la configuración sin aplicarla.

## Comprobaciones

```sh
# El vhost responde y niega lo demás
curl -s  https://components.flyweb.lamosquita.net/_estado.json     # {"etapa":"E0"}
curl -sI https://components.flyweb.lamosquita.net/                 # 403
# fail2ban no ve el registro nuevo
sudo fail2ban-client get apache-scan logpath | grep -c flyweb-components   # 0
# CrowdSec sí lo lee
sudo cscli metrics show acquisition | grep flyweb-components
# La lista blanca actúa: lanzar una descarga de prueba y explicar la línea
curl -s -o /dev/null https://components.flyweb.lamosquita.net/release/prueba.crx   # 404: debe CONTAR
sudo cscli explain --file /var/log/flyweb-components/access.log --type apache2 -v | tail -40
```

En `cscli explain`:
- La petición 404 de prueba debe pasar los analizadores **sin** «whitelisted».
- Cuando haya descargas reales con 200, esas sí deben salir como «whitelisted» por `lamosquita/flyweb-components-whitelist`.
- Si los campos `http_*` no aparecen, el analizador instalado usa otros nombres: pasar la salida a SERVIDOR o NUBE para
  ajustar la regla.

## Marcha atrás

```sh
sudo a2dissite components.flyweb.lamosquita.net && sudo systemctl reload apache2
sudo rm /etc/crowdsec/acquis.d/flyweb-components.yaml /etc/crowdsec/parsers/s02-enrich/flyweb-components-whitelist.yaml
sudo systemctl reload crowdsec
sudo rm /etc/logrotate.d/flyweb-components
```

Nada de esto toca la configuración de otros sitios, los jails de fail2ban ni `/etc/crowdsec/acquis.yaml`.
