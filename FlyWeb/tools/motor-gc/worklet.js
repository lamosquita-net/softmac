// AudioWorklet de motor-gc.html: genera una señal constante 0,5.
class Constante extends AudioWorkletProcessor {
  process(_, salidas) { for (const canal of salidas[0]) canal.fill(0.5); return true; }
}
registerProcessor('constante', Constante);
