# Para «Local (22)»: pruebas de la 3.2.1 (#1165 + #1171) antes de compilar (COORDINACIÓN-59)

COORDINACIÓN-59 releva a la 58 desde el 21-11 ~22:55 UTC. Contenido de la 3.2.1 decidido por Titín (DIRECTIVAS #1182):
**#1165** (seguridad `siguiente/`) y **#1171** (más visitados de la nueva pestaña). Nada más. Lo rojo se quita.
Todavía **no** es la compilación final: versión y build los da Titín cuando todo esté en verde.

1. **Fuentes** (comprobadas con `git ls-remote`, 22:57 UTC):
   - #1165: rama `claude/seguridad-portes-33-siguiente`, punta **51d8f94d45** (`FlyWeb/seguridad/siguiente/`).
   - #1171: rama `claude/motor47-ntp-mas-visitados`, punta **1dff7b4353**.
2. **Montaje sobre la 3.2.0 publicada** (`local/320g-final`):
   - chromium: **68861cb878** (con renderer-webgl) + `siguiente/chromium` 0001–0010 → **e6aa9fedc5**. Árboles intermedios en
     `buzon/COORDINACION/20261121-2246-SEGURIDAD-PORTES-33.md` §1.
   - brave-core: árbol de la 3.2.0 antes de la versión **02c6111221** → `siguiente/brave-core` 0001–0003 (e324bbe493 →
     31704acc36 → ca13e3d45e) → #1171 0001 → **af99cc3984** (sin el commit de la versión; MOTOR-47,
     `buzon/COORDINACION/20261121-2242-MOTOR-47.md`). `patches/v8` **a4c9a44d28**, V8 **c8e7b3da27** (D8-LINUX, verde;
     época 38 → 39).
   Si algún árbol no cuadra, para y avísame.
3. **Pruebas sin ventana, en la 7,1** (lista de SEGURIDAD-PORTES-33, §2 del mismo fichero):
   - `blink_unittests --gtest_filter='*Event*Target*:*PseudoElement*:ScriptedAnimationControllerTest.*'` (0001 y 0008);
   - `media_unittests --gtest_filter='HlsDataSourceProvider*'` (0002);
   - `components_unittests --gtest_filter='VariationsServiceTest.*'` (0003);
   - la cctest de V8 que ya corre con la época, y las de #1171 que traiga su README.
4. **Con ventana, solo en la 6,1** (#1176; `pgrep -fl Chromium` antes, perfil y puerto propios, las ventanas de Titín no se tocan):
   - `views_unittests` de menús 0009–0010 con el filtro de SEGURIDAD-PORTES-33;
   - una sola tanda de `run_web_tests.py` con las 8 pruebas de §2 (la orden completa está en el fichero);
   - en la build: un vídeo HLS `.m3u8`; soltar un enlace en una carpeta de marcadores, repetir con Esc, abrir y cerrar menús;
     la nueva pestaña enseña los más visitados (webs de prueba de siempre: elpais.com, eldiario.es, youtube.com, wikipedia).
5. **Compilar:** hoy sábado y mañana domingo, al máximo sin preguntar; desde el lunes 23, pregúntale antes a Titín.
   `ps` antes de `build.sh` (una compilación a la vez). Tras cada SEGV o timeout, `pgrep -fl _unittests`.
6. **Resultado:** por escrito en `buzon/COORDINACION/` (puntas, árboles, cada prueba en verde o rojo; distingue lo visto en
   pantalla de lo comprobado por código) y avísame por `SendMessage` a «Coordinación (59)». Con todo en verde fusiono #1165 y
   #1171 y pido a Titín versión y build.

Todo en español; commits en inglés.
