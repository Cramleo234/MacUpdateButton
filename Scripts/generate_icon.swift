import AppKit
import Foundation

let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = projectRoot.appendingPathComponent("App/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func point(_ x: CGFloat, _ y: CGFloat, _ size: CGFloat) -> NSPoint {
    NSPoint(x: x * size, y: y * size)
}

func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ size: CGFloat) -> NSRect {
    NSRect(x: x * size, y: y * size, width: width * size, height: height * size)
}

func makeBaseIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let canvas = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    canvas.fill()

    let inset = size * 0.032
    let iconRect = canvas.insetBy(dx: inset, dy: inset)
    let cornerRadius = size * 0.218
    let iconShape = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    iconShape.addClip()

    NSGradient(colors: [
        color(0.05, 0.88, 0.90),
        color(0.05, 0.43, 0.96),
        color(0.17, 0.08, 0.46)
    ])!.draw(in: iconRect, angle: -42)

    // Soft depth and glass, macOS-ish but not that old blue lump again.
    NSGradient(colors: [
        color(1.0, 1.0, 1.0, 0.22),
        color(1.0, 1.0, 1.0, 0.02)
    ])!.draw(in: NSBezierPath(ovalIn: rect(-0.18, 0.48, 1.02, 0.58, size)), angle: -18)

    NSGradient(colors: [
        color(0.02, 0.05, 0.16, 0.00),
        color(0.02, 0.05, 0.16, 0.34)
    ])!.draw(in: rect(0.03, 0.03, 0.94, 0.52, size), angle: 90)

    // Outer instrument ring: UpdatePilot as a small cockpit/update dial.
    let dialCenter = point(0.50, 0.49, size)
    let outerDial = NSRect(x: dialCenter.x - size * 0.335, y: dialCenter.y - size * 0.335, width: size * 0.67, height: size * 0.67)

    let dialShadow = NSShadow()
    dialShadow.shadowColor = color(0.00, 0.02, 0.10, 0.35)
    dialShadow.shadowBlurRadius = size * 0.028
    dialShadow.shadowOffset = NSSize(width: 0, height: -size * 0.018)
    dialShadow.set()

    color(0.02, 0.07, 0.22, 0.25).setFill()
    NSBezierPath(ovalIn: outerDial).fill()
    NSShadow().set()

    NSGradient(colors: [
        color(0.92, 1.0, 1.0, 0.96),
        color(0.62, 0.95, 1.0, 0.90),
        color(0.18, 0.42, 0.96, 0.52)
    ])!.draw(in: NSBezierPath(ovalIn: outerDial), angle: -35)

    color(0.03, 0.10, 0.30, 0.82).setFill()
    NSBezierPath(ovalIn: outerDial.insetBy(dx: size * 0.045, dy: size * 0.045)).fill()

    NSGradient(colors: [
        color(0.09, 0.72, 0.96, 0.72),
        color(0.08, 0.18, 0.58, 0.95)
    ])!.draw(in: NSBezierPath(ovalIn: outerDial.insetBy(dx: size * 0.083, dy: size * 0.083)), angle: -42)

    // Update arc, deliberately broken so it reads as motion at small sizes.
    let arc = NSBezierPath()
    arc.appendArc(withCenter: dialCenter, radius: size * 0.276, startAngle: 213, endAngle: 505, clockwise: false)
    arc.lineWidth = size * 0.050
    arc.lineCapStyle = .round
    color(0.93, 1.0, 1.0, 0.96).setStroke()
    arc.stroke()

    let arcHead = NSBezierPath()
    arcHead.move(to: point(0.815, 0.548, size))
    arcHead.line(to: point(0.885, 0.636, size))
    arcHead.line(to: point(0.777, 0.652, size))
    arcHead.close()
    color(0.93, 1.0, 1.0, 0.98).setFill()
    arcHead.fill()

    // Tiny tick marks like a cockpit gauge. They disappear gracefully at 16px.
    color(0.85, 1.0, 1.0, 0.45).setStroke()
    for tick in stride(from: 210.0, through: 330.0, by: 30.0) {
        let radians = CGFloat(tick) * .pi / 180
        let inner = size * 0.210
        let outer = size * 0.242
        let start = NSPoint(x: dialCenter.x + cos(radians) * inner, y: dialCenter.y + sin(radians) * inner)
        let end = NSPoint(x: dialCenter.x + cos(radians) * outer, y: dialCenter.y + sin(radians) * outer)
        let mark = NSBezierPath()
        mark.move(to: start)
        mark.line(to: end)
        mark.lineWidth = size * 0.010
        mark.lineCapStyle = .round
        mark.stroke()
    }

    // Pilot/navigation mark: an upward paper-plane arrow. Better silhouette than the old download blob.
    let planeShadow = NSShadow()
    planeShadow.shadowColor = color(0.00, 0.02, 0.10, 0.36)
    planeShadow.shadowBlurRadius = size * 0.026
    planeShadow.shadowOffset = NSSize(width: 0, height: -size * 0.016)
    planeShadow.set()

    let plane = NSBezierPath()
    plane.move(to: point(0.500, 0.735, size))
    plane.line(to: point(0.665, 0.325, size))
    plane.curve(to: point(0.520, 0.405, size), controlPoint1: point(0.615, 0.366, size), controlPoint2: point(0.565, 0.392, size))
    plane.line(to: point(0.500, 0.268, size))
    plane.line(to: point(0.480, 0.405, size))
    plane.curve(to: point(0.335, 0.325, size), controlPoint1: point(0.435, 0.392, size), controlPoint2: point(0.385, 0.366, size))
    plane.close()

    NSGradient(colors: [
        color(1.0, 1.0, 1.0, 1.0),
        color(0.70, 0.96, 1.0, 0.96),
        color(0.17, 0.82, 0.96, 0.94)
    ])!.draw(in: plane, angle: -90)
    NSShadow().set()

    color(1.0, 1.0, 1.0, 0.30).setFill()
    let planeHighlight = NSBezierPath()
    planeHighlight.move(to: point(0.500, 0.666, size))
    planeHighlight.line(to: point(0.565, 0.445, size))
    planeHighlight.curve(to: point(0.505, 0.476, size), controlPoint1: point(0.546, 0.462, size), controlPoint2: point(0.524, 0.473, size))
    planeHighlight.close()
    planeHighlight.fill()

    // Subtle lower base to keep the icon grounded in the Dock.
    color(0.01, 0.08, 0.26, 0.34).setFill()
    NSBezierPath(roundedRect: rect(0.318, 0.194, 0.364, 0.045, size), xRadius: size * 0.022, yRadius: size * 0.022).fill()

    let border = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    border.lineWidth = size * 0.008
    color(1.0, 1.0, 1.0, 0.32).setStroke()
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
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in sizes {
    try savePNG(base, size: size, filename: filename)
}

print("Generated UpdatePilot app icon set in \(outputURL.path)")
