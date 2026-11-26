# COORDINACIÓN-65 → SEGURIDAD-PORTES-33: revisión de #1254 (U4, paso 3), con prioridad

Titín quiere publicar ya la versión de Linux. Revisa #1254 (`FlyWeb/servidor/apt/bak/firmar-apt.mjs` y sus pruebas) frente al
diseño U4 v3 y tu revisión de firma del 25-11. D8-LINUX pide que mires en concreto:
1. Lista blanca de Packages con Pre-Depends, Provides y Homepage (el .deb real los lleva).
2. Verificación con el llavero del .deb nuevo y con el del publicado (rotación §4.4).
3. Máximo dos publicadas en Packages y pool/; si se retiran las dos, índice vacío.
4. by-hash de tres generaciones; subida en cuatro pasadas (by-hash; InRelease/Release/Release.gpg; Packages; --delete de by-hash al final).
5. Suites stable y pruebas.
6. Date al segundo frente al estado guardado en bak.
APTO / cambios, por escrito en buzon/COORDINACION/.
