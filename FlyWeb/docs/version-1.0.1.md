# FlyWeb 1.0.1 — plan (NUBE, 04-10-2026)

**Base:** `flyweb` **1fda577e** (pasos 37–45 integrados y probados por LOCAL el 04/10, con el arreglo
`local/traducir-include` del 39). Primera versión que **se actualiza sola**; la 1.0 hay que sustituirla a mano una vez.

## Qué trae respecto a la 1.0

| Paso | Cambio | Para el usuario |
|---|---|---|
| 37 | H.264 por defecto (VP9/AV1 no se anuncian) | YouTube fluido en la 6,1: CPU de la pestaña ~100 % → ~12 % |
| 38 | D-DIN en todas las páginas internas | Tipografía del diseño también en Ajustes, historial… |
| 39 | Traducir apagado por defecto; si se activa, directo a Google | Ya no se ofrece sola ni va a `translate.brave.com` |
| 40 | Extensiones de la Chrome Web Store directas de Google | **Se pueden instalar extensiones** (en la 1.0, «acceso denegado») |
| 41+42 | Sincronización propia («FlyWeb Sync»), sin móvil ni QR | Contraseñas y marcadores entre los tres Mac (con el servidor en ns2) |
| 44 | `flyweb://` también en las cadenas de Chromium | Sin `chrome://` en textos y enlaces |
| 45 | Actualizaciones automáticas desde `updates.flyweb.lamosquita.net` | A partir de aquí, las versiones llegan solas |

## Orden de trabajo

### 1. Clave de actualizaciones (HUMANO, en bak) — bloquea todo lo demás

Pasos en `FlyWeb/servidor/actualizaciones/README.md`, «Instalación en bak». Descargar del commit `eaa329f` (o
posterior) y comprobar:

```
0587988b97bbfeff448b905ec566dfcc871cec76cc681b100755689f8b0c23ab  firmar-actualizacion.mjs
```

`generar-clave` imprime **solo la clave pública** (44 caracteres terminados en `=`). Pasársela a NUBE (o a LOCAL), que
la pone en `FlyWeb/servidor/actualizaciones/clave-publica.txt` con un PR. Copia de seguridad cifrada de la privada:
**sin ella, ninguna FlyWeb instalada aceptará actualizaciones nuevas.**

### 2. ns2 (LOCAL con permiso del HUMANO)

- `install -d /var/www/FlyWeb/updates/stable` (root 0755).
- Línea de `authorized_keys` para la subida desde bak restringida a `/var/www/FlyWeb/updates` (README de
  actualizaciones, «Subida a ns2»), y el alias `ns2-updates` en `~flywebfirma/.ssh/config` de bak.
- **Sincronización (recomendado antes de compilar):** instalar `flyweb-sync` siguiendo
  `FlyWeb/servidor/sync/README.md`, «Instalar en ns2». Binario de la release `flyweb-sync` del repo, SHA-256
  `6b690b21467c3637b9e655a72c7888585aca974270d330c460876c3872b0007c` (comprobar también el `.sha256` publicado). Sin
  servidor, la 1.0.1 funciona igual, pero «Sincronizar» falla al crear la cadena.
- Si se abre la sincronización a otros usuarios: antes, privacidad actualizada en la web (`web-flyweb.md` §2) y
  `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`. Mientras solo la use el HUMANO, no hace falta.

### 3. Compilar (LOCAL)

```sh
FLYWEB_BUILD_NUMBER=1 FlyWeb/scripts/build.sh Release
```

Debe imprimir «Actualizaciones: activadas (FlyWeb build 1, CFBundleVersion 157.64.1)». Si dice «SIN actualizaciones
automáticas», falta `clave-publica.txt` en el commit de softmac: **parar**.

Comprobar en el `.app`, antes de firmar:
- `defaults read …/FlyWeb.app/Contents/Info CFBundleVersion` → `157.64.1`
- `defaults read …/FlyWeb.app/Contents/Info SUPublicEDKey` → igual que `clave-publica.txt`
- `Contents/Frameworks/FlyWeb Framework.framework/…/Sparkle.framework` existe
- `check-no-avx.sh` limpio

### 4. Firmar, notarizar, DMG (LOCAL)

Como la 1.0 (`herramientas/firmar-flyweb.sh`, `publicar-flyweb.sh`). Sparkle.framework queda dentro de la app y se
firma con ella, de dentro hacia fuera. DMG: `FlyWeb-1.0.1.dmg`.

### 5. Pruebas antes de publicar (LOCAL; el HUMANO las de ventana)

En la 7,1 y en la 6,1 (Mojave), con perfil nuevo y con el perfil de la 1.0:

1. **Arranque y firma:** `spctl -a -t exec -vv` → `Notarized Developer ID`; arranca sin aviso de llavero nuevo.
2. **Perfil de la 1.0:** marcadores, contraseñas e historial siguen ahí tras instalar la 1.0.1 encima.
3. **YouTube 1080p en la 6,1:** `flyweb://media-internals` → `avc1`; CPU de la pestaña ~12 %.
4. **Extensiones (HUMANO):** instalar una desde la Chrome Web Store.
5. **Traducir:** no se ofrece solo; activado en Ajustes, traduce una página en inglés; NetLog sin `translate.brave.com`.
6. **D-DIN** en Ajustes e historial; **`flyweb://`** en textos (p. ej. `flyweb://version`).
7. **Actualizador:** `flyweb://settings/help` ya no dice «desconectado» (dirá que está al día o que no encuentra el
   appcast, según el paso 6). NetLog: una petición a `updates.flyweb.lamosquita.net/stable/appcast.xml`, ninguna a
   `updates.bravesoftware.com`.
8. **Sincronización** (si el servidor está en ns2): «Prueba con FlyWeb» de `FlyWeb/servidor/sync/README.md`.
9. **Contraseñas, fase 1** (datos falsos): `FlyWeb/docs/contrasenas.md`.
10. **Auditoría de red** completa (`network-audit.py`): 0 peticiones a `*.brave.com`, `*.bravesoftware.com`,
    `*.brave-http-only.com`.

### 6. Publicar

1. DMG a ns2: `/var/www/FlyWeb/updates/FlyWeb-1.0.1.dmg` **y** a la web (`descargas/`, con su `-sha256.txt`), que
   es donde la bajarán a mano los que tengan la 1.0.
2. SHA-256 al HUMANO → aprobación y firma en bak (README de actualizaciones, «Publicar una versión», paso 7).
3. `curl -s https://updates.flyweb.lamosquita.net/stable/appcast.xml` muestra la 1.0.1.
4. La 1.0.1 instalada encuentra el appcast y dice que está al día (la prueba de verdad del actualizador llegará con
   la 1.0.2: desde la 1.0.1 debe bajarla e instalarla sola al reiniciar).
5. Página de descarga: versión 1.0.1 y nota de que la 1.0 no se actualiza sola.
6. `integracion.md`: «1.0.1 = `flyweb` <commit>»; `TAREAS.md`: F0.8.

## Después (1.0.2, para probar el actualizador)

Una versión pequeña (aunque sea solo con el número cambiado, `FLYWEB_BUILD_NUMBER=2`) para comprobar el ciclo entero
en la 6,1: la 1.0.1 la encuentra, la descarga, la verifica (firma EdDSA + Developer ID) y la instala al reiniciar.
