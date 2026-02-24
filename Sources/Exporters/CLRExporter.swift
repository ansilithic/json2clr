import AppKit

enum CLRExporter {
    static func export(palette: ColorPalette, to url: URL) throws {
        let colorList = NSColorList(name: palette.name)

        for namedColor in palette.colors {
            let (r, g, b) = HexColor.parse(namedColor.hex)
            let nsColor = NSColor(
                srgbRed: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: 1.0
            )
            colorList.setColor(nsColor, forKey: namedColor.name)
        }

        try colorList.write(to: url)
    }

    static func install(palette: ColorPalette) throws -> URL {
        let colorListsDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Colors")
        try FileManager.default.createDirectory(at: colorListsDir, withIntermediateDirectories: true)

        let url = colorListsDir.appendingPathComponent("\(palette.name).clr")
        try export(palette: palette, to: url)
        return url
    }
}
