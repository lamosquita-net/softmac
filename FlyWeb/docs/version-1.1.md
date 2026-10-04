# FlyWeb 1.1 — plan (NUBE, 04-10-2026)

**Qué es:** el primer nivel de motor nuevo (117). Por decisión del HUMANO, cada nivel sube el número menor (1.1, 1.2…),
no el tercero; la 1.0.2 que se había previsto para probar el actualizador **es esta 1.1**.

**Base:** `flyweb` 1fda577e (1.0.1) + brave-core `nube/motor-117` (pasos 46–49; LOCAL ya integró y probó 46–48) + softmac `build.sh`
de este PR.

## Qué trae respecto a la 1.0.1

| Paso | Cambio | Para el usuario |
|---|---|---|
| 46, 48 | Nivel 117: subgrid, `@starting-style`, `transition-behavior` (portado), `overlay`, `text-wrap: pretty`, `contain-intrinsic-size: auto none`, `light-dark()`, `Object.groupBy`/`Map.groupBy`, con los arreglos que Chrome 117 llevaba; **declara Chrome 117**. Probado por LOCAL: 14/14 y WPT 238/240 (= Chrome 117) | Webs que usan CSS de 2023 se ven como en Chrome 117 |
| 47, 48 | **Sin excepciones por sitio:** Google también ve 117 (antes, 153); el código de la anulación ya no está | Gmail puede volver a mostrar la barra azul de navegador antiguo; funciona igual. Es lo decidido: se ve qué webs aceptan el nivel real |
| 47 | Versión de FlyWeb visible (1.1) en Información, Finder y el menú de Ajustes | Ya no pone «1.57.64» |
| 47 | DNS seguro apagado por defecto (F2.7) | Usa el DNS del sistema; sin consultas a `dns.google` ni Cloudflare |
| 47, 49 | Enlaces de ayuda a `flyweb.lamosquita.net/ayuda/`; código fuente al nuestro; «Informar de un sitio roto» sin Brave (F1.14) | Ningún enlace lleva a Brave; nada se envía a `webcompat.brave.com` |

## Orden de trabajo (LOCAL salvo donde se dice)

1. **Integrar** `nube/motor-117` en `flyweb` (merge «paso 49») y este PR de softmac (o `main` cuando se fusione).
2. **Compilar:** `FLYWEB_BUILD_NUMBER=2 FlyWeb/scripts/build.sh Release` → «Actualizaciones: activadas (… 157.64.2)».
   - Si `apply_patches` falla en algún `patches/third_party-blink-*` (48, 49) o en `patches/v8/` (46), pasar el error a
     NUBE. Si falla la compilación de Blink, el fichero que falla indica el paso: `animation/` o `css/` → 48;
     `layout/ng/grid/` o `layout/ng/inline/` → 49.
3. **Comprobar el `.app`:** `CFBundleShortVersionString` = `1.1`, `CFBundleVersion` = `157.64.2`, `SUPublicEDKey`
   igual que `clave-publica.txt`; `check-no-avx.sh` limpio.
4. **Pruebas** en la 7,1 y la 6,1, con perfil nuevo y con el de la 1.0.1:
   1. `FlyWeb/tools/motor-117.html` (abrir el fichero): todo «ok» salvo, si acaso, la última (client hints en
      `file://`). Las WPT enlazadas: anotar «X de Y» en FM.1, junto al resultado de la 1.0.1.
   2. Gmail, Drive y Docs: `navigator.userAgent` dice `Chrome/117` (como `https://example.com`). **Anotar** si sale la
      barra azul de navegador antiguo y si todo funciona igual (`compatibilidad.md` §5). Vista previa de impresión de
      una página con rejilla (p. ej. un Google Doc) sin cuelgues.
   3. Información: «1.1 (motor 117) · Brave 1.57.64 · Chromium: 116.0.5845.188»; el enlace de código fuente lleva a
      `lamosquita-net/brave-core/tree/<commit de flyweb-build-info.txt>`. Ayuda → Ayuda de FlyWeb abre nuestra web.
   4. Menú → «Informar de un sitio roto» abre `flyweb.lamosquita.net/ayuda/#informar` (sin formulario de Brave).
   5. DNS: Ajustes → Privacidad → «Usar DNS seguro» apagado en perfil nuevo; NetLog sin `dns.google` ni
      `cloudflare-dns.com`. En el perfil de la 1.0.1 sigue como estaba.
   6. `strings` del binario y los `.pak` sin `support.brave.com`, `community.brave.com` ni `github.com/brave`
      (puede quedar texto de código no visible: anotar lo que salga).
   7. Auditoría de red completa: 0 peticiones a `*.brave.com`, `*.bravesoftware.com`, `*.brave-http-only.com`.
   8. claude.ai completo (criterio de aceptación), YouTube, una web de noticias: sin cosas raras con el CSS nuevo.
5. **Firmar, notarizar, DMG** (`FlyWeb-1.1.dmg`), subir a ns2 y a la web.
6. **HUMANO, en bak:** aprobar `<sha256>  157.64.2  # FlyWeb 1.1` y firmar con `--version 157.64.2 --visible 1.1`.
7. **La prueba del actualizador:** en la 6,1 con la **1.0.1** instalada, `flyweb://settings/help` → encuentra la 1.1,
   la descarga, pide reiniciar y tras reiniciar Información dice 1.1. Si falla, Console.app filtrando por «Sparkle».

## Antes de publicar (HUMANO / LOCAL, web)

- **W8, `/ayuda/`** (`web-flyweb.md`): aunque sea una sola página con los títulos de las anclas que usa el navegador.
  Sin ella, los enlaces llevan a un 404.
- Página de descarga con la 1.1 y sus novedades (`/descargas/#novedades`, al que enlaza Información).
