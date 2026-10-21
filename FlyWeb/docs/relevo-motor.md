# Relevo de MOTOR: de MOTOR-13 a MOTOR-14 (21-10-2026)

MOTOR-13 (`session_01EqxadojDaRbipYn8TDzVd6`, Opus 5.5, `xhigh`) portó FM.28: **FlyWeb 1.15.2 = anchor positioning del
nivel 131**, en código y probada. Lo hecho está en la fila FM.28, en `FlyWeb/docs/version-1.15.2.md` y en
`FlyWeb/tools/port/README.md` («Porte grande con fusión a tres bandas»). **Tu encargo es FM.29 (1.15.3 = view
transitions entre documentos)**, sobre la 1.15.2, cuando esté entregada a PUBLICACIÓN; antes, si te llega, lo que quede
de FM.28 (abajo). Después, FM.36 (tests de la 116 con `shadowroot=`), sin prisa.

**Ramas de brave-core:**

| Rama | Cabeza | Estado |
|---|---|---|
| `nube/motor-131-anchor` = `nube/motor-131-anchor-f13` | **357d708c47** | **candidato a la 1.15.2** (F12 f2699e58e7 + `seg/top-layer-box` 1f7b9912, upstream 0e454ce616, fundida; el área de MOTOR-13 ya la lleva): `-1152` (9069fb3e1a: porte F1–F4 + arreglos de las compilaciones + FS.22 + `flyweb_version` 1.15.2) + los arreglos de las WPT de la F11 (`overflow: hidden`, 1624b1441b9, 14c9714ba83e) + 12bfef324f99 (caída de `getComputedStyle()` tras un layout de subárbol, presente desde la 1.15). Base de FM.29 cuando LOCAL lo entregue |
| `nube/motor-131-anchor-f2` … `-f10` | 4efeaf5685 … ecb6ce11ed | puntos de compilación de prueba de FM.28; solo de referencia |
| `nube/motor-131-escapes` | fa4fae392f | 1.15.1, base del porte |
| `seg/cve-criticos-128` | ad21546964 | FS.22, ya fundida en la 1.15.2 (`merge-base --is-ancestor` OK) |

**Lo que queda de FM.28 (no bloquea FM.29 si ya está cerrado al llegar):**

- **F13 (357d708c47; antes F12 f2699e58e7 y F11 9472de6fe0) por compilar y probar** (LOCAL-6, cuando la 7,1 acabe la 128): navegador, `blink_unittests`, WPT de
  la lista y los dos crashtests de container queries con capa superior (se caen en la 1.15.1 y en la F9; con 1624b1441b9
  deberían pasar) y `FlyWeb/tools/caidas-fm28.html` (12bfef324f99). Las WPT de la F9 ya están en `version-1.15.2.md`; si la F11 deja algo del anchor peor que CfT 131, se
  arregla en `nube/motor-131-anchor` (rama fija nueva) o va a «Diferencias conocidas».
- **Revisión de SEGURIDAD-PORTES-4** (regla 17): la F11 tiene visto bueno (#402); la F12 (12bfef324f99 en
  `layout_box.cc`/`ng_layout_result.*`), pedida el 21-10; la F13 solo añade su propio `seg/top-layer-box`.
- **Release:** cuando lo diga Titín (FM.31: la 7,1 compila también la 128). La entrega en la fila es de LOCAL.
- Fuera de FM.28, ya acordado: `ElementFragmentAnchorTest.AnchorRemovedBeforeBeginFrameCrash` (fragmentos `#ancla`).

**Comunicación** (cambió el 21-10): MOTOR-13 tenía la tarjeta de confianza aprobada por Titín y escribía a LOCAL-6 con
`send_message` (`session_01XThFQyF9gwmE2erjeaAdRL`); a COORDINACIÓN-9 no llegaba. **Tú abres sin aprobar**
(COORDINACIÓN-10): a la 7,1 se escribe por la rama `buzon` de softmac (`docs/ARRANQUE.md`, paso 2), y si un
`send_message` falla sin `content_digest`, no se busca otro canal: se informa en el PR y en la fila.

**Entorno** (igual que en la nota anterior, en el historial; ~15 min): clon de brave-core en `nube/motor-131-anchor`,
historia de Chromium con las etiquetas 116 y 131, `cr116` y `cr131`, `ngmap.json` (para la 131 sirve
`FlyWeb/tools/port/ngmap-fm28.json.gz`, con los nombres de FM.28). Para FM.29 hace falta montar un área nueva (`mkws.sh`) y
**reconstruir la base real** (116 + parches de la rama de partida, como `base115/` en FM.28): comparar con el commit «brave»
del área engaña, porque no es la versión publicada.

**Trampas de FM.28 que valen para FM.29** (detalle y herramientas en el README del port):

- **`ComputedStyle` es GC en upstream y `scoped_refptr` en la 116.** Lo que compila puede caerse: un `std::move(style)`
  seguido de `style->…` (la caída de `RecalcOwnStyle` de la F7, SEGV en cada recálculo de estilo) o un miembro
  `const ComputedStyle*` que en upstream mantiene vivo el GC. Antes de entregar: `trasmove.py` y buscar esos miembros.
  View transitions también guarda estilos (pseudoelementos `::view-transition-*`): ojo.
- **La autorresolución de la fusión a tres bandas pierde cosas sin avisar:** un método entero (`Position::ApplyInherit`,
  el navegador compiló y no enlazó), una flag vecina del json5 (`CSSPictureInPicture`), un commit que cambia un `status`
  (19879a57c77). `custfn.py`, comparar nombres y `status` de flags con la 1.15.x y con la N, y `perdidas.py`.
- **`blink_unittests` ya compila y enlaza con todos los niveles** (FM.28, solo tests): no dejar que se rompa. Los tests de
  cada commit portado van con él; los de la 116 que usan una API renombrada, también. Muchos errores vienen de los
  `chromium_src` de Brave (`brave-core/chromium_src/<ruta>`), no de los niveles. clang corta en 20 errores por fichero.
- **LOCAL compila con `-k 0`; los puntos de compilación, en ramas fijas** (`-fN`), con el sha de `git ls-remote`. Un
  arreglo que solo toca tests se dice («no hace falta recompilar el navegador»): ahorra horas.
- **Flags que upstream quita:** en FM.28 `CSSAnchorPositioning` se quedó en `stable` para el código de la 116 que la
  consulta, y los tests de upstream que comprobaban el flag apagado se quitaron como en 3253335fbac.
- **`KeyboardFocusableScrollers` quedó en `experimental`** en la 1.15.2 (regla 20, como Brave 1.73; `motor-130.html` lo
  espera así).

**Herramientas nuevas** (en `FlyWeb/tools/port/`, con el README): `sig.sh`/`m3.sh`/`autores.py` (fusión a tres bandas),
`gnirama.py` (lo pasa `chk.sh`), `custfn.py`, `trasmove.py`, `barrido.py`, `sueltas.py`, `ver.sh`, `fixc.sh`,
`fmtdelta.sh`, `perdidas.py`, `ciclos.py`.

---

**Relevos anteriores** (MOTOR-2 a MOTOR-13): [`relevo-motor-historial.md`](relevo-motor-historial.md).
