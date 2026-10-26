# Relevo de MOTOR: de MOTOR-19 a MOTOR-20 (26-10-2026, ~18:25)

MOTOR-19 (`session_017Tq5AVGdzh2afxt2uAe97F`, Opus 5.5, alto) hizo la 2.0.1 (FM.40). **Se archiva sin relevo activo**
(directiva: no se espera con una sesión abierta); MOTOR-20 se abre cuando lleguen los resultados de LOCAL o la captura de Titín.
Todo en `FlyWeb/docs/version-2.0.1.md` (PR #513).

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p19` (2.0.1) | 4b4bb3cc68 | bundle `p16-p19.bundle` en la rama de softmac `nube/motor19-p19` (sin push a brave-core; lo sube LOCAL) |

**Lo que queda (tuyo):**

1. **Resultados de LOCAL** (orden `buzon/LOCAL/20261026-1815-MOTOR-19.md`): Release de la -p19 (build 29), `--simulate-outdated`
   en 2.0.0 frente a 2.0.1, Sparkle intacto (Acerca de > buscar y relanzar), «FlyWeb Sync», NTP con 7 fondos, y el `build.sh`
   nuevo (`FLYWEB_BASE=128`) frente a su guion: corregir lo que diga.
2. **Pestañas fijadas** (prueba de 5 pasos, §3 de `version-2.0.1.md`): si apunta a las fijadas compartidas, portar a la 2.0.x el
   arreglo `restored_browsers_`/`SynchronizeRestoredBrowser` de la 1.15 (brave-core `flyweb`, `browser/ui/tabs/shared_pinned_tab_service.cc`)
   sobre el de la 1.69, que sincroniza al activar comparando URL.
3. **Passkey «Brave»**: con la captura de Titín. Ninguna cadena nuestra lo dice; mirar si lo pone el teléfono/Google
   (identificación por client hints o UA) antes de tocar nada.
4. Barrido de marca (§2e): propuestas a Titín; nada de .grd/.xtb a mano. Usuario `@brave.com` y ruta `braveSync`, no se tocan.

**Trampas nuevas:** en `docs/TRAMPAS.md` (MOTOR, 26-10: guardas que la base nueva quita; `grd_string_replacements.py`). Además:
- raw.githubusercontent.com da **429** a menudo con etiquetas de la 116 (la 128 va mejor); reintentar con pausas de 15–20 s.
  `git fetch` de github.com/chromium/chromium da 504.
- `git grep` sobre una rama traída con `--filter=blob:none` baja blob a blob: solo `git show rama:fichero` concreto.
- `pkill -f` volvió a matar el propio shell (ya estaba en las trampas de MOTOR-17).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-17; MOTOR-18 no dejó nota propia): [`relevo-motor-historial.md`](relevo-motor-historial.md).
