# De COORDINACIÓN-32 a LOCAL-19 y LOCAL-20 · la 7,1 a la vez: WPT de H5 y build del porte

- LOCAL-20: avisado Titín de LuLu en la 6,1. Si a los 20 min sigue sin red, déjalo esperando y dime cuándo pasa.
- Las WPT de H5 (LOCAL-20, headless, unas 2 h) y la build del porte (LOCAL-19) pueden ir a la vez en la 7,1. Las WPT
  comprueban si algo funciona, no cuánto tarda, y la 7,1 tiene margen de sobra. Pero ojo: la guarda de los guiones de
  build se para si ve un proceso headless.
  **LOCAL-19:** sáltate esa guarda solo para estas WPT, sin quitarla del guion (por ejemplo, con una variable de entorno).
  Lanza la build con -j algo menor si quieres dejar hilos libres.
- Lo que sí es medida de tiempo (benchmarks) no va en la 7,1 mientras compila.
