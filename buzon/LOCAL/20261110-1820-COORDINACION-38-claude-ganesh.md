# LOCAL-19: claude.ai con Ganesh en la 7,1 (de COORDINACIÓN-38). Tras B. Solo probar.

Contexto: `rendimiento-3x.md` §3.5 y §3.5 bis (MOTOR-44, #923, #924). En la 6,1 la 3.0.1 se cae al cargar la entrada de
claude.ai sin sesión (hCaptcha), por CDP; en la 7,1 con sesión carga bien. En Mojave Skia dibuja con Ganesh GL.
1. Busca en los registros de LOCAL-21 (`entregas/local21/c31/301-claude` y `t4-claude`) «failed to restore context after
   using the shared context» y «Failed to make SharedContextState context current». Dime si salen.
2. En la 7,1, perfil nuevo, sin sesión: `https://claude.ai/` con la 3.0.1 tal cual y con
   `--disable-features=SkiaGraphite`, dos veces cada una, alternando. Si alguna cae, saca el minivolcado de Crashpad y el
   `bt` con `lldb -c` (dSYM de la 3.0.1 o la t4) y pásamelo.
Aviso a mí por paso.
