# Actualizaciones de FlyWeb (Sparkle)

**Estado (04-10-2026, LOCAL con permiso del HUMANO):** firmador instalado en bak (commit ff67f5e, suma comprobada), clave EdDSA generada (`/var/lib/flyweb-firma/claves/actualizaciones.pem`, flywebfirma 0600; pública en `clave-publica.txt`), clave SSH propia `flyweb-ns2-updates` → ns2 `flywebsubida` con `rrsync -wo /var/www/FlyWeb/updates`, solo desde la IP de bak (probado: escribe en `stable/`, no sale de su carpeta). **Pendiente del HUMANO: copia de seguridad cifrada de `actualizaciones.pem` fuera de bak.**

**Estado (04-10-2026):** código listo (brave-core `nube/actualizador` = paso 45; `build.sh`; firmador de bak con sus
pruebas). **Falta:** la clave en bak (HUMANO), `clave-publica.txt` en el repo, y la primera versión publicada así.

FlyWeb 1.0 se publicó con «actualizador desconectado»: `build.sh` apagaba Sparkle y el código de Brave miraba el
appcast de Brave. **La 1.0 no puede actualizarse sola**: la 1.0.1 se instala a mano una vez, y desde ella ya llegan
solas las siguientes.

## Cómo funciona

```
MacPro7,1 (LOCAL)                             bak (HUMANO aprueba)                       ns2
 FLYWEB_BUILD_NUMBER=1 build.sh Release
 firma G2 + notariza + DMG          ──sube──►  /var/www/FlyWeb/updates/FlyWeb-1.0.1.dmg  (servido, aún sin anunciar)
 da el SHA-256 al HUMANO
                                    HUMANO: «<sha256>  157.64.1» → /etc/flyweb-firma/actualizaciones-aprobadas
                                    firmar-actualizacion.mjs: descarga el DMG de ns2,
                                    comprueba SHA-256 + versión aprobados, firma (ed25519)
                                    y genera el appcast                    ──rsync──►  /var/www/FlyWeb/updates/stable/appcast.xml
FlyWeb (cada 3 horas)   ◄────────────────────────────────────────────────────────────── appcast + DMG
 Sparkle comprueba: firma EdDSA con SUPublicEDKey, Developer ID igual que el instalado → instala al reiniciar
```

- **La clave privada no sale de bak.** La app lleva solo la pública (`SUPublicEDKey`, la pone `build.sh` desde
  `clave-publica.txt`).
- **Dos firmas independientes:** la de Apple (Developer ID G2 + notarización) y la nuestra (EdDSA). Sparkle 1.24 exige
  las dos: si alguien cambia el DMG en ns2, la EdDSA no cuadra; si alguien roba la clave EdDSA, sigue faltando el
  Developer ID.
- **Nada se publica sin el HUMANO:** bak solo firma un DMG cuyo SHA-256 y versión estén en un fichero de root.
- **Versiones:** la base de Brave sigue en 1.57.64 (`CFBundleVersion` 157.64). Cada versión de FlyWeb añade
  `FLYWEB_BUILD_NUMBER` → 157.64.1, 157.64.2… El firmador rechaza una versión que no sea posterior a la publicada.
- **Privacidad:** Sparkle pide `https://updates.flyweb.lamosquita.net/stable/appcast.xml` cada 3 horas (el intervalo del código de brave-core, comprobado
  por SERVIDOR-LOCAL el 05-10; antes aquí ponía «una vez al día»), sin datos
  del sistema (`SUEnableSystemProfiling` = false); el vhost no guarda IP. Ya está en el texto de privacidad.
- **Sparkle 1.24.3** (el que trae Brave 1.57) funciona en 10.9 o superior. Sus fallos conocidos posteriores son de
  escalada local (otro usuario del mismo Mac), no remotos. Riesgo asumido; subir a Sparkle 2 obligaría a reescribir
  `sparkle_glue.mm`.

## Instalación en bak (HUMANO, una vez)

Igual que el firmador de componentes (`../componentes/bak/README.md`), con el mismo usuario `flywebfirma`.

```sh
C=<commit>; U=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/actualizaciones
curl -fsSLo firmar-actualizacion.mjs "$U/bak/firmar-actualizacion.mjs"
sha256sum firmar-actualizacion.mjs      # comparar con la suma del PR
sudo install -m 0644 firmar-actualizacion.mjs /opt/flyweb-firma/
sudo install -d -m 0700 -o flywebfirma -g flywebfirma /var/lib/flyweb-firma/actualizaciones
sudo touch /etc/flyweb-firma/actualizaciones-aprobadas && sudo chmod 0644 /etc/flyweb-firma/actualizaciones-aprobadas

# Clave EdDSA. Solo imprime la PÚBLICA: pásasela a NUBE (va a clave-publica.txt).
sudo -u flywebfirma node /opt/flyweb-firma/firmar-actualizacion.mjs generar-clave \
  --clave /var/lib/flyweb-firma/claves/actualizaciones.pem
```

Copia de seguridad de `actualizaciones.pem`, cifrada y por tu canal habitual: **si se pierde, ninguna FlyWeb
instalada aceptará actualizaciones nuevas** (habría que reinstalar a mano en cada Mac).

**Subida a ns2:** otra línea en el `authorized_keys` del usuario de subida de ns2, con una clave SSH **propia** de
`flywebfirma` (no la de componentes: con la misma clave, sshd aplica siempre la primera línea) restringida a `/var/www/FlyWeb/updates` (`command="rrsync /var/www/FlyWeb/updates",restrict …`), y en
bak un alias en `~flywebfirma/.ssh/config` (p. ej. `Host ns2-updates`). `install -d /var/www/FlyWeb/updates/stable`
en ns2.

## Publicar una versión (LOCAL, con el HUMANO)

1. **Número:** el siguiente al último publicado (`FLYWEB_BUILD_NUMBER`; 1.0.1 = 1, 1.1 = 2). La versión visible
   (`--visible`) es la de brave-core `build/config.gni` (`flyweb_version`), la que muestra Información. Integrar en `flyweb` lo que vaya
   en esa versión (como mínimo el paso 45) y anotar en `integracion.md` qué pasos lleva.
2. **Compilar:** `FLYWEB_BUILD_NUMBER=1 FlyWeb/scripts/build.sh Release`. Debe decir «Actualizaciones: activadas
   (… 157.64.1)». Si dice «SIN actualizaciones automáticas», falta `clave-publica.txt`: no publicar.
3. **Comprobar el `.app`:** `defaults read …/FlyWeb.app/Contents/Info SUPublicEDKey` = el contenido de
   `clave-publica.txt`; `CFBundleVersion` = 157.64.1; `Contents/Frameworks/…/Sparkle.framework` presente y firmado.
4. **Firmar (G2), notarizar y crear el DMG**, como en la 1.0. Nombre: `FlyWeb-1.0.1.dmg`.
5. **Subir el DMG a ns2:** `/var/www/FlyWeb/updates/FlyWeb-1.0.1.dmg` (root 0644). Todavía no lo anuncia nadie.
6. **SHA-256** (`shasum -a 256 FlyWeb-1.0.1.dmg`) → al HUMANO, junto con la versión (157.64.1).
7. **HUMANO, en bak:**
   ```sh
   echo "<sha256>  157.64.1  # FlyWeb 1.0.1" | sudo tee -a /etc/flyweb-firma/actualizaciones-aprobadas
   sudo -u flywebfirma node /opt/flyweb-firma/firmar-actualizacion.mjs firmar \
     --dmg https://updates.flyweb.lamosquita.net/FlyWeb-1.0.1.dmg --version 157.64.1 --visible 1.0.1 \
     --clave /var/lib/flyweb-firma/claves/actualizaciones.pem \
     --aprobados /etc/flyweb-firma/actualizaciones-aprobadas \
     --salida /var/lib/flyweb-firma/actualizaciones --subir ns2-updates
   ```
8. **Comprobar:** `curl -s https://updates.flyweb.lamosquita.net/stable/appcast.xml` muestra la versión nueva. En un
   Mac con la versión anterior (desde la 1.0.1): `flyweb://settings/help` → «Buscar actualizaciones» → descarga, pide
   reiniciar y, tras reiniciar, `flyweb://version` dice 157.64.N. Probar en la 6,1 (Mojave).

**Si algo sale mal:** retirar la versión es publicar una posterior (Sparkle nunca baja de versión). Para parar las
actualizaciones al momento, en ns2 dejar el appcast anterior (`/var/lib/flyweb-firma/actualizaciones/stable/` tiene
el estado; el appcast de ns2 se puede restaurar a mano).

## Pruebas

`node pruebas/firma-actualizacion.mjs` (sin red, con clave desechable): rechaza DMG sin aprobar, otra versión con el
mismo DMG, descargas fuera de `https://updates.flyweb.lamosquita.net` y versiones no posteriores; la firma la
verifica también **OpenSSL** (ed25519 sobre el DMG entero, como Sparkle) y deja de valer con un bit cambiado.
