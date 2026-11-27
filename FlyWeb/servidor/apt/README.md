# Repositorio apt de FlyWeb para Linux (U4)

**Estado (27-11-2026):** firmador y pruebas en #1254. Revisión de SEGURIDAD-PORTES; el CI de ubuntu-22.04 verifica con su
`gpgv` 2.2. Titín firmó así la 3.2.2-51 el 27-11, con tres firmas.

**Versión de este PR:** una sola orden por versión, `publicar`, que firma `pruebas`, lo comprueba en ns2 y solo entonces
firma `stable`. Además, tres cambios de la revisión de #1254: la cota superior del `Date`, el llavero de la versión más
alta y la aprobación atada a la suite.

| Dato | Valor |
|---|---|
| Huella de la clave principal | `C1A73800D3570C82F18431491C7B292C7F37D941` (Ed25519, solo certificar, sin caducidad; 26-11-2026) |
| Huella de la subclave de firma (la de bak) | `5F93D81F55B2D87877C69A77F42AD6C8426E03CA` (Ed25519, firma) |
| **Caducidad de la subclave** | **2028-11-25** (rotar con meses de margen, §4.4 del diseño) |
| Pública | `clave-publica.asc` (sha256 `4309fbf0…92ba`; en binario, el llavero del .deb: `2b55f2b4…730d`) |

Diseño: `U4-diseno.md` v3 (§3 repositorio, §4 firma). La firma va en bak, como Sparkle (`../actualizaciones`).

## Cómo funciona

```
Ubuntu (D8-LINUX o LOCAL)                 bak (Titín aprueba)                          ns2 (apt.flyweb.lamosquita.net)
 flyweb-release.sh … empaquetar
 (con llavero_apt = la pública)
 Titín sube el .deb          ──rsync──►  /var/www/FlyWeb/apt/pool/main/f/flyweb/flyweb_<v>_amd64.deb (aún fuera del índice)
 SHA-256 y versión → Titín
                              Titín: sudo … publicar --version <v> --sha256 <sha>
                              (apunta «<sha256>  <v>  stable» en /etc/flyweb-firma/apt-aprobados)
                              firmar (pruebas, luego stable): descarga de ns2, SHA-256 aprobado antes
                              de leer nada, control estricto, versión y Date mayores, Packages
                              (lista blanca), by-hash, Release sin Valid-Until, firma con la
                              subclave y verifica con gpgv (y sqv) contra el llavero del .deb
                                                            ──rsync──►  dists/<suite>/ en cuatro pasadas
Equipos con FlyWeb: apt update / unattended-upgrades ◄──────────────── InRelease, Packages, .deb
```

- **Dos llaves para publicar:** el SHA-256 aprobado por Titín en un fichero de root y la subclave, que solo está en bak.
  Quien suba un `.deb` a `pool/` no consigue que ningún equipo lo instale sin índice firmado.
- **La subclave equivale a root en todos los equipos con FlyWeb** (`postinst` corre como root). Por eso solo se firma el
  paquete `flyweb`, la subclave caduca a 2 años y la clave principal no está en ninguna máquina conectada.
- **Sin `Valid-Until`.** El índice vale hasta la versión siguiente. `apt` no acepta un `InRelease` con `Date` menor que
  el de su caché, así que el firmador se niega si el `Date` nuevo no es mayor que el publicado. Tampoco firma si el reloj
  de bak se separa más de 5 minutos del de ns2 (abajo, «Reloj»).
- **En el índice, solo la versión más nueva no retirada.** En `pool/` se quedan las dos últimas.
- **Suites:** `stable` (la que lleva el `.deb` en `flyweb.sources` y la que actualiza `unattended-upgrades`) y
  `pruebas` (para probar una publicación antes; ningún equipo la mira salvo que se añada a mano).

## Paso 4: la clave (Titín, una vez)

En la Ubuntu de Titín, con la clave en RAM (`/dev/shm`, se va al reiniciar) y, si quieres, con la red quitada.
GnuPG 2.4 crea claves v4; se comprueba igual. `<contacto>` es el contacto público que ya usa Mac.

```sh
export GNUPGHOME=$(mktemp -d /dev/shm/flyweb-apt-XXXXXX)
gpg --batch --pinentry-mode loopback --passphrase '' \
  --quick-gen-key 'FlyWeb apt <contacto>' ed25519 cert never        # principal: solo certificar, sin caducidad
P=$(gpg --with-colons --list-keys | awk -F: '/^fpr/{print $10; exit}')
gpg --batch --pinentry-mode loopback --passphrase '' --quick-add-key "$P" ed25519 sign 2y
S=$(gpg --with-colons --list-keys | awk -F: '/^sub/{s=1; next} s && /^fpr/{print $10; exit}')
echo "principal $P"; echo "subclave  $S"
gpg --export "$P" | gpg --list-packets | grep -o '\bversion [0-9]*' | sort | uniq -c   # todo «version 4»
gpg --with-colons --list-keys "$P" | awk -F: '/^sub/{print "caduca", strftime("%F", $7)}'

mkdir -m 700 ~/flyweb-apt-clave && cd ~/flyweb-apt-clave
gpg --armor --export "$P" > clave-publica.asc                      # pública: a softmac (servidor/apt/) y al .deb
gpg --armor --export-secret-subkeys "$S!" > subclave-bak.asc       # solo la subclave: a bak
gpg --armor --export-secret-keys "$P" | gpg --symmetric --armor --cipher-algo AES256 \
  --output flyweb-apt-COPIA-CIFRADA.asc                            # pide una frase: la copia de la principal
gpgconf --kill gpg-agent
```

- **`flyweb-apt-COPIA-CIFRADA.asc`** (principal y subclave): fuera de cualquier máquina conectada, por tu canal habitual
  (p. ej. dos memorias USB). Sin ella no se puede rotar la subclave: si se pierde, los equipos dejan de recibir
  actualizaciones cuando caduque la subclave.
- **`subclave-bak.asc`**: va a bak (abajo) y después se quita de la Ubuntu.
- **`clave-publica.asc`**: a NUBE o a la COORDINACIÓN, para `servidor/apt/clave-publica.asc` en softmac. Huellas y
  caducidad, en la tabla de arriba.
- `$GNUPGHOME` está en RAM: desaparece al reiniciar la Ubuntu. Reinicia antes de volver a conectar si quitaste la red.

## Instalación en bak (Titín, una vez)

Mismo usuario `flywebfirma` que Sparkle y componentes. Hacen falta `node`, `gpg`, `gpgv`, `dpkg-deb`, `dpkg`, `xz`,
`rsync` y `runuser` (de util-linux; `publicar` lo usa para firmar como `flywebfirma`), y `sqv` si lo hay: verifica también
con él.

```sh
C=<commit>; U=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/apt
curl -fsSLo firmar-apt.mjs "$U/bak/firmar-apt.mjs"
sha256sum firmar-apt.mjs                     # comparar con la suma del PR (y la que imprime el CI)
sudo install -m 0644 firmar-apt.mjs /opt/flyweb-firma/
sudo install -d -m 0700 -o flywebfirma -g flywebfirma /var/lib/flyweb-firma/claves/apt /var/lib/flyweb-firma/apt
sudo touch /etc/flyweb-firma/apt-aprobados && sudo chmod 0644 /etc/flyweb-firma/apt-aprobados
echo 'subclave=<S>' | sudo tee /etc/flyweb-firma/apt.conf && sudo chmod 0644 /etc/flyweb-firma/apt.conf

# La subclave (copiada antes a bak por tu canal):
sudo -u flywebfirma env GNUPGHOME=/var/lib/flyweb-firma/claves/apt gpg --batch --import subclave-bak.asc
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs caducidad \
  --gnupghome /var/lib/flyweb-firma/claves/apt --subclave <S>
```

`caducidad` comprueba que la principal está como «stub» (sin parte secreta), que la subclave es de firma y v4, y da la
fecha. Si la principal tiene su parte secreta, se niega: se importó el fichero equivocado.

`/etc/flyweb-firma/apt.conf` (de root) lleva una línea `clave=valor` por dato. Solo hace falta `subclave`; los demás
valores tienen por defecto los de esta instalación:
- `aprobados=/etc/flyweb-firma/apt-aprobados`
- `gnupghome=/var/lib/flyweb-firma/claves/apt`
- `salida=/var/lib/flyweb-firma/apt`
- `subir=ns2-apt`
- `usuario=flywebfirma`

**Al actualizar desde la versión de #1254:** basta con instalar el script nuevo y crear `apt.conf`. `estado.json` y los
llaveros guardados sirven igual. Las líneas antiguas de `apt-aprobados`, sin tercera columna, ya solo valen para
`pruebas`; como ya están firmadas, no importa.

**Subida a ns2:** clave SSH **propia** de `flywebfirma` (`flyweb-ns2-apt`, no la de Sparkle ni la de componentes) con
`rrsync` en `/var/www/FlyWeb/apt`, solo desde la IP de bak, y alias en `~flywebfirma/.ssh/config` (`Host ns2-apt`). Esta
necesita borrar (los `by-hash` viejos, en la última pasada). El `.deb` lo sube otra clave, limitada a `pool/` y sin
borrar ni sobrescribir.

## Publicar una versión

1. **Compilar y empaquetar** en la Ubuntu: `flyweb-release.sh <manifiesto> empaquetar`, con `llavero_apt=` la pública en
   binario (`gpg --dearmor < clave-publica.asc`). Sin llavero (`deb_prueba=1`) el `.deb` no sirve para publicar.
2. **Subir el `.deb`** a `pool/main/f/flyweb/flyweb_<versión>-<build>_amd64.deb` en ns2. Todavía no lo ve `apt`.
3. **SHA-256 y versión** (`sha256sum`, p. ej. `3.2.2-52`) a Titín, ya metidos en la orden del paso 4.
4. **Titín, en bak, una sola orden** (cabe en una línea):
   ```sh
   sudo node /opt/flyweb-firma/firmar-apt.mjs publicar --version 3.2.2-52 --sha256 <sha256>
   ```
   Qué hace, en este orden:
   1. **Aprobación.** Apunta `<sha256>  3.2.2-52  stable  # publicar, <fecha>` en `apt-aprobados`, si no está ya. Se para
      si esa versión ya está aprobada con otro SHA-256, si el fichero no es de root o si otro usuario puede escribirlo.
   2. **`pruebas`.** Como `flywebfirma` (con `runuser`, sin shell), firma `pruebas` con todas las comprobaciones de
      `firmar` (abajo) y lo sube.
   3. **Comprobación de `pruebas`** en `https://apt.flyweb.lamosquita.net/dists/pruebas/`, también como `flywebfirma`.
      Las peticiones esquivan cachés: consulta aleatoria y `Cache-Control: no-cache`. Lo que se comprueba:
      - el `InRelease` publicado es byte a byte el que ha firmado bak, con el `Date` nuevo;
      - `Packages` coincide, y `Packages` y `Packages.xz` también por `by-hash`;
      - en `Packages`, la versión, el SHA-256 y el tamaño son los aprobados.

      Si algo falla lo reintenta dos veces más, y después se para diciendo qué no cuadra y que **`stable` no se ha
      tocado**.
   4. **`stable`.** Si `pruebas` cuadra, firma `stable` y lo comprueba igual.

   **Se puede repetir.** Lo que ya esté firmado con ese SHA-256 no se vuelve a firmar, solo se comprueba. Así, si se cortó
   la red a medias, la misma orden termina el trabajo.
5. **En un equipo con FlyWeb:** `apt update` y `apt policy flyweb`; el candidato tiene que ser la versión nueva. Con
   `unattended-upgrades` llega sola, normalmente en un día; para no esperar, `sudo unattended-upgrade -d`.

Qué comprueba `firmar` antes de firmar cada suite:
- el SHA-256 y la versión aprobados para esa suite, antes de pasar el `.deb` a `dpkg-deb`;
- que la URL es la de `pool/` por https;
- el `control`: `Package: flyweb`, la versión aprobada y `Architecture: amd64`. Además, un solo párrafo, sin caracteres de
  control y sin campos de la lista blanca escritos con otras mayúsculas;
- que el llavero del `.deb` es un fichero normal, no un enlace;
- que la versión es mayor que todas las firmadas en la suite, también las retiradas;
- el reloj contra ns2, y que el `Date` crece.

Después de firmar, verifica `InRelease` y `Release.gpg` (los dos firmados por la subclave) con tres llaveros:
- el del `.deb` nuevo;
- el del publicado hasta ahora;
- el de la versión más alta firmada nunca, aunque esté retirada. Es el que tienen los equipos que la instalaron, porque
  apt no baja de versión.

**A mano**, como antes, sigue habiendo `firmar` (una suite) y `comprobar`, como `flywebfirma`. Para `firmar` en `stable`,
la línea de `apt-aprobados` tiene que llevar `stable` en la tercera columna; sin ella, solo vale para `pruebas`:
```sh
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs firmar \
  --deb https://apt.flyweb.lamosquita.net/pool/main/f/flyweb/flyweb_3.2.2-52_amd64.deb --version 3.2.2-52 \
  --aprobados /etc/flyweb-firma/apt-aprobados --gnupghome /var/lib/flyweb-firma/claves/apt --subclave <S> \
  --salida /var/lib/flyweb-firma/apt --suite stable --subir ns2-apt
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs comprobar --version 3.2.2-52 --sha256 <sha256> \
  --salida /var/lib/flyweb-firma/apt --suite stable
```

## Reloj

- `firmar`, `retirar` y `refirmar` comparan el reloj de bak con la cabecera `Date` de `https://apt.flyweb.lamosquita.net/`.
  Si la diferencia pasa de 5 minutos, no firman. Si ns2 no contesta, se conforman con que
  `timedatectl show -p NTPSynchronized` diga `yes`; si tampoco, no firman.
  - Así el `Date` firmado no queda en el futuro. apt no aceptaría ese `InRelease`, y bak no podría volver a firmar hasta
    esa fecha.
- Si aun así el `Date` publicado quedó en el futuro, el error lo dice. Entonces hay que esperar a que pase esa hora, o
  decidir con SEGURIDAD qué hacer con `estado.json`.
- **Sin `estado.json` en bak pero con un `InRelease` ya publicado** (estado perdido o restaurado de una copia vieja),
  `firmar` no firma: empezaría la cuenta de versiones y de `Date` de cero. Primero hay que recuperar `estado.json`. Solo
  si de verdad es la primera publicación de la suite, se añade `--primera si`.

## Retirar una versión (Titín, en bak)

```sh
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs retirar --version 3.2.2-NN \
  --gnupghome /var/lib/flyweb-firma/claves/apt --subclave <S> --salida /var/lib/flyweb-firma/apt --subir ns2-apt
```

- Vuelve a poner en el índice la anterior no retirada (o lo deja vacío), anota la retirada en `estado.json` y guarda el
  estado anterior en `estado.json.<fecha>`.
- **apt nunca baja de versión:** quien ya la tiene se queda en ella hasta la siguiente. La corrección es siempre una
  versión con `build` nuevo; `firmar` no acepta un número igual o menor que uno ya publicado, aunque esté retirado.
- Con `unattended-upgrades`, una versión puede llegar a muchos equipos el primer día: retirar no la quita de ellos.

## Refirmar y cambiar de subclave

`refirmar` vuelve a firmar el índice actual con `Date` nuevo. Solo hace falta después de cambiar la subclave de bak:

```sh
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs refirmar \
  --gnupghome /var/lib/flyweb-firma/claves/apt --subclave <S-nueva> --salida /var/lib/flyweb-firma/apt --subir ns2-apt
```

Rotación (§4.4 del diseño), con meses de margen:
1. Con la copia cifrada, en RAM y sin red: subclave de firma nueva (`--quick-add-key <P> ed25519 sign 2y`). La pública
   nueva (principal y las dos subclaves) va a softmac.
2. Una versión del paquete lleva esa pública (`/usr/share/keyrings/flyweb.gpg` no es conffile) y se firma todavía con
   la subclave vieja.
3. Cuando esa versión lleva un tiempo publicada: en bak solo la subclave nueva y `refirmar`. Quien no haya actualizado
   verá un error de firma y tendrá que bajar el `.deb` de la web.

**Si se sospecha que han robado la subclave:** subclave nueva y revocación de la vieja con la copia cifrada; una sola
versión cuyo llavero lleve las dos cosas, firmada aún con la vieja; las siguientes, con la nueva.

## Caducidad

`firmar`, `retirar` y `refirmar` avisan si a la subclave le quedan **menos de 9 meses** y **no firman con menos de 3**. Tras
rotar, también avisan si en el `GNUPGHOME` queda otra subclave de firma con su parte secreta: debe haber solo una.
Si caduca sin rotar, todos los equipos ven un error de firma en `apt update`. Para mirarla:

```sh
sudo -u flywebfirma node /opt/flyweb-firma/firmar-apt.mjs caducidad --gnupghome /var/lib/flyweb-firma/claves/apt --subclave <S>
```

## Pruebas

`node pruebas/firma-apt.mjs` (sin red, con clave desechable v4; 98 comprobaciones). Cubre:
- los rechazos: aprobación (también por suite), versión, `Package`, URL, `control` inyectado o con caracteres de control,
  `Date`, reloj, estado perdido y clave;
- el SHA-256 antes de `dpkg-deb`, `Release` sin `Valid-Until` y que `gpgv` acepte el `InRelease` firmado por la subclave;
- retirar, refirmar y el orden de subida;
- la rotación: se verifica también con el llavero de la más alta retirada;
- `comprobar`, con un ns2 de mentira: lo firmado, un `InRelease` viejo y un `by-hash` que falta;
- `publicar`: el orden pruebas → stable, que `stable` no se toque si `pruebas` no cuadra, repetir sin volver a firmar, y
  los rechazos de sudo, permisos, `apt.conf` y SHA-256 en conflicto. Con
`FLYWEB_APT_GUARDAR=<dir>` deja el repositorio para `pruebas/contenedores.sh` (`gpgv` de 22.04, `sqv` y `apt` en 22.04,
24.04, Debian 12 y 26.04, con podman). El CI (`.github/workflows/flyweb-apt.yml`) corre las pruebas en ubuntu-22.04.
