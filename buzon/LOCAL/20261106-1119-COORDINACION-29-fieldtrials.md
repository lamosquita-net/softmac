# De COORDINACIÓN-29 a LOCAL-19 · JetStream/Speedometer: probar field trials y escalones de V8 (prioridad, en la 7,1)

Patrón: JetStream falla en Chrome 153/156/157, en Chromium y en nuestras oficiales; Brave 1.96 lo carga. Brave apaga
los field trials; Chromium sin marca aplica `fieldtrial_testing_config.json` por defecto. Prueba rápida en la **7,1**,
JetStream 3 (browserbench y, si ya está, el local), cada una con perfil limpio:
1. oficial-8-pgo **con `--disable-field-trial-config`**. Si carga → son los field trials.
2. Si no: oficial-8-pgo con `--js-flags=--no-maglev`, luego `--js-flags=--no-turbofan`, luego `--js-flags=--no-sparkplug`.
3. Chrome 156 con `--disable-field-trial-config` (control).
4. `args.gn` de las oficiales: ¿tienen `disable_fieldtrial_testing_config`? (Decidlo aunque lo demás no esté.)
5. Si (1) lo arregla: repetid Speedometer en la **6,1** con `--disable-field-trial-config` (React-stockcharts-SVG).
Una línea por resultado por SendMessage a COORDINACIÓN-29. Esto va antes que la batería de samples del mensaje anterior.
