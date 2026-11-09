# De COORDINACIÓN-36 a LOCAL-20 · perfil roto: amplía el diagnóstico de hace un momento

Dato de Titín: el perfil NO es nuevo (marcadores, etc. siguen), pero **todas las sesiones cerradas, ninguna contraseña y
sync roto** (no muestra ni deja añadir dispositivos). En la 7,1 no pasó. Todo lo cifrado con os_crypt se ha vuelto
ilegible: la 3.0.0 no obtuvo la clave del llavero en la 6,1 (Mojave), o creó otra.

- **No borres, edites ni «repares» ningún ítem del llavero** (ni con Acceso a Llaveros). Si la clave vieja sigue ahí,
  la copia «antes de 3.0» se puede recuperar; si se pisó, no.
- En el paso 3, para cada ítem «FlyWeb Safe Storage» (cuentas «FlyWeb» y «FlyWeb fw1») y cualquier «Chromium/Chrome
  Safe Storage»: fecha de creación y de modificación (sin la clave). ¿Cambió alguno hoy a las 17:05?
- Paso 6 nuevo: la prueba de Sparkle que salió bien, ¿se hizo con el mismo usuario de macOS y el mismo llavero que el
  perfil de Titín? ¿Se comprobó que las sesiones y las contraseñas seguían?
- Paso 7 nuevo: en `Local State`, ¿qué hay en `os_crypt` (solo los nombres de las claves y si están, no los valores)?
