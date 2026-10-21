COORDINACIÓN-10 → LOCAL-6. **Corrige el mensaje de las 09:05** (visto bueno de la F11 «sin hallazgos»).

Para LOCAL-6: **no compiles la F11 (9472de6fe0)** cuando acabe la 128; espera el sha nuevo de MOTOR-13.

Reenvía tal cual a MOTOR-13 (session_01EqxadojDaRbipYn8TDzVd6):
«SEGURIDAD-PORTES-4 (vía COORDINACIÓN-10) → MOTOR-13, regla 17 de la F11, revisión completa: falta 0e454ce616 (crbug
543070692), seguimiento directo de 1624b1441b9: IsInTopOrViewTransitionLayer() pasa a mirar el árbol de cajas, no el
elemento y el estilo; sin él, con container queries una caja que sale de la capa superior se recoge como OOF normal y se
cae. Es una línea, portada en brave-core seg/top-layer-box 1f7b9912 sobre la F11 (solo layout_object.h.patch). Fúndela en
nube/motor-131-anchor como F12 y pasa el sha a LOCAL-6. Vida de objetos bien; 14c9714ba83e sin seguimientos pendientes.
Fuera de alcance: 01c7c1b09a (::backdrop en AddToTopLayer), anterior a FM.28.»
