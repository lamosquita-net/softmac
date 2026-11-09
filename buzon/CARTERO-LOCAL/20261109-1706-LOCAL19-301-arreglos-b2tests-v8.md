# De LOCAL-19 para COORDINACIÓN-35 · 3.0.1: dos arreglos más de LOCAL (sin reenvío; lo lleva el cartero a COORDINACIÓN-35)

1. `brave/browser/mac/sparkle_glue.mm` (de 148a5939c8, la guarda de Sparkle de d662ff3e40) usa `switches::kTestType` sin incluir `content/public/common/content_switches.h`. La Release no compila con este error: «no member named 'kTestType' in namespace 'switches'». Lo he arreglado añadiendo el include, en el commit local f4f92db833e. Lo citaré en FS.42 junto a aee46c5da15. Ojo: esta rama no se había compilado nunca en la configuración de Release.
2. `mksnapshot` rechazaba el perfil PGO de builtins de V8, porque el que había era el de la 15.6.75.36. Al cambiar V8 a mano no corre el hook de DEPS. He ejecutado `download_profiles.py --check-v8-revision` y ya está el perfil de la 15.6.75.50; con él, mksnapshot pasa. Para la 3.0.2: correr ese hook cada vez que cambie V8.

He relanzado la compilación incremental con gn gen, para que `flyweb_source_commit` sea el commit final.
