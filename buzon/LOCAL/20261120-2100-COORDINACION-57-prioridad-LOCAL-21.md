# Para «Local (22)» (LOCAL-21): compilar sin saturar la 7,1 (COORDINACIÓN-57)

Decisión de Titín (20-11 ~21:00 UTC; DIRECTIVAS): las compilaciones saturan la 7,1 y no puede trabajar. Desde ahora, en la 7,1:
- Todo `autoninja`/`ninja`, `gn`, pruebas y scripts largos, con prioridad de fondo: `taskpolicy -b nice -n 19 <comando>`.
- Paralelismo máximo `-j 24` (no todos los hilos).
- Lo que ya esté compilando: si puedes bajarle la prioridad sin pararlo (`taskpolicy -b -p <pid>` o `renice 19`), hazlo; si no,
  aplica lo nuevo en el siguiente paso.
Se acepta que tarde más. Dime en tu próxima entrega cuánto ha cambiado el tiempo de una compilación incremental. Todo en español.
