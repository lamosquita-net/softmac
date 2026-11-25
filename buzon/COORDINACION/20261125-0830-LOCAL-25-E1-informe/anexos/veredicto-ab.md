# Veredicto §11.3 · e1ab · valor = mediana de fps por segundo (MotionMark: puntuación)

## Escala 1

| Caso | Base (pasadas) | E1 (pasadas) | Med. base | Med. E1 | Ruido | Pérdida | Veredicto |
|---|---|---|---|---|---|---|---|
| MotionMark total | 1606.53 1574.84 1561.39 | 1643.68 1573.85 1577.29 | 1574.84 | 1577.29 | 2.9 % | -0.2 % | pasa |
| MM Multiply | 1600.27 1596.5 1579.58 | 1654.4 1626.65 1535.62 | 1596.5 | 1626.65 | 1.3 % | -1.9 % | pasa |
| MM Canvas Arcs | 3202.86 3078.15 3028.73 | 3386.86 3296.95 3256.11 | 3078.15 | 3296.95 | 5.7 % | -7.1 % | pasa |
| MM Leaves | 1268.84 1270.75 1243.43 | 1309.58 1305.14 1287.81 | 1268.84 | 1305.14 | 2.2 % | -2.9 % | pasa |
| MM Paths | 15944.7 15618.6 14929.7 | 15550.4 14828.2 15154.7 | 15618.6 | 15154.7 | 6.5 % | +3.0 % | dudoso |
| MM Canvas Lines | 20377.5 20345.4 19957.9 | 20733.6 18403.7 19909.8 | 20345.4 | 19909.8 | 2.1 % | +2.1 % | falla |
| MM Images | 210.96 201.74 212.98 | 210.19 212.58 209.45 | 210.96 | 210.19 | 5.3 % | +0.4 % | pasa |
| MM Design | 238.64 224.67 228.84 | 260.26 225.65 230.06 | 228.84 | 230.06 | 6.1 % | -0.5 % | pasa |
| MM Suits | 417.14 420.66 408.92 | 411.64 410.87 409.19 | 417.14 | 410.87 | 2.8 % | +1.5 % | pasa |
| Aquarium 5000 lienzo 1024 | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 10000 lienzo 1024 | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 15000 lienzo 1024 | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 20000 lienzo 1024 | 47 33.4 48.2 47.3 48 | 48.2 49 48 49 49.2 | 47.3 | 49 | 31.3 % | -3.6 % | no medible |
| Aquarium 30000 lienzo 1024 | 32.4 33 32.9 32.4 32.9 | 33 32.9 32.9 32.5 32.9 | 32.9 | 32.9 | 1.8 % | +0.0 % | pasa |
| cruce4k | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| textura2d | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| shader-local | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |

## Escala 2

| Caso | Base (pasadas) | E1 (pasadas) | Med. base | Med. E1 | Ruido | Pérdida | Veredicto |
|---|---|---|---|---|---|---|---|
| MotionMark total | 870.2 1029.24 934.33 | 969.51 870.23 978.6 | 934.33 | 969.51 | 17.0 % | -3.8 % | no medible |
| MM Multiply | 1647.6 1647.47 1707.26 | 1595.6 1630.91 1579.05 | 1647.6 | 1595.6 | 3.6 % | +3.2 % | falla |
| MM Canvas Arcs | 3159.97 3192.58 3125.63 | 3392.3 3347.59 3271.19 | 3159.97 | 3347.59 | 2.1 % | -5.9 % | pasa |
| MM Leaves | 1236.31 1228.86 1238.96 | 1299.94 1280.48 1265.99 | 1236.31 | 1280.48 | 0.8 % | -3.6 % | pasa |
| MM Paths | 15706.8 15910.6 15554.1 | 15088.5 15040.8 15539.2 | 15706.8 | 15088.5 | 2.3 % | +3.9 % | falla |
| MM Canvas Lines | 20187.1 19959.1 20372.8 | 20049.2 20138.3 20050.6 | 20187.1 | 20050.6 | 2.0 % | +0.7 % | pasa |
| MM Images | 206.24 207.38 199.46 | 207.57 204.8 205.94 | 206.24 | 205.94 | 3.8 % | +0.1 % | pasa |
| MM Design | 128.43 128.63 130.1 | 129.09 127.47 134.21 | 128.63 | 129.09 | 1.3 % | -0.4 % | pasa |
| MM Suits | 6.08 23 10.68 | 13.69 5.95 14.93 | 10.68 | 13.69 | 158.4 % | -28.2 % | no medible |
| YouTube 4K solo | 60 | 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 5000 con YouTube 4K al lado | 60 | 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 5000 lienzo 1024 | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 10000 lienzo 1024 | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| Aquarium 15000 lienzo 1024 | 60 60 60 60 54 | 57 55 60 60 60 | 60 | 60 | 10.0 % | +0.0 % | pasa |
| Aquarium 20000 lienzo 1024 | 47.9 47 47 47 42 | 44 32.8 48.3 49 49.1 | 47 | 48.3 | 12.6 % | -2.8 % | no medible |
| Aquarium 30000 lienzo 1024 | 33 32.9 32.4 32.9 28.1 | 29.5 28.6 32.5 32.4 32.5 | 32.9 | 32.4 | 14.9 % | +1.5 % | no medible |
| cruce4k | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| textura2d | 60 60 60 60 60 | 60 60 60 60 60 | 60 | 60 | 0.0 % | +0.0 % | pasa |
| shader-local | 39 39 39 39 39 | 37.4 37.4 37.4 37.4 37.4 | 39 | 37.4 | 0.0 % | +4.1 % | falla |

## Aquarium 15000: estados (≥ 55 fps rápida)

- escala 1 base: 5 rápidas, 0 lentas: [60, 60, 60, 60, 60]
- escala 1 e1: 5 rápidas, 0 lentas: [60, 60, 60, 60, 60]
- escala 2 base: 4 rápidas, 1 lentas: [60, 60, 60, 60, 54]
- escala 2 e1: 5 rápidas, 0 lentas: [57, 55, 60, 60, 60]

## Pasadas no válidas

- e1ab-video-esc1-01-base-conductor YouTube 4K solo vídeo sin 4K60 reproduciéndose (1280x720@24 / 1280x720@24, 208 fotogramas)
- e1ab-video-esc1-01-base-conductor Aquarium 5000 con YouTube 4K al lado vídeo sin 4K60 reproduciéndose (1280x720@24 / 854x480@24, 208 fotogramas)
- e1ab-video-esc1-02-e1-conductor YouTube 4K solo vídeo sin 4K60 reproduciéndose (0x0@30, 0 fotogramas)
- e1ab-video-esc1-02-e1-conductor Aquarium 5000 con YouTube 4K al lado vídeo sin 4K60 reproduciéndose (0x0@30, 0 fotogramas)
