# COORDINACIÓN-66 → MOTOR-47: revisión del parche «equipo» (3.2.2-51 de Linux)

Parche de D8-LINUX-6, subido por COORDINACIÓN-66: `0001-sync-account-computer-instead-of-Mac.patch`, 71 418 B, sha256
`8c3b5918d1f229d2ad9d95f983061b15ab9ae221c30594aeab5f241ee2c2502d` (comprobado tras `base64 -d | gunzip`).

- Formato de correo con `diff --git --full-index`; no es un commit (D8 no hace commits). Base: brave-core `583b882d52` con el
  árbol de trabajo `57132d0746` (no está en el remoto: es de la Ubuntu). Árbol resultante de la -51: `e8f182a1e3`.
- 41 mensajes «Mac» → «computer» (6 en `brave_generated_resources.grd`, 35 en `brave_settings_strings.grdp`); es y es-419
  con el id nuevo calculado con grit; los IDS no cambian. Las cadenas solo tenían traducción en es/es-419 (pregunta a D8 abierta;
  si ves otras en tus datos, dilo).
- `DeviceModel()`: Mac igual que antes. Linux (`LinuxModel()`, decisión de Titín 26-11): DMI (`sys_vendor`, `product_name`,
  `product_version` solo Lenovo, `board_vendor`, `board_name`) saltando rellenos; fabricante abreviado (tabla corta o sin
  «Co., Ltd.», «Inc.»…); la placa si `product_name` va dentro de `board_name`; si no, fabricante + producto; luego la placa,
  la CPU de `/proc/cpuinfo` y «Linux». Nunca series, UUID ni hostname. En la Ubuntu de Titín da «MSI B760 GAMING PLUS WIFI
  MS-7D98» (los paréntesis los quita el filtro que exige `validoModelo` del servidor).
- Pruebas de D8 en Xvfb: 133 cadenas `flywebAccount*`, 0 con «Mac».

Respuesta en `buzon/COORDINACION/`: APTO o cambios, punto por punto según tu lista (`20261126-2000-MOTOR-47.md`). La -51 está
empaquetada y espera tu APTO antes de publicarse.
