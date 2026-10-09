// Flags: --allow-natives-syntax --expose-gc
// FlyWeb: exercises JSNativeContextSpecialization::BuildExtendPropertiesBackingStore
// (CVE-2025-13223 backport) with out-of-object fields of every representation
// (Smi, Double, HeapObject, Tagged) interleaved with accessor and constant
// (non-field) descriptors, so the descriptor walk has to skip them.

function getter() { return 7; }

function make(n) {
  let o = {};
  for (let i = 0; i < 4; i++) o['p' + i] = i;           // in-object
  o.s = 1;                                              // Smi
  Object.defineProperty(o, 'acc', {get: getter, configurable: true, enumerable: true});
  o.d = 1.5;                                            // Double
  o.h = {k: n};                                         // HeapObject
  o.t = n % 2 ? 'str' : 3;                              // Tagged (mixed)
  o.f = function() { return n; };                       // constant function
  o.e = 2.25;                                           // Double again
  return o;
}

function extend(o, v) {
  o.newprop = v;   // forces a property backing store extension
  return o;
}

function check(o, n) {
  assertEquals(1, o.s);
  assertEquals(7, o.acc);
  assertEquals(1.5, o.d);
  assertEquals(n, o.h.k);
  assertEquals(n % 2 ? 'str' : 3, o.t);
  assertEquals(n, o.f());
  assertEquals(2.25, o.e);
}

%PrepareFunctionForOptimization(extend);
for (let n = 0; n < 4; n++) check(extend(make(n), {n}), n);
%OptimizeFunctionOnNextCall(extend);
for (let n = 0; n < 2000; n++) {
  let o = extend(make(n), {n});
  check(o, n);
  assertEquals(n, o.newprop.n);
  o.d += 1; assertEquals(2.5, o.d);       // mutate double box after extension
  o.h = {k: -1}; assertEquals(-1, o.h.k);
  if (n % 500 == 0) gc();
}
assertOptimized(extend);
gc();

// Same shape, but a field generalizes (HeapObject -> Tagged) after optimization;
// with the representation dependency the code must deopt and stay correct.
function make2() {
  let o = {};
  for (let i = 0; i < 4; i++) o['q' + i] = i;
  o.x = {}; o.y = {}; o.z = {};
  return o;
}
function grow(o) { o.a = 42; return o; }
%PrepareFunctionForOptimization(grow);
grow(make2());
%OptimizeFunctionOnNextCall(grow);
grow(make2());
let g = make2(); g.x = 5;            // in-place generalization to Tagged
let r = grow(g);
gc();
assertEquals(5, r.x);
assertEquals(42, r.a);
