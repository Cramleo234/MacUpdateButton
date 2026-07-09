import AppKit
import Foundation

let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = projectRoot.appendingPathComponent("App/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

func makeBaseIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    rect.fill()

    let inset = size * 0.03125
    let cornerRadius = size * 0.215
    let iconRect = rect.insetBy(dx: inset, dy: inset)
    let shape = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    shape.addClip()

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.06, green: 0.55, blue: 1.0, alpha: 1.0),
        NSColor(calibratedRed: 0.03, green: 0.26, blue: 0.84, alpha: 1.0),
        NSColor(calibratedRed: 0.10, green: 0.10, blue: 0.42, alpha: 1.0)
    ])!
    gradient.draw(in: iconRect, angle: -45)

    NSColor.white.withAlphaComponent(0.18).setFill()
    NSBezierPath(ovalIn: NSRect(x: -size * 0.12, y: size * 0.44, width: size * 0.92, height: size * 0.70)).fill()

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.25)
    shadow.shadowBlurRadius = size * 0.018
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.018)
    shadow.set()

    let ring = NSBezierPath()
    ring.appendArc(withCenter: NSPoint(x: size * 0.5, y: size * 0.5), radius: size * 0.268, startAngle: 34, endAngle: 323, clockwise: false)
    ring.lineWidth = size * 0.074
    ring.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.96).setStroke()
    ring.stroke()

    NSShadow().set()

    // Arrow head for circular update ring.
    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: size * 0.748, y: size * 0.758))
    arrow.line(to: NSPoint(x: size * 0.887, y: size * 0.719))
    arrow.line(to: NSPoint(x: size * 0.787, y: size * 0.622))
    arrow.close()
    NSColor.white.withAlphaComponent(0.96).setFill()
    arrow.fill()

    // Download arrow inside.
    let accent = NSColor(calibratedRed: 0.02, green: 0.20, blue: 0.54, alpha: 1.0)
    accent.setFill()
    NSBezierPath(roundedRect: NSRect(x: size * 0.463, y: size * 0.420, width: size * 0.074, height: size * 0.260), xRadius: size * 0.037, yRadius: size * 0.037).fill()

    let down = NSBezierPath()
    down.move(to: NSPoint(x: size * 0.5, y: size * 0.315))
    down.line(to: NSPoint(x: size * 0.348, y: size * 0.488))
    down.line(to: NSPoint(x: size * 0.455, y: size * 0.488))
    down.line(to: NSPoint(x: size * 0.455, y: size * 0.438))
    down.line(to: NSPoint(x: size * 0.545, y: size * 0.438))
    down.line(to: NSPoint(x: size * 0.545, y: size * 0.488))
    down.line(to: NSPoint(x: size * 0.652, y: size * 0.488))
    down.close()
    down.fill()

    NSBezierPath(roundedRect: NSRect(x: size * 0.334, y: size * 0.237, width: size * 0.332, height: size * 0.066), xRadius: size * 0.033, yRadius: size * 0.033).fill()

    let border = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    border.lineWidth = size * 0.008
    NSColor.white.withAlphaComponent(0.34).setStroke()
    border.stroke()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, size: Int, filename: String) throws {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "UpdatePilotIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not render PNG"])
    }

    rep.size = NSSize(width: size, height: size)
    guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
        throw NSError(domain: "UpdatePilotIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create bitmap context"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), operation: .copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "UpdatePilotIcon", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not encode PNG"])
    }

    try png.write(to: outputURL.appendingPathComponent(filename))
}

let base = makeBaseIcon(size: 1024)
let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
    ("icon_preview_1024.png", 1024)
]

for (filename, size) in sizes {
    try savePNG(base, size: size, filename: filename)
}

print("Generated UpdatePilot app icon set in \(outputURL.path)")
