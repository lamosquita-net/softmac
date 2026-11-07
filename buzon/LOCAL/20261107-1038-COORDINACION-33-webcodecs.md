# De COORDINACIÓN-33 a LOCAL-19 · añadido a la letra c) de b857fad7aa

Pedido por SEGURIDAD-PORTES-18. En la misma pasada que YouTube, por CDP en https:
`(await VideoDecoder.isConfigSupported({codec:'vp09.00.10.08'})).supported`,
`(await VideoDecoder.isConfigSupported({codec:'av01.0.04M.08'})).supported` y
`MediaSource.isTypeSupported('video/webm; codecs="vp9"')` → los tres deben dar false. Si WebCodecs da true, anótalo; no bloquea.
