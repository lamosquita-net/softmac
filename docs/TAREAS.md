# Tablero de tareas y reparto entre agentes

Hay dos agentes de Claude trabajando en paralelo, más el humano (titín), que decide y prueba en los Mac.
Este fichero es **la única fuente de verdad** sobre quién hace qué. Hay que leerlo al empezar cada sesión.

| Agente | Dónde corre | Puede | No puede |
|---|---|---|---|
| **NUBE** | Contenedor Linux (claude.ai/code) | Investigar, escribir código, parches, scripts y documentación, compilar Go (BackupDrive) y probar en Linux, CI, PRs | Compilar Chromium, ejecutar nada de macOS, ver los discos del Mac |
| **LOCAL** | MacPro7,1 (Claude Code local) | Compilar FlyWeb, ejecutar y medir, Xcode, firma y notarización, scripts que necesitan el checkout de Chromium | Trabajar sin el Mac encendido |
| **HUMANO** | — | Decisiones, credenciales (Google, Apple), pruebas en la 6,1 y la 5,1, iconos | — |

## Reglas para no pisarse

1. **Reclamar antes de empezar:** poner tu nombre en la columna "Quién" y el estado `en curso`, hacer commit y
   push, y solo entonces empezar. No tocar tareas `en curso` de otro agente.
2. **Ramas separadas:**
   - `softmac`: NUBE trabaja en `claude/*` y abre PRs. LOCAL trabaja en `local/*` y abre PRs. Nadie hace push directo a `main`.
   - `brave-core` / `brave-browser`: **solo LOCAL escribe en `flyweb`**, porque es quien compila y prueba. NUBE
     propone cambios en ramas `nube/<tema>` del fork. LOCAL los compila y, si funcionan, los fusiona en `flyweb`.
3. **Ficheros compartidos** (`CLAUDE.md`, este tablero): cambios pequeños y frecuentes. Antes de editar, `git pull`.
   Cada agente edita solo sus filas.
4. **Entregas entre agentes:** en "Notas", qué se deja hecho y qué necesita el otro (por ejemplo "rama
   `nube/jitless` lista para compilar").
5. **Nunca en el repo:** tokens, `backupdrive.conf`, contraseñas ni certificados.
6. Cuando una tarea termina: estado `hecho`, más el enlace al PR o commit.

Estados: `pendiente` · `en curso` · `bloqueada` · `hecho`.

## Tablero

### FlyWeb — Fase 0 (compilación)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F0.1 | Terminar `gclient sync` (plan B con `-j 4`) y `npm run sync` | HUMANO/LOCAL | en curso | falló por HTTP 429 de googlesource |
| F0.2 | Primera compilación con `build.sh`; validar `mac_sdk_path` con Xcode 26 activo | LOCAL | pendiente | necesita F0.1 y el PR #3 fusionado |
| F0.3 | Script de comprobación AVX en los comandos de compilación | NUBE | hecho | `FlyWeb/scripts/check-no-avx.sh`; LOCAL: ejecutarlo tras cada `gn gen`/build |
| F0.4 | `build.sh`: sello de versión y commits en el `.app`, soporte sccache | NUBE | pendiente | |
| F0.5 | Firma Developer ID y notarización con `notarytool` | LOCAL | pendiente | necesita el certificado del HUMANO |
| F0.6 | Prueba de arranque en la 6,1 y la 5,1 | HUMANO | pendiente | después de F0.2 |

### FlyWeb — Fase 1 (marca y servicios)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F1.1 | Marca: nombre, bundle id, perfil, llavero, iconos | NUBE | hecho | brave-core `flyweb` 77b25c6b |
| F1.2 | Reglas de sustitución Brave→FlyWeb en `script/lib/l10n/grd_string_replacements.py` | NUBE | pendiente | rama `nube/l10n` |
| F1.3 | Ejecutar `chromium-rebase-l10n.py` con esas reglas y hacer commit de las cadenas | LOCAL | pendiente | necesita F0.1 y F1.2 |
| F1.4 | Parches: referrals, stats ping, Talk y News desactivados | NUBE | pendiente | rama `nube/servicios` |
| F1.5 | Script de auditoría de red (mitmproxy) con lista de permitidos | NUBE | pendiente | |
| F1.6 | Ejecutar la auditoría de red durante 30 minutos | LOCAL | pendiente | necesita F0.2 y F1.5 |

### FlyWeb — Fase 3A (seguridad inmediata)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F3A.1 | Parche: jitless por defecto y lista de sitios con JIT | NUBE | hecho | brave-core rama `nube/jitless` (6b81fc54): **LOCAL: compilar y, si funciona, fusionar en `flyweb`**. Lista de permitidos: `FlyWeb/policies/flyweb-jit-allowlist.mobileconfig` |
| F3A.2 | Medir jitless en claude.ai, Gmail, Docs, Sheets y Drive | LOCAL/HUMANO | pendiente | |
| F3A.3 | Triaje de CVE explotados posteriores a 116 → `FlyWeb/docs/cve-triage.md` | NUBE | hecho | 25 CVE, jitless mitiga seguro 4; 4 fugas del sandbox en macOS |
| F3A.4 | Desactivar WebGPU por defecto (CVE-2026-5281) | NUBE | hecho | brave-core rama `nube/webgpu-off`: override de `kWebGPUService` en `chromium_src/gpu/config/gpu_finch_features.cc`. **LOCAL: compilar, comprobar `navigator.gpu === undefined` y fusionar en `flyweb`** |
| F3A.5 | Portar fugas del sandbox: CVE-2025-6558 (ANGLE), CVE-2024-4671 (viz), CVE-2023-6345 (Skia) | NUBE | en curso | una rama `nube/cve-XXXX` por CVE; parches sobre `src/` en `brave-core/patches/` |
| F3A.6 | ¿Lleva `third_party/libvpx` el arreglo de CVE-2023-5217? | LOCAL | pendiente | mirar `git log` de `src/third_party/libvpx/source/libvpx` tras F0.1 |
| F3A.7 | Confirmar en Chrome Releases el "in the wild" de CVE-2026-3909 y CVE-2026-5281 | NUBE | pendiente | no están en la copia actual de KEV |

### BackupDrive
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| B.1 | Crear el OAuth client de Google y el `backupdrive.conf` | HUMANO/LOCAL | en curso | en la MacPro7,1 |
| B.2 | Probar `bisync` contra Drive real en Mojave (`--dry-run` → `--resync` → launchd) | HUMANO | pendiente | en la 6,1 |
| B.3 | Iconos de barra de menús: trazos más gruesos | HUMANO | pendiente | ver revisión del PR #3 |
| B.4 | App Cocoa de barra de menús (Xcode 11, Mojave) | LOCAL | pendiente | después de B.2 |
