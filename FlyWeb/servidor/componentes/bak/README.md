# Firma en bak

**Estado (03-10-2026):** instalado por el HUMANO en bak y ns2; primera firma hecha y temporizador activo.
Pendiente: actualizar bak para el espejo de Google (F2.2, [abajo](#actualizar-espejo-de-google-f22)).

Los componentes se **construyen** en GitHub Actions sin claves privadas (`.github/workflows/flyweb-shields.yml`) y se
**firman** en bak. Así, el código de terceros (las listas, uBlock Origin, el motor en Rust, npm) nunca corre en bak,
y las claves nunca salen de bak.

```
GitHub Actions (03:17 UTC)                bak (05:23 UTC, usuario flywebfirma)            ns2
 empaquetar.mjs → zips sin firmar  ──►     firmar.mjs: comprueba y firma         ──rsync──►   /var/www/FlyWeb/components
 release «shields» (público)               (solo Node, 3 ficheros, sin npm)                   (go-update lo sirve)
```

## Qué hay en bak

| Fichero | Qué |
|---|---|
| `/opt/flyweb-firma/{firmar,zip,crx3,google}.mjs` | El firmador y el espejo de Google: unas 350 líneas, solo Node. **No se actualiza solo**: lo copia el HUMANO desde un commit revisado |
| `/opt/flyweb-firma/{generar-claves.sh,listas.json}` | Para crear las claves (una vez, y al añadir listas) |
| `/var/lib/flyweb-firma/claves/` | Claves privadas (0700/0600, usuario `flywebfirma`). Copia de seguridad fuera de bak, cifrada, por el canal del HUMANO |
| `/var/lib/flyweb-firma/salida/` | CRX firmados y copiados, `catalog.json`, `_estado.json`, `firmado.json` (lo ya firmado) y `google.json` (lo ya copiado) |
| `/etc/flyweb-firma/recursos-aprobados` | Hashes de `resources.json` aprobados. **De root**: el firmador lo lee pero no puede escribirlo |
| `flyweb-firma.service` / `.timer` | Una vez al día, endurecido (sin privilegios, sistema de ficheros de solo lectura salvo su carpeta) |

## Qué comprueba antes de firmar

- El SHA-256 de cada zip coincide con `indice.json`.
- Cada zip tiene solo `manifest.json` y su fichero de datos.
- El manifest lleva **nuestra** clave.
- La versión es posterior a la ya firmada, para que no se pueda volver a una versión antigua.
- En el catálogo, cada lista apunta a nuestro ID y nuestra clave.
- Una lista no pierde más de la mitad de sus reglas.
- **`resources.json`, el único componente con JavaScript, solo se firma si su hash está aprobado.**

Y antes de copiar un CRX de Google:

- Tamaño y SHA-256 iguales a los que anuncia el servidor de Google; descarga solo por https de sus dominios.
- CRX3 con todas las firmas válidas (RSA o ECDSA, como Chromium 116), el ID del componente y la prueba del
  publicador de **Google** (la misma clave que exige Chromium 116).
- Versión posterior a la ya copiada: un CRLSet antiguo volvería a dar por buenos certificados revocados.

Si algo falla, ese componente no se firma, se conserva lo anterior y el servicio termina con error: se ve en el
journal y en `https://components.flyweb.lamosquita.net/_estado.json` (`fallos`, `recursos_pendientes`).

Pruebas: `node pruebas/firma-bak.mjs` y `node pruebas/google-bak.mjs` (sin red, con claves desechables). El CI ejecuta
además `google.mjs` contra Google de verdad (trabajo `google` de `flyweb-shields.yml`), sin subir nada.

## Aprobar recursos nuevos

`resources.json` cambia solo cuando se sube la versión fijada de uBlock Origin en `fijado.json`. Esa subida va en un
PR y el CI exige que la versión tenga al menos 14 días. Tras fusionarlo, `_estado.json` mostrará el hash pendiente;
NUBE o el agente SERVIDOR te lo dirán. Si el hash coincide con el que imprime el CI de ese commit:

```sh
echo "<hash>  # uBlock Origin <versión>" | sudo tee -a /etc/flyweb-firma/recursos-aprobados
```

## Instalación (HUMANO, una vez)

Pasos para hacer a mano, a tu manera. Ningún comando muestra claves privadas.

### En bak

```sh
sudo apt install nodejs rsync          # Node ≥ 18 (en Ubuntu 24.04, el de apt es 18.19)
sudo adduser --system --group --home /var/lib/flyweb-firma --shell /usr/sbin/nologin flywebfirma
sudo install -d -m 0755 /opt/flyweb-firma /etc/flyweb-firma
sudo install -d -m 0700 -o flywebfirma -g flywebfirma /var/lib/flyweb-firma/salida /var/lib/flyweb-firma/.ssh
# Descarga desde un commit concreto (inmutable) y comprueba los SHA-256 que da el PR antes de instalar:
C=<commit>; U=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/componentes
mkdir -p ~/flyweb-firma-src && cd ~/flyweb-firma-src
for f in bak/firmar.mjs bak/zip.mjs bak/crx3.mjs generar-claves.sh listas.json; do curl -fsSLo "$(basename $f)" "$U/$f"; done
sha256sum -c sumas.txt          # sumas.txt: las líneas «<sha256>  <fichero>» del PR; todas deben decir «La suma coincide»
sudo install -m 0644 firmar.mjs zip.mjs crx3.mjs generar-claves.sh listas.json /opt/flyweb-firma/
sudo touch /etc/flyweb-firma/recursos-aprobados && sudo chmod 0644 /etc/flyweb-firma/recursos-aprobados

# Claves de firma. Solo muestra datos PÚBLICOS: pásaselos a NUBE (van a claves-publicas.json y a brave-core).
sudo -u flywebfirma sh /opt/flyweb-firma/generar-claves.sh /var/lib/flyweb-firma/claves /opt/flyweb-firma/listas.json

# Clave SSH para subir a ns2 (solo para esto). Muestra la huella y la clave pública, no la privada.
sudo -u flywebfirma ssh-keygen -t ed25519 -N '' -C flywebfirma@bak -f /var/lib/flyweb-firma/.ssh/flyweb-ns2
sudo cat /var/lib/flyweb-firma/.ssh/flyweb-ns2.pub
```

`/var/lib/flyweb-firma/.ssh/config` (de `flywebfirma`, 0600):

```
Host flyweb-ns2
  HostName ns2.lamosquita.net
  User flywebsubida
  IdentityFile ~/.ssh/flyweb-ns2
  IdentitiesOnly yes
  BatchMode yes
  StrictHostKeyChecking yes
```

Clave de host de ns2: en ns2, `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`. En bak,
`ssh-keyscan -t ed25519 ns2.lamosquita.net | sudo -u flywebfirma tee /var/lib/flyweb-firma/.ssh/known_hosts` y
compara la huella con `sudo -u flywebfirma ssh-keygen -lf /var/lib/flyweb-firma/.ssh/known_hosts` antes de seguir.

### En ns2

```sh
sudo adduser --system --group --home /var/lib/flyweb-subida --shell /bin/sh flywebsubida
sudo chown -R flywebsubida:flywebsubida /var/www/FlyWeb/components    # Apache y go-update solo leen
sudo install -d -m 0700 -o flywebsubida -g flywebsubida /var/lib/flyweb-subida/.ssh
ls /usr/bin/rrsync                                                      # viene con rsync 3.2 en Ubuntu 24.04
sudo sshd -T | grep -iE '^(allowusers|allowgroups) '                    # si sale algo, añadir flywebsubida
```

`/var/lib/flyweb-subida/.ssh/authorized_keys` (de `flywebsubida`, 0600), una sola línea:

```
restrict,from="<IP de bak>",command="/usr/bin/rrsync -wo /var/www/FlyWeb/components" ssh-ed25519 AAAA… flywebfirma@bak
```

`restrict` quita terminal, reenvíos y agente. `rrsync -wo` solo deja **escribir** dentro de esa carpeta: ni leer, ni
salir de ella, ni ejecutar nada (probado en NUBE: `..` y lecturas rechazados).

### Primera ejecución y temporizador (en bak)

```sh
sudo install -m 0644 flyweb-firma.service flyweb-firma.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start flyweb-firma.service; sudo journalctl -u flyweb-firma -n 30   # recursos quedará pendiente
sudo systemctl enable --now flyweb-firma.timer
```

## Actualizar: espejo de Google (F2.2)

Cambian `firmar.mjs`, `crx3.mjs` y el servicio; `google.mjs` es nuevo. `zip.mjs`, las claves y ns2 no cambian.
Antes, si bak filtra el tráfico de salida: debe poder abrir https hacia `update.googleapis.com`, `dl.google.com`,
`edgedl.me.gvt1.com`, `redirector.gvt1.com` y `www.google.com` (hasta ahora solo usaba GitHub).

```sh
C=<commit>; U=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/componentes
mkdir -p ~/flyweb-firma-src && cd ~/flyweb-firma-src
for f in bak/firmar.mjs bak/crx3.mjs bak/google.mjs bak/flyweb-firma.service; do curl -fsSLo "$(basename $f)" "$U/$f"; done
sha256sum -c sumas.txt          # las 4 líneas del PR
sudo install -m 0644 firmar.mjs crx3.mjs google.mjs /opt/flyweb-firma/
sudo install -m 0644 flyweb-firma.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start flyweb-firma.service; sudo journalctl -u flyweb-firma -n 30   # deben salir 7 «+» de Google
```

Comprobación: `https://components.flyweb.lamosquita.net/_estado.json` lista los 7 en `google`.
