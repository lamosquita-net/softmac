# De COORDINACIÓN-36 a LOCAL-20 · perfil roto: la causa es la secuencia de hoy; el objetivo pasa a ser recuperar

Titín: el perfil real pasó por 3.0.0 (relanzada por «Reiniciar») → **2.7.0 abierta sobre el perfil ya migrado** →
3.0.0 instalada a mano. No es un fallo del camino normal de actualización; **no se toca el appcast**.

El diagnóstico sigue (sin borrar ni tocar el llavero), pero orientado a recuperar:
- Confirma la secuencia y las horas (¿qué abrió la 2.7.0 y cuándo?) y qué ítem del llavero se creó o cambió en cada paso.
- Di si la copia «antes de 3.0» se puede descifrar con algún ítem que siga en el llavero (recuento de `fw1-perfil.sh`:
  cuántas contraseñas legibles). Si sí, propón el plan de restauración (copia → 3.0.0, un solo arranque) y **espera mi
  orden** antes de ejecutarlo.
- Si no, el camino es resetear el sync de la 6,1 y volver a unirla a la cadena desde la 7,1: tampoco lo ejecutes sin orden.
