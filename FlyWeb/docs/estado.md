# FlyWeb — estado a 04-10-2026 (NUBE)

## FlyWeb 1.0 (publicada por LOCAL el 04-10)

- **Qué es:** Release oficial de `flyweb` **955352ec** (Brave 1.57.64 = Chromium 116.0.5845.188), x86_64, sin AVX.
  Firmada con el Developer ID **G2** y notarizada; Mojave 10.14.6 la acepta (`Notarized Developer ID`) y arranca en
  5 s. DMG con el fondo del HUMANO (`software/entregas/FlyWeb-1.0/FlyWeb-1.0.dmg`, sha256 2b932fc5…).
- **Lleva** los pasos 0–36, 36b y 43 de `integracion.md`: marca FlyWeb (iconos, nombre, `flyweb://`), pestaña nueva
  y bienvenida propias, Escudos con listas propias firmadas en bak, componentes desde ns2 (y espejo de los de Google),
  Wallet/Rewards/News/Talk/VPN/Leo/P3A fuera, nada pasa por proxies de Brave, sin portal cautivo, parches de seguridad
  portados (fugas del sandbox de ANGLE, Skia y viz; V8; libvpx; WebRTC; CSS; Loader), WebGPU apagado, JIT solo en la
  lista de confianza. Auditoría de red de la Release: **0 peticiones a Brave**.
- **No lleva** (integrados después en `nube/*`, pendientes de LOCAL): 37 H.264 por defecto (YouTube fluido en la 6,1),
  38 D-DIN en todas las páginas, 39 Traducir apagado y sin Brave, 40 extensiones de la Web Store, 41+42
  sincronización, 44 `flyweb://` en las cadenas de Chromium, 45 actualizaciones.

### Fallos conocidos de la 1.0

| Qué | Por qué | Arreglo |
|---|---|---|
| **«Actualizador desconectado»** | `build.sh` apagaba Sparkle y el código miraba el appcast de Brave | Paso 45 + clave en bak (F0.8). **La 1.0 no se actualiza sola**: la 1.0.1 se instala a mano una vez |
| **No se pueden instalar extensiones** de la Chrome Web Store («acceso denegado») | La URL de extensiones era la de nuestro servidor de componentes, que exige clave | Paso 40 |
| **Traducir** viene ofrecido y, si se usa, va a `translate.brave.com` con nuestra clave de servicio | Código de Brave | Paso 39 (apagado por defecto; si se activa, directo a Google) |
| **YouTube en la 6,1** con la CPU al ~100 % | YouTube sirve AV1, que la D500 no decodifica por hardware | Paso 37 (H.264: ~12 %) |
| **Sin sincronización** (Sincronizar oculto) | Paso 25 lo apagó; faltaba servidor | Pasos 41+42 y servidor en ns2 |
| **Safe Browsing** sin listas | ns2 sale a Google por IPv6 y la clave solo admite la IPv4 | HUMANO: añadir la IPv6 a la clave en Google Cloud (F2.6) |
| Algunos textos dicen `chrome://` | Cadenas de Chromium | Paso 44 (las de brave-core); el resto, pasada de l10n |

## Servicios (ns2 y bak)

| Servicio | Estado |
|---|---|
| `components.` (go-update + listas firmadas en bak + espejo de Google) | **En producción**, 15 componentes, firma diaria |
| `proxy.` (Safe Browsing, descargas, diccionarios) | **En producción**; Safe Browsing espera el cambio de IP de la clave |
| `updates.` | Vhost en producción; **falta** la clave EdDSA en bak y el primer appcast (F0.8) |
| `sync.` | Servidor hecho y probado (`FlyWeb/servidor/sync`, binario en la release `flyweb-sync`); **falta instalarlo** |
| `flyweb.lamosquita.net` (web) | Vhost en producción; páginas W1–W7 por hacer (`web-flyweb.md`), privacidad antes de abrir `sync.` a otros |

## Contraseñas

- **Sin probar.** Protocolo escrito en `contrasenas.md`: el importador de la 116 acepta el CSV de Apple tal cual,
  pero solo hasta 150 KB por fichero (script para partirlo); exportar e importar dentro de un disco en RAM.
- Fase 1 (LOCAL, ya, con la 1.0): prueba con datos falsos. Fase 2: migración real en la 7,1. Fase 3: sincronizar a
  los Mojave (necesita 41+42 y el servidor).

## Siguiente, por orden

1. **LOCAL:** integrar 37–45 (41+42 juntos; el 44 lleva el 42) y compilar la **1.0.1** con `FLYWEB_BUILD_NUMBER=1`
   cuando esté la clave de actualizaciones. Fase 1 de contraseñas.
2. **HUMANO:** IPv6 en la clave de Safe Browsing; clave EdDSA en bak (`actualizaciones/README.md`); instalar
   `flyweb-sync` en ns2 (o dar permiso a LOCAL).
3. **NUBE:** `clave-publica.txt` en cuanto llegue; lo que salga de las pruebas de LOCAL.
4. **Diseños del HUMANO** (F7.2, F7.4, F7.6): páginas internas, perfiles.
5. **Mantenimiento:** `cve-watch.py` cada semana (hoy, 0 sin triar); parches de seguridad según `cve-triage.md`.
