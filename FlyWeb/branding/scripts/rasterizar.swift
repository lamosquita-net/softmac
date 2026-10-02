// Rasteriza un SVG (o PNG) a un PNG de tamaño exacto, con AppKit (sin Playwright ni Illustrator).
// Uso: rasterizar <entrada.svg> <ancho> <alto> <salida.png> [tinte #rrggbb|-] [margen 0..0.5]
// - Encaja el dibujo manteniendo la proporción y lo centra (como lamina.swift).
// - tinte: pinta toda la silueta de un color (p. ej. #ffffff para la mosca blanca de Escudos).
// - margen: fracción del lado que se deja libre en cada borde.
// Compilar una vez: swiftc -O rasterizar.swift -o rasterizar
import AppKit

let a = CommandLine.arguments
guard a.count >= 5, let w = Int(a[2]), let h = Int(a[3]) else {
  FileHandle.standardError.write("uso: rasterizar <svg> <ancho> <alto> <salida.png> [tinte] [margen]\n".data(using: .utf8)!)
  exit(2)
}
let tinte = a.count > 5 && a[5] != "-" ? a[5] : nil
let margen = a.count > 6 ? CGFloat(Double(a[6]) ?? 0) : 0
guard let img = NSImage(contentsOfFile: a[1]) else { print("no se puede leer \(a[1])"); exit(1) }

func color(_ hex: String) -> NSColor {
  var s = hex; if s.hasPrefix("#") { s.removeFirst() }
  var v: UInt64 = 0; Scanner(string: s).scanHexInt64(&v)
  return NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255, blue: CGFloat(v & 0xff) / 255, alpha: 1)
}

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: w, height: h)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current!.imageInterpolation = .high
let mx = CGFloat(w) * margen, my = CGFloat(h) * margen
let aw = CGFloat(w) - 2 * mx, ah = CGFloat(h) - 2 * my
let k = min(aw / img.size.width, ah / img.size.height)
let dw = img.size.width * k, dh = img.size.height * k
img.draw(in: NSRect(x: (CGFloat(w) - dw) / 2, y: (CGFloat(h) - dh) / 2, width: dw, height: dh))
if let t = tinte { color(t).setFill(); NSRect(x: 0, y: 0, width: w, height: h).fill(using: .sourceIn) }
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[4]))
