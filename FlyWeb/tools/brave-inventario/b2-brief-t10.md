# T10 (MOTOR-35): llevar a la 156 los parches propios de FlyWeb marcados «reportar» en §12.13

Además del brief común (FlyWeb/tools/brave-inventario/b2-brief-t5bis.md:
herramientas, método, comprobaciones y commits; en los asuntos usa `[b2-porte-t10]` en vez de `[b2-porte-t5-bis]`):

- La tabla fuente es /home/user/softmac/FlyWeb/docs/brave-propio.md §12.13.2, subtabla «2.1» (columnas Fichero | Subtipo |
  Qué hace | 156 | Veredicto). Léela solo para tus filas.
- **Cruce obligatorio con `flynk-b1d`**: el Chromium que compila LOCAL para la 3.0.0 es `lamosquita-net/chromium`, rama
  `flynk-b1d` (156.0.8078.90 + arreglos de Mojave de LOCAL, «// FlyWeb B1d»). Es público: lee ficheros con
  `curl -sf https://raw.githubusercontent.com/lamosquita-net/chromium/flynk-b1d/<ruta>` y compáralos con el de 156
  (`b2-cr156 <ruta>`). Para cada parche de tus filas:
  1. Si `flynk-b1d` ya arregla lo mismo en ese fichero (mismo efecto en 10.14, aunque con otro código) → el parche
     **sobra**: bórralo de `patches/` (y lo que solo existiera para él). Si `flynk-b1d` toca el fichero pero cubre solo
     una parte, deja en el parche solo lo que falta.
  2. Si no lo arregla → **portar**: reancla el parche a la 156 (b2-cr156 + b2-mkpatch), conservando su intención
     (columna «Qué hace» y el parche actual). Debe aplicar contra 156 (b2-chkpatch) **y** no chocar con flynk-b1d:
     si flynk-b1d modificó ese fichero, comprueba también `git apply --check` del parche contra el fichero de flynk-b1d
     (bájalo a un árbol temporal con la misma ruta); si choca, genera el parche contra el de flynk-b1d y dilo.
  3. Si la 156 ya lo trae por sí misma → sobra, bórralo.
- Los parches de Mojave existen porque FlyWeb compila con destino 10.14: no los «mejores», solo llévalos a la 156.
- Un commit por parche o por grupo pequeño de parches relacionados (p. ej. eye_dropper, color, fido).
- Informe final (≤ 50 líneas, en español): tabla `parche | flynk-b1d lo cubre (sí/parcial/no) | acción (borrado/
  reanclado/recortado) | b2-chkpatch | choca con flynk-b1d (sí/no)`, más dudas y lo que no hayas podido resolver.
