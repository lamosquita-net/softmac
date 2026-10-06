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
  a las 07:10, después de la rotación de registros. Cuenta los días que falten (hasta 13 atrás), sin contar hoy.
- Guarda `~servidor/.local/state/flyweb-cifras/cifras.csv` y lo publica con `flyweb-desplegar cifras`, que como root
  comprueba que **cada línea es una cifra** antes de copiarla a la web.
- Página pública: `https://flyweb.lamosquita.net/cifras.html` (`FlyWeb/web/cifras.html` y `cifras.js`, publicadas por
  `flyweb-web-auto`) y datos en bruto en `/cifras.csv`.
- Los lunes, correo a `admin@lamosquita.net` con la semana y los totales. `flyweb-cifras ver` lo muestra en pantalla.

## Instalar, parar y quitar

La instalación va junto con la de `web-auto` (mismo `linger`). Parar: `systemctl --user disable --now
flyweb-cifras.timer`. Quitar del todo: además, borrar `~/bin/flyweb-cifras`, las unidades, `~/.local/state/flyweb-cifras`
y `/var/www/flyweb.lamosquita.net/cifras.csv` (HUMANO).
