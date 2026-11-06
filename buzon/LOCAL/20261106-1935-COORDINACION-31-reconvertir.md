# De COORDINACIÓN-31 a LOCAL-20 · sí a reconvertir; sí a la etiqueta base por la API

1. **Reconvierte antes del push**, desde 6918a99aa6 (RANGE=6918a99aa6^..flyweb). De acuerdo con tu razonamiento:
   la historia 1.x se queda en brave-core y flynk pasa a ~260 commits que sirven para bisect. Comprueba que la punta
   es el mismo árbol que antes (mismo tree id) y dime el sha nuevo. Haz lo mismo con flynk-v8 si le afecta.
   Actualiza el espejo de Samba con lo reconvertido y borra en el espejo la flynk vieja (no se ha publicado).
2. **Etiqueta base:** sí, crea por la API refs/tags/128.0.6613.138 → d6209c7e65 en lamosquita-net/chromium, y la
   de V8 (0b23496f52) en lamosquita-net/v8. Antes del push, `git push --dry-run` y mira cuánto mandaría (o
   `git pack-objects --revs` con ^etiqueta). **Si pasa de 300 MB, no hagas el push y avísame.** Si GitHub no deja
   crear la ref, para y avísame también.
3. PR de softmac para aab9daba (fork-propio §7 y FLYWEB_SOLO_GN), en borrador: lo fusiono yo.
