# Comparativa de navegadores en la MacPro7,1 (Titín, 05-11-2026)

MacPro7,1, macOS 15 Sequoia. Mismo monitor (NEC, 60 Hz) y mismo tamaño de ventana para todos. BrowserBench:
Speedometer 3.1, JetStream 3, MotionMark 1.3. Una pasada por navegador (salvo Chrome). **No es la máquina objetivo**: en
Mojave (6,1/5,1) la 156 va sin Graphite, así que allí las cifras serán menores; esto mide el techo en Sequoia.

| Navegador | Base | Speedometer | JetStream | MotionMark | Notas |
|---|---|---|---|---|---|
| Chrome 156.0.8078.80 | 156 | **21,0** | no carga | **3861** | |
| Chrome 153 | 153 | 20,2 | no carga | 3676 | |
| Brave 1.96.61 | 154 | 19,0 | **169,9** | 2988 | |
| Thorium 138.0.7204.303 | 138 | 17,9 | 149,9 | 3477 | MotionMark lo tomó como pantalla mediana; Multiply ±33 % |
| **FlyWeb B1d `oficial-6`** | 156 | 15,7 | 160,7 | 2632 | Chromium limpio + parches Mojave; Skia GraphiteDawnMetal |
| Safari | WebKit | 15,6 | 157,9 | 1404 | |
| Firefox 154 | Gecko | 15,2 | 101,0 | (406 a 144 Hz) | detecta 144 Hz con el monitor a 60: no comparable |
| FlyWeb 2.7.0, `--use-angle=metal` | 128 | 10,8 | 131,7 | 874 | |

## MotionMark por pruebas

| Prueba | Chrome 156 | Brave 1.96 | Thorium 138 | oficial-6 | Safari | 2.7.0 Metal |
|---|---|---|---|---|---|---|
| Multiply | 2819 | 1211 | 2364 | 1821 | 1875 | 850 |
| Canvas Arcs | 19515 | 20684 | 18442 | 11633 (±15 %) | 4306 | 1460 |
| Leaves | 2048 | 1304 | 1931 | 1668 | 1071 | 961 |
| Paths | 43751 | 43766 | 37974 | 28506 | 1691 | 1163 |
| Canvas Lines | 39620 | 43584 | 42395 | 25203 | 23321 | 13719 |
| Images | 313 | 189 | 312 | 277 | 213 | 157 |
| Design | 347 | 303 | 301 | 229 | 161 | 185 |
| Suits | 2326 | 1783 | 1681 | 1428 | 1288 | 617 |

## Lectura

- **oficial-6 frente a la 2.7.0 (con Metal):** Speedometer +45 %, JetStream +22 %, MotionMark ×3,0. Con la 2.7.0 en Metal
  MotionMark solo da 874: el salto no es solo Metal, es Graphite y la 156.
- **oficial-6 frente a Chrome 156 (misma base):** Speedometer −25 %, MotionMark −32 %. Sospechoso principal: **PGO** (los
  perfiles de Google, `chrome_pgo_phase`, que en un checkout que no es de Google no se bajan por defecto); después,
  opciones de compilación oficiales. Primera tarea de optimización: comprobarlo y medir con PGO.
- Cada navegador ajeno tiene su pega (JetStream no carga en Chrome, Firefox no detecta el refresco, Thorium otra
  pantalla). Una sola pasada: repetir antes de usar estas cifras para decidir.
