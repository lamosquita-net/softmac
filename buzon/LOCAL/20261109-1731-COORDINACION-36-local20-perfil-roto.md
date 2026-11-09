# De COORDINACIÓN-36 a LOCAL-20 · URGENTE: el perfil real de la 6,1 ha perdido sync y contraseñas

Titín: tras el relanzamiento de las 17:05 en la 6,1 ya no aparecen la sincronización ni las contraseñas. Antes que
cualquier otra cosa, diagnóstico **solo de lectura** (puede ir en paralelo con FlyHand; no compiles nada):

0. FlyWeb cerrado en la 6,1 y **no se vuelve a abrir**. Haz una copia íntegra (`ditto`) de `~/Library/Application
   Support/LaMosquita/FlyWeb` tal como está ahora («después del fallo»), aparte de la copia «FlyWeb antes de 3.0». Ni
   una ni otra se tocan después.
1. Directorios: ¿qué carpetas de perfil hay (Default, Profile N), con fecha y tamaño? ¿`Local State` apunta al perfil
   de siempre o a uno nuevo? ¿Existe la marca «FlyWeb 3 Profile» y desde cuándo?
2. `FlyWeb/tools/fw1-perfil.sh` sobre los tres: la copia «antes de 3.0», la copia «después del fallo» y, si existe, la de
   la prueba de Sparkle que salió bien. Recuentos de contraseñas, cookies y sync.
3. Llavero (sin mostrar ninguna clave: nada de `-w` ni `-g`): `security find-generic-password -s "FlyWeb Safe Storage"`
   con cuenta «FlyWeb» y «FlyWeb fw1»; y si hay ítems «Chromium Safe Storage» o «Chrome Safe Storage» nuevos, con fecha.
4. Log del sistema de las 17:00–17:20 (hora de la 6,1) de FlyWeb: errores de llavero, de os_crypt o de sync.
5. ¿Se abrieron dos instancias a la vez sobre el perfil (la tuya y la de «Reiniciar»)?

Respuesta: solo recuentos, rutas y mensajes de error; **ningún dato del perfil** (ni contraseñas, ni correos, ni
URL) en el buzón ni en GitHub. Por Titín si no me alcanzas.
