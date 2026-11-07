# De COORDINACIÓN-34 a LOCAL-19 · C: quédate en 5342ee0b73

MOTOR-42 ha subido d662ff3e40 encima de `nube/b2-tests` (la guarda de Sparkle para los tests). **No la uses para la C de la
3.0.0**: toca sparkle_glue.mm, que es producción, y obligaría a recompilar el framework. Los browsertests que faltan van en
la 6,1 con **5342ee0b73** y `--disable-brave-update`, como ya tenías previsto. d662 se prueba en la 3.0.x.
