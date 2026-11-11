# Maglev en la MacPro5,1

Mide la FlyWeb **instalada** en la 5,1, con el perfil de quien la usa: Speedometer 3.1 y JetStream 3 con Maglev de serie
y con `--js-flags=--no-maglev`, tres pasadas de cada uno. Es la condición 2 de B6 (`FlyWeb/docs/base-siguiente.md`;
`docs/DIRECTIVAS.md`, «Maglev»). Desde la 3.1, Maglev va encendido de serie. Si en la 5,1 pierde, se estudia para la 3.2.

## Cómo pasarlo (Titín, en la 5,1)

1. Ten a mano esta carpeta (`medir-maglev-51.command`, `fw51.html` y `srv51.py`, juntos) y los benchmarks:
   - si la 5,1 tiene montada la carpeta de red, el guion usa `entregas/bench-local`;
   - si no, copia esa carpeta junto al guion con el nombre `bench`.
2. Si hace falta, dale permiso de ejecución: `chmod +x medir-maglev-51.command`.
3. Haz doble clic en `medir-maglev-51.command`:
   - el guion cierra FlyWeb como con Cmd-Q y la abre dos veces seguidas, primero de serie y luego sin Maglev;
   - cada vez se abre una pestaña con una barra gris arriba que dice por dónde va;
   - **no toques el ratón ni el teclado mientras mide, y no bloquees la pantalla**: con la sesión bloqueada FlyWeb no
     pinta y la medida se para (el guion lo avisa);
   - tarda entre 1 y 1,5 horas.
4. Cuando el Terminal diga «Hecho», pulsa una tecla. FlyWeb queda cerrada y se puede volver a abrir.

Junto al guion queda `resultado-51-<fecha>.txt`:
- arriba, la CPU (en la 5,1 debe decir 0 AVX) y la versión de FlyWeb;
- al final, el RESUMEN con las medianas «serie» y «no-maglev», cuántas pasadas dieron número (p. ej. `3/3`), si hubo
  reaperturas y si hubo caídas.

El `.txt` no lleva el nombre de la cuenta: las rutas de la carpeta personal salen como `~` y el perfil, como «el de la
cuenta actual».

Además deja un `.json` por caso, con cada pasada. Basta con pasar el `.txt` a COORDINACIÓN o a LOCAL.

## Cómo funciona

- Sin CDP: desde Chrome 136, el depurador remoto no se activa con el perfil por defecto.
  - `srv51.py` sirve en 127.0.0.1 los benchmarks y `fw51.html`.
  - El guion abre FlyWeb con `open -a FlyWeb --args [--js-flags=--no-maglev] http://127.0.0.1:8127/fw51.html?caso=…`.
  - `fw51.html` pasa los benchmarks en un iframe del mismo origen y lee el resultado del DOM, igual que el conductor de
    la 6,1 y la 7,1 (`rendimiento-3x.md` §3.7). Lo manda a `srv51.py` tras cada pasada.
  - JetStream 3 avisa del fin de cada subprueba con `top.currentResolve`, como si fuera la ventana de arriba:
    `fw51.html` reenvía `currentResolve` y `currentReject` al iframe. Sin eso, la primera subprueba no acaba nunca.
- Comprueba en `ps` que el flag llega a FlyWeb y cuenta los volcados de Crashpad. Una caída del renderer sería, por
  ejemplo, un SIGILL por una instrucción AVX sin despacho (ver `rendimiento-3x.md` §3.8).
- Mantiene el equipo despierto con `caffeinate -dims` mientras dure y declara actividad (`caffeinate -u`) cada 20 s, que
  también aparta el salvapantallas: con la pantalla dormida o tapada, Chrome deja de pintar y Speedometer se para.
- **Pasada colgada:** la primera de cada benchmark tiene 1 h; las siguientes, 3 veces la mediana de las que acabaron
  (mínimo 10 min). Si una pasada se queda sin resultado, el guion cierra FlyWeb, la vuelve a abrir y la página sigue en
  la pasada siguiente con lo ya medido (`/previo`). Como mucho, 3 reaperturas por caso; cada caso tiene 4 h en total.
- **Pestañas restauradas:** cada apertura lleva un token `t` (la hora). La página avisa a `srv51.py` (`/hola`) y solo
  sigue la de la apertura más nueva (`/vigente`); `/resultado` rechaza los tokens viejos. Así, la pestaña de un caso
  anterior que FlyWeb restaure al abrirse ni mide a la vez ni pisa el resultado (pasó en la primera pasada de la 5,1:
  «serie» salía «SIN ACABAR» y «no-maglev» se colgaba).
- Si un cortafuegos (LuLu, Little Snitch) no deja a FlyWeb conectar con 127.0.0.1, el guion lo dice a los 3 minutos y
  pasa al caso siguiente.
- Solo usa lo que trae Mojave: bash, `open`, `osascript`, curl y `/usr/bin/python` 2.7.
- **Con el perfil real:** si FlyWeb restaura pestañas al abrirse, esas pestañas también cargan mientras mide. Para la
  medida más limpia, ciérralas antes.

## Pruebas

Variables: `FW_APP` (otra app), `FW_EXTRA` (flags extra; en pruebas, `--user-data-dir=/tmp/…` para no usar el perfil de
nadie), `PASADAS`, `BENCH_DIR`, `PY`, `PUERTO` y `FW_LIMITE` (límite en segundos de la primera pasada, para provocar
reaperturas). Probado en la 6,1 (Mojave, Python 2.7 de serie) con una copia de la app
y un perfil de prueba, nunca con el de Titín: ver el PR.
