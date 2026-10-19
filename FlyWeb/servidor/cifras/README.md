# Cifras de FlyWeb

Decisión del HUMANO (06-10-2026): saber aproximadamente cuántos usan FlyWeb **sin tocar la privacidad**. No se recoge
nada nuevo y el navegador no envía nada: se cuenta en registros que ya existen y se guarda solo «fecha, tipo, versión,
número».

| Cifra | De dónde | Qué significa |
|---|---|---|
| `web` | Registro de `flyweb.lamosquita.net` (ya existe, con IP, 14 días; declarado en la privacidad) | Descargas completas (`GET`, 200) de `descargas/FlyWeb-*.dmg`, sin robots ni `curl` |
| `act` | Registro de `updates.` (sin IP) | Descargas completas de `FlyWeb-*.dmg` por la actualización automática: cada Mac baja cada versión una vez, así que es la mejor aproximación a cuántos FlyWeb están en uso |

**No se cuentan** las consultas al appcast (cada 3 h): distinguir un navegador de otro exigiría un identificador.
Son descargas, no personas.

## Cómo funciona

- `flyweb-cifras diario`, en ns2 como `servidor` (grupo `adm`, que lee los registros), con un temporizador de usuario
  cada hora (a y 7; desde el 07-10). Cuenta los días que falten (hasta 13 atrás) y vuelve a contar ayer y hoy en cada
  pasada: una versión nueva sale en las cifras en menos de una hora tras sus primeras descargas.
- Guarda `~servidor/.local/state/flyweb-cifras/cifras.csv` y lo publica con `flyweb-desplegar cifras`, que como root
  comprueba que **cada línea es una cifra** antes de copiarla a la web.
- Página pública: `https://flyweb.lamosquita.net/cifras.html` (`FlyWeb/web/cifras.html` y `cifras.js`, publicadas por
  `flyweb-web-auto`) y datos en bruto en `/cifras.csv`.
- Los lunes, correo a `admin@lamosquita.net` con la semana y los totales. `flyweb-cifras ver` lo muestra en pantalla.

## Sin la oficina y con IP distintas (solo en la web; 19-10-2026, por orden del HUMANO vía COORDINACIÓN)

- **Qué es nuevo.** En la web (el único registro con IP) `flyweb-cifras` **no cuenta las descargas de la oficina** y cuenta,
  además, **cuántas IP distintas** hubo por día y versión. Las IP se cuentan en memoria y se descartan: no se imprime ni se
  guarda ninguna. En `updates.` **no se puede hacer ninguna de las dos cosas**: su registro va sin IP a propósito (promesa de
  privacidad). Por eso el correo avisa de que «actualizaciones» incluye los Macs de la oficina.
- **Dónde vive la IP de la oficina: solo en ns2, nunca en el repo.** El nombre de host a excluir está en
  `~servidor/.config/flyweb-cifras/oficina` (un nombre por fichero, 0600; lo crea SERVIDOR-LOCAL en ns2, **fuera del repo**: ni
  el host ni la IP van a GitHub, a commits, a PR ni a este README). En cada pasada `diario` el script lo resuelve y anota
  «segundos IP» en `~servidor/.local/state/flyweb-cifras/oficina.hist` (0600, 14 días, nunca publicado). Una línea del registro
  de la web no cuenta si su IP está anotada en ese historial a ±90 minutos de la hora de la petición. Sin fichero de
  configuración no se excluye nada (el comportamiento de antes). **Límite:** el historial empieza el día que se instala; las
  descargas anteriores no se pueden descontar. Si la IP cambia y el nombre tarda en actualizarse, puede colarse alguna.
- **IP distintas.** `~servidor/.local/state/flyweb-cifras/ip.csv` (`fecha,webip,dmg,ips`, 0600, **nunca publicado**; no pasa por
  `flyweb-desplegar` ni lo lee `cifras.js`). El correo de los lunes añade, junto a las descargas, la suma de las IP distintas de
  cada día de los últimos 7 días (solo el número; es una cota superior de personas: la misma IP en dos días cuenta dos veces).
- **Registros rotados.** `leer()` lee `.1` a `.9` sin comprimir (como están en ns2) y `.gz` si los hubiera; antes solo leía
  `.2.gz` y `.3.gz`, que no existen.
- **Filtro de robots y descargas.** Igual que antes (GET con 200 a `/descargas/FlyWeb-*.dmg`, sin `bot|crawl|spider|curl|wget|python`),
  ahora en un pequeño Python con `-I` (el mismo que usan los guiones de PUBLICACIÓN).

## Instalar, parar y quitar

La instalación va junto con la de `web-auto` (mismo `linger`). Parar: `systemctl --user disable --now
flyweb-cifras.timer`. Quitar del todo: además, borrar `~/bin/flyweb-cifras`, las unidades, `~/.local/state/flyweb-cifras`
y `/var/www/flyweb.lamosquita.net/cifras.csv` (HUMANO).
