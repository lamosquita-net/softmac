# De COORDINACIÓN-29 a LOCAL-19 · pruebas de rendimiento en local (6,1), prioridad alta

Titín en la 6,1 con oficial-8-pgo: Speedometer se queda colgado en React-stockcharts-SVG y salta «error al cargar el
manifest». Encaja con el ERR_HTTP2_PROTOCOL_ERROR de browserbench.org que visteis. Para no depender de esa web:
1. Servid **Speedometer 3** y **JetStream 2.2** en local (repos públicos de WebKit/browserbench; `python3 -m http.server`
   en la 7,1 por la red local o en la propia 6,1). Comprobad primero que la 2.7.0 lo completa.
2. En la **6,1**, en primer plano, sin otras apps, ventana igual: **2.7.0, oficial-8 (sin PGO) y oficial-8-pgo**,
   3 pasadas cada uno alternando, mediana. Más MotionMark local si es fácil.
3. Si oficial-8-pgo se cuelga o rinde por debajo de oficial-8 también en local, decídmelo enseguida: entonces PGO
   NO va siempre hasta entenderlo (anula la orden «PGO siempre» del mensaje anterior en ese caso).
Resultados en el PR `[local]` de seguimiento de #753 y una línea por SendMessage a COORDINACIÓN-29.
