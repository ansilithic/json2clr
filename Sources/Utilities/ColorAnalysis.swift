import Foundation

struct RGBComponents {
    let r: Int, g: Int, b: Int
    var string: String { "\(r), \(g), \(b)" }
    var cssString: String { "rgb(\(r), \(g), \(b))" }
}

struct HSLComponents {
    let h: Int, s: Int, l: Int
    var string: String { "\(h)\u{00B0}, \(s)%, \(l)%" }
}

struct CMYKComponents {
    let c: Int, m: Int, y: Int, k: Int
    var string: String { "\(c)%, \(m)%, \(y)%, \(k)%" }
}

struct ColorInfo {
    let hex: String
    let rgb: RGBComponents
    let hsl: HSLComponents
    let cmyk: CMYKComponents
    let luminance: Double
    let contrastOnWhite: Double
    let contrastOnBlack: Double

    var wcagOnWhite: String { wcagRating(contrastOnWhite) }
    var wcagOnBlack: String { wcagRating(contrastOnBlack) }

    private func wcagRating(_ ratio: Double) -> String {
        if ratio >= 7 { return "AAA" }
        if ratio >= 4.5 { return "AA" }
        if ratio >= 3 { return "AA Large" }
        return "Fail"
    }
}

enum ColorAnalysis {
    static func analyze(_ hex: String) -> ColorInfo {
        let (r8, g8, b8) = HexColor.parse(hex)
        let r = Double(r8) / 255.0
        let g = Double(g8) / 255.0
        let b = Double(b8) / 255.0

        let rgb = RGBComponents(r: Int(r8), g: Int(g8), b: Int(b8))
        let hsl = rgbToHSL(r: r, g: g, b: b)
        let cmyk = rgbToCMYK(r: r, g: g, b: b)

        let lum = relativeLuminance(r: r, g: g, b: b)
        let onWhite = contrastRatio(lum, 1.0)
        let onBlack = contrastRatio(lum, 0.0)

        return ColorInfo(
            hex: hex,
            rgb: rgb,
            hsl: hsl,
            cmyk: cmyk,
            luminance: lum,
            contrastOnWhite: onWhite,
            contrastOnBlack: onBlack
        )
    }

    private static func rgbToHSL(r: Double, g: Double, b: Double) -> HSLComponents {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        let l = (maxC + minC) / 2

        guard delta > 0 else {
            return HSLComponents(h: 0, s: 0, l: Int((l * 100).rounded()))
        }

        let s = l < 0.5 ? delta / (maxC + minC) : delta / (2 - maxC - minC)

        var h: Double = 0
        if maxC == r {
            h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
        } else if maxC == g {
            h = (b - r) / delta + 2
        } else {
            h = (r - g) / delta + 4
        }
        h *= 60
        if h < 0 { h += 360 }

        return HSLComponents(
            h: Int(h.rounded()),
            s: Int((s * 100).rounded()),
            l: Int((l * 100).rounded())
        )
    }

    private static func rgbToCMYK(r: Double, g: Double, b: Double) -> CMYKComponents {
        let k = 1 - max(r, g, b)
        guard k < 1 else {
            return CMYKComponents(c: 0, m: 0, y: 0, k: 100)
        }

        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)

        return CMYKComponents(
            c: Int((c * 100).rounded()),
            m: Int((m * 100).rounded()),
            y: Int((y * 100).rounded()),
            k: Int((k * 100).rounded())
        )
    }

    private static func relativeLuminance(r: Double, g: Double, b: Double) -> Double {
        func linearize(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    private static func contrastRatio(_ l1: Double, _ l2: Double) -> Double {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
}
