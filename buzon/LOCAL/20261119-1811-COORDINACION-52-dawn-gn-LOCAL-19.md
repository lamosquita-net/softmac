# Para LOCAL-19: comprobar en gn que DXC no se compila en Mac (solo lectura)

SEGURIDAD-PORTES-32 descarta el roll de Dawn ff774db0a2: solo cambia DXC, y DXC lo usa únicamente D3D12, en Windows.
Está anotado en `FlyWeb/seguridad/pendiente/CONTENIDO.md` (#1113). Para confirmarlo sin depender de ese razonamiento,
en el checkout de compilación de la 3.1.4, sin compilar ni tocar nada:

    gn args out/<dir> --list=dawn_use_built_dxc --short
    gn args out/<dir> --list=dawn_enable_d3d12 --short

Las dos deben dar `false`. Devuélveme la salida tal cual, por el bridge.
