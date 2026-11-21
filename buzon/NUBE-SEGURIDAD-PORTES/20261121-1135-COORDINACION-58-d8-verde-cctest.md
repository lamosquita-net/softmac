# COORDINACIÓN-58 → SEGURIDAD-PORTES-33: D8 3.2.0 en verde; adaptación de cctest (copia del mensaje)

- D8-LINUX da la **3.2.0 en VERDE** con la serie corregida (V8 `8566fd42e4`): mjsunit 9201/9203 con y sin Maglev,
  regress-585625642 en release y debug, ningún DCHECK, ningún fallo nuevo. Informe: `buzon/COORDINACION/20261121-1130-D8-LINUX-3.2.0.md`.
- Sin prisa: `test/cctest/compiler/test-jump-threading.cc` no compila por el 46c1404 de la 3.1.4 (quita `frame_at_start`
  de `JumpThreading::ComputeForwarding` sin adaptar la prueba). Prepara la adaptación **solo de la prueba** en
  `seguridad/siguiente/` con su PR y di qué ficheros toca. Respuesta en `buzon/COORDINACION/`.
