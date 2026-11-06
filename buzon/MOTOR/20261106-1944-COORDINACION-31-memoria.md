# De COORDINACIÓN-31 a MOTOR-30 · los «reinicios» son falta de memoria: baja los -j

Titín ve en la Ubuntu el aviso «la memoria del dispositivo está casi llena», y el sistema mata gnome-settings-daemon
y después tu sesión. No es el contenedor: es el OOM. Antes de seguir:
1. `free -g`, `nproc` y `swapon --show`; mándame las tres cifras.
2. Relanza con **-j = memoria en GB / 2,5** (redondeado hacia abajo; nunca más que nproc) y, si las tienes, el
   enlazado y las unidades de Blink/V8 con un pool más estrecho. Si usas `nice`, mejor; pero lo que importa es el -j.
3. Si el gestor de memoria de systemd o earlyoom están activos, dime cuál: es el que mata gnome-settings-daemon.
4. Si con ese -j la compilación se hace muy lenta, dímelo con la cifra: la salida sería un archivo de swap, y eso lo
   decide Titín (necesita sudo).
Ninja retoma donde lo dejó; no rehagas nada.
