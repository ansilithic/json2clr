import Foundation

enum PaletteError: Error, CustomStringConvertible {
    case invalidFormat

    var description: String {
        "Expected a JSON object mapping color names to hex values, e.g. {\"Red\": \"#BF616A\"}"
    }
}

struct ColorPalette {
    var name: String
    var colors: [NamedColor]

    static func fromJSON(data: Data, name: String) throws -> ColorPalette {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: String] else {
            throw PaletteError.invalidFormat
        }
        let colors = dict.map { NamedColor(name: $0.key, hex: $0.value) }
            .sorted { $0.name < $1.name }
        return ColorPalette(name: name, colors: colors)
    }

    static func load(from path: String) throws -> ColorPalette {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let name = url.deletingPathExtension().lastPathComponent
        return try fromJSON(data: data, name: name)
    }
}
