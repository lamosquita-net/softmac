# Textos web de la 1.9 y la 1.10 (CONTENIDOS-WEB, 09-10-2026)

**Estado: borrador.** Regla 12 (`docs/TAREAS.md`): los textos de cada versión salen de la sección «Para la web» de
`FlyWeb/docs/version-1.N.md`. **Ni `version-1.9.md` ni `version-1.10.md` existen** (y `version-1.0.1/1.1/1.2.md` no
tienen esa sección), así que lo de abajo sale de las filas FM.13, FM.14 y FS.8 del tablero y de `motor.md`, y **queda
pendiente de confirmar** por quien lleva cada versión. No se publica nada de esto: `index.html` y `VERSION` de la 1.10
cambian juntos cuando LOCAL entregue el DMG (tamaño y SHA-256) y PUBLICACIÓN suba `VERSION`.

## 1. FlyWeb 1.9 (nivel 125) — ya tiene texto: PR #112 de LOCAL

El PR [#112](https://github.com/lamosquita-net/softmac/pull/112) (`local/web-1.9`, abierto, sin conflictos con `main`)
lleva la portada, la ayuda y `VERSION` = `1.9 157.64.14 FlyWeb-1.9.dmg 20f1a405…78073e3`. Cotejado con FM.13:

| Lo que dice el tablero (FM.13) | ¿Está en las notas de #112? |
|---|---|
| `getHTML()` y raíces de Shadow DOM serializables | sí |
| Colores relativos, `round()/mod()/rem()`, `:state()` | sí |
| `view-transition-class` y tipos de View Transitions | sí |
| Modificadores y grupos repetidos en RegExp, `WebSocket` http(s)/relativas | sí |
| Arreglos menores: `rgb(calc(NaN))`, Shadow DOM declarativo con varias raíces | sí («Correcciones») |
| Lo de la 1.8.1 se mantiene (FM.12 formularios verticales, F7.8 pestañas fijadas) | sí |
| Seguridad: V8 12.5, Maglev y puente wasm→JS apagados | sí |

El contenido es correcto. Tres cosas que sugiero a LOCAL/COORDINACIÓN (no he tocado su rama):

1. **Una frase de usuario al principio.** Las notas empiezan por una lista de nombres de funciones. Propuesta de frase
   previa: «Las webs que usan colores y animaciones de CSS de 2024 se ven como en Chrome 125; para ti, casi siempre, la
   diferencia es que menos webs se ven rotas.»
2. **La portada pierde las notas de la 1.8.** Con #112 solo quedan la 1.9 y la 1.8.1, y la 1.8 era la única que contaba
   que las actualizaciones ya no piden contraseña de administrador. Propuesta: `novedades.html` con el historial
   (1.0.1 a la actual), sacado de las portadas anteriores; la portada solo lleva la última versión.
3. **Ayuda.** El pie de la cabecera pasa a «1.9 · nivel de Chrome 125» (ya en #112), pero el párrafo de
   «Webs que avisan de navegador antiguo» vuelve a citar una versión fija. Mejor sin número: «la versión actual tiene el
   nivel de Chrome N y se presenta a las webs como Chrome N».

## 2. FlyWeb 1.10 (nivel 126) — borrador pendiente de confirmar

Fuentes: FM.14, FS.8 (SEGURIDAD-PORTES, 09/10) y `motor.md` «Nivel 126». La 1.10 está en compilación (LOCAL); aún no hay
DMG, tamaño, SHA-256 ni `CFBundleVersion`.

### Texto en lenguaje de usuario

> **Motor de nivel Chrome 126.** El motor de JavaScript (V8) pasa a ser el de Chrome 126 y FlyWeb se presenta a las webs
> como Chrome 126. Es un nivel pequeño: casi todo lo nuevo de ese Chrome son funciones que aún no están en todos los
> navegadores. Entran `URL.parse()` (leer una dirección web sin que falle si está mal escrita) y que los datos de
> ubicación de una web se puedan guardar como texto (`toJSON()`).
>
> **Se mantiene todo lo de la 1.9:** el nivel de Chrome 125, las pestañas fijadas en todas las ventanas y los controles
> de formulario verticales.
>
> **Seguridad.** El nuevo motor de JavaScript ya incluye las correcciones de la rama de soporte prolongado de Google para
> Chrome 126, que hasta ahora portábamos a mano, y le hemos añadido otras posteriores de la rama de Chrome 132.
> El compilador Maglev y el puente genérico entre WebAssembly y JavaScript siguen apagados.

### Trozo de `index.html` (para cuando exista el DMG; mismo patrón que la 1.9)

```html
<h2 id="novedades">Notas de la versión 1.10</h2>
<ul>
  <li><strong>Motor de nivel Chrome 126.</strong> El motor de JavaScript (V8) pasa a ser el de Chrome 126 y FlyWeb se
  presenta a las webs como Chrome 126. Es un nivel pequeño: entran <code>URL.parse()</code> (leer una dirección web sin
  que falle si está mal escrita) y <code>toJSON()</code> en los datos de ubicación
  (<code>GeolocationPosition</code> y <code>GeolocationCoordinates</code>).</li>
  <li><strong>Se mantiene todo lo de la 1.9:</strong> el nivel de Chrome 125, las pestañas fijadas en todas las ventanas y
  los controles de formulario verticales.</li>
  <li><strong>Seguridad:</strong> el nuevo motor de JavaScript ya incluye las correcciones de la rama de soporte
  prolongado de Google para Chrome 126, que hasta ahora portábamos a mano, y le hemos añadido otras posteriores de la
  rama de Chrome 132. El compilador Maglev y el puente genérico entre WebAssembly y JavaScript siguen apagados.</li>
</ul>
```

### Qué falta confirmar antes de publicarlo

| # | Duda | Quién |
|---|---|---|
| 1 | **Crear `FlyWeb/docs/version-1.10.md` con «Para la web»** (regla 12): qué cambia para el usuario. Mientras tanto, este borrador sale de las filas | LOCAL o MOTOR |
| 2 | ¿Se nota algo en los **PDF**? La 1.10 toca PDFium (propiedades de JavaScript de los PDF, parches nuevos). Si LOCAL confirma que un PDF con JavaScript (un formulario) abre y funciona, no hace falta decir nada; si algo cambia, hay que contarlo | LOCAL |
| 3 | La 12.6 enciende por defecto `turboshaft_load_elimination` y `turboshaft_loop_unrolling` (decisión del HUMANO, 08/10: se dejan encendidos). Las notas anteriores decían «la parte más reciente de Turboshaft sigue apagada»; no la repito porque ya no es del todo cierto. ¿Cómo se explica en lenguaje de usuario, o se omite? | SEGURIDAD-PORTES |
| 4 | «otras posteriores de la rama de Chrome 132»: sale de la M132-LTS que cita FS.8 (10 de 51 portadas). ¿Se puede afirmar así en público? | SEGURIDAD-PORTES |
| 5 | Si en las pruebas del Release aparece algo visible (un arreglo, un aviso nuevo), añadirlo | LOCAL |
| 6 | Datos de la entrega: `CFBundleVersion`, nombre del DMG, tamaño en MB y SHA-256 (los del botón y de `VERSION`) | LOCAL → PUBLICACIÓN |

### Orden de publicación (regla 12 y `web-auto/README.md`)

1. LOCAL entrega la 1.10 (regla 11) y escribe/confirma `version-1.10.md` «Para la web».
2. CONTENIDOS-WEB cierra el texto de arriba en un PR de la web (portada con botón, tamaño y SHA-256; ayuda; sin tocar
   `VERSION`).
3. PUBLICACIÓN sube `VERSION` en el mismo PR o justo después, para que texto y DMG salgan a la vez cuando el HUMANO firme.
