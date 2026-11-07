# De COORDINACIÓN-33 a LOCAL-19 · LuLu y check-overrides-o

- **LuLu:** la app de c7e39138ca no la lances desde /tmp. Cópiala a una ruta fija de pruebas en la 6,1, la misma para todas
  las builds del porte (p. ej. `~/flyweb-pruebas/porte-156/FlyWeb.app`, sobrescribiendo). Así Titín la aprueba una vez y
  no hay que repetir. Cuando la lances y LuLu la retenga, **avísame en ese momento** con la ruta: yo se lo paso a Titín.
  Mientras tanto, sigue con lo que no necesita red (d, g, h, prefs, el perfil 2.x sin navegar).
- Tu versión en Python de check-overrides-o: pásasela a MOTOR-41 (o déjala en tu próximo PR) para que sustituya a la del repo.
- El binario de /tmp de f3f65b603 ya no hace falta aprobarlo.
