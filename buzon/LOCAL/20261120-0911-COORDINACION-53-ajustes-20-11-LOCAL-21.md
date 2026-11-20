# Para LOCAL-21: compilar los ajustes de Titín del 20-11 (0008–0011) y dejarlos abiertos para él

Orden de COORDINACIÓN-53. Entregar a **«LOCAL-21 relevo en MacPro7,1»** (9d9f5f).

Parches `FlyWeb/parches/3.2-interfaz/` 0008–0011 de la rama `claude/motor46-interfaz-ajustes-20-11-b`, punta `286e583bb9`
(#1138, borrador). Pasos completos en el README de `3.2-interfaz`, apartado «Ajustes de Titín del 20-11»:
- 0008: brillo de la URL con foco, en oscuro;
- 0009: URL 2 dip más baja, quitados por arriba;
- 0010: hover de la inactiva #EBEBEB / #585959;
- 0011: título y favicon de las inactivas 4 dip más abajo, solo en la tira horizontal.

**Montaje:** sobre `local/320b-tema-visible` (árbol `a0c808d485`), `git am` del 0008 al 0011. Árboles esperados: 0008
`b127946356`, 0009 `7d533d1ef9`, 0010 `e0ff1d94a6`, 0011 `46c2d18b98`. Si alguno no coincide, para y avísame. Ninja
incremental en `out/Interfaz320`, con los tests que pida el README (`BraveColorMixersTest.*`).

**Copia a la 6,1 como `bt-320c`**, con perfil limpio con pestañas, varias fijadas, marcadores y registro. No toques bt-320a
ni bt-320b.

**Capturas**, ventana normal en claro y en oscuro, a 1x y en Retina:
- la tira con la activa, inactivas y fijadas (que se vea el desnivel del título y del favicon);
- la URL (alto y separación de las pestañas);
- si puedes, el hover de una inactiva y la URL con foco. Si sin ratón ni teclado no se puede, dilo: los mira Titín.
Compáralas con las maquetas en `FlyWeb/branding/interfaz-3.2.0/ajustes-20-11/maqueta-*-hd.webp`.

Deja bt-320c abierta para Titín. **No cierres bt-320a ni bt-320b**: eso lo decide Titín.
