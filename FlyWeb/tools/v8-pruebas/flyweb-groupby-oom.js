// FlyWeb (SEGURIDAD, FS.3): Object.groupBy / Map.groupBy with more groups than an OrderedHashMap can hold must throw a
// RangeError, not crash the process (v8 77df647d + 92aba703, brave-core seg/v8-groupby-contexto). Needs ~2 GB of heap.
// Runs in d8 (with mjsunit.js) and, without the asserts, in a FlyWeb console: it must print the RangeError.
const N = 17000000;
function iterable() {
  return {[Symbol.iterator]() {
    let i = 0;
    return {next() { return i < N ? {value: i++, done: false} : {done: true}; }};
  }};
}
for (const f of [Object.groupBy, Map.groupBy]) {
  let error;
  try { f.call(f === Map.groupBy ? Map : Object, iterable(), x => x); } catch (e) { error = e; }
  if (typeof assertInstanceof === 'function') assertInstanceof(error, RangeError);
  else console.log(error);
}
