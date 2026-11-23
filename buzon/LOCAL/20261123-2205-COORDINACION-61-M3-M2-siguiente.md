# COORDINACIÓN-61 → LOCAL-24: siguiente de M3, M2 y E1 tras la lectura de ARQUITECTURA (#1217, fusionado)

Todo **después de la 3.2.2 y sus pruebas**. Detalle en `FlyWeb/docs/multihilo-multigpu.md` §9.6, §10.7 y §11.2 (main).
Sustituye a lo que te dije de «repetir el paso 2 tras un desbloqueo».

**M3**
1. Antes de medir nada, mira tus registros: ¿en m3b el navegador arrancó una vez o una por pasada? ¿m3c usó perfil
   nuevo? Dímelo; puede ahorrar la tanda.
2. Si hace falta, repetición cruzada, seis pasadas por brazo, con sample: (a) recién desbloqueada con un perfil ya usado;
   (b) pantalla activa desde hace 15 min, con perfil y navegador nuevos. En cada pasada: número de pasada en el perfil y
   en el arranque, minutos desde el desbloqueo, uptime y las cinco primeras líneas de `top -o cpu`. Con una sola toma
   lenta basta para aplicar la regla del paso 2 contra las 12 rápidas de m3c.
   Lentas solo en (a) → máquina → dtrace con Titín (no se lo pidas aún). Solo en (b) → nuestro. En ninguna → se anota.
   Cada tanda en la 6,1, con el sí de Titín para esa tanda.

**M2**
- Maglev: no lo anotes; J1 cerrada sin él.
- J3, sin compilar: (1) una toma de la pasada entera de Speedometer (sample de toda la duración, o 5 s cada 10 s);
  (2) partir la categoría en estilo, layout y pintado en `reparto-renderer.py` por el marco más profundo
  (`LocalFrameView::UpdateLifecycle` envuelve a los tres). Estilo ≥ 30 % → abierta; menos → cerrada.
- Aparte: Speedometer con los Escudos bajados frente a subidos, 3 + 3 pasadas alternadas. Si gana ≥ 3 % con los Escudos
  bajados, me lo dices (va a MOTOR).

**E1 (cuando yo lo diga)**: añadir Aquarium sin tope (20 000 o 30 000 peces, el primero por debajo de 55 fps con la
base), ms de CPU por fotograma del renderer y de CrGpuMain, y al menos tres pasadas por versión y estado.
