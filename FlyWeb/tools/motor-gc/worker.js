// Worker de motor-gc.html: devuelve lo que recibe y comprueba DOM de worker (OffscreenCanvas, fetch, Blob).
onmessage = async (e) => {
  const r = { tipo: e.data && e.data.constructor && e.data.constructor.name };
  try {
    if (e.data instanceof Blob) r.texto = await e.data.text();
    if (typeof ImageBitmap !== 'undefined' && e.data instanceof ImageBitmap) r.ancho = e.data.width;
    const c = new OffscreenCanvas(8, 8); const x = c.getContext('2d'); x.fillStyle = '#f00'; x.fillRect(0, 0, 8, 8);
    r.pixel = Array.from(x.getImageData(1, 1, 1, 1).data).join(',');
    r.fetch = (await (await fetch('blank.html')).text()).length > 0;
  } catch (err) { r.error = String(err); }
  postMessage([r, e.data]);
};
