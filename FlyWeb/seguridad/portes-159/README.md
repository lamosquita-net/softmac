# Portes de la 159 a la 156 (antes de que lleguen a la 8078)

Arreglos de la rama de la 159 (`branch-heads/8154`, en beta) que COORDINACIÓN pide portar **ya**, sin esperar a que
Chrome los lleve a la 156. Prepararlos **no los mete en ninguna versión**: eso lo decide Titín. Carpeta aparte de
`seguridad/pendiente/` (#1147) para no mezclar. Lo prepara SEGURIDAD-PORTES (desde la -33, 20-11-2026).

Si el arreglo llega después a la 8078 como merge M156, se compara con el de aquí. Si es igual, el de aquí se da por
bueno. Si es distinto, manda el de Chrome.

## Base

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`90418ba4fd`** (= `seguridad/pendiente/chromium/0001`–`0008`, #1147) | `chromium/0002` | **`1c458472cc`** |

`0002` no toca ficheros de `pendiente/chromium/0001`–`0008`. Comprobado con `git am` sobre `90418ba4fd`: árbol
**`1c458472cc`**, sin ficheros borrados. Hasta el 21-11, con `0001`, la cadena daba `2bb85047ec`; ese árbol ya no vale.

## `chromium/0001` (menús FOR_DROP, 8154 afa45b8e16): **fuera de la 3.2.0** (21-11)

LOCAL dio **ROJO**: `views_unittests` `MenuRunner*` pasó 23 de 25 y fallaron las dos pruebas del propio `0001`. Faltaba un
prerrequisito: main `041491e936` (bug 574516887). Sin él, `MenuRunnerImpl::OnMenuClosed` pone `controller_ = nullptr` y
el `MenuRunner` que se suelta después se borra en el acto en vez de aplazarse (análisis completo en #1175).

**Decisión de Titín (21-11, ~13:55 UTC, vía COORDINACIÓN-58):** lo rojo sale de la 3.2.0 y lo nuevo va a la 3.2.1.

- El `0001` se quita de aquí.
- El prerrequisito y el `0001` corregido pasan juntos a `seguridad/siguiente/chromium/` (#1165) como `0009` (main
  `041491e936`) y `0010` (afa45b8e16). Tienen el mismo `patch-id` que los de #1175, que queda cerrado.
- El número `0001` no se reutiliza.

## `chromium/0002`: 8154 b079c8f6c8 (bug 586171393, merge M159 588196490)

`url::SchemeHostPort`, y con él `url::Origin`, aceptaba un host vacío en cualquier esquema `SCHEME_WITH_HOST`, por
ejemplo `("chrome", "", 0)`. Un `GURL` así no es válido: `GURL` rechaza `chrome://`. Una tupla de ese tipo no podía
salir de una URL real, pero **sí podía llegar por IPC** (deserialización de `url.mojom.Origin`) y confundir a la pila
de navegación. Con el arreglo, un host vacío solo vale para `file:` (y para esquemas no estándar). La deserialización
por mojo de un `Origin` así falla, y `GetURL()` añade un `CHECK` de coherencia. Hace falta un *renderer* comprometido
que mande el `Origin` falso: es endurecimiento del proceso del navegador frente a IPC. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). **Aplica limpio** sobre `90418ba4fd`. La nota del fichero dice «Applied after
  portes-159/chromium/0001», pero no depende de él: toca solo `url/`. El fichero no se cambia porque LOCAL lo probó así (verde).
- brave-core no tiene parches ni `chromium_src` en `url/`. Los esquemas propios (`brave://`, `chrome-extension://`)
  siempre llevan host, así que el cambio no les afecta.
- Comprobado: `git am` sobre `90418ba4fd` da el árbol **`1c458472cc`** (antes, sobre `403ec1c98c`, daba `2bb85047ec`).
- **LOCAL: VERDE** (21-11, `url_unittests` 34/34).
- **Ya está en la 156 (21-11, 00:10 UTC):** merge oficial `04db7fff13` en la 8078 (merge 588196153), **idéntico** (`patch-id` igual) a este `0002`.
- **Gravedad: no consta** (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0002`

Es el cambio de upstream sin tocar nada. Efecto visible: ninguno. Una URL o un origen con host vacío en un esquema
estándar distinto de `file:` ya no se consideran válidos, igual que ya pasaba con `GURL`.

**Pruebas para LOCAL:** `url_unittests --gtest_filter='SchemeHostPortTest.*:OriginTest.*:MojoGURLStructTraitsTest.*'`
(trae `OriginDeserializationWithEmptyHost`). En la build: abrir `file:///`, una página de ajustes (`brave://settings`)
y una extensión, y comprobar que cargan.

