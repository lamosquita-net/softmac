#!/bin/bash
# Banco de sin/cos de LLVM libc (MOTOR-45). No compila FlyWeb: solo estos .cc con clang.
# Uso: run.sh <ruta a llvm-libc>   (p. ej. flyweb-build/src/third_party/llvm-libc/src, revisión b8b28272d32b)
# En Mac: clang de Xcode. Sin FMA = como la 6,1 y la 5,1; con FMA solo donde la CPU lo tenga (7,1, portátiles 2013+).
set -euo pipefail
L="${1:?ruta a llvm-libc}"; cd "$(dirname "$0")"; O=$(mktemp -d)
C="clang++ -std=c++20 -O2 -ffp-contract=off -DLIBC_NAMESPACE=__llvm_libc_cr -I$L -I$L/include"
NOFMA="-mno-fma -mno-avx -msse3"; FMA="-mfma -mavx2"
clang++ -O2 $NOFMA gen-entradas.cc -o $O/gen && (cd $O && ./gen)          # 110 M entradas (880 MB) en $O/inputs.bin
$C $NOFMA libc-math-flags.cc -o $O/f0 && $C $NOFMA -DFLAGS libc-math-flags.cc -o $O/f1
(cd $O && ./f0 o0.bin && ./f1 o1.bin && cmp o0.bin o1.bin && echo "LIBC_MATH (0003): mismos bits")
$C $NOFMA bench-memo.cc -o $O/memo && $O/memo 3000000                      # identidad y velocidad de la memo
if sysctl -n machdep.cpu.leaf7_features machdep.cpu.features 2>/dev/null | grep -qw FMA; then
  $C $NOFMA eval-fma.cc -o $O/e0 && $C $FMA eval-fma.cc -o $O/e1
  (cd $O && ./e0 a.bin && ./e1 b.bin && (cmp a.bin b.bin && echo "FMA = sin FMA" || echo "FMA y sin FMA difieren (esperado: solo sin(x) con |x| < 2^-1015)"))
  $C $FMA bench-memo.cc -o $O/memo-fma && $O/memo-fma 300000
fi
rm -rf "$O"
