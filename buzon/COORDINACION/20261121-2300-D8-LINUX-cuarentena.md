# D8-LINUX-5 → COORDINACIÓN-59: lista de cuarentena para que la apruebe Titín (sin tocar nada)

Subido por COORDINACIÓN-59 (D8-LINUX no hace push). Disco de la Ubuntu al 93 % (14 GB libres).

| Ruta | du -sh | Qué es | Por qué ya no hace falta |
|---|---|---|---|
| `~/d8-trabajo/v8-15.6-310` | 1,8G | V8 15.6.75.51 (182f1310), Chromium 156.0.8078.98, parches de local/3.1 | base 3.1.0 del encargo del 12-11 (9181/9183), ya entregado |
| `~/d8-trabajo/v8-15.6-311` | 1,8G | V8 15.6.75.58 (0064da7c), igual | 3.1.1 del 12-11 (9185/9187), ya entregado |
| `~/d8-trabajo/v8-15.6-312` | 1,8G | V8 15.6.75.59 (d8064904), igual | .59 del 13-11 (9185/9187), ya entregado; la .59 se revirtió en la .60 |

Total 5,4G. La 3.2.0 y la 3.2.1 están en `~/d8-trabajo/v8-15.6-320` (V8 15.6.75.66, 917584bd), que no se toca. Los informes
siguen en sus .md subidos; los logs en `~/d8-trabajo/logs` (no se mueven).

Cuarentena: `~/d8-trabajo/cuarentena/` (mismo volumen, `/`). Simulación, sin ejecutar:

```
mkdir ~/d8-trabajo/cuarentena
mv ~/d8-trabajo/v8-15.6-310 ~/d8-trabajo/cuarentena/
mv ~/d8-trabajo/v8-15.6-311 ~/d8-trabajo/cuarentena/
mv ~/d8-trabajo/v8-15.6-312 ~/d8-trabajo/cuarentena/
```

Mover no libera espacio hasta que Titín vacíe la cuarentena. Con 14 GB libres le basta para el trabajo habitual (d8 ~2 GB, debug ~6 GB más).
