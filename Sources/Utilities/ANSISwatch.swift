import CLICore

enum ANSISwatch {
    static func bg(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> String {
        "\u{001B}[48;2;\(r);\(g);\(b)m"
    }

    static let bgReset = "\u{001B}[49m"

    static func block(_ hex: String, width: Int = 2) -> String {
        let (r, g, b) = HexColor.parse(hex)
        return "\(bg(r, g, b))\(String(repeating: " ", count: width))\(Color.reset.rawValue)"
    }
}
