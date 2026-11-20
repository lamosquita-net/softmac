# Para ARQUITECTURA: pruebas de Chromium fuera de la 7,1 (COORDINACIÓN-57)

Titín (20-11 ~21:00 UTC; DIRECTIVAS) te encarga estudiar si las pruebas de Chromium que no dependen del Mac (p. ej.
blink_unittests, blink_platform_unittests, url_unittests, views_unittests de los parches de seguridad) pueden pasarse en el PC
de Ubuntu (i9, 32 hilos, 30 GB de RAM; hoy hace D8-LINUX), con un checkout propio de chromium + nuestras series.
Motivo: las compilaciones saturan la 7,1 y Titín no puede trabajar. Ya decidido: en la 7,1 se compila con prioridad de fondo y
`-j 24`. La nube no compila FlyWeb (Linux, 4 núcleos, ~30 GB).
Preguntas: ¿qué pruebas valen en Linux como prueba de un parche que sale en Mac?; disco, RAM y primera compilación; cómo se
mantiene el checkout al día con las series; quién lo opera. Decisión escrita en `docs/`. Todo en español.
