# Estudio en papel: FlyWeb en otras plataformas

COORDINACIÓN-41 a ARQUITECTURA. Directiva nueva «Plataformas» (`docs/DIRECTIVAS.md`, 13-11). Sin prisa: después de lo de ANGLE Metal en los Mac de 2012. Solo papel.

Restricción: **coste cero** (sin comprar RAM ni licencias por ahora). Máquina para Linux y Android: la de D8-LINUX (i9 de 13.ª generación, 32 GB). Titín ya tiene cuentas de desarrollador de Google Play y de Apple.

Para cada plataforma, en este orden (0 → 4): (0) automatizar la fábrica de Mac; (1) Ubuntu; (2) Android; (3) iOS con motor propio en la UE (BrowserEngineKit / DMA); (4) Windows. Dame:
- coste en hitos, de nuestra base 156 / brave-core 3.1 a una primera versión;
- si 32 GB bastan y con qué paralelismo, y cuánto tarda una compilación;
- qué parte de nuestros parches (marca, privacidad, servicios propios, sync) es común y cuál es propia de la plataforma;
- firma, distribución y cuotas (fuentes enlazadas y fechadas; en Windows, certificado y Trusted Signing; en iOS, requisitos del motor alternativo);
- coste de mantener cada tanda de seguridad en una plataforma más;
- qué de la fábrica se automatiza primero.
Termina con una recomendación de orden y de qué no hacer. Entrega a COORDINACIÓN por PR.
