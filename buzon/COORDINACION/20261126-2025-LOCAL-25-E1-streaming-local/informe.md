# LOCAL-25 → ARQUITECTURA y COORDINACIÓN (65): E1 con streaming local, 4 + 4

Lo pidió ARQUITECTURA el 26-11 porque los datos anteriores de E1 con vídeo al lado eran todos de YouTube, que Titín
invalidó.

**Condiciones de la prueba:**

- binario de E1 `e1-322`, con e1d (E1 apagado, `FLYWEB_METAL_DISPLAY_GPU=1`) y e1x (E1 encendido);
- orden [e1d e1x e1x e1d] ×2;
- escala 2 y sin muestreador;
- streaming local MSE con H.264 1080p60 servido en 127.0.0.1 (`vlocal/mse.html`; ver
  `20261126-2005-LOCAL-25-streaming-local`);
- Aquarium 5000 al lado durante 45 s, desde la carga.

Las 8 pasadas están en `entregas/local24/ml-e1-esc2-NN-ver`.

**Las 8 son válidas:**

- 1920x1080@60 de principio a fin;
- `VideoToolboxVideoDecoder`, el de plataforma;
- «Metal device by id» ×2 en las 4 e1x y ninguno en las 4 e1d.

| Pasada | Versión | válida | Metal device by id | descodificador | mediana fps s5→fin | perdidos s15→fin | perdidos carga→s15 | racha máx < 55 tras s3 |
|---|---|---|---|---|---|---|---|---|
| ml-e1-esc2-01-e1d | e1d | sí | 0 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 58 | 2 |
| ml-e1-esc2-02-e1x | e1x | sí | 2 | VideoToolboxVideoDecoder (true) | 59.9 | 0 | 54 | 1 |
| ml-e1-esc2-03-e1x | e1x | sí | 2 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 57 | 1 |
| ml-e1-esc2-04-e1d | e1d | sí | 0 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 56 | 2 |
| ml-e1-esc2-05-e1d | e1d | sí | 0 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 54 | 1 |
| ml-e1-esc2-06-e1x | e1x | sí | 2 | VideoToolboxVideoDecoder (true) | 59.9 | 0 | 58 | 2 |
| ml-e1-esc2-07-e1x | e1x | sí | 2 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 54 | 1 |
| ml-e1-esc2-08-e1d | e1d | sí | 0 | VideoToolboxVideoDecoder (true) | 60.0 | 0 | 54 | 1 |
- e1d: 4 válidas; medianas [60.0, 60.0, 60.0, 60.0] (mediana de medianas 60.0); perdidos s15→fin [0, 0, 0, 0] (total 0); racha máx 2
- e1x: 4 válidas; medianas [59.9, 60.0, 59.9, 60.0] (mediana de medianas 60.0); perdidos s15→fin [0, 0, 0, 0] (total 0); racha máx 2

## Criterio de §11.3 (fijado por ARQUITECTURA antes de medir)

- Mediana de Aquarium con E1 del s5 al final ≥ 58,8 fps: **cumple**, con 59,9–60,0 en las 4 e1x.
- Con E1 no se pierden más fotogramas de vídeo del s15 al final que sin E1: **cumple**, 0 en las 8 pasadas.
- Ninguna pasada con 3 o más segundos seguidos < 55 fps tras el s3: **cumple**. La racha más larga es de 2 s, en los
  s3–4 de la carga, y sale igual en las dos versiones.

**E1 pasa con vídeo local al lado.** Lo único que se pierde, unos 55 fotogramas de vídeo, ocurre durante la carga de
Aquarium y es igual con E1 y sin él.

Con las 3 `vl4` y las 2 `ml-mse` ya son 9 pasadas con vídeo local sin E1 (5 de la base y 4 e1d), y ninguna tiene el
estado lento.
