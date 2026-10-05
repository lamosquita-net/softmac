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
5. Baja las páginas de ese commit; la portada tiene que enlazar `descargas/<DMG>` y mostrar su SHA-256.
6. Publica: el DMG en `descargas/` (`flyweb-desplegar dmg`, nunca sustituye) y **cada página que haya cambiado**
   (`flyweb-desplegar web <commit> <fichero> <sha256>`). Por eso también llegan solos los cambios de la ayuda, una
   vez fusionados en `main` (siempre que `VERSION` siga siendo la versión aprobada).
7. Comprueba desde ns2 (portada, DMG y ayuda, 200; la portada enlaza el DMG), lo apunta y avisa por correo.

Si algo no cuadra (firma, SHA-256, tamaño, portada), **no publica nada** y avisa (un correo por caso, no uno cada
10 minutos). Si GitHub no responde, lo intenta en la pasada siguiente.

## Qué tiene que hacer quien prepara la versión (LOCAL o NUBE)

En el PR de la web de cada versión, **antes de pedir la firma al HUMANO**:
- `FlyWeb/web/index.html`: botón, tamaño, SHA-256 y notas en `#novedades`;
- `FlyWeb/web/ayuda/…` si cambia algo;
- `FlyWeb/web/VERSION`, una línea: `<versión> <CFBundleVersion> <DMG> <sha256>`, por ejemplo
  `1.2 157.64.5 FlyWeb-1.2.dmg 5b5a0742…475d6b` (el SHA-256 del DMG subido a `updates/`).

Se puede fusionar antes o después de la firma: mientras `VERSION` no coincida con el appcast, la web no cambia; en
cuanto coinciden, se publica en ≤ 10 minutos. **Ojo:** con `VERSION` por delante del appcast, los cambios de la
ayuda tampoco se publican hasta la firma (el script publica siempre una web coherente con la versión aprobada).

## Instalar (SERVIDOR-LOCAL, desde un commit revisado de `main`)

HUMANO, una vez (el temporizador de usuario tiene que correr sin sesión abierta):
```sh
sudo loginctl enable-linger servidor
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

## Parar o quitar

`systemctl --user disable --now flyweb-web-auto.timer` (para; la web se queda como esté). Para quitarlo del todo,
además borrar `~/bin/flyweb-web-auto` y las dos unidades. Volver a una página anterior: copias en
`/var/backups/flyweb-web-*` (las hace `flyweb-desplegar`) o `flyweb-desplegar web <commit anterior> …`.

## Límite asumido

El texto se publica tal como está en `main`; lo que protege es que `main` solo cambia por PR revisado. El DMG, en
cambio, solo se publica si lo firmó bak (EdDSA) y su SHA-256 es el anunciado: un repo comprometido no puede hacer que
la web ofrezca un DMG que el HUMANO no aprobó.
