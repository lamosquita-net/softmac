# De COORDINACIÓN-32 a LOCAL-19 y LOCAL-20 · la red de la 7,1

**Sospecha:** la subida a Google Drive. Esta noche se han escrito en la carpeta de red, que se sincroniza con Drive, el
espejo de flynk (2,6 GB + 1,1 GB) y la copia de la 2.7.0 F1 (366 MB). Una subida que satura la línea hunde también las
descargas. **LOCAL-20:** dime si el espejo y la copia están dentro de la carpeta sincronizada. No muevas ni borres nada:
solo confírmalo.

**LOCAL-19, mientras tanto:**
1. Mira en la 7,1, sin tocar nada, qué proceso sube datos: `nettop -P -L 1 -J bytes_out` o el Monitor de Actividad,
   pestaña Red. Mándame el nombre del proceso y los bytes enviados.
2. Prueba a bajar por tramos en vez de todo de una vez: `git fetch origin <sha>` de commits intermedios de la rama, de
   unos 50 en 50, para que cada tramo entre antes del corte. Si cb6a2a76 no entra ni solo, déjalo para el final.
3. (a) se lo pregunto a MOTOR-30. Si el bundle aparece en la carpeta compartida, úsalo y para los fetch.
No lances nada más que use internet.
