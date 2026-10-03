# FlyWeb — servicios del servidor (ns2)

Código y configuración de `components.flyweb.lamosquita.net` (Fase 2) y `sync.flyweb.lamosquita.net` (F7.5). Reglas y etapas: [`docs/SERVIDOR.md`](../../docs/SERVIDOR.md).
Plan e inventario: [`FlyWeb/docs/componentes.md`](../docs/componentes.md).

| Carpeta | Qué es | Licencia |
|---|---|---|
| `e0/` | Los vhost de FlyWeb **tal como están en ns2** (E0 hecho el 02-10) y logrotate | MIT (raíz) |
| `go-update/` | [`brave/go-update`](https://github.com/brave/go-update) 1da7d75 (`git subtree --squash`), con el parche de FlyWeb | **MPL-2.0** (la suya) |
| `sync/` | **flyweb-sync**: sincronización de FlyWeb (go-sync de Brave con SQLite; F7.5). Ver su `README.md` | **MPL-2.0** (la de go-sync) |
| `systemd/` | Unidades endurecidas de los servicios (`flyweb-components`, `flyweb-sync`) | MIT (raíz) |

## Parche de FlyWeb sobre go-update

Ficheros nuevos: `controller/flyweb.go`, `controller/flyweb_test.go` y `server/flyweb.go`. Toca tres líneas de
`controller/controller.go` y dos bloques de `server/server.go`. Sin las variables de entorno, el comportamiento es el
de Brave.

| Variable | Efecto |
|---|---|
| `FLYWEB_CATALOG_FILE=/var/www/FlyWeb/components/catalog.json` | Lee el catálogo de un JSON local (lista de objetos con `ID`, `Version`, `SHA256`, `Title`, `Size`) en vez de DynamoDB. Lo recarga cada 10 min. Una entrada borrada del JSON sigue servida hasta reiniciar el servicio |
| `FLYWEB_NO_REDIRECT=1` | Un componente desconocido recibe `error-unknownApplication`, en vez de una redirección a los servidores de Brave o Google. El navegador conserva la versión que tiene y no habla con terceros |
| `FLYWEB_LISTEN=127.0.0.1:8192` | **Brave escucha en todas las interfaces** (`:8192`); aquí, solo en local, detrás de Apache |
| `FLYWEB_METRICS_LISTEN=off` | Brave abre además métricas en `:9090`, en todas las interfaces. Aquí no se abren |
| `S3_EXTENSIONS_BUCKET_HOST=components.flyweb.lamosquita.net` | (de Brave) Las URL de descarga apuntan a nuestro `/release/<id>/extension_<versión con _>.crx` |
| `SENTRY_DSN=` vacío | (de Brave) Sin envío de errores a Sentry |

**Registros del servicio.** El servicio no registra las peticiones, solo el arranque y la recarga del catálogo. Detrás
de Apache solo ve `127.0.0.1`.

## Compilar

CI: `.github/workflows/flyweb-components.yml`.
- Pasos: `go vet`, pruebas, binario `linux/amd64` estático y su SHA-256. Al fusionar en `main`, el binario se
  publica en la release `go-update`.
- **En ns2 no se compila nada.**

En local (Go 1.26):
```sh
cd FlyWeb/servidor/go-update
GOEXPERIMENT=jsonv2 go test ./...
GOEXPERIMENT=jsonv2 CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -buildvcs=false -tags=noasm,nounsafe -ldflags "-s -w" -o ../build/flyweb-components .
```

## Probado en NUBE (02-10)

| Prueba | Resultado |
|---|---|
| Pruebas de Brave y de FlyWeb (`go vet`, `go test ./...`) | Todo en verde |
| Binario con las variables de arriba, detrás del vhost de `e0/` (Apache 2.4.58), petición JSON de un componente del catálogo con versión antigua | 200, con la URL `https://components.flyweb.lamosquita.net/release/<id>/extension_1_0_123.crx` |
| Lo mismo, con un componente desconocido | 200 con `error-unknownApplication`, sin redirección |
| Direcciones de escucha | Solo `127.0.0.1:8192`; nada en `:9090` |
| IP del cliente (`127.0.0.5`) en los registros de Apache y del servicio | 0 veces |

## Instalación en ns2 (HUMANO) — hecha el 03-10-2026

El CI publica el binario en la release pública `go-update` (`flyweb-components.yml`, al fusionar en `main`). NUBE lo
recompila por su cuenta: el binario es reproducible, y la suma de NUBE tiene que coincidir con la de la release.

```sh
U=https://github.com/lamosquita-net/softmac/releases/download/go-update
mkdir -p ~/flyweb-go-update && cd ~/flyweb-go-update
curl -fsSLO "$U/flyweb-components" && curl -fsSLO "$U/flyweb-components.sha256"
cat flyweb-components.sha256          # compárala con la que te da NUBE
sha256sum -c flyweb-components.sha256
sudo install -d -m 0755 /opt/flyweb-components
sudo install -m 0755 flyweb-components /opt/flyweb-components/

C=<commit>     # la unidad, desde un commit fijo, con su suma
curl -fsSLo flyweb-components.service "https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/systemd/flyweb-components.service"
echo "<sha256>  flyweb-components.service" | sha256sum -c
sudo install -m 0644 flyweb-components.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now flyweb-components
```

Comprobaciones (ninguna muestra la clave de servicio):

```sh
systemctl is-active flyweb-components                       # active
sudo ss -ltnp | grep 8192                                   # solo 127.0.0.1:8192, nada en :9090
sudo journalctl -u flyweb-components -n 5 --no-pager        # «Extension refresh from file completed» item_count 9
# Directo al servicio: debe devolver la URL de /release/… de la lista por defecto
curl -s -X POST http://127.0.0.1:8192/extensions -H 'Content-Type: application/json' \
  -d '{"request":{"protocol":"3.1","app":[{"appid":"oncmalfeabebooncbcbcaofghlfnkjgc","version":"0.0.0.0","updatecheck":{}}]}}'
# Por Apache sin clave: 403
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://components.flyweb.lamosquita.net/extensions
```

Deshacer: `sudo systemctl disable --now flyweb-components`, y borrar la unidad y `/opt/flyweb-components`.

## Actualizar go-update

```sh
git subtree pull --prefix=FlyWeb/servidor/go-update https://github.com/brave/go-update.git master --squash
```

Después: resolver conflictos si los hay, ejecutar las pruebas (`flyweb_test.go` comprueba el parche) y revisar en el
diff que las variables siguen aplicándose.

## Pendiente

- ~~Copia diaria de los CRX de Brave~~: descartada, porque el almacén de Brave no se puede listar. Los componentes de
  Shields son propios (`componentes/`, firmados en bak), y `catalog.json` lo escribe bak.
- **Componentes de Google** (Widevine, CRLSet): pendientes de la decisión del HUMANO sobre `FLYWEB_NO_REDIRECT`.
- **Ejecutor de despliegues** `flyweb-deploy` (§4 de `docs/SERVIDOR.md`), para que las actualizaciones de go-update no
  sean a mano.
