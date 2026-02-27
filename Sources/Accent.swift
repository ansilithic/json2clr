import ArgumentParser
import CLICore
import Foundation

@main
struct JSON2CLR: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "json2clr",
        abstract: "Convert JSON color palettes to macOS color lists (.clr)"
    )

    @Argument(help: "Path to a JSON color palette file")
    var file: String

    @Flag(name: .long, help: "Export as macOS color list (.clr)")
    var clr = false

    @Flag(name: .long, help: "Install .clr to ~/Library/Colors")
    var install = false

    @Option(name: .shortAndLong, help: "Output file path for .clr export")
    var output: String?

    func run() throws {
        let palette = try ColorPalette.load(from: file)

        printPalette(palette)

        if clr {
            let url: URL
            if let output {
                url = URL(fileURLWithPath: output)
            } else {
                url = URL(fileURLWithPath: "\(palette.name).clr")
            }
            try CLRExporter.export(palette: palette, to: url)
            Output.success("Exported \(url.path)")
        }

        if install {
            let url = try CLRExporter.install(palette: palette)
            Output.success("Installed \(url.path)")
        }
    }

    private func printPalette(_ palette: ColorPalette) {
        let maxName = palette.colors.map(\.name.count).max() ?? 0

        print()
        print("  \(styled(palette.name, .bold))")

        for color in palette.colors {
            let (r, g, b) = color.rgb
            let swatch = ANSISwatch.block(color.hex)
            let name = color.name.padding(toLength: maxName, withPad: " ", startingAt: 0)
            let hex = color.hex.uppercased()
            let rgbStr = "rgb(\(r), \(g), \(b))"
            let info = ColorAnalysis.analyze(color.hex)

            print()
            print("  \(swatch)  \(styled(name, .bold))  \(styled(hex, .gray))  \(styled(rgbStr, .gray))")

            print("      \(styled("\u{251C}\u{2500}\u{2500}", .gray)) \(styled("HSL", .cyan))  \(info.hsl.string)")
            print("      \(styled("\u{2514}\u{2500}\u{2500}", .gray)) \(styled("CMYK", .cyan)) \(info.cmyk.string)")
        }

        print()
    }
}
