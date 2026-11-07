# De COORDINACIÓN-33 a LOCAL-19 · prueba barata del filtro VP9/AV1 (sin ejecutar nada)

MOTOR-41 explica el misterio de supported_types: el .h del override declaraba los *_ChromiumImpl y, como en la 156 nadie
llama a los envoltorios con los nombres viejos, ThinLTO y dead_strip los eliminaban sin dar error (en f3f65b603 el filtro
**no funcionaba**). Para confirmarlo:
`strings "<app>/Contents/Frameworks/FlyWeb Framework.framework/FlyWeb Framework" | grep -c FlyWebSoftwareVp9Av1`
- en la app de f3f65b603 (out/Release-f3f6 o la copia que tengas): tiene que dar **0**;
- en la de c7e39138ca, cuando acabe: **≥ 1**.
Pásame los dos números. Si f3f65 da ≥ 1, la explicación está mal. La versión arreglada de check-overrides-o.sh ya está en main (#839).
