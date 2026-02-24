import Foundation

enum HexColor {
    static func parse(_ hex: String) -> (r: UInt8, g: UInt8, b: UInt8) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)

        switch h.count {
        case 6:
            return (
                r: UInt8((rgb >> 16) & 0xFF),
                g: UInt8((rgb >> 8) & 0xFF),
                b: UInt8(rgb & 0xFF)
            )
        case 8:
            return (
                r: UInt8((rgb >> 24) & 0xFF),
                g: UInt8((rgb >> 16) & 0xFF),
                b: UInt8((rgb >> 8) & 0xFF)
            )
        default:
            return (r: 0, g: 0, b: 0)
        }
    }
}
