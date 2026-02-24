struct NamedColor {
    var name: String
    var hex: String

    init(name: String, hex: String) {
        self.name = name
        self.hex = hex.hasPrefix("#") ? hex : "#\(hex)"
    }

    var rgb: (r: UInt8, g: UInt8, b: UInt8) {
        HexColor.parse(hex)
    }
}
