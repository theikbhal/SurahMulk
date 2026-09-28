import AppKit

// Generates Resources/AppIcon.png (1024px) — deep green/gold gradient + crescent.
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Resources/AppIcon.png"
let px = 1024

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: px,
    pixelsHigh: px,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("could not create bitmap")
}

rep.size = NSSize(width: px, height: px)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let rect = NSRect(x: 0, y: 0, width: px, height: px)
let path = NSBezierPath(roundedRect: rect.insetBy(dx: 10, dy: 10), xRadius: 210, yRadius: 210)

let top = NSColor(red: 0.09, green: 0.42, blue: 0.30, alpha: 1)
let bottom = NSColor(red: 0.04, green: 0.20, blue: 0.24, alpha: 1)
NSGradient(colors: [top, bottom])?.draw(in: path, angle: -90)

let config = NSImage.SymbolConfiguration(pointSize: 430, weight: .semibold)
    .applying(NSImage.SymbolConfiguration(paletteColors: [NSColor.systemYellow, NSColor.systemYellow]))

if let symbol = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let size = symbol.size
    let drawRect = NSRect(
        x: (CGFloat(px) - size.width) / 2,
        y: (CGFloat(px) - size.height) / 2,
        width: size.width,
        height: size.height
    )
    symbol.draw(in: drawRect)
}

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("could not encode png")
}

let url = URL(fileURLWithPath: outPath)
try FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try png.write(to: url)
print("wrote \(outPath)")
