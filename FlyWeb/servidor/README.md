# FlyWeb — servicios del servidor (ns2)

Código y configuración de `components.flyweb.lamosquita.net` (Fase 2). Reglas y etapas: [`docs/SERVIDOR.md`](../../docs/SERVIDOR.md).
Plan e inventario: [`FlyWeb/docs/componentes.md`](../docs/componentes.md).

| Carpeta | Qué es | Licencia |
|---|---|---|
| `e0/` | Vhost de Apache (sin IPs) y logrotate, para la instalación manual (E0) | MIT (raíz) |
| `go-update/` | [`brave/go-update`](https://github.com/brave/go-update) 1da7d75 (`git subtree --squash`), con el parche de FlyWeb | **MPL-2.0** (la suya) |
| `systemd/` | Unidad endurecida del servicio (referencia para E2) | MIT (raíz) |

## Parche de FlyWeb sobre go-update

Ficheros nuevos: `controller/flyweb.go`, `controller/flyweb_test.go` y `server/flyweb.go`. Toca tres líneas de
`controller/controller.go` y dos bloques de `server/server.go`. Sin las variables de entorno, el comportamiento es el
de Brave.

| Variable | Efecto |
|---|---|
| `FLYWEB_CATALOG_FILE=/srv/flyweb/components/catalog.json` | Lee el catálogo de un JSON local (lista de objetos con `ID`, `Version`, `SHA256`, `Title`, `Size`) en vez de DynamoDB. Lo recarga cada 10 min. Una entrada borrada del JSON sigue servida hasta reiniciar el servicio |
| `FLYWEB_NO_REDIRECT=1` | Un componente desconocido recibe `error-unknownApplication`, en vez de una redirección a los servidores de Brave o Google. El navegador conserva la versión que tiene y no habla con terceros |
| `FLYWEB_LISTEN=127.0.0.1:8192` | **Brave escucha en todas las interfaces** (`:8192`); aquí, solo en local, detrás de Apache |
| `FLYWEB_METRICS_LISTEN=off` | Brave abre además métricas en `:9090`, en todas las interfaces. Aquí no se abren |
| `S3_EXTENSIONS_BUCKET_HOST=components.flyweb.lamosquita.net` | (de Brave) Las URL de descarga apuntan a nuestro `/release/<id>/extension_<versión con _>.crx` |
| `SENTRY_DSN=` vacío | (de Brave) Sin envío de errores a Sentry |

**Registros del servicio.** El servicio no registra las peticiones, solo el arranque y la recarga del catálogo. Detrás
de Apache solo ve `127.0.0.1`.

## Compilar

CI: `.github/workflows/flyweb-components.yml`.
- Pasos: `go vet`, pruebas, binario `linux/amd64` estático y su SHA-256. El binario sale como artefacto.
- **En ns2 no se compila nada.**

En local (Go 1.26):
```sh
cd FlyWeb/servidor/go-update
GOEXPERIMENT=jsonv2 go test ./...
GOEXPERIMENT=jsonv2 CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -tags=noasm,nounsafe -ldflags "-s -w" -o ../build/flyweb-components .
```

## Probado en NUBE (02-10)

| Prueba | Resultado |
|---|---|
| Pruebas de Brave y de FlyWeb (`go vet`, `go test ./...`) | Todo en verde |
| Binario con las variables de arriba, detrás del vhost de `e0/` (Apache 2.4.58), petición JSON de un componente del catálogo con versión antigua | 200, con la URL `https://components.flyweb.lamosquita.net/release/<id>/extension_1_0_123.crx` |
| Lo mismo, con un componente desconocido | 200 con `error-unknownApplication`, sin redirección |
| Direcciones de escucha | Solo `127.0.0.1:8192`; nada en `:9090` |
| IP del cliente (`127.0.0.5`) en los registros de Apache y del servicio | 0 veces |

## Actualizar go-update

```sh
git subtree pull --prefix=FlyWeb/servidor/go-update https://github.com/brave/go-update.git master --squash
```

Después: resolver conflictos si los hay, ejecutar las pruebas (`flyweb_test.go` comprueba el parche) y revisar en el
diff que las variables siguen aplicándose.

## Pendiente

- **Copia diaria** (`mirror/`): descargar los CRX de Brave y de Google, comprobar su SHA-256 y escribir `catalog.json`.
  Desde la sesión de NUBE no se llega a los servidores de Brave (los bloquea el proxy), así que se probará en ns2 o
  con datos de prueba.
- **Ejecutor de despliegues** `flyweb-deploy` (§4 de `docs/SERVIDOR.md`).
