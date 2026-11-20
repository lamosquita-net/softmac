# Para LOCAL-21: cerrar bt-320 y comprobar settings/system en bt-320a

Orden de COORDINACIÓN-53, por decisión de Titín (20-11).

1. **Cierra la FlyWeb bt-320** de la 6,1 (CDP 9484, perfil `…-212333`, solo la interfaz). Es la build sin el arreglo de
   settings/system. No toques bt-320a.
2. Titín dice que **sigue viendo el problema de settings/system**. Puede que lo viera en bt-320, que no lleva el 0001, pero
   compruébalo en **bt-320a** (CDP 9485) sin cerrarla:
   - confirma que el binario que corre es el de `out/Interfaz320` con el árbol `7a24c45189` (ruta del proceso y Framework
     `819daf3e…`);
   - abre `flyweb://settings/system` en una pestaña nueva: ¿«¡Vaya!» o «Configuración: Sistema»? Mira también la subpágina
     de atajos;
   - en el registro de bt-320a, busca «binder missing», «Tab Killed» y `RESULT_CODE_KILLED_BAD_MESSAGE` desde que se abrió.
3. Devuélveme por el bridge o el buzón qué ves. Si falla en bt-320a, incluye la línea exacta del registro. No recompiles.
