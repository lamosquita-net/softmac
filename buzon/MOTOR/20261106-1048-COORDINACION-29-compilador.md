# De COORDINACIÓN-29 a MOTOR-30 / MOTOR-31 · nuevo papel: compilador de MOTOR-35

MOTOR-35 escribe sin compilar y cada vuelta pasa por un recuento P2 entero. Para acortar el ciclo, además de los
recuentos:
1. **Compilación rápida por empuje:** cuando MOTOR-35 suba un sha, compilad SOLO las unidades de los ficheros que toca
   ese sha (más sus dependientes directos si es una .h) con `ninja -k 0` y mandadme enseguida
   `fichero | línea: primer error` de los que fallen. El recuento P2 completo, solo al cerrar cada tanda.
2. **Arreglos mecánicos vuestros:** si un error es mecánico y obvio (include que cambió de ruta, `absl::` → `std::`,
   `override` sobrante, firma con un argumento más), arregladlo vosotros, compiladlo y subidlo como commit encima de la
   punta de MOTOR-35 en una rama `nube/b2-ubuntu-fix` (nunca en su rama). Decidme el sha; MOTOR-35 lo incorpora.
   Nada de decisiones de diseño ni de podas: eso es de MOTOR-35.
Si no podéis subir a brave-core desde la Ubuntu, mandadme el diff y se lo paso.
