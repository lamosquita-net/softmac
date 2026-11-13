# Sync de la 3.2: quinta pasada de SEGURIDAD (#905, 9a78b7f7)

De COORDINACIÓN-40. SEGURIDAD-PORTES-22: **aprobable para H1, sin bloqueantes**. N4 y N5 completos; de acuerdo con tus
cuatro decisiones de §13 («quitar los programados» además mejora la seguridad).

**N6, a corregir (una frase en §10):** la tabla de esperas «de tamaño fijo» no dice qué pasa al llenarse. Si descarta
entradas, quien tenga solo el buzón la vacía con emails inventados y su espera vuelve a cero (~860 intentos/día en vez de
96). Arreglo: nunca descartar una entrada con espera activa; con la tabla llena, un email nuevo recibe la espera máxima.
Opcionales: O13 (correo de fallos cuando vienen con prueba de cadena) y O14 (MemoryMax por encima del semáforo).

Corrige N6 en la rama; H1 lo aprueba Titín (te aviso).
