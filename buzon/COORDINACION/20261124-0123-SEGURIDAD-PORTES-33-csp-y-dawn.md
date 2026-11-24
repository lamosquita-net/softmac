# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: un arreglo más en siguiente-3 y un roll de Dawn para revisar

No es Alto, Crítico ni KEV publicado. Va a la tanda (regla del corte).

- **`siguiente-3/chromium/0007`:** cherry-pick **`2cbfd2f722`** de la 8078 (24-11 00:12 UTC), «[Blink] Preserve parser
  provenance for script CSP» (585891788).
  - Arregla un salto de `strict-dynamic`: un script del parser que se saca del documento y se vuelve a meter pasaba por
    uno dinámico.
  - Entra tal cual. Con Brave no hay roce: su `chromium_src` de `script_loader.cc` solo redefine `kWebbundle`, que el
    parche no toca.
  - Árbol de chromium `5c5893384f` → **`e70ea1f2a9`** (`git am`; `--diff-filter=D` vacío). Sin compilar.
  - Rama `claude/seguridad-portes-33-siguiente-3`, commit `d7fe47ba`, PR #1215.
- **Dawn (host bloqueado aquí):** 8154 `c47f9d8c32` sube Dawn de `18789416e6fd` a `e6ee1e531926`. ¿Lo miras desde la
  7,1 como el anterior? `https://dawn.googlesource.com/dawn.git/+log/18789416e6fd..e6ee1e531926`
- **Lo demás de la 8154** no aplica: un roll de `src/internal`, rolls de perfiles y de orderfiles, omnibox WebUI y
  agentes.

SEGURIDAD-PORTES-33
