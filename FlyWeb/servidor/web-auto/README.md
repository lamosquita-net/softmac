# Publicación automática de la web (SV.6)

Decisión del HUMANO (05-10-2026): cuando aprueba y firma una versión en bak, `flyweb.lamosquita.net` se pone al día
sola (descarga, portada, notas y ayuda), **sin revisión previa si todo cuadra**. SERVIDOR-LOCAL revisa después y lo
anota en `CAMBIOS.md`. Clase de cambio autorizada en E3 (`docs/SERVIDOR.md` §3).

## Cómo funciona

`flyweb-web-auto` corre en ns2 como el usuario `servidor`, cada 10 minutos (temporizador de systemd de usuario).
Solo puede publicar a través de `flyweb-desplegar` (la única orden como root que tiene `servidor` para la web).

En cada pasada:
1. Lee el appcast **local** (`/var/www/FlyWeb/updates/stable/appcast.xml`, lo escribe bak al firmar) y toma la
   versión más alta.
2. Pide a GitHub el commit de `main` (una petición). Si ni el commit ni la versión han cambiado desde la última
   pasada, termina.
3. Lee `FlyWeb/web/VERSION` de ese commit. Si no describe la versión del appcast, **espera** (no publica nada) y
   avisa una vez.
4. Comprueba el DMG de `updates/`: tamaño = el del appcast; SHA-256 = el de `VERSION`; **firma EdDSA del appcast
   válida con la clave pública fijada en el script** (no la lee del repo).
5. Baja las páginas de ese commit; la portada tiene que enlazar `descargas/<DMG>` y mostrar su SHA-256. Además,
   `VERSION` y cada página que vaya a cambiar tienen que haber llegado a `main` **por un PR fusionado** (API de
   GitHub): `main` también recibe pushes directos (filas del tablero), y esos nunca se publican solos.
6. Publica: el DMG en `descargas/` (`flyweb-desplegar dmg`, nunca sustituye) y **cada página que haya cambiado**
   (`flyweb-desplegar web <commit> <fichero> <sha256>`). Por eso también llegan solos los cambios de la ayuda, una
   vez fusionados en `main` (siempre que `VERSION` siga siendo la versión aprobada).
7. Comprueba desde ns2 (portada, DMG y ayuda, 200; la portada enlaza el DMG), lo apunta y avisa por correo.
8. **Limpieza** (decisión del HUMANO, 06-10): deja como mucho **10 DMG** en `updates/` y otros 10 en `descargas/`,
   borrando los más antiguos con `flyweb-desplegar borrar`. Nunca borra uno que esté en el appcast ni
   `FlyWeb-1.0.dmg`, y `flyweb-desplegar` vuelve a comprobarlo como root.

Si algo no cuadra (firma, SHA-256, tamaño, portada), **no publica nada** y avisa (un correo por caso, no uno cada
10 minutos). Si GitHub no responde, lo intenta en la pasada siguiente.

## Qué tiene que hacer quien prepara la versión (LOCAL o NUBE)

En el PR de la web de cada versión, **antes de pedir la firma al HUMANO**:
- `FlyWeb/web/index.html`: botón, tamaño, SHA-256 y notas en `#novedades`;
- `FlyWeb/web/ayuda/…` si cambia algo;
- `FlyWeb/web/novedades.html` (cuando esté en las listas, ver más abajo): la banda de la versión nueva, arriba;
- `FlyWeb/web/VERSION`, una línea: `<versión> <CFBundleVersion> <DMG> <sha256>`, por ejemplo
  `1.2 157.64.5 FlyWeb-1.2.dmg 5b5a0742…475d6b` (el SHA-256 del DMG subido a `updates/`).

Se puede fusionar antes o después de la firma: mientras `VERSION` no coincida con el appcast, la web no cambia; en
cuanto coinciden, se publica en ≤ 10 minutos. **Ojo:** con `VERSION` por delante del appcast, los cambios de la
ayuda tampoco se publican hasta la firma (el script publica siempre una web coherente con la versión aprobada).

## Instalar (SERVIDOR-LOCAL, desde un commit revisado de `main`)

HUMANO, una vez: el temporizador de usuario tiene que correr sin sesión abierta, y `flyweb-desplegar` necesita la
orden `borrar` (`C` = commit de `main` con este PR):
```sh
sudo loginctl enable-linger servidor
curl -fsSLo flyweb-desplegar "https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/acceso/flyweb-desplegar"
echo "<sha256 del PR>  flyweb-desplegar" | sha256sum -c \
  && sudo install -m 0755 -o root -g root flyweb-desplegar /usr/local/sbin/flyweb-desplegar && rm flyweb-desplegar
```
SERVIDOR-LOCAL, en ns2 como `servidor` (`C` = commit de `main`):
```sh
R=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/web-auto
install -d -m 0755 ~/bin ~/.config/systemd/user
curl -fsSL -o ~/bin/flyweb-web-auto "$R/flyweb-web-auto" && chmod 0755 ~/bin/flyweb-web-auto
curl -fsSL -o ~/.config/systemd/user/flyweb-web-auto.service "$R/flyweb-web-auto.service"
curl -fsSL -o ~/.config/systemd/user/flyweb-web-auto.timer "$R/flyweb-web-auto.timer"
sha256sum ~/bin/flyweb-web-auto ~/.config/systemd/user/flyweb-web-auto.*      # = las del PR
~/bin/flyweb-web-auto comprobar                                              # qué haría
systemctl --user daemon-reload && systemctl --user enable --now flyweb-web-auto.timer
```

Ver: `systemctl --user list-timers`, `journalctl --user -u flyweb-web-auto`, `~/.local/state/flyweb-web-auto/registro.log`
y `/var/log/flyweb-deploy/desplegar.log`.

## Añadir una página a la lista (HUMANO + SERVIDOR-LOCAL)

Solo se publican los ficheros de `FICHEROS` (en `flyweb-web-auto`) y los que admite `flyweb-desplegar`. Para `novedades.html`
(PR de CONTENIDOS-WEB) hay que cambiar **las dos** listas, y **en este orden**:

1. **HUMANO:** instalar el `flyweb-desplegar` nuevo. Con el PR ya fusionado, en ns2 con tu usuario (el que tiene `sudo`):
   ```sh
   C=<commit de main con el PR fusionado>      # git log -1 en main, o el "merge commit" del PR en GitHub
   cd "$(mktemp -d)"
   curl -fsSLo flyweb-desplegar "https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/acceso/flyweb-desplegar"
   sha256sum flyweb-desplegar                  # debe ser el SHA-256 que pone el PR
   diff /usr/local/sbin/flyweb-desplegar flyweb-desplegar   # solo deben salir 2 líneas distintas: un comentario y el `case`, con `novedades.html`
   bash -n flyweb-desplegar && echo sintaxis-ok
   sudo install -m 0755 -o root -g root flyweb-desplegar /usr/local/sbin/flyweb-desplegar
   ls -l /usr/local/sbin/flyweb-desplegar      # -rwxr-xr-x root root
   sudo /usr/local/sbin/flyweb-desplegar 2>&1 | grep novedades   # sin argumentos imprime el uso; debe salir novedades
   ```
   Si el `diff` enseña algo más que esas dos líneas (por ejemplo, porque el instalado es más viejo que `main`), no instales:
   pregunta antes. No hace falta tocar `sudoers`: la orden y sus permisos no cambian.
2. **SERVIDOR-LOCAL:** instalar el `flyweb-web-auto` nuevo (receta de «Instalar» más arriba, con el mismo `C`), comprobar su
   SHA-256 y ejecutar `~/bin/flyweb-web-auto comprobar`.

Al revés (primero `web-auto`), la siguiente publicación falla a mitad: `flyweb-desplegar` rechaza la página, y el DMG ya
estaría puesto. Hasta que estén las dos, ninguna página debe enlazar a `novedades.html` (daría 404).

## Parar o quitar

`systemctl --user disable --now flyweb-web-auto.timer` (para; la web se queda como esté). Para quitarlo del todo,
además borrar `~/bin/flyweb-web-auto` y las dos unidades. Volver a una página anterior: copias en
`/var/backups/flyweb-web-*` (las hace `flyweb-desplegar`) o `flyweb-desplegar web <commit anterior> …`.

## Límite asumido

El texto se publica tal como está en `main`, pero solo si cada fichero llegó por un PR fusionado: un push directo a
`main` (como los del tablero) nunca se publica solo. Queda un caso raro: un commit empujado directamente que luego
entra en un PR (GitHub lo da por fusionado); lo cubre la revisión de esos PR. El DMG, en
cambio, solo se publica si lo firmó bak (EdDSA) y su SHA-256 es el anunciado: un repo comprometido no puede hacer que
la web ofrezca un DMG que el HUMANO no aprobó.

## JavaScript: nunca se publica solo (HUMANO, 06-10-2026)

`js/mosca.js` (la mosca de la portada) y `js/cifras.js` los instala **el HUMANO a mano, una vez**, en
`/var/www/flyweb.lamosquita.net/js/`, con la **carpeta y los ficheros `root:root`** (0755/0644): así ni `supermosquita`,
ni `servidor`, ni `flyweb-desplegar` (que no los tiene en su lista) pueden cambiarlos ni sustituirlos. `nosniff` y la
CSP impiden que otro fichero de la web se ejecute como script.

- Cada `<script>` lleva `integrity="sha384-…"`: si el fichero del servidor cambia, el navegador no lo ejecuta.
- `flyweb-web-auto` compara en cada pasada los JS del servidor con los de `main` y, si no coinciden, **para** (no
  publica nada, ni páginas ni DMG) y avisa por correo; no los toca. Si publicara la página con el `integrity` nuevo y
  el JS viejo, el navegador no ejecutaría el script (`cifras.html` se quedaría vacía).
- Cambiar un JS: PR (con el `integrity` nuevo en la página) → fusionar → el HUMANO lo instala a mano → la pasada
  siguiente publica las páginas.

## Publicar una versión, de principio a fin (HUMANO, 07-10-2026)

1. **LOCAL** compila, notariza y deja el DMG en `~/proyectos/softmac/entregas/FlyWeb-<v>/FlyWeb-<v>.dmg`.
2. **LOCAL** lo sube a ns2 con `~/proyectos/softmac/herramientas/subir-dmg-ns2.sh <v> <sha256>`: usuario compartido
   `claude` (`cc-ns2`), una sesión, comprueba la IP de la oficina contra `lamosquita5g.duckdns.org`, el SHA-256 antes y
   después, no sustituye un DMG existente y lo deja root:root 0644 en `updates/`. Claude Code tiene una regla de permiso
   para ese script (y solo ese), así que no se bloquea.
3. **LOCAL** abre y fusiona el PR de la web: portada (botón, tamaño, SHA-256, notas en `#novedades`), ayuda si cambia, y
   `FlyWeb/web/VERSION` = `<v> <CFBundleVersion> FlyWeb-<v>.dmg <sha256>`. Si cambia `estilo.css`, `img/` o `js/`:
   `python3 FlyWeb/web/versionar.py`. Si cambia un JS, **el HUMANO lo instala a mano** en `js/`; hasta entonces
   `flyweb-web-auto` no publica nada.
4. **El HUMANO** firma en bak.
5. **`flyweb-web-auto`** (ns2, cada 10 min) publica solo: DMG en `descargas/`, portada con la versión enlazada, notas y
   ayuda; comprueba y avisa por correo. **Las cifras** de la versión nueva salen a la mañana siguiente (`flyweb-cifras`,
   07:10, cuenta hasta el día anterior).

Si algo falla, el correo dice qué; a mano solo SERVIDOR-LOCAL (`flyweb-desplegar`), anotándolo en `CAMBIOS.md` antes.

