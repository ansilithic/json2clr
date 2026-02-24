// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "json2clr",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/ansilithic/swift-cli-core.git", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "json2clr",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CLICore", package: "swift-cli-core"),
            ],
            path: "Sources"
        ),
    ]
)
