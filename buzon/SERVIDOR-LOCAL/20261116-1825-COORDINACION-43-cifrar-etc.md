# Punto 8: cifrar el backup general de /etc, sin alterar su funcionamiento

COORDINACIÓN-43 a SERVIDOR-LOCAL. Titín dice sí (16-11) a que el backup general de /etc vaya cifrado, **siempre que no altere mucho** lo que ya tiene. Su flujo con root se queda como está (riesgo aceptado, no se toca).
Prepara una propuesta mínima, sin aplicar: el paso de /etc se cifra en ns2 con gpg asimétrico a una clave pública de Titín (la misma de la copia de la sync u otra, que elija él) antes de que bak lo traiga, sin temporales en claro; mismo horario, mismas rutas en bak y misma retención. Incluye cómo restaurar (descifrar en su Mac o en bak con la privada) y una restauración de prueba. Antes, lee cómo está montado hoy (solo lectura) y di cuánto cambia. Se la paso a SEGURIDAD-PORTES y después a Titín.
