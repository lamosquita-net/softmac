# flyweb-sync — sincronización de FlyWeb (F7.5)

Servidor de «Sincronizar» de FlyWeb: contraseñas, marcadores, historial, ajustes, pestañas abiertas… entre los Macs
del usuario. Decisión del HUMANO (03/10): sistema propio, en ns2, con el menor mantenimiento posible.

## Qué es

- **[go-sync](https://github.com/brave/go-sync) de Brave** (MPL-2.0), el servidor que Brave usa para la sincronización
  de Brave 1.57. La versión está **fijada en `go.mod`**; su protocolo es el de Chromium 116, el mismo que FlyWeb.
  Usamos tal cual su lógica de protocolo, autenticación, cuotas y límites de dispositivos.
- **Cambiado por nosotros:** en lugar de DynamoDB, **SQLite** (`sqlite.go`); en lugar de Redis, **caché en memoria**
  (`cache.go`); arranque propio (`main.go`). Resultado: **un binario estático (Go, sin cgo) y un fichero**, sin Java,
  sin Redis y sin servicios aparte.
- **Por qué no DynamoDB Local:** su licencia (Amazon DynamoDB Local License Agreement) exige una cuenta de AWS, solo
  permite uso interno «en conexión con los servicios de AWS» y prohíbe actuar como «service bureau». No vale para dar
  servicio a usuarios de FlyWeb. ScyllaDB (compatible con DynamoDB) es demasiado pesado para esto.
- **Licencia de este directorio:** MPL-2.0 (`LICENSE`), como go-sync.

## Privacidad

- **Cifrado de extremo a extremo.** El navegador cifra todo con una clave que sale del código de 24 palabras de la
  cadena y nunca sale de los Macs del usuario. En ns2 solo hay datos cifrados: ni nosotros podemos leerlos.
- **Sin cuentas.** La cadena se identifica por una clave pública ed25519 (derivada del código); cada petición va
  firmada (token de `brave_sync_auth_manager.cc`), y go-sync comprueba la firma y la hora (±1 día).
- **Sin IP.** flyweb-sync no registra peticiones; solo avisos y errores, sin IP (algún error de go-sync puede llevar
  la clave pública de la cadena, que es un seudónimo). Escucha solo
  en `127.0.0.1`; Apache, delante, no le pasa la IP y tampoco la registra (`e0/apache/flyweb-sync-vhost.conf`).
- **Borrado.** «Borrar datos de sincronización» en el navegador borra todo lo de la cadena en el servidor y la
  desactiva. El historial caduca a los 14 días (como en Brave).
- **Cadenas sin uso** (decisión del HUMANO, 03/10): si algún día se abre a otros usuarios, se borran las que lleven
  un año sin escrituras, con `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` en la unidad de systemd (desactivado por defecto).
  Quedan desactivadas como si el usuario las hubiera borrado: un Mac que vuelva recibe el aviso de que la cadena ya no
  existe. Chromium renueva a diario la ficha de cada dispositivo, así que una cadena en uso nunca llega a un año sin
  escrituras.
- **Solo si el usuario quiere.** El navegador solo contacta con el servidor si el usuario activa Sincronizar.

## Diferencias con go-sync sobre DynamoDB

- **mtime estrictamente creciente por cadena** (`reloj()` en `sqlite.go`). go-sync usa el mtime (ms) como versión y
  como token de GetUpdates (`mtime > token`). Con SQLite, dos escrituras caben en el mismo milisegundo; empatarían y la
  siguiente consulta podría saltarse una o desordenar padres e hijos. Si coincide, se suma 1 ms. En DynamoDB no pasa
  porque cada escritura tarda más de 1 ms.
- **Tablas separadas** (entidades, etiquetas, cadenas desactivadas, contadores) en lugar de la tabla única de
  DynamoDB. Para go-sync se comporta igual (`ClearServerData` devuelve lo mismo).
- **Límite de gzip:** go-sync descomprime sin límite. Aquí se comprueba el token **antes** de leer el cuerpo, y se
  descomprime con tope (8 MB comprimido, 32 MB descomprimido).
- **Sin `/metrics`, pprof ni `/health-check`**: solo `POST /v2/command/`.

## Pruebas

```sh
go test -race ./...     # propias: reloj, caducidad, caché, y de punta a punta por HTTP con el token de Brave 1.57
pruebas/go-sync.sh      # las de go-sync (command/ y datastore/) contra SQLite y la caché en memoria
```

`pruebas/go-sync.sh` copia go-sync en un directorio temporal, cambia DynamoDB y Redis por lo nuestro
(`pruebas/adaptar.py`) y ejecuta sus pruebas: **pasan todas** (03/10, también con `-race`). Las de `datastore/` van
sin el reloj creciente, porque fijan el mtime a mano y comparan entidades enteras.

Además se probó (NUBE, 03/10) el binario detrás del vhost de Apache 2.4.58: dos «Macs» con la misma cadena se pasan
una contraseña cifrada, otra cadena no ve nada, sin token o con firma falsa da 401, todo lo demás da 404, el puerto 80
redirige, y no aparece ninguna IP en los registros.

**Falta (LOCAL):** la prueba con FlyWeb de verdad (ver «Prueba con FlyWeb»).

## Compilar

CI: `.github/workflows/flyweb-sync.yml` (vet, pruebas propias, `pruebas/go-sync.sh`, binario `linux/amd64` estático y
su SHA-256). Al fusionar en `main`, el binario se publica en la release `flyweb-sync`. **En ns2 no se compila nada.**

En local, cualquier Mac o Linux con Go ≥ 1.26 (Go descarga la versión que pide `go.mod`). No es para Mojave: corre en ns2.

```sh
cd FlyWeb/servidor/sync
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags=-s -o flyweb-sync .
shasum -a 256 flyweb-sync
```

## Instalar en ns2 (HUMANO o LOCAL con permiso; lo verifica el HUMANO)

Pasos exactos, con comprobaciones antes y después, prueba desde fuera y vuelta atrás: **[`instalar-ns2.md`](instalar-ns2.md)**
(SV.1). Binario: release `flyweb-sync`, construido por el CI desde `eb7a424`,
SHA-256 `6b690b21467c3637b9e655a72c7888585aca974270d330c460876c3872b0007c` (reproducido por SERVIDOR). La release se
reescribe en cada fusión: la suma que vale es la de `instalar-ns2.md`, no la `.sha256` de la release.

La base queda en `/var/lib/private/flyweb-sync/sync.db` (con `DynamicUser`), cifrada por los navegadores. Copia, si se
quiere: `sqlite3 sync.db ".backup /ruta/copia.db"` con el servicio en marcha. Si se pierde, basta con volver a
sincronizar desde cualquier Mac. Antes de abrirlo a otros usuarios, publicar el texto de privacidad (W2,
`FlyWeb/docs/web-flyweb.md`).

## Prueba con FlyWeb (LOCAL, cuando esté en ns2)

1. Compilar con `build.sh` (ya apunta a `https://sync.flyweb.lamosquita.net/v2`; se cambia con `FLYWEB_SYNC_URL`).
2. En la 7,1: Ajustes › Sincronizar › empezar una cadena nueva; guardar el código de 24 palabras.
3. En la 6,1 y la 5,1: unirse con ese código. Comprobar que aparecen los tres dispositivos.
4. Importar unas contraseñas de prueba por CSV en la 7,1 (Ajustes › Contraseñas › Importar) → deben aparecer en la 6,1
   y la 5,1 en menos de un minuto. Crear una en la 5,1 → aparece en la 7,1.
5. Marcadores: crear una carpeta con dos marcadores → misma estructura en las otras.
6. «Borrar datos de sincronización» → en las otras, la cadena se desactiva.
7. En el NetLog: solo `sync.flyweb.lamosquita.net`; 0 peticiones a `*.brave.com`.
