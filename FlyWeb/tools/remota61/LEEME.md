# Pruebas remotas en la MacPro6,1

Sirve para probar una compilación en la 6,1 (macOS 10.14, FirePro D500) sin moverse de la máquina que compila, y sin parar la compilación. Vale para B1d, para la 3.0.0 y para F1.

```bash
FW61=<destino ssh> FW61_OPCIONES="<opciones ssh>" FW_QUIEN=local19 \
  zsh FlyWeb/tools/remota61/prueba-remota.sh <zip con la .app> <etiqueta> gpu motor138
```

- **Qué hace.** Copia el zip a la 6,1 y lo descomprime allí. Lanza la app con un perfil nuevo en `/tmp` y abre un túnel de DevTools. Pasa las pruebas por CDP desde aquí y cierra la app. Trae a `resultados-61/<etiqueta>.txt`:
  - las cifras;
  - las capturas;
  - el recuento de caídas: MTLCompilerService, navegador y ayudantes, reinicios de la GPU, contextos perdidos, `unrecognized selector`, `Check failed`, y pipelines o librerías Metal fallidas;
  - los errores más repetidos.
- **Pruebas.**
  - `gpu`: la batería de `FlyWeb/docs/pruebas-gpu.md`.
  - `motor138`: `FlyWeb/tools/motor-138.html`, servida en la propia 6,1 desde `http://127.0.0.1:9492`. Da cuántas líneas salen ok y cuáles FALLO.
  - `gpuinfo`: el resumen de `chrome://gpu`.
  - Pruebas sueltas de la batería por su número, como `3a` o `9`.
- **M1 del llavero** (`brave-propio.md`): con `FW_LLAVERO=1`, la app se lanza sin `--use-mock-keychain` y se cuentan los ítems «FlyWeb / Chromium / Chrome Safe Storage» del llavero antes y después.
  - Con `FW_PERFIL=<ruta en la 6,1>` se usa una copia de un perfil envejecido; el original no se toca.
  - Resultado esperado: no aparece ningún «Chromium Safe Storage» ni «Chrome Safe Storage», y el número de «FlyWeb Safe Storage» no cambia.
- **Reglas de la 6,1.**
  - Una sesión SSH por paso, nunca dos a la vez.
  - No lanza nada si hay un Chromium o FlyWeb abierto.
  - Espera su turno mientras exista otro `/tmp/*-61-en-uso` o el puerto esté ocupado, y crea el suyo, `/tmp/<FW_QUIEN>-61-en-uso`.
  - Cierra todo lo que lanza.
- **LuLu.** Cada binario nuevo sin firmar se queda sin red hasta que se aprueba en la 6,1. El guion lo avisa una vez y espera, sin relanzar.
- **Nada de datos de acceso en el repo.** El destino y las opciones de ssh solo van en el entorno de quien lo lanza.
- **Requisitos.** `bateria.py` solo usa la biblioteca estándar de Python 3, en la máquina que lanza. En la 6,1 basta con lo que trae Mojave (`ditto`, `security`, `python` para servir la página).
