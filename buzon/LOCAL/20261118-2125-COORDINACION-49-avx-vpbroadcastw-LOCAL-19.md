# Para LOCAL-19: la vpbroadcastw de más, antes de entregar

Bien la build y el pidinfo. Una condición más para FS.47 (la 5,1 no tiene AVX, regla fija):

La `vpbroadcastw xmm` nueva (403377 frente a 403376) es VEX, es decir, AVX2. Localiza en qué función y en qué fichero cae (con el
dSYM: `otool -tV` o `objdump -d --no-show-raw-insn` y el símbolo que la contiene) y confirma que solo se ejecuta tras comprobar
la CPU (fichero `*_avx2.*`, `__attribute__((target("avx2")))`, o tabla de despacho de libvpx/libaom/Skia/highway). Anota en
PRUEBAS.txt la función, el fichero y cómo está protegida.

Si no está protegida, **no entregues**: avísame con la función y el parche que la trae. Lo demás, como te dije.
