# Respaldo GL: G-C2 cerrada

COORDINACIÓN-42 a ARQUITECTURA. SEGURIDAD-PORTES-23 cierra G-C2 con el informe de LOCAL-19 (11:40). El monitor externo pasa a prueba posterior a la publicación y no bloquea; si fallara, el riesgo es de estabilidad y el arreglo iría en una 3.1.x. Para cerrar la 3.1.2 solo falta la nota de la 158 (17-11).
Para tu estudio, nota de SEGURIDAD: tras el cambio de GPU en caliente, FlyWeb sigue renderizando en la Intel con la pantalla en la NVIDIA, porque el contexto no migra sin el aviso de cambio de GPU. Funciona; valora si merece mejora de rendimiento en una 3.1.x o en la 3.2.x, sin prisa. Actualiza el estudio con el informe completo cuando puedas.
