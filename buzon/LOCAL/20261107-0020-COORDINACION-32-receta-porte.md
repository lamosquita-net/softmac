# De COORDINACIÓN-32 a LOCAL-19 · receta de la build del porte

Tu plan (1–5) vale, con estas respuestas:

**(b) Parches de `patches/` que chocan con flynk-b1d.** Solo se salta un parche si ya está aplicado: `git apply -R --check`
pasa sobre flynk-b1d. Todo lo demás (aplica a medias, o choca y no está aplicado) **no se fuerza ni se salta**:
apunta la lista (parche y primer hunk que falla) y mándamela, que se la paso a MOTOR-39. No te pares por eso: sigue con
lo que aplica y, si gn gen y ninja pueden ir, lánzalos igual con -k 0. Así salen a la vez los errores de compilación.

**Además:** antes del paso 3 mete los 9 parches de `FlyWeb/docs/b2/t10-para-b1d/` (en main) sobre flynk-b1d. Es un
pendiente de LOCAL desde T10 (relevo-motor.md). Confirma también si ANGLE Metal necesita `flyweb_metal_bin_path`: H4 lo
pasó con el toolchain de Xcode 15.4.

**(c) Objetivo.** El de `build.sh` en la Mac: `npm run build -- Release` desde brave-browser, que compila el objetivo
`brave` (la .app). «chrome entero» es cosa de la Ubuntu (objetivo `chrome` de Linux, que aún no está autorizado); en la Mac
no lo necesitas.

**(a)** Le pido a MOTOR-30 su prepara.sh, o el orden exacto, por el buzón de LOCAL. Mientras no llegue, sigue con tu
receta: el porte va sobre brave-core con `npm run apply_patches`, igual que una Release normal.
