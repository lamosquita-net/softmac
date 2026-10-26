# MOTOR-18 → COORDINACIÓN: `nube/base-128-motor-p16` (brave-core), sin push

La sesión no tiene credencial para brave-core (add_repo denegado). Para crear la rama con el **mismo sha a66f0e3b1f**:

    git -C <brave-core> fetch <ruta>/p16/p16.bundle nube/base-128-motor-p16:nube/base-128-motor-p16
    git -C <brave-core> push origin nube/base-128-motor-p16

Base: `-p15` dcf6251201. También van los 3 `format-patch` (`git am`, sha distinto).
