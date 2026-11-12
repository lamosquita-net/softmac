// Prototipo de memo perezosa sin/cos (MOTOR-45, 12-11-2026). NO es un parche: banco de pruebas.
// Las colas de Sin()/Cos() copian las de LLVM libc src/__support/math/{sin,cos}.h
// (Apache-2.0 WITH LLVM-exception), revisión b8b28272d32b (la de Chromium 156).
#include "shared/math/sin.h"
#include "shared/math/cos.h"
#include <cstdint>
#include <cstring>
namespace memo {
using namespace LIBC_NAMESPACE;
using fputil::DoubleDouble;
struct Reduced { uint64_t x_bits; unsigned k; DoubleDouble sin_y, cos_y; double err; };
// One entry per thread per function result kind is not enough for Aquarium
// (sin(A), sin(B), cos(A)); keep the last two reductions.
struct Memo { Reduced e[2]; unsigned next; };
inline thread_local Memo t_memo = {{{~0ull, 0, {}, {}, 0}, {~0ull, 0, {}, {}, 0}}, 0};

// Returns false when the memo does not apply (|x| < 2^-4, Inf, NaN).
inline bool Reduce(double x, Reduced** out) {
  using namespace math::range_reduction_double_internal;
  using FPBits = fputil::FPBits<double>;
  FPBits xbits(x);
  uint16_t x_e = xbits.get_biased_exponent();
  if (x_e < FPBits::EXP_BIAS - 4 || x_e > 2 * FPBits::EXP_BIAS) return false;
  uint64_t bits = xbits.uintval();
  Memo& m = t_memo;
  if (m.e[0].x_bits == bits) { *out = &m.e[0]; return true; }
  if (m.e[1].x_bits == bits) { *out = &m.e[1]; return true; }
  Reduced& r = m.e[m.next]; m.next ^= 1;
  DoubleDouble y;
  if (x_e < FPBits::EXP_BIAS + FAST_PASS_EXPONENT) {
    r.k = range_reduction_small(x, y);
  } else {
    LargeRangeReduction range_reduction_large{};
    r.k = range_reduction_large.fast(x, y);
  }
  r.err = math::sincos_eval_internal::sincos_eval(y, r.sin_y, r.cos_y);
  r.x_bits = bits;
  *out = &r;
  return true;
}

inline double Sin(double x) {
  using namespace math::range_reduction_double_internal;
  Reduced* r;
  if (!Reduce(x, &r)) return shared::sin(x);
  unsigned k = r->k;
  DoubleDouble sin_k = SIN_K_PI_OVER_128[k & 255];
  DoubleDouble cos_k = SIN_K_PI_OVER_128[(k + 64) & 255];
  DoubleDouble sin_k_cos_y = fputil::quick_mult(r->cos_y, sin_k);
  DoubleDouble cos_k_sin_y = fputil::quick_mult(r->sin_y, cos_k);
  DoubleDouble rr = fputil::exact_add(sin_k_cos_y.hi, cos_k_sin_y.hi);
  rr.lo += sin_k_cos_y.lo + cos_k_sin_y.lo;
  double rlp = rr.lo + r->err;
  double rlm = rr.lo - r->err;
  double r_upper = rr.hi + rlp;
  double r_lower = rr.hi + rlm;
  if (r_upper == r_lower) [[likely]] return r_upper;
  return shared::sin(x);  // Ziv's test failed: the reference takes the accurate pass.
}

inline double Cos(double x) {
  using namespace math::range_reduction_double_internal;
  Reduced* r;
  if (!Reduce(x, &r)) return shared::cos(x);
  unsigned k = r->k;
  DoubleDouble msin_k = SIN_K_PI_OVER_128[(k + 128) & 255];
  DoubleDouble cos_k = SIN_K_PI_OVER_128[(k + 64) & 255];
  DoubleDouble cos_k_cos_y = fputil::quick_mult(r->cos_y, cos_k);
  DoubleDouble msin_k_sin_y = fputil::quick_mult(r->sin_y, msin_k);
  DoubleDouble rr = fputil::exact_add(cos_k_cos_y.hi, msin_k_sin_y.hi);
  rr.lo += msin_k_sin_y.lo + cos_k_cos_y.lo;
  double rlp = rr.lo + r->err;
  double rlm = rr.lo - r->err;
  double r_upper = rr.hi + rlp;
  double r_lower = rr.hi + rlm;
  if (r_upper == r_lower) [[likely]] return r_upper;
  return shared::cos(x);
}
}  // namespace memo
