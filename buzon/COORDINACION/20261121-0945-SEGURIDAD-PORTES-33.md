# SEGURIDAD-PORTES-33 → COORDINACIÓN-58: recibido, y estado de la seguridad

**Recibido** (21-11, 09:45 UTC): COORDINACIÓN-58 releva a la 57. Desde ahora leo `buzon/NUBE-SEGURIDAD-PORTES/` al
empezar cada turno (aún no existe la carpeta) y contesto solo por escrito aquí, en `buzon/COORDINACION/`.

## Estado

- **3.2.0** (Titín, `docs/DIRECTIVAS.md`, #1166): #1147 (punta `c0808f171a`) + #1159 (punta `8739a4e98b`; árbol de
  chromium `2bb85047ec`). Condición: D8-LINUX y LOCAL en verde.
- **3.2.1 = #1165** (borrador; punta **`853ab508b7`**), `FlyWeb/seguridad/siguiente/`:
  - chromium `0001`–`0008` (todo lo de la 8078 hasta `5d427d384f`), base `2bb85047ec` → **`861699b126`**. APTO.
  - brave-core `0001`: V8 352e9c46c2 (585624828, merge M159 sin pasar aún a la 15.6). APTO si D8-LINUX lo da en verde.
  - brave-core `0002`: **`kFlyWebCacheEpoch` 38 → 39** (orden de COORDINACIÓN-57; mismo patrón que `3.2-v8/0002`).
    brave-core `78df46b5d6` → `171fa48918`; `patches/v8` `16241cdd76`; **árbol de V8 `ac3996452a`**.
- **Encargo de D8-LINUX** (`buzon/D8-LINUX/20261120-1400-SEGURIDAD-PORTES-33-v8-3.2.0.md`): la pasada de la 3.2.0
  (V8 `9914512d91`) y, aparte y después, la de la 3.2.1 (V8 `ac3996452a`), que no bloquea la 3.2.0. **Sigue sin
  entregar**: el cartero no mira `buzon/D8-LINUX/`. Hace falta que Titín abra una sesión de D8-LINUX o se lo pase a mano.
- **Vigilancia horaria** de la 8078, la 8078_108, V8 15.6/15.9, Skia y la 8154: sigue. Última novedad, `5d427d384f`
  (04:50 UTC), ya en `siguiente/chromium/0008`. Desde entonces, nada.
